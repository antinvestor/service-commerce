// Copyright 2023-2026 Ant Investor Ltd
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package repository_test

import (
	"context"
	"errors"
	"sync/atomic"
	"testing"
	"time"

	"github.com/pitabwire/frame/v3"
	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/frametests/definition"
	"github.com/pitabwire/util"
	"gorm.io/gorm"

	"github.com/antinvestor/service-commerce/apps/default/service/models"
	"github.com/antinvestor/service-commerce/apps/default/service/repository"
)

// An order is read back, and an idempotency key replayed, from the primary:
// a replica that has not caught up must never make a just-placed order look
// missing.
func (rts *RepositoryTestSuite) TestOrderReadsAfterWriteUseThePrimary() {
	t := rts.T()

	rts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := rts.CreateServiceWithLaggingReplica(t, dep)
		shopRepo, productRepo, variantRepo, _, _, orderRepo, _, _, _ := rts.getRepos(ctx, svc)

		shop := rts.createTestShop(ctx, shopRepo)
		product := rts.createTestProduct(ctx, productRepo, shop.GetID())
		variant := rts.createTestVariant(ctx, variantRepo, product.GetID())
		order := rts.createUnpaidOrder(ctx, orderRepo, shop.GetID(), variant)

		_, err := orderRepo.GetByID(ctx, order.GetID())
		rts.Require().Truef(frame.ErrorIsNotFound(err), "the replica really is behind: %v", err)

		got, err := orderRepo.GetWithLines(ctx, order.GetID())
		rts.Require().NoError(err)
		rts.Require().Len(got.Lines, 1)

		replayed, err := orderRepo.GetByIdempotencyKey(ctx, order.IdempotencyKey)
		rts.Require().NoError(err)
		rts.Require().Equal(order.GetID(), replayed.GetID())
	})
}

func (rts *RepositoryTestSuite) newGuestOrder(
	ctx context.Context,
	orderRepo repository.OrderRepository,
	shopID string,
	variant *models.ProductVariant,
	quantity int64,
) (*models.Order, error) {
	const limit = 10
	due := time.Now().Add(time.Hour)
	order := &models.Order{
		ShopID: shopID, IdempotencyKey: "storefront:" + util.RandomAlphaNumericString(12),
		Status: 4, PaymentStatus: 1, Guest: true, PaymentDueAt: &due,
		SubtotalCurrency: "USD", SubtotalUnits: 10 * quantity, TotalCurrency: "USD", TotalUnits: 10 * quantity,
	}
	lines := []*models.OrderLine{{
		ProductVariantID: variant.GetID(), UnitPriceCurrency: "USD", UnitPriceUnits: 10, Quantity: quantity,
		TotalPriceCurrency: "USD", TotalPriceUnits: 10 * quantity,
	}}
	opts := repository.CreateOrderOptions{GuestUnitsCap: limit}
	return order, orderRepo.CreateWithLinesAndStock(ctx, order, lines, opts)
}

// A shop's unpaid guest orders hold at most the cap; paid, signed-in and
// lapsed orders do not count towards it, and a concurrent burst cannot
// slip past it.
func (rts *RepositoryTestSuite) TestGuestOrdersHoldAtMostTheCap() {
	t := rts.T()

	rts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := rts.CreateService(t, dep)
		shopRepo, productRepo, variantRepo, _, _, orderRepo, _, _, _ := rts.getRepos(ctx, svc)
		shop := rts.createTestShop(ctx, shopRepo)
		variant := rts.createTestVariant(
			ctx,
			variantRepo,
			rts.createTestProduct(ctx, productRepo, shop.GetID()).GetID(),
		)

		first, err := rts.newGuestOrder(ctx, orderRepo, shop.GetID(), variant, 6)
		rts.Require().NoError(err)
		_, err = rts.newGuestOrder(ctx, orderRepo, shop.GetID(), variant, 5)
		rts.Require().ErrorIs(err, repository.ErrGuestHoldLimit)
		_, err = rts.newGuestOrder(ctx, orderRepo, shop.GetID(), variant, 4)
		rts.Require().NoError(err, "up to the cap is fine")

		// A signed-in buyer's order is not held to it.
		rts.createUnpaidOrder(ctx, orderRepo, shop.GetID(), variant)

		// Money on a guest order, or a lapsed payment window, frees its units.
		db := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName).DB(ctx, false)
		rts.Require().NoError(db.Model(&models.Order{}).Where("id = ?", first.GetID()).
			UpdateColumn("amount_paid_nanos", 1).Error)
		_, err = rts.newGuestOrder(ctx, orderRepo, shop.GetID(), variant, 6)
		rts.Require().NoError(err)

		other := rts.createTestShop(ctx, shopRepo)
		otherVariant := rts.createTestVariant(ctx, variantRepo,
			rts.createTestProduct(ctx, productRepo, other.GetID()).GetID())
		var placed atomic.Int32
		done := make(chan error, racers)
		for range racers {
			go func() {
				_, raceErr := rts.newGuestOrder(ctx, orderRepo, other.GetID(), otherVariant, 3)
				if raceErr == nil {
					placed.Add(1)
				}
				if raceErr != nil && !errors.Is(raceErr, repository.ErrGuestHoldLimit) {
					done <- raceErr
					return
				}
				done <- nil
			}()
		}
		for range racers {
			rts.Require().NoError(<-done)
		}
		rts.Require().Equal(int32(3), placed.Load(), "3 x 3 units fit under 10, a fourth does not")
	})
}

// The checkout limit is counted in the database, so two instances (two
// repositories) share one count per key and window.
func (rts *RepositoryTestSuite) TestLimitsAreSharedAndExpire() {
	t := rts.T()

	rts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := rts.CreateService(t, dep)
		dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)
		one, two := repository.NewLimitRepository(dbPool), repository.NewLimitRepository(dbPool)

		window := time.Now().UTC().Truncate(time.Minute)
		counts, err := one.Hit(ctx, []string{"visitor:a", "shop:s", "visitor:a"}, window, window.Add(-time.Minute))
		rts.Require().NoError(err)
		rts.Require().Equal(map[string]int64{"visitor:a": 1, "shop:s": 1}, counts, "a key counts once per hit")

		counts, err = two.Hit(ctx, []string{"visitor:a", "shop:s"}, window, window.Add(-time.Minute))
		rts.Require().NoError(err)
		rts.Require().Equal(int64(2), counts["visitor:a"])

		next := window.Add(time.Minute)
		counts, err = one.Hit(ctx, []string{"visitor:a"}, next, next)
		rts.Require().NoError(err)
		rts.Require().Equal(int64(1), counts["visitor:a"], "a new window starts again")

		var left int64
		rts.Require().NoError(dbPool.DB(ctx, false).Raw(
			`SELECT count(*) FROM storefront_limits WHERE window_start < ?`, next).Scan(&left).Error)
		rts.Require().Zero(left, "finished windows are cleared as hits arrive")
	})
}

// A buyer's history narrowed to one shop is narrowed in the query, so a
// page is full and the cursor walks only that shop's orders.
func (rts *RepositoryTestSuite) TestListByProfileIDFiltersByShopBeforePaging() {
	t := rts.T()

	rts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := rts.CreateService(t, dep)
		shopRepo, productRepo, variantRepo, _, _, orderRepo, _, _, _ := rts.getRepos(ctx, svc)
		mine, other := rts.createTestShop(ctx, shopRepo), rts.createTestShop(ctx, shopRepo)
		mineVariant := rts.createTestVariant(
			ctx,
			variantRepo,
			rts.createTestProduct(ctx, productRepo, mine.GetID()).GetID(),
		)
		otherVariant := rts.createTestVariant(ctx, variantRepo,
			rts.createTestProduct(ctx, productRepo, other.GetID()).GetID())

		profile := "buyer-" + util.RandomAlphaNumericString(6)
		place := func(shopID string, variant *models.ProductVariant) {
			order := rts.createUnpaidOrder(ctx, orderRepo, shopID, variant)
			db := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName).DB(ctx, false)
			rts.Require().NoError(db.Model(&models.Order{}).Where("id = ?", order.GetID()).
				UpdateColumn("profile_id", profile).Error)
		}
		for range 3 {
			place(mine.GetID(), mineVariant)
			place(other.GetID(), otherVariant)
			place(other.GetID(), otherVariant)
		}

		page, next, err := orderRepo.ListByProfileID(ctx, profile, mine.GetID(), repository.OrderStatusFilter{},
			repository.Page{Limit: 2})
		rts.Require().NoError(err)
		rts.Require().Len(page, 2)
		rts.Require().NotNil(next)
		rest, _, err := orderRepo.ListByProfileID(ctx, profile, mine.GetID(), repository.OrderStatusFilter{},
			repository.Page{Limit: 2, After: next})
		rts.Require().NoError(err)
		rts.Require().Len(rest, 1)
		for _, o := range append(page, rest...) {
			rts.Require().Equal(mine.GetID(), o.ShopID)
		}
	})
}

// Variants for an order or a storefront page load in a fixed number of
// queries however many there are.
func (rts *RepositoryTestSuite) TestVariantBatchLoadsAreBounded() {
	t := rts.T()

	rts.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := rts.CreateService(t, dep)
		shopRepo, productRepo, variantRepo, _, _, _, _, _, _ := rts.getRepos(ctx, svc)
		shop := rts.createTestShop(ctx, shopRepo)

		var ids, productIDs []string
		for range 12 {
			product := rts.createTestProduct(ctx, productRepo, shop.GetID())
			productIDs = append(productIDs, product.GetID())
			ids = append(ids, rts.createTestVariant(ctx, variantRepo, product.GetID()).GetID())
		}

		db := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName).DB(ctx, false)
		var queries atomic.Int32
		const hook = "test:count_queries"
		rts.Require().NoError(db.Callback().Query().Before("gorm:query").Register(hook, func(*gorm.DB) {
			queries.Add(1)
		}))
		t.Cleanup(func() { _ = db.Callback().Query().Remove(hook) })

		variants, err := variantRepo.ListByIDs(ctx, ids)
		rts.Require().NoError(err)
		rts.Require().Len(variants, 12)
		for _, v := range variants {
			rts.Require().NotNil(v.Product)
			rts.Require().Equal(shop.GetID(), v.Product.ShopID)
		}
		rts.Require().LessOrEqual(queries.Load(), int32(2), "variants, then their products")

		queries.Store(0)
		byProduct, err := variantRepo.ListByProductIDs(ctx, productIDs)
		rts.Require().NoError(err)
		rts.Require().Len(byProduct, 12)
		rts.Require().Equal(int32(1), queries.Load())
	})
}
