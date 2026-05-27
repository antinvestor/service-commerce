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

	"buf.build/gen/go/antinvestor/procurement/connectrpc/go/v1/procurementv1connect"
	procurementv1 "buf.build/gen/go/antinvestor/procurement/protocolbuffers/go/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame"
	"github.com/pitabwire/frame/datastore"

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

func NewProcurementServer(ctx context.Context, svc *frame.Service, authzMiddleware authz.Middleware) *ProcurementServer {
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

func (ps *ProcurementServer) SaveSupplier(
	ctx context.Context,
	req *connect.Request[procurementv1.SaveSupplierRequest],
) (*connect.Response[procurementv1.SaveSupplierResponse], error) {
	supplier, err := ps.supplierBusiness.SaveSupplier(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&procurementv1.SaveSupplierResponse{Supplier: supplier}), nil
}

func (ps *ProcurementServer) GetSupplier(
	ctx context.Context,
	req *connect.Request[procurementv1.GetSupplierRequest],
) (*connect.Response[procurementv1.GetSupplierResponse], error) {
	supplier, err := ps.supplierBusiness.GetSupplier(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&procurementv1.GetSupplierResponse{Supplier: supplier}), nil
}

func (ps *ProcurementServer) SearchSuppliers(
	ctx context.Context,
	req *connect.Request[procurementv1.SearchSuppliersRequest],
) (*connect.Response[procurementv1.SearchSuppliersResponse], error) {
	suppliers, err := ps.supplierBusiness.SearchSuppliers(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&procurementv1.SearchSuppliersResponse{Suppliers: suppliers}), nil
}

func (ps *ProcurementServer) SaveSupplierItem(
	ctx context.Context,
	req *connect.Request[procurementv1.SaveSupplierItemRequest],
) (*connect.Response[procurementv1.SaveSupplierItemResponse], error) {
	item, err := ps.supplierBusiness.SaveSupplierItem(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&procurementv1.SaveSupplierItemResponse{SupplierItem: item}), nil
}

func (ps *ProcurementServer) SearchSupplierItems(
	ctx context.Context,
	req *connect.Request[procurementv1.SearchSupplierItemsRequest],
) (*connect.Response[procurementv1.SearchSupplierItemsResponse], error) {
	items, err := ps.supplierBusiness.SearchSupplierItems(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&procurementv1.SearchSupplierItemsResponse{SupplierItems: items}), nil
}

// ----------------------
// Purchase Orders
// ----------------------

func (ps *ProcurementServer) CreatePurchaseOrder(
	ctx context.Context,
	req *connect.Request[procurementv1.CreatePurchaseOrderRequest],
) (*connect.Response[procurementv1.CreatePurchaseOrderResponse], error) {
	po, err := ps.purchaseOrderBusiness.CreatePurchaseOrder(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&procurementv1.CreatePurchaseOrderResponse{PurchaseOrder: po}), nil
}

func (ps *ProcurementServer) GetPurchaseOrder(
	ctx context.Context,
	req *connect.Request[procurementv1.GetPurchaseOrderRequest],
) (*connect.Response[procurementv1.GetPurchaseOrderResponse], error) {
	po, err := ps.purchaseOrderBusiness.GetPurchaseOrder(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&procurementv1.GetPurchaseOrderResponse{PurchaseOrder: po}), nil
}

func (ps *ProcurementServer) SearchPurchaseOrders(
	ctx context.Context,
	req *connect.Request[procurementv1.SearchPurchaseOrdersRequest],
) (*connect.Response[procurementv1.SearchPurchaseOrdersResponse], error) {
	orders, err := ps.purchaseOrderBusiness.SearchPurchaseOrders(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&procurementv1.SearchPurchaseOrdersResponse{PurchaseOrders: orders}), nil
}

func (ps *ProcurementServer) SubmitPurchaseOrder(
	ctx context.Context,
	req *connect.Request[procurementv1.SubmitPurchaseOrderRequest],
) (*connect.Response[procurementv1.SubmitPurchaseOrderResponse], error) {
	po, err := ps.purchaseOrderBusiness.SubmitPurchaseOrder(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&procurementv1.SubmitPurchaseOrderResponse{PurchaseOrder: po}), nil
}

func (ps *ProcurementServer) CancelPurchaseOrder(
	ctx context.Context,
	req *connect.Request[procurementv1.CancelPurchaseOrderRequest],
) (*connect.Response[procurementv1.CancelPurchaseOrderResponse], error) {
	po, err := ps.purchaseOrderBusiness.CancelPurchaseOrder(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&procurementv1.CancelPurchaseOrderResponse{PurchaseOrder: po}), nil
}

func (ps *ProcurementServer) SuggestPurchaseOrders(
	ctx context.Context,
	_ *connect.Request[procurementv1.SuggestPurchaseOrdersRequest],
) (*connect.Response[procurementv1.SuggestPurchaseOrdersResponse], error) {
	// Placeholder: returns empty suggestions for now
	return connect.NewResponse(&procurementv1.SuggestPurchaseOrdersResponse{
		PurchaseOrders: nil,
	}), nil
}

// ----------------------
// Goods Receipts
// ----------------------

func (ps *ProcurementServer) CreateGoodsReceipt(
	ctx context.Context,
	req *connect.Request[procurementv1.CreateGoodsReceiptRequest],
) (*connect.Response[procurementv1.CreateGoodsReceiptResponse], error) {
	gr, err := ps.goodsReceiptBusiness.CreateGoodsReceipt(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&procurementv1.CreateGoodsReceiptResponse{GoodsReceipt: gr}), nil
}

func (ps *ProcurementServer) GetGoodsReceipt(
	ctx context.Context,
	req *connect.Request[procurementv1.GetGoodsReceiptRequest],
) (*connect.Response[procurementv1.GetGoodsReceiptResponse], error) {
	gr, err := ps.goodsReceiptBusiness.GetGoodsReceipt(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&procurementv1.GetGoodsReceiptResponse{GoodsReceipt: gr}), nil
}

func (ps *ProcurementServer) SearchGoodsReceipts(
	ctx context.Context,
	req *connect.Request[procurementv1.SearchGoodsReceiptsRequest],
) (*connect.Response[procurementv1.SearchGoodsReceiptsResponse], error) {
	receipts, err := ps.goodsReceiptBusiness.SearchGoodsReceipts(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return connect.NewResponse(&procurementv1.SearchGoodsReceiptsResponse{GoodsReceipts: receipts}), nil
}
