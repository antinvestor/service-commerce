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
	"strings"

	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3"
	"github.com/pitabwire/frame/v3/data"
	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/util"

	commercev1 "github.com/antinvestor/service-commerce/gen/go/commerce/v1"

	"github.com/antinvestor/service-commerce/apps/default/service/models"
	"github.com/antinvestor/service-commerce/apps/default/service/repository"
)

const maxStockReferenceLength = 255

// StockReceiptBusiness raises variant stock for goods received elsewhere
// (procurement), once per reference.
type StockReceiptBusiness interface {
	// ReceiveStock adds req.quantity to the variant's stock unless
	// req.reference was already received, in which case it changes nothing.
	// The variant must belong to req.tenant_id. ctx must be able to read the
	// variant's tenant (the handler reads across tenants for the internal
	// caller).
	ReceiveStock(ctx context.Context, req *commercev1.ReceiveStockRequest) (*commercev1.ReceiveStockResponse, error)
}

// NewStockReceiptBusiness builds stock receipts over the variant store.
func NewStockReceiptBusiness(
	variantRepo repository.ProductVariantRepository,
	receipts repository.StockReceiptRepository,
) StockReceiptBusiness {
	return &stockReceiptBusiness{variantRepo: variantRepo, receipts: receipts}
}

type stockReceiptBusiness struct {
	variantRepo repository.ProductVariantRepository
	receipts    repository.StockReceiptRepository
}

func (b *stockReceiptBusiness) ReceiveStock(
	ctx context.Context,
	req *commercev1.ReceiveStockRequest,
) (*commercev1.ReceiveStockResponse, error) {
	reference := strings.TrimSpace(req.GetReference())
	switch {
	case req.GetVariantId() == "":
		return nil, connect.NewError(connect.CodeInvalidArgument, "variant_id is required")
	case req.GetTenantId() == "":
		return nil, connect.NewError(connect.CodeInvalidArgument, "tenant_id is required")
	case req.GetQuantity() <= 0:
		return nil, connect.NewError(connect.CodeInvalidArgument, "quantity must be positive")
	case reference == "" || len(reference) > maxStockReferenceLength:
		return nil, connect.NewError(connect.CodeInvalidArgument, "reference is required (at most 255 characters)")
	}

	variant, err := b.variantRepo.GetByID(ctx, req.GetVariantId())
	if err != nil {
		if frame.ErrorIsNotFound(err) {
			return nil, connect.NewError(connect.CodeNotFound, "product variant not found")
		}
		return nil, data.ErrorConvertToAPI(err)
	}
	// Another tenant's variant is reported exactly as a missing one.
	if variant.TenantID != req.GetTenantId() {
		return nil, connect.NewError(connect.CodeNotFound, "product variant not found")
	}

	receipt := &models.StockReceipt{
		Quantity:  req.GetQuantity(),
		Reference: reference,
		ActorID:   actorOf(ctx),
	}
	stock, recorded, replayed, err := b.receipts.Receive(ctx, variant, receipt)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	if replayed && (recorded.VariantID != variant.GetID() || recorded.Quantity != req.GetQuantity()) {
		return nil, connect.NewError(connect.CodeAlreadyExists,
			"reference was already received for another variant or quantity")
	}
	util.Log(ctx).WithFields(map[string]any{
		"variant_id": variant.GetID(), "quantity": req.GetQuantity(), "reference": reference,
		"stock": stock, "replayed": replayed,
	}).Info("commerce.stock.received")
	return &commercev1.ReceiveStockResponse{StockQuantity: stock, Replayed: replayed}, nil
}

// actorOf is the authenticated subject, for the audit trail.
func actorOf(ctx context.Context) string {
	claims := security.ClaimsFromContext(ctx)
	if claims == nil {
		return ""
	}
	subject, _ := claims.GetSubject()
	return subject
}
