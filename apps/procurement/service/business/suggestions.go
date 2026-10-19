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
	"math"
	"sort"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	procurementv1 "buf.build/gen/go/antinvestor/procurement/protocolbuffers/go/v1"
	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/util"

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

const nanosPerUnit = 1_000_000_000

func (sb *suggestionBusiness) SuggestPurchaseOrders(
	ctx context.Context,
	req *procurementv1.SuggestPurchaseOrdersRequest,
) ([]*procurementv1.PurchaseOrderSuggestion, error) {
	if req.GetPlanId() == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, "plan_id is required")
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

	set := newSuggestionSet()
	for _, shortage := range shortages {
		if shortage.Quantity <= 0 || shortage.InventoryItemID == "" {
			continue
		}
		item, findErr := sb.bestSupplierItem(ctx, shortage.InventoryItemID)
		if findErr != nil {
			return nil, findErr
		}
		if item == nil {
			set.addUnsourced(shortage)
			continue
		}
		set.add(shortage, item)
	}
	if set.unsourced != nil {
		util.Log(ctx).WithField("plan_id", req.GetPlanId()).WithField("items", len(set.unsourced.GetLines())).
			Info("plan shortages with no active supplier")
	}
	return set.result(), nil
}

// suggestionSet groups suggestion lines by supplier and currency.
type suggestionSet struct {
	bySupplier map[string]*procurementv1.PurchaseOrderSuggestion
	totals     map[string]int64
	unsourced  *procurementv1.PurchaseOrderSuggestion
}

func newSuggestionSet() *suggestionSet {
	return &suggestionSet{
		bySupplier: map[string]*procurementv1.PurchaseOrderSuggestion{},
		totals:     map[string]int64{},
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
func (s *suggestionSet) add(shortage Shortage, item *models.SupplierItem) {
	quantity := math.Max(shortage.Quantity, item.MinOrderQuantity)
	key := item.SupplierID + "|" + item.CurrencyCode
	suggestion, ok := s.bySupplier[key]
	if !ok {
		suggestion = &procurementv1.PurchaseOrderSuggestion{SupplierId: item.SupplierID}
		if item.Supplier != nil {
			suggestion.SupplierName = item.Supplier.Name
		}
		s.bySupplier[key] = suggestion
	}
	unit := shortage.Unit
	if item.Unit != "" {
		unit = item.Unit
	}
	suggestion.Lines = append(suggestion.Lines, &procurementv1.PurchaseOrderSuggestionLine{
		InventoryItemId:  shortage.InventoryItemID,
		ItemName:         shortage.ItemName,
		ShortageQuantity: quantity,
		Unit:             unit,
		SupplierItemId:   item.GetID(),
		UnitPrice:        moneyOf(item.CurrencyCode, item.PriceUnits*nanosPerUnit+int64(item.PriceNanos)),
	})
	s.totals[key] += lineTotalNanos(item, quantity)
}

// result lists suppliers in a stable order, then the unsourced remainder.
func (s *suggestionSet) result() []*procurementv1.PurchaseOrderSuggestion {
	keys := make([]string, 0, len(s.bySupplier))
	for key := range s.bySupplier {
		keys = append(keys, key)
	}
	sort.Strings(keys)
	out := make([]*procurementv1.PurchaseOrderSuggestion, 0, len(keys)+1)
	for _, key := range keys {
		suggestion := s.bySupplier[key]
		currency := suggestion.GetLines()[0].GetUnitPrice().GetCurrencyCode()
		suggestion.EstimatedTotal = moneyOf(currency, s.totals[key])
		out = append(out, suggestion)
	}
	if s.unsourced != nil {
		out = append(out, s.unsourced)
	}
	return out
}

// bestSupplierItem picks the cheapest active item from an active supplier,
// preferring the shorter lead time and then the smaller minimum order.
func (sb *suggestionBusiness) bestSupplierItem(
	ctx context.Context,
	inventoryItemID string,
) (*models.SupplierItem, error) {
	items, err := sb.supplierItemRepo.ListByInventoryItemID(ctx, inventoryItemID)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	var best *models.SupplierItem
	for _, item := range items {
		if item.Status != int32(procurementv1.SupplierItemStatus_SUPPLIER_ITEM_STATUS_ACTIVE) {
			continue
		}
		if item.Supplier != nil && item.Supplier.Status != int32(procurementv1.SupplierStatus_SUPPLIER_STATUS_ACTIVE) {
			continue
		}
		if best == nil || better(item, best) {
			best = item
		}
	}
	return best, nil
}

func better(a, b *models.SupplierItem) bool {
	pa := a.PriceUnits*nanosPerUnit + int64(a.PriceNanos)
	pb := b.PriceUnits*nanosPerUnit + int64(b.PriceNanos)
	if pa != pb {
		return pa < pb
	}
	if a.LeadTimeDays != b.LeadTimeDays {
		return a.LeadTimeDays < b.LeadTimeDays
	}
	return a.MinOrderQuantity < b.MinOrderQuantity
}

// lineTotalNanos is quantity times the item's price, rounded to the nano the
// same way purchase order lines are.
func lineTotalNanos(item *models.SupplierItem, quantity float64) int64 {
	price := float64(item.PriceUnits*nanosPerUnit + int64(item.PriceNanos))
	return int64(math.Round(price * quantity))
}

func moneyOf(currency string, nanos int64) *commonv1.Money {
	if currency == "" {
		return nil
	}
	return &commonv1.Money{
		CurrencyCode: currency,
		Units:        nanos / nanosPerUnit,
		Nanos:        int32(nanos % nanosPerUnit),
	}
}
