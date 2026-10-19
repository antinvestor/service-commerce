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
	"fmt"
	"sync"
	"testing"
	"time"

	"github.com/pitabwire/frame/v3/frametests/definition"
	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/util"
	"github.com/stretchr/testify/require"

	"github.com/antinvestor/service-commerce/apps/default/service/models"
	"github.com/antinvestor/service-commerce/apps/default/service/repository"
)

const racers = 8

// createUnpaidOrder places a 10.00 order with one unit of variant.
func (rts *RepositoryTestSuite) createUnpaidOrder(
	ctx context.Context,
	orderRepo repository.OrderRepository,
	shopID string,
	variant *models.ProductVariant,
) *models.Order {
	order, err := newUnpaidOrder(ctx, orderRepo, shopID, variant)
	rts.Require().NoError(err)
	return order
}

// newUnpaidOrder is createUnpaidOrder without assertions, for goroutines.
func newUnpaidOrder(
	ctx context.Context,
	orderRepo repository.OrderRepository,
	shopID string,
	variant *models.ProductVariant,
) (*models.Order, error) {
	order := &models.Order{
		ShopID:           shopID,
		IdempotencyKey:   "idem-" + util.RandomAlphaNumericString(12),
		Status:           4, // pending payment
		PaymentStatus:    1,
		SubtotalCurrency: "USD",
		SubtotalUnits:    10,
		TotalCurrency:    "USD",
		TotalUnits:       10,
	}
	lines := []*models.OrderLine{{
		ProductVariantID: variant.GetID(), SKUSnapshot: variant.SKU, NameSnapshot: variant.Name,
		UnitPriceCurrency: "USD", UnitPriceUnits: 10, Quantity: 1,
		TotalPriceCurrency: "USD", TotalPriceUnits: 10,
	}}
	return order, orderRepo.CreateWithLinesAndStock(ctx, order, lines, "", 0)
}

// addPaid is a transition that only records the money.
func addPaid(order *models.Order, _ *models.OrderPayment) []*models.OrderEvent {
	return []*models.OrderEvent{{ShopID: order.ShopID, OrderID: order.GetID(), Type: 1}}
}

func (rts *RepositoryTestSuite) TestApplyPayment_ConcurrentDistinctPaymentsAllCount() {
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
		order := rts.createUnpaidOrder(ctx, orderRepo, shop.GetID(), variant)

		var wg sync.WaitGroup
		errs := make(chan error, racers)
		for i := range racers {
			wg.Add(1)
			go func() {
				defer wg.Done()
				_, _, _, err := orderRepo.ApplyPayment(ctx, order.GetID(), &models.OrderPayment{
					Currency:    "USD",
					AmountNanos: 1_000_000_000,
					Reference:   fmt.Sprintf("ref-%d", i),
					PaidAt:      time.Now(),
				}, addPaid)
				errs <- err
			}()
		}
		wg.Wait()
		close(errs)
		for err := range errs {
			require.NoError(t, err)
		}

		loaded, err := orderRepo.GetWithLines(ctx, order.GetID())
		require.NoError(t, err)
		require.Len(t, loaded.Payments, racers)
		require.Equal(t, int64(racers)*1_000_000_000, loaded.AmountPaidNanos,
			"no instalment is lost to a concurrent writer")
	})
}

func (rts *RepositoryTestSuite) TestApplyPayment_ConcurrentSameReferenceAppliesOnce() {
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
		order := rts.createUnpaidOrder(ctx, orderRepo, shop.GetID(), variant)

		type outcome struct {
			applied bool
			err     error
		}
		var wg sync.WaitGroup
		results := make(chan outcome, racers)
		for range racers {
			wg.Add(1)
			go func() {
				defer wg.Done()
				_, _, ok, err := orderRepo.ApplyPayment(ctx, order.GetID(), &models.OrderPayment{
					Currency: "USD", AmountNanos: 3_000_000_000, Reference: "cs_same", PaidAt: time.Now(),
				}, addPaid)
				results <- outcome{applied: ok, err: err}
			}()
		}
		wg.Wait()
		close(results)
		applied := 0
		for r := range results {
			require.NoError(t, r.err)
			if r.applied {
				applied++
			}
		}

		require.Equal(t, 1, applied)
		loaded, err := orderRepo.GetWithLines(ctx, order.GetID())
		require.NoError(t, err)
		require.Len(t, loaded.Payments, 1)
		require.Equal(t, int64(3_000_000_000), loaded.AmountPaidNanos)
	})
}

func (rts *RepositoryTestSuite) TestApplyPayment_SeesConcurrentCancellation() {
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
		order := rts.createUnpaidOrder(ctx, orderRepo, shop.GetID(), variant)

		// The transition cancels the order under the payment's feet on its
		// first run; the version check must make the payment re-read and
		// see the cancellation rather than overwrite it.
		attempts := 0
		transition := func(o *models.Order, p *models.OrderPayment) []*models.OrderEvent {
			attempts++
			if attempts == 1 {
				ok, err := orderRepo.CancelAndRestock(ctx, o.GetID(), []int32{4}, 0, "raced", time.Now(), nil)
				require.NoError(t, err)
				require.True(t, ok)
			}
			if o.Status != 2 {
				o.Status = 1
			}
			return addPaid(o, p)
		}
		_, _, applied, err := orderRepo.ApplyPayment(ctx, order.GetID(), &models.OrderPayment{
			Currency: "USD", AmountNanos: 10_000_000_000, Reference: "cs_race", PaidAt: time.Now(),
		}, transition)
		require.NoError(t, err)
		require.True(t, applied)
		require.Equal(t, 2, attempts)

		loaded, err := orderRepo.GetWithLines(ctx, order.GetID())
		require.NoError(t, err)
		require.Equal(t, int32(2), loaded.Status, "the cancellation survives")
	})
}

func (rts *RepositoryTestSuite) TestCreateOrder_ConcurrentFirstOrdersGetDistinctNumbers() {
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

		type outcome struct {
			number string
			err    error
		}
		var wg sync.WaitGroup
		results := make(chan outcome, racers)
		for range racers {
			wg.Add(1)
			go func() {
				defer wg.Done()
				order, err := newUnpaidOrder(ctx, orderRepo, shop.GetID(), variant)
				results <- outcome{number: order.OrderNumber, err: err}
			}()
		}
		wg.Wait()
		close(results)
		numbers := make([]string, 0, racers)
		for r := range results {
			require.NoError(t, r.err)
			numbers = append(numbers, r.number)
		}

		seen := map[string]bool{}
		for _, n := range numbers {
			require.False(t, seen[n], "duplicate order number %s", n)
			seen[n] = true
		}
		for i := 1; i <= racers; i++ {
			require.True(t, seen[fmt.Sprintf("ORD-%06d", i)], "numbers are gap-free")
		}
	})
}

func (rts *RepositoryTestSuite) TestApplyPayment_InheritsTheOrdersTenancy() {
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

		order := rts.createUnpaidOrder(ctx, orderRepo, shop.GetID(), variant)
		order.TenantID, order.PartitionID = "tenant-shop", "partition-shop"
		_, err := orderRepo.Update(ctx, order, "tenant_id", "partition_id")
		if err != nil {
			// tenant_id is immutable through the base repository; set it directly.
			require.NoError(t, svc.DatastoreManager().GetPool(ctx, "").DB(ctx, false).
				Model(&models.Order{}).Where("id = ?", order.GetID()).
				UpdateColumns(map[string]any{"tenant_id": "tenant-shop", "partition_id": "partition-shop"}).Error)
		}

		// Applied by a caller from another tenant (here, the reconciler's service
		// account), the payment and its events still belong to the shop.
		other := &security.AuthenticationClaims{TenantID: "tenant-svc", PartitionID: "partition-svc"}
		other.Subject = "svc"
		applied, events, ok, err := orderRepo.ApplyPayment(other.ClaimsToContext(ctx), order.GetID(),
			&models.OrderPayment{Currency: "USD", AmountNanos: 10_000_000_000, Reference: "cs_t", PaidAt: time.Now()},
			func(o *models.Order, _ *models.OrderPayment) []*models.OrderEvent {
				e := &models.OrderEvent{ShopID: o.ShopID, OrderID: o.GetID(), Type: 1}
				e.CopyPartitionInfo(&o.BaseModel)
				return []*models.OrderEvent{e}
			})
		require.NoError(t, err)
		require.True(t, ok)
		require.Len(t, events, 1)
		require.Equal(t, "tenant-shop", events[0].TenantID)

		loaded, err := orderRepo.GetWithLines(ctx, applied.GetID())
		require.NoError(t, err)
		require.Len(t, loaded.Payments, 1)
		require.Equal(t, "tenant-shop", loaded.Payments[0].TenantID)
		require.Equal(t, "partition-shop", loaded.Payments[0].PartitionID)
	})
}
