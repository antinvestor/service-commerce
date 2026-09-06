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
	"time"

	"connectrpc.com/connect"
	"github.com/pitabwire/frame/v2/data"
	"github.com/pitabwire/util"

	commercev1 "github.com/antinvestor/service-commerce/gen/go/commerce/v1"

	"github.com/antinvestor/service-commerce/apps/default/service/models"
	"github.com/antinvestor/service-commerce/apps/default/service/notifications"
	"github.com/antinvestor/service-commerce/apps/default/service/repository"
)

type FulfilmentBusiness interface {
	CreateFulfilment(ctx context.Context, req *commercev1.CreateFulfilmentRequest) (*commercev1.Fulfilment, error)
	UpdateFulfilment(ctx context.Context, req *commercev1.UpdateFulfilmentRequest) (*commercev1.Fulfilment, error)
	GetFulfilment(ctx context.Context, id string) (*commercev1.Fulfilment, error)
}

func NewFulfilmentBusiness(
	_ context.Context,
	fulfilmentRepo repository.FulfilmentRepository,
	fulfilmentLineRepo repository.FulfilmentLineRepository,
	orderRepo repository.OrderRepository,
	orderLineRepo repository.OrderLineRepository,
	shopRepo repository.ShopRepository,
	notifier notifications.Notifier,
) FulfilmentBusiness {
	if notifier == nil {
		notifier = notifications.New(nil)
	}
	return &fulfilmentBusiness{
		fulfilmentRepo:     fulfilmentRepo,
		fulfilmentLineRepo: fulfilmentLineRepo,
		orderRepo:          orderRepo,
		orderLineRepo:      orderLineRepo,
		shopRepo:           shopRepo,
		notifier:           notifier,
	}
}

type fulfilmentBusiness struct {
	fulfilmentRepo     repository.FulfilmentRepository
	fulfilmentLineRepo repository.FulfilmentLineRepository
	orderRepo          repository.OrderRepository
	orderLineRepo      repository.OrderLineRepository
	shopRepo           repository.ShopRepository
	notifier           notifications.Notifier
}

func (fb *fulfilmentBusiness) CreateFulfilment(
	ctx context.Context,
	req *commercev1.CreateFulfilmentRequest,
) (*commercev1.Fulfilment, error) {
	order, err := fb.orderRepo.GetWithLines(ctx, req.GetOrderId())
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	if order.Status == int32(commercev1.OrderStatus_ORDER_STATUS_CANCELLED) {
		return nil, connect.NewError(connect.CodeFailedPrecondition, errors.New("cannot fulfil a cancelled order"))
	}
	if order.Status == int32(commercev1.OrderStatus_ORDER_STATUS_PENDING_PAYMENT) {
		return nil, connect.NewError(connect.CodeFailedPrecondition, errors.New("order has not been paid"))
	}

	if len(req.GetLines()) == 0 {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("fulfilment must have at least one line"))
	}

	if validErr := fb.validateFulfilmentLines(ctx, order, req.GetLines()); validErr != nil {
		return nil, validErr
	}

	fulfilment := &models.Fulfilment{
		OrderID: req.GetOrderId(),
		Status:  int32(commercev1.FulfilmentStatus_FULFILMENT_STATUS_PENDING),
	}
	lines := make([]*models.FulfilmentLine, 0, len(req.GetLines()))
	for _, fl := range req.GetLines() {
		lines = append(lines, &models.FulfilmentLine{
			OrderLineID: fl.GetOrderLineId(),
			Quantity:    fl.GetQuantity(),
		})
	}

	if createErr := fb.fulfilmentRepo.CreateWithLines(ctx, fulfilment, lines); createErr != nil {
		return nil, data.ErrorConvertToAPI(createErr)
	}

	fb.syncOrderFulfilmentStatus(ctx, order)

	return fb.GetFulfilment(ctx, fulfilment.GetID())
}

func (fb *fulfilmentBusiness) validateFulfilmentLines(
	ctx context.Context,
	order *models.Order,
	lines []*commercev1.FulfilmentLine,
) error {
	orderLineMap := make(map[string]*models.OrderLine, len(order.Lines))
	for _, ol := range order.Lines {
		orderLineMap[ol.GetID()] = ol
	}

	fulfilled, err := fb.fulfilmentLineRepo.SumFulfilledByOrderID(ctx, order.GetID())
	if err != nil {
		return data.ErrorConvertToAPI(err)
	}

	// Aggregate the request first so the same order line listed twice cannot
	// slip past the remaining-quantity check.
	requested := make(map[string]int64, len(lines))
	for _, fl := range lines {
		if fl.GetQuantity() <= 0 {
			return connect.NewError(connect.CodeInvalidArgument,
				fmt.Errorf("quantity must be positive for order line %s", fl.GetOrderLineId()))
		}
		if _, ok := orderLineMap[fl.GetOrderLineId()]; !ok {
			return connect.NewError(connect.CodeInvalidArgument,
				fmt.Errorf("order line %s not found in order", fl.GetOrderLineId()))
		}
		requested[fl.GetOrderLineId()] += fl.GetQuantity()
	}

	for orderLineID, qty := range requested {
		remaining := orderLineMap[orderLineID].Quantity - fulfilled[orderLineID]
		if qty > remaining {
			return connect.NewError(connect.CodeFailedPrecondition,
				fmt.Errorf("quantity %d exceeds remaining unfulfilled quantity %d for order line %s",
					qty, remaining, orderLineID))
		}
	}

	return nil
}

func (fb *fulfilmentBusiness) UpdateFulfilment(
	ctx context.Context,
	req *commercev1.UpdateFulfilmentRequest,
) (*commercev1.Fulfilment, error) {
	fulfilment, err := fb.fulfilmentRepo.GetWithLines(ctx, req.GetId())
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	previousStatus := fulfilment.Status
	updateColumns, applyErr := applyFulfilmentFields(fulfilment, req)
	if applyErr != nil {
		return nil, applyErr
	}

	if len(updateColumns) > 0 {
		if _, updateErr := fb.fulfilmentRepo.Update(ctx, fulfilment, updateColumns...); updateErr != nil {
			return nil, data.ErrorConvertToAPI(updateErr)
		}
	}

	order, orderErr := fb.orderRepo.GetWithLines(ctx, fulfilment.OrderID)
	if orderErr == nil {
		fb.syncOrderFulfilmentStatus(ctx, order)
		fb.notifyStatus(ctx, order, fulfilment, previousStatus)
	}

	return fb.GetFulfilment(ctx, req.GetId())
}

// notifyStatus tells the buyer when their parcel ships and when the whole
// order has been delivered.
func (fb *fulfilmentBusiness) notifyStatus(
	ctx context.Context,
	order *models.Order,
	fulfilment *models.Fulfilment,
	previousStatus int32,
) {
	if fulfilment.Status == previousStatus {
		return
	}
	shop, err := fb.shopRepo.GetByID(ctx, order.ShopID)
	if err != nil {
		return
	}
	shipped := int32(commercev1.FulfilmentStatus_FULFILMENT_STATUS_SHIPPED)
	if fulfilmentStatusRank(fulfilment.Status) >= fulfilmentStatusRank(shipped) &&
		fulfilmentStatusRank(previousStatus) < fulfilmentStatusRank(shipped) {
		fb.notifier.OrderShipped(ctx, shop, order, fulfilment)
	}
	if order.Status == int32(commercev1.OrderStatus_ORDER_STATUS_FULFILLED) {
		fb.notifier.OrderDelivered(ctx, shop, order)
	}
}

// fulfilmentStatusRank orders statuses along the delivery path. Cancelled is
// terminal and outside the path.
func fulfilmentStatusRank(s int32) int {
	switch commercev1.FulfilmentStatus(s) {
	case commercev1.FulfilmentStatus_FULFILMENT_STATUS_PENDING:
		return 1
	case commercev1.FulfilmentStatus_FULFILMENT_STATUS_PREPARING:
		return 2 //nolint:mnd // rank
	case commercev1.FulfilmentStatus_FULFILMENT_STATUS_PACKED:
		return 3 //nolint:mnd // rank
	case commercev1.FulfilmentStatus_FULFILMENT_STATUS_SHIPPED:
		return 4 //nolint:mnd // rank
	case commercev1.FulfilmentStatus_FULFILMENT_STATUS_DELIVERED:
		return 5 //nolint:mnd // rank
	case commercev1.FulfilmentStatus_FULFILMENT_STATUS_CANCELLED,
		commercev1.FulfilmentStatus_FULFILMENT_STATUS_UNSPECIFIED:
		return 0
	default:
		return 0
	}
}

func applyFulfilmentFields(
	fulfilment *models.Fulfilment,
	req *commercev1.UpdateFulfilmentRequest,
) ([]string, error) {
	fields := req.GetUpdateMask().GetPaths()
	if len(fields) == 0 {
		fields = []string{fieldStatus, "carrier", "tracking_number", "shipped_at"}
	}

	updateColumns := make([]string, 0, len(fields)+1)
	for _, field := range fields {
		switch field {
		case fieldStatus:
			columns, err := applyFulfilmentStatus(fulfilment, req.GetStatus())
			if err != nil {
				return nil, err
			}
			updateColumns = append(updateColumns, columns...)
		case "carrier":
			if req.GetCarrier() != "" {
				fulfilment.Carrier = req.GetCarrier()
				updateColumns = append(updateColumns, "carrier")
			}
		case "tracking_number":
			if req.GetTrackingNumber() != "" {
				fulfilment.TrackingNumber = req.GetTrackingNumber()
				updateColumns = append(updateColumns, "tracking_number")
			}
		case "shipped_at":
			if req.GetShippedAt() != nil && req.GetShippedAt().IsValid() {
				t := req.GetShippedAt().AsTime()
				fulfilment.ShippedAt = &t
				updateColumns = append(updateColumns, "shipped_at")
			}
		}
	}

	return updateColumns, nil
}

// applyFulfilmentStatus enforces the forward-only delivery path. Cancelled and
// delivered are terminal; any other status may move to cancelled or forward.
// Reaching shipped (or beyond) stamps shipped_at if it is not already set.
func applyFulfilmentStatus(
	fulfilment *models.Fulfilment,
	newStatus commercev1.FulfilmentStatus,
) ([]string, error) {
	if newStatus == commercev1.FulfilmentStatus_FULFILMENT_STATUS_UNSPECIFIED ||
		int32(newStatus) == fulfilment.Status {
		return nil, nil
	}

	current := commercev1.FulfilmentStatus(fulfilment.Status)
	if current == commercev1.FulfilmentStatus_FULFILMENT_STATUS_CANCELLED ||
		current == commercev1.FulfilmentStatus_FULFILMENT_STATUS_DELIVERED {
		return nil, connect.NewError(connect.CodeFailedPrecondition,
			errors.New("fulfilment is in a terminal state"))
	}
	if newStatus != commercev1.FulfilmentStatus_FULFILMENT_STATUS_CANCELLED &&
		fulfilmentStatusRank(int32(newStatus)) < fulfilmentStatusRank(fulfilment.Status) {
		return nil, connect.NewError(connect.CodeFailedPrecondition,
			fmt.Errorf("fulfilment cannot move backwards from %s to %s", current, newStatus))
	}

	fulfilment.Status = int32(newStatus)
	columns := []string{fieldStatus}
	shippedRank := fulfilmentStatusRank(int32(commercev1.FulfilmentStatus_FULFILMENT_STATUS_SHIPPED))
	if fulfilmentStatusRank(int32(newStatus)) >= shippedRank && fulfilment.ShippedAt == nil {
		now := time.Now()
		fulfilment.ShippedAt = &now
		columns = append(columns, "shipped_at")
	}
	return columns, nil
}

func (fb *fulfilmentBusiness) GetFulfilment(ctx context.Context, id string) (*commercev1.Fulfilment, error) {
	fulfilment, err := fb.fulfilmentRepo.GetWithLines(ctx, id)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	return fulfilment.ToAPI(), nil
}

// syncOrderFulfilmentStatus derives the order's fulfilment status from its
// fulfilments. The order becomes FULFILLED only when every line is covered by
// delivered fulfilments; otherwise it reports the least-advanced live
// fulfilment so a buyer-facing status never runs ahead of reality.
func (fb *fulfilmentBusiness) syncOrderFulfilmentStatus(ctx context.Context, order *models.Order) {
	log := util.Log(ctx).WithField("order_id", order.GetID())

	fulfilments, err := fb.fulfilmentRepo.ListByOrderID(ctx, order.GetID())
	if err != nil {
		log.WithError(err).Warn("could not list fulfilments to sync order status")
		return
	}

	deliveredByLine := make(map[string]int64)
	lowestRank := 0
	lowestStatus := int32(commercev1.FulfilmentStatus_FULFILMENT_STATUS_UNSPECIFIED)
	for _, f := range fulfilments {
		if f.Status == int32(commercev1.FulfilmentStatus_FULFILMENT_STATUS_CANCELLED) {
			continue
		}
		if rank := fulfilmentStatusRank(f.Status); lowestRank == 0 || rank < lowestRank {
			lowestRank = rank
			lowestStatus = f.Status
		}
		if f.Status == int32(commercev1.FulfilmentStatus_FULFILMENT_STATUS_DELIVERED) {
			for _, l := range f.Lines {
				deliveredByLine[l.OrderLineID] += l.Quantity
			}
		}
	}

	if lowestRank == 0 {
		// No live fulfilments.
		fb.setOrderFulfilment(ctx, order, order.Status,
			int32(commercev1.FulfilmentStatus_FULFILMENT_STATUS_UNSPECIFIED))
		return
	}

	allDelivered := true
	for _, ol := range order.Lines {
		if deliveredByLine[ol.GetID()] < ol.Quantity {
			allDelivered = false
			break
		}
	}

	if allDelivered {
		fb.setOrderFulfilment(ctx, order,
			int32(commercev1.OrderStatus_ORDER_STATUS_FULFILLED),
			int32(commercev1.FulfilmentStatus_FULFILMENT_STATUS_DELIVERED))
		return
	}

	fb.setOrderFulfilment(ctx, order, order.Status, lowestStatus)
}

func (fb *fulfilmentBusiness) setOrderFulfilment(
	ctx context.Context,
	order *models.Order,
	orderStatus, fulfilmentStatus int32,
) {
	if order.Status == orderStatus && order.FulfilmentStatus == fulfilmentStatus {
		return
	}
	ok, err := fb.orderRepo.UpdateStatus(ctx, order.GetID(), order.Status, orderStatus, fulfilmentStatus)
	if err != nil {
		util.Log(ctx).WithError(err).WithField("order_id", order.GetID()).
			Warn("could not update order fulfilment status")
		return
	}
	if !ok {
		util.Log(ctx).WithField("order_id", order.GetID()).
			Debug("order status changed concurrently; fulfilment status sync skipped")
	}
}
