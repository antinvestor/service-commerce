package business

import (
	"context"
	"errors"
	"fmt"

	commercev1 "buf.build/gen/go/antinvestor/commerce/protocolbuffers/go/commerce/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/data"
	"google.golang.org/protobuf/types/known/timestamppb"

	"github.com/antinvestor/service-commerce/apps/default/service/models"
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
) FulfilmentBusiness {
	return &fulfilmentBusiness{
		fulfilmentRepo:     fulfilmentRepo,
		fulfilmentLineRepo: fulfilmentLineRepo,
		orderRepo:          orderRepo,
		orderLineRepo:      orderLineRepo,
	}
}

type fulfilmentBusiness struct {
	fulfilmentRepo     repository.FulfilmentRepository
	fulfilmentLineRepo repository.FulfilmentLineRepository
	orderRepo          repository.OrderRepository
	orderLineRepo      repository.OrderLineRepository
}

func (fb *fulfilmentBusiness) CreateFulfilment(ctx context.Context, req *commercev1.CreateFulfilmentRequest) (*commercev1.Fulfilment, error) {
	// Validate order exists and is in a fulfillable state
	order, err := fb.orderRepo.GetWithLines(ctx, req.GetOrderId())
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	if order.Status == int32(commercev1.OrderStatus_ORDER_STATUS_CANCELLED) {
		return nil, connect.NewError(connect.CodeFailedPrecondition, errors.New("cannot fulfil a cancelled order"))
	}

	if len(req.GetLines()) == 0 {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("fulfilment must have at least one line"))
	}

	// Build a map of order line IDs for validation
	orderLineMap := make(map[string]*models.OrderLine, len(order.Lines))
	for _, ol := range order.Lines {
		orderLineMap[ol.GetID()] = ol
	}

	// Validate fulfilment lines
	for _, fl := range req.GetLines() {
		ol, ok := orderLineMap[fl.GetOrderLineId()]
		if !ok {
			return nil, connect.NewError(connect.CodeInvalidArgument,
				fmt.Errorf("order line %s not found in order", fl.GetOrderLineId()))
		}

		// Check remaining unfulfilled quantity
		fulfilledQty, qErr := fb.fulfilmentLineRepo.GetFulfilledQuantityByOrderLineID(ctx, fl.GetOrderLineId())
		if qErr != nil {
			return nil, data.ErrorConvertToAPI(qErr)
		}

		remaining := ol.Quantity - fulfilledQty
		if fl.GetQuantity() > remaining {
			return nil, connect.NewError(connect.CodeFailedPrecondition,
				fmt.Errorf("quantity %d exceeds remaining unfulfilled quantity %d for order line %s",
					fl.GetQuantity(), remaining, fl.GetOrderLineId()))
		}
	}

	// Create fulfilment
	fulfilment := &models.Fulfilment{
		OrderID: req.GetOrderId(),
		Status:  int32(commercev1.FulfilmentStatus_FULFILMENT_STATUS_PENDING),
	}

	if createErr := fb.fulfilmentRepo.Create(ctx, fulfilment); createErr != nil {
		return nil, data.ErrorConvertToAPI(createErr)
	}

	// Create fulfilment lines
	for _, fl := range req.GetLines() {
		fulfilmentLine := &models.FulfilmentLine{
			FulfilmentID: fulfilment.GetID(),
			OrderLineID:  fl.GetOrderLineId(),
			Quantity:     fl.GetQuantity(),
		}
		if lineErr := fb.fulfilmentLineRepo.Create(ctx, fulfilmentLine); lineErr != nil {
			return nil, data.ErrorConvertToAPI(lineErr)
		}
	}

	// Check if order is fully fulfilled and update status
	fb.updateOrderFulfilmentStatus(ctx, order)

	return fb.GetFulfilment(ctx, fulfilment.GetID())
}

func (fb *fulfilmentBusiness) UpdateFulfilment(ctx context.Context, req *commercev1.UpdateFulfilmentRequest) (*commercev1.Fulfilment, error) {
	fulfilment, err := fb.fulfilmentRepo.GetWithLines(ctx, req.GetId())
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	fields := req.GetUpdateMask().GetPaths()
	if len(fields) == 0 {
		fields = []string{"status", "carrier", "tracking_number", "shipped_at"}
	}

	updateColumns := make([]string, 0, len(fields))
	for _, field := range fields {
		switch field {
		case "status":
			if req.GetStatus() != commercev1.FulfilmentStatus_FULFILMENT_STATUS_UNSPECIFIED {
				fulfilment.Status = int32(req.GetStatus())
				updateColumns = append(updateColumns, "status")
			}
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
			if req.GetShippedAt() != nil && req.GetShippedAt() != (&timestamppb.Timestamp{}) {
				// shipped_at is tracked via the status transition to SHIPPED
				updateColumns = append(updateColumns, "modified_at")
			}
		}
	}

	if len(updateColumns) > 0 {
		_, updateErr := fb.fulfilmentRepo.Update(ctx, fulfilment, updateColumns...)
		if updateErr != nil {
			return nil, data.ErrorConvertToAPI(updateErr)
		}
	}

	// If status changed, check if order fulfilment status needs updating
	order, orderErr := fb.orderRepo.GetWithLines(ctx, fulfilment.OrderID)
	if orderErr == nil {
		fb.updateOrderFulfilmentStatus(ctx, order)
	}

	return fb.GetFulfilment(ctx, req.GetId())
}

func (fb *fulfilmentBusiness) GetFulfilment(ctx context.Context, id string) (*commercev1.Fulfilment, error) {
	fulfilment, err := fb.fulfilmentRepo.GetWithLines(ctx, id)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	return fulfilment.ToAPI(), nil
}

func (fb *fulfilmentBusiness) updateOrderFulfilmentStatus(ctx context.Context, order *models.Order) {
	allFulfilled := true
	for _, ol := range order.Lines {
		fulfilledQty, err := fb.fulfilmentLineRepo.GetFulfilledQuantityByOrderLineID(ctx, ol.GetID())
		if err != nil || fulfilledQty < ol.Quantity {
			allFulfilled = false
			break
		}
	}

	if allFulfilled {
		order.Status = int32(commercev1.OrderStatus_ORDER_STATUS_FULFILLED)
		order.FulfilmentStatus = int32(commercev1.FulfilmentStatus_FULFILMENT_STATUS_DELIVERED)
		_, _ = fb.orderRepo.Update(ctx, order, "status", "fulfilment_status")
	}
}
