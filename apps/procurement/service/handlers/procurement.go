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

package handlers

import (
	"context"

	"buf.build/gen/go/antinvestor/procurement/connectrpc/go/v2/v1/procurementv1connect"
	procurementv1 "buf.build/gen/go/antinvestor/procurement/protocolbuffers/go/v1"
	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3"
	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/security/authorizer"

	"github.com/antinvestor/service-commerce/apps/procurement/service/authz"
	"github.com/antinvestor/service-commerce/apps/procurement/service/business"
	"github.com/antinvestor/service-commerce/apps/procurement/service/repository"
	"github.com/antinvestor/service-commerce/pkg/errorutil"
)

type ProcurementServer struct {
	authz                 authz.Middleware
	supplierBusiness      business.SupplierBusiness
	purchaseOrderBusiness business.PurchaseOrderBusiness
	goodsReceiptBusiness  business.GoodsReceiptBusiness
	suggestionBusiness    business.SuggestionBusiness
}

// The server implements every RPC itself: a method the published stub adds
// or renames fails the build instead of answering Unimplemented.
var _ procurementv1connect.ProcurementServiceHandler = (*ProcurementServer)(nil)

func NewProcurementServer(
	ctx context.Context,
	svc *frame.Service,
	authzMiddleware authz.Middleware,
	materials business.MaterialSource,
) *ProcurementServer {
	workMan := svc.WorkManager()
	dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)

	supplierRepo := repository.NewSupplierRepository(ctx, dbPool, workMan)
	supplierItemRepo := repository.NewSupplierItemRepository(ctx, dbPool, workMan)
	poRepo := repository.NewPurchaseOrderRepository(ctx, dbPool, workMan)
	polRepo := repository.NewPurchaseOrderLineRepository(ctx, dbPool, workMan)
	grRepo := repository.NewGoodsReceiptRepository(ctx, dbPool, workMan)
	grlRepo := repository.NewGoodsReceiptLineRepository(ctx, dbPool, workMan)

	return &ProcurementServer{
		authz:                 authzMiddleware,
		supplierBusiness:      business.NewSupplierBusiness(ctx, supplierRepo, supplierItemRepo),
		purchaseOrderBusiness: business.NewPurchaseOrderBusiness(ctx, poRepo, polRepo, supplierItemRepo),
		goodsReceiptBusiness:  business.NewGoodsReceiptBusiness(ctx, grRepo, grlRepo, poRepo, polRepo),
		suggestionBusiness:    business.NewSuggestionBusiness(materials, supplierItemRepo),
	}
}

// ----------------------
// Suppliers
// ----------------------
//
// Suppliers are tenant-scoped vendor records, not per-property resources, so
// they are governed by connection-level RLS tenancy and the functional access
// plane rather than a per-property Keto check (none exists for suppliers).

func (ps *ProcurementServer) SupplierSave(
	ctx context.Context,
	req *procurementv1.SupplierSaveRequest,
) (*procurementv1.SupplierSaveResponse, error) {
	supplier, err := ps.supplierBusiness.SaveSupplier(ctx, req)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &procurementv1.SupplierSaveResponse{Supplier: supplier}, nil
}

func (ps *ProcurementServer) SupplierGet(
	ctx context.Context,
	req *procurementv1.SupplierGetRequest,
) (*procurementv1.SupplierGetResponse, error) {
	supplier, err := ps.supplierBusiness.GetSupplier(ctx, req.GetId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &procurementv1.SupplierGetResponse{Supplier: supplier}, nil
}

func (ps *ProcurementServer) SupplierSearch(
	ctx context.Context,
	req *procurementv1.SupplierSearchRequest,
) (*procurementv1.SupplierSearchResponse, error) {
	suppliers, err := ps.supplierBusiness.SearchSuppliers(ctx, req)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &procurementv1.SupplierSearchResponse{Suppliers: suppliers}, nil
}

func (ps *ProcurementServer) SupplierItemSave(
	ctx context.Context,
	req *procurementv1.SupplierItemSaveRequest,
) (*procurementv1.SupplierItemSaveResponse, error) {
	item, err := ps.supplierBusiness.SaveSupplierItem(ctx, req)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &procurementv1.SupplierItemSaveResponse{SupplierItem: item}, nil
}

func (ps *ProcurementServer) SupplierItemSearch(
	ctx context.Context,
	req *procurementv1.SupplierItemSearchRequest,
) (*procurementv1.SupplierItemSearchResponse, error) {
	items, err := ps.supplierBusiness.SearchSupplierItems(ctx, req)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &procurementv1.SupplierItemSearchResponse{SupplierItems: items}, nil
}

// ----------------------
// Purchase Orders
// ----------------------
//
// Purchase orders are per-property resources: every handler enforces the
// property-scoped Keto check (Plane 3) in addition to tenancy RLS and the
// functional access plane.

func (ps *ProcurementServer) PurchaseOrderCreate(
	ctx context.Context,
	req *procurementv1.PurchaseOrderCreateRequest,
) (*procurementv1.PurchaseOrderCreateResponse, error) {
	if err := ps.authz.CanPurchaseOrderManage(ctx, req.GetPropertyId()); err != nil {
		return nil, authorizer.ToConnectError(err)
	}

	po, err := ps.purchaseOrderBusiness.CreatePurchaseOrder(ctx, req)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &procurementv1.PurchaseOrderCreateResponse{PurchaseOrder: po}, nil
}

func (ps *ProcurementServer) PurchaseOrderGet(
	ctx context.Context,
	req *procurementv1.PurchaseOrderGetRequest,
) (*procurementv1.PurchaseOrderGetResponse, error) {
	po, err := ps.purchaseOrderBusiness.GetPurchaseOrder(ctx, req.GetId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	if err = ps.authz.CanPurchaseOrderView(ctx, po.GetPropertyId()); err != nil {
		return nil, notVisible(authorizer.ToConnectError(err))
	}
	return &procurementv1.PurchaseOrderGetResponse{PurchaseOrder: po}, nil
}

func (ps *ProcurementServer) PurchaseOrderSearch(
	ctx context.Context,
	req *procurementv1.PurchaseOrderSearchRequest,
) (*procurementv1.PurchaseOrderSearchResponse, error) {
	if req.GetPropertyId() == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument,
			"property_id is required")
	}
	if err := ps.authz.CanPurchaseOrderView(ctx, req.GetPropertyId()); err != nil {
		return nil, authorizer.ToConnectError(err)
	}

	orders, err := ps.purchaseOrderBusiness.SearchPurchaseOrders(ctx, req)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &procurementv1.PurchaseOrderSearchResponse{PurchaseOrders: orders}, nil
}

func (ps *ProcurementServer) PurchaseOrderSubmit(
	ctx context.Context,
	req *procurementv1.PurchaseOrderSubmitRequest,
) (*procurementv1.PurchaseOrderSubmitResponse, error) {
	existing, err := ps.purchaseOrderBusiness.GetPurchaseOrder(ctx, req.GetId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	if err = ps.authz.CanPurchaseOrderManage(ctx, existing.GetPropertyId()); err != nil {
		return nil, authorizer.ToConnectError(err)
	}

	po, err := ps.purchaseOrderBusiness.SubmitPurchaseOrder(ctx, req)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &procurementv1.PurchaseOrderSubmitResponse{PurchaseOrder: po}, nil
}

func (ps *ProcurementServer) PurchaseOrderCancel(
	ctx context.Context,
	req *procurementv1.PurchaseOrderCancelRequest,
) (*procurementv1.PurchaseOrderCancelResponse, error) {
	existing, err := ps.purchaseOrderBusiness.GetPurchaseOrder(ctx, req.GetId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	if err = ps.authz.CanPurchaseOrderManage(ctx, existing.GetPropertyId()); err != nil {
		return nil, authorizer.ToConnectError(err)
	}

	po, err := ps.purchaseOrderBusiness.CancelPurchaseOrder(ctx, req)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &procurementv1.PurchaseOrderCancelResponse{PurchaseOrder: po}, nil
}

func (ps *ProcurementServer) SuggestPurchaseOrders(
	ctx context.Context,
	req *procurementv1.SuggestPurchaseOrdersRequest,
) (*procurementv1.SuggestPurchaseOrdersResponse, error) {
	if req.GetPropertyId() == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument,
			"property_id is required")
	}
	if err := ps.authz.CanPurchaseOrderView(ctx, req.GetPropertyId()); err != nil {
		return nil, authorizer.ToConnectError(err)
	}

	suggestions, err := ps.suggestionBusiness.SuggestPurchaseOrders(ctx, req)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &procurementv1.SuggestPurchaseOrdersResponse{Suggestions: suggestions}, nil
}

// ----------------------
// Goods Receipts
// ----------------------
//
// Goods receipts are per-property resources; handlers enforce the
// property-scoped Keto check (Plane 3).

func (ps *ProcurementServer) GoodsReceiptCreate(
	ctx context.Context,
	req *procurementv1.GoodsReceiptCreateRequest,
) (*procurementv1.GoodsReceiptCreateResponse, error) {
	// A receipt lands on its purchase order's property, so that property is
	// the one the caller must manage, whatever property_id says.
	if err := ps.checkPurchaseOrderProperty(ctx, req.GetPurchaseOrderId(), req.GetPropertyId(),
		ps.authz.CanGoodsReceiptManage); err != nil {
		return nil, err
	}

	gr, err := ps.goodsReceiptBusiness.CreateGoodsReceipt(ctx, req)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &procurementv1.GoodsReceiptCreateResponse{GoodsReceipt: gr}, nil
}

func (ps *ProcurementServer) GoodsReceiptGet(
	ctx context.Context,
	req *procurementv1.GoodsReceiptGetRequest,
) (*procurementv1.GoodsReceiptGetResponse, error) {
	gr, err := ps.goodsReceiptBusiness.GetGoodsReceipt(ctx, req.GetId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	if err = ps.authz.CanGoodsReceiptView(ctx, gr.GetPropertyId()); err != nil {
		return nil, notVisible(authorizer.ToConnectError(err))
	}
	return &procurementv1.GoodsReceiptGetResponse{GoodsReceipt: gr}, nil
}

func (ps *ProcurementServer) GoodsReceiptSearch(
	ctx context.Context,
	req *procurementv1.GoodsReceiptSearchRequest,
) (*procurementv1.GoodsReceiptSearchResponse, error) {
	// Goods receipts may be scoped by property directly, or by a purchase
	// order, whose own property then decides. Either way the caller must
	// hold the property-level view permission.
	switch {
	case req.GetPurchaseOrderId() != "":
		if err := ps.checkPurchaseOrderProperty(ctx, req.GetPurchaseOrderId(), req.GetPropertyId(),
			ps.authz.CanGoodsReceiptView); err != nil {
			return nil, notVisible(err)
		}
	case req.GetPropertyId() != "":
		if err := ps.authz.CanGoodsReceiptView(ctx, req.GetPropertyId()); err != nil {
			return nil, authorizer.ToConnectError(err)
		}
	default:
		return nil, connect.NewError(connect.CodeInvalidArgument,
			"property_id or purchase_order_id is required")
	}

	receipts, err := ps.goodsReceiptBusiness.SearchGoodsReceipts(ctx, req)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &procurementv1.GoodsReceiptSearchResponse{GoodsReceipts: receipts}, nil
}

// notVisible answers a read of a record the caller may not see exactly as a
// read of one that does not exist, so ids cannot be probed for existence.
func notVisible(err error) error {
	if connect.CodeOf(err) == connect.CodePermissionDenied {
		return connect.NewError(connect.CodeNotFound, "record not found")
	}
	return err
}

// checkPurchaseOrderProperty loads a purchase order and applies check to its
// property. A property_id the caller also sent must name that same property.
func (ps *ProcurementServer) checkPurchaseOrderProperty(
	ctx context.Context,
	purchaseOrderID, claimedPropertyID string,
	check func(context.Context, string) error,
) error {
	if purchaseOrderID == "" {
		return connect.NewError(connect.CodeInvalidArgument, "purchase_order_id is required")
	}
	po, err := ps.purchaseOrderBusiness.GetPurchaseOrder(ctx, purchaseOrderID)
	if err != nil {
		return errorutil.CleanErr(err)
	}
	if err = check(ctx, po.GetPropertyId()); err != nil {
		return authorizer.ToConnectError(err)
	}
	if claimedPropertyID != "" && claimedPropertyID != po.GetPropertyId() {
		return connect.NewError(connect.CodeInvalidArgument,
			"property_id does not match the purchase order's property")
	}
	return nil
}
