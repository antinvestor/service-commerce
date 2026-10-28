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

package business

import (
	"context"
	"errors"
	"fmt"
	"math/big"
	"sort"
	"strings"

	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/util"
	"golang.org/x/text/currency"

	procurementv1 "github.com/antinvestor/service-commerce/gen/go/procurement/v1"

	"github.com/antinvestor/service-commerce/apps/procurement/service/models"
	"github.com/antinvestor/service-commerce/apps/procurement/service/repository"
)

// Shortage is one material a production plan needs more of than is on hand
// or already on order.
type Shortage struct {
	InventoryItemID string
	ItemName        string
	Quantity        float64
	Unit            string
}

// MaterialSource is where shortages come from: the manufacturing service's
// material requirements for a production plan.
type MaterialSource interface {
	// PlanShortages returns the plan's shortages after checking that the plan
	// belongs to propertyID.
	PlanShortages(ctx context.Context, propertyID, planID string) ([]Shortage, error)
}

// ErrPlanNotInProperty is returned when a plan belongs to another property.
var ErrPlanNotInProperty = errors.New("production plan does not belong to this property")

// SuggestionBusiness proposes purchase orders that cover a plan's shortages.
type SuggestionBusiness interface {
	// SuggestPurchaseOrders groups each shortage under the supplier offering
	// the cheapest active item for it (shorter lead time breaks ties), with
	// the quantity raised to the supplier's minimum order. Shortages no
	// active supplier carries come back in a suggestion with no supplier, so
	// the buyer can see what still needs sourcing.
	SuggestPurchaseOrders(
		ctx context.Context,
		req *procurementv1.SuggestPurchaseOrdersRequest,
	) ([]*procurementv1.PurchaseOrderSuggestion, error)
}

// NewSuggestionBusiness builds suggestions over source. A nil source means
// manufacturing is not configured and suggestions are unavailable.
func NewSuggestionBusiness(
	source MaterialSource,
	supplierItemRepo repository.SupplierItemRepository,
) SuggestionBusiness {
	return &suggestionBusiness{source: source, supplierItemRepo: supplierItemRepo}
}

type suggestionBusiness struct {
	source           MaterialSource
	supplierItemRepo repository.SupplierItemRepository
}

// maxShortages bounds one suggestion run.
const maxShortages = 500

func (sb *suggestionBusiness) SuggestPurchaseOrders(
	ctx context.Context,
	req *procurementv1.SuggestPurchaseOrdersRequest,
) ([]*procurementv1.PurchaseOrderSuggestion, error) {
	if req.GetPlanId() == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, "plan_id is required")
	}
	currencyCode := strings.ToUpper(strings.TrimSpace(req.GetCurrencyCode()))
	if currencyCode != "" {
		if _, err := currency.ParseISO(currencyCode); err != nil || len(currencyCode) != 3 {
			return nil, connect.NewError(connect.CodeInvalidArgument,
				fmt.Sprintf("currency_code %q is not an ISO 4217 code", req.GetCurrencyCode()))
		}
	}
	if sb.source == nil {
		return nil, connect.NewError(connect.CodeUnimplemented,
			"manufacturing is not configured, so plan shortages are unavailable")
	}
	shortages, err := sb.source.PlanShortages(ctx, req.GetPropertyId(), req.GetPlanId())
	if err != nil {
		if errors.Is(err, ErrPlanNotInProperty) {
			return nil, connect.NewError(connect.CodeNotFound, "production plan not found")
		}
		return nil, err
	}
	if len(shortages) > maxShortages {
		return nil, connect.NewError(connect.CodeResourceExhausted,
			fmt.Sprintf("the plan is short of %d materials; at most %d can be suggested at once",
				len(shortages), maxShortages))
	}

	candidates, err := sb.candidates(ctx, shortages)
	if err != nil {
		return nil, err
	}

	set := newSuggestionSet()
	for _, shortage := range shortages {
		quantity, qErr := models.QuantityFromFloat(shortage.Quantity)
		if qErr != nil || quantity <= 0 || shortage.InventoryItemID == "" {
			continue
		}
		item := bestSupplierItem(candidates[shortage.InventoryItemID], currencyCode)
		if item == nil {
			set.addUnsourced(shortage)
			continue
		}
		set.add(shortage, quantity, item)
	}
	if set.unsourced != nil {
		util.Log(ctx).WithField("plan_id", req.GetPlanId()).WithField("items", len(set.unsourced.GetLines())).
			Info("plan shortages with no active supplier")
	}
	return set.result()
}

// candidates loads, in one query, the active items of active suppliers for
// every shortage, by inventory item.
func (sb *suggestionBusiness) candidates(
	ctx context.Context,
	shortages []Shortage,
) (map[string][]*models.SupplierItem, error) {
	seen := make(map[string]bool, len(shortages))
	ids := make([]string, 0, len(shortages))
	for _, shortage := range shortages {
		if shortage.InventoryItemID != "" && !seen[shortage.InventoryItemID] {
			seen[shortage.InventoryItemID] = true
			ids = append(ids, shortage.InventoryItemID)
		}
	}
	items, err := sb.supplierItemRepo.ListActiveForInventoryItems(ctx, ids)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	byItem := make(map[string][]*models.SupplierItem, len(ids))
	for _, item := range items {
		byItem[item.InventoryItemID] = append(byItem[item.InventoryItemID], item)
	}
	return byItem, nil
}

// suggestionSet groups suggestion lines by supplier and currency.
type suggestionSet struct {
	bySupplier map[string]*procurementv1.PurchaseOrderSuggestion
	totals     map[string]*big.Int
	unsourced  *procurementv1.PurchaseOrderSuggestion
}

func newSuggestionSet() *suggestionSet {
	return &suggestionSet{
		bySupplier: map[string]*procurementv1.PurchaseOrderSuggestion{},
		totals:     map[string]*big.Int{},
	}
}

func (s *suggestionSet) addUnsourced(shortage Shortage) {
	if s.unsourced == nil {
		s.unsourced = &procurementv1.PurchaseOrderSuggestion{}
	}
	s.unsourced.Lines = append(s.unsourced.Lines, &procurementv1.PurchaseOrderSuggestionLine{
		InventoryItemId:  shortage.InventoryItemID,
		ItemName:         shortage.ItemName,
		ShortageQuantity: shortage.Quantity,
		Unit:             shortage.Unit,
	})
}

// add orders the shortage from item's supplier, raised to its minimum order.
func (s *suggestionSet) add(shortage Shortage, quantity models.Quantity, item *models.SupplierItem) {
	quantity = max(quantity, item.MinOrderQuantity)
	key := item.SupplierID + "|" + item.CurrencyCode
	suggestion, ok := s.bySupplier[key]
	if !ok {
		suggestion = &procurementv1.PurchaseOrderSuggestion{SupplierId: item.SupplierID}
		if item.Supplier != nil {
			suggestion.SupplierName = item.Supplier.Name
		}
		s.bySupplier[key] = suggestion
		s.totals[key] = new(big.Int)
	}
	unit := shortage.Unit
	if item.Unit != "" {
		unit = item.Unit
	}
	suggestion.Lines = append(suggestion.Lines, &procurementv1.PurchaseOrderSuggestionLine{
		InventoryItemId:  shortage.InventoryItemID,
		ItemName:         shortage.ItemName,
		ShortageQuantity: quantity.Float(),
		Unit:             unit,
		SupplierItemId:   item.GetID(),
		UnitPrice:        models.MoneyToProto(item.CurrencyCode, item.PriceUnits, item.PriceNanos),
	})
	s.totals[key].Add(s.totals[key], lineTotal(item.PriceUnits, item.PriceNanos, quantity))
}

// result lists suppliers in a stable order, then the unsourced remainder.
func (s *suggestionSet) result() ([]*procurementv1.PurchaseOrderSuggestion, error) {
	keys := make([]string, 0, len(s.bySupplier))
	for key := range s.bySupplier {
		keys = append(keys, key)
	}
	sort.Strings(keys)
	out := make([]*procurementv1.PurchaseOrderSuggestion, 0, len(keys)+1)
	for _, key := range keys {
		suggestion := s.bySupplier[key]
		units, nanos, err := moneyFromNanos(s.totals[key])
		if err != nil {
			return nil, err
		}
		currencyCode := suggestion.GetLines()[0].GetUnitPrice().GetCurrencyCode()
		suggestion.EstimatedTotal = models.MoneyToProto(currencyCode, units, nanos)
		out = append(out, suggestion)
	}
	if s.unsourced != nil {
		out = append(out, s.unsourced)
	}
	return out, nil
}

// bestSupplierItem picks the cheapest item, preferring the shorter lead time
// and then the smaller minimum order. Prices are compared only within one
// currency: currencyCode when given; otherwise the candidates must all share
// one, or the material is left unsourced for the buyer to choose.
func bestSupplierItem(items []*models.SupplierItem, currencyCode string) *models.SupplierItem {
	var best *models.SupplierItem
	for _, item := range items {
		if currencyCode != "" && item.CurrencyCode != currencyCode {
			continue
		}
		if best != nil && item.CurrencyCode != best.CurrencyCode {
			return nil
		}
		if best == nil || better(item, best) {
			best = item
		}
	}
	return best
}

func better(a, b *models.SupplierItem) bool {
	if a.PriceUnits != b.PriceUnits {
		return a.PriceUnits < b.PriceUnits
	}
	if a.PriceNanos != b.PriceNanos {
		return a.PriceNanos < b.PriceNanos
	}
	if a.LeadTimeDays != b.LeadTimeDays {
		return a.LeadTimeDays < b.LeadTimeDays
	}
	return a.MinOrderQuantity < b.MinOrderQuantity
}
