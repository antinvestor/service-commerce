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
	"errors"

	"buf.build/gen/go/antinvestor/procurement/connectrpc/go/v1/procurementv1connect"
	procurementv1 "buf.build/gen/go/antinvestor/procurement/protocolbuffers/go/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/v2"
	"github.com/pitabwire/frame/v2/datastore"
	"github.com/pitabwire/frame/v2/security/authorizer"

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

	procurementv1connect.UnimplementedProcurementServiceHandler
}

func NewProcurementServer(
	ctx context.Context,
	svc *frame.Service,
	authzMiddleware authz.Middleware,
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
	}
}

// ----------------------
// Suppliers
// ----------------------
//
// Suppliers are tenant-scoped vendor records, not per-property resources, so
// they are governed by connection-level RLS tenancy and the functional access
// plane rather than a per-property Keto check (none exists for suppliers).

func (ps *ProcurementServer) SaveSupplier(
	ctx context.Context,
	req *connect.Request[procurementv1.SupplierSaveRequest],
) (*connect.Response[procurementv1.SupplierSaveResponse], error) {
	supplier, err := ps.supplierBusiness.SaveSupplier(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&procurementv1.SupplierSaveResponse{Supplier: supplier}), nil
}

func (ps *ProcurementServer) GetSupplier(
	ctx context.Context,
	req *connect.Request[procurementv1.SupplierGetRequest],
) (*connect.Response[procurementv1.SupplierGetResponse], error) {
	supplier, err := ps.supplierBusiness.GetSupplier(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&procurementv1.SupplierGetResponse{Supplier: supplier}), nil
}

func (ps *ProcurementServer) SearchSuppliers(
	ctx context.Context,
	req *connect.Request[procurementv1.SupplierSearchRequest],
) (*connect.Response[procurementv1.SupplierSearchResponse], error) {
	suppliers, err := ps.supplierBusiness.SearchSuppliers(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&procurementv1.SupplierSearchResponse{Suppliers: suppliers}), nil
}

func (ps *ProcurementServer) SaveSupplierItem(
	ctx context.Context,
	req *connect.Request[procurementv1.SupplierItemSaveRequest],
) (*connect.Response[procurementv1.SupplierItemSaveResponse], error) {
	item, err := ps.supplierBusiness.SaveSupplierItem(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&procurementv1.SupplierItemSaveResponse{SupplierItem: item}), nil
}

func (ps *ProcurementServer) SearchSupplierItems(
	ctx context.Context,
	req *connect.Request[procurementv1.SupplierItemSearchRequest],
) (*connect.Response[procurementv1.SupplierItemSearchResponse], error) {
	items, err := ps.supplierBusiness.SearchSupplierItems(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&procurementv1.SupplierItemSearchResponse{SupplierItems: items}), nil
}

// ----------------------
// Purchase Orders
// ----------------------
//
// Purchase orders are per-property resources: every handler enforces the
// property-scoped Keto check (Plane 3) in addition to tenancy RLS and the
// functional access plane.

func (ps *ProcurementServer) CreatePurchaseOrder(
	ctx context.Context,
	req *connect.Request[procurementv1.PurchaseOrderCreateRequest],
) (*connect.Response[procurementv1.PurchaseOrderCreateResponse], error) {
	if err := ps.authz.CanPurchaseOrderManage(ctx, req.Msg.GetPropertyId()); err != nil {
		return nil, authorizer.ToConnectError(err)
	}

	po, err := ps.purchaseOrderBusiness.CreatePurchaseOrder(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&procurementv1.PurchaseOrderCreateResponse{PurchaseOrder: po}), nil
}

func (ps *ProcurementServer) GetPurchaseOrder(
	ctx context.Context,
	req *connect.Request[procurementv1.PurchaseOrderGetRequest],
) (*connect.Response[procurementv1.PurchaseOrderGetResponse], error) {
	po, err := ps.purchaseOrderBusiness.GetPurchaseOrder(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	if err = ps.authz.CanPurchaseOrderView(ctx, po.GetPropertyId()); err != nil {
		return nil, authorizer.ToConnectError(err)
	}
	return connect.NewResponse(&procurementv1.PurchaseOrderGetResponse{PurchaseOrder: po}), nil
}

func (ps *ProcurementServer) SearchPurchaseOrders(
	ctx context.Context,
	req *connect.Request[procurementv1.PurchaseOrderSearchRequest],
) (*connect.Response[procurementv1.PurchaseOrderSearchResponse], error) {
	if req.Msg.GetPropertyId() == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument,
			errors.New("property_id is required"))
	}
	if err := ps.authz.CanPurchaseOrderView(ctx, req.Msg.GetPropertyId()); err != nil {
		return nil, authorizer.ToConnectError(err)
	}

	orders, err := ps.purchaseOrderBusiness.SearchPurchaseOrders(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&procurementv1.PurchaseOrderSearchResponse{PurchaseOrders: orders}), nil
}

func (ps *ProcurementServer) SubmitPurchaseOrder(
	ctx context.Context,
	req *connect.Request[procurementv1.PurchaseOrderSubmitRequest],
) (*connect.Response[procurementv1.PurchaseOrderSubmitResponse], error) {
	existing, err := ps.purchaseOrderBusiness.GetPurchaseOrder(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	if err = ps.authz.CanPurchaseOrderManage(ctx, existing.GetPropertyId()); err != nil {
		return nil, authorizer.ToConnectError(err)
	}

	po, err := ps.purchaseOrderBusiness.SubmitPurchaseOrder(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&procurementv1.PurchaseOrderSubmitResponse{PurchaseOrder: po}), nil
}

func (ps *ProcurementServer) CancelPurchaseOrder(
	ctx context.Context,
	req *connect.Request[procurementv1.PurchaseOrderCancelRequest],
) (*connect.Response[procurementv1.PurchaseOrderCancelResponse], error) {
	existing, err := ps.purchaseOrderBusiness.GetPurchaseOrder(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	if err = ps.authz.CanPurchaseOrderManage(ctx, existing.GetPropertyId()); err != nil {
		return nil, authorizer.ToConnectError(err)
	}

	po, err := ps.purchaseOrderBusiness.CancelPurchaseOrder(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&procurementv1.PurchaseOrderCancelResponse{PurchaseOrder: po}), nil
}

func (ps *ProcurementServer) SuggestPurchaseOrders(
	ctx context.Context,
	req *connect.Request[procurementv1.SuggestPurchaseOrdersRequest],
) (*connect.Response[procurementv1.SuggestPurchaseOrdersResponse], error) {
	if req.Msg.GetPropertyId() == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument,
			errors.New("property_id is required"))
	}
	if err := ps.authz.CanPurchaseOrderView(ctx, req.Msg.GetPropertyId()); err != nil {
		return nil, authorizer.ToConnectError(err)
	}

	// Placeholder: returns empty suggestions for now
	return connect.NewResponse(&procurementv1.SuggestPurchaseOrdersResponse{
		Suggestions: nil,
	}), nil
}

// ----------------------
// Goods Receipts
// ----------------------
//
// Goods receipts are per-property resources; handlers enforce the
// property-scoped Keto check (Plane 3).

func (ps *ProcurementServer) CreateGoodsReceipt(
	ctx context.Context,
	req *connect.Request[procurementv1.GoodsReceiptCreateRequest],
) (*connect.Response[procurementv1.GoodsReceiptCreateResponse], error) {
	if err := ps.authz.CanGoodsReceiptManage(ctx, req.Msg.GetPropertyId()); err != nil {
		return nil, authorizer.ToConnectError(err)
	}

	gr, err := ps.goodsReceiptBusiness.CreateGoodsReceipt(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&procurementv1.GoodsReceiptCreateResponse{GoodsReceipt: gr}), nil
}

func (ps *ProcurementServer) GetGoodsReceipt(
	ctx context.Context,
	req *connect.Request[procurementv1.GoodsReceiptGetRequest],
) (*connect.Response[procurementv1.GoodsReceiptGetResponse], error) {
	gr, err := ps.goodsReceiptBusiness.GetGoodsReceipt(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	if err = ps.authz.CanGoodsReceiptView(ctx, gr.GetPropertyId()); err != nil {
		return nil, authorizer.ToConnectError(err)
	}
	return connect.NewResponse(&procurementv1.GoodsReceiptGetResponse{GoodsReceipt: gr}), nil
}

func (ps *ProcurementServer) SearchGoodsReceipts(
	ctx context.Context,
	req *connect.Request[procurementv1.GoodsReceiptSearchRequest],
) (*connect.Response[procurementv1.GoodsReceiptSearchResponse], error) {
	// Goods receipts may be scoped by property directly, or by a purchase
	// order (whose property we resolve). Either way the caller must hold the
	// property-level view permission.
	propertyID := req.Msg.GetPropertyId()
	if propertyID == "" {
		if req.Msg.GetPurchaseOrderId() == "" {
			return nil, connect.NewError(connect.CodeInvalidArgument,
				errors.New("property_id or purchase_order_id is required"))
		}
		po, poErr := ps.purchaseOrderBusiness.GetPurchaseOrder(ctx, req.Msg.GetPurchaseOrderId())
		if poErr != nil {
			return nil, errorutil.CleanErr(poErr)
		}
		propertyID = po.GetPropertyId()
	}
	if err := ps.authz.CanGoodsReceiptView(ctx, propertyID); err != nil {
		return nil, authorizer.ToConnectError(err)
	}

	receipts, err := ps.goodsReceiptBusiness.SearchGoodsReceipts(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&procurementv1.GoodsReceiptSearchResponse{GoodsReceipts: receipts}), nil
}
