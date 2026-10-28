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

package tests_test

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connecthttp"
	"github.com/pitabwire/frame/v3/frametests/definition"
	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/frame/v3/security/authorizer"
	"github.com/pitabwire/util"
	"github.com/stretchr/testify/require"
	"github.com/stretchr/testify/suite"

	procurementv1 "github.com/antinvestor/service-commerce/gen/go/procurement/v1"
	"github.com/antinvestor/service-commerce/gen/go/procurement/v1/procurementv1connect"

	"github.com/antinvestor/service-commerce/apps/procurement/service/authz"
	"github.com/antinvestor/service-commerce/apps/procurement/service/handlers"
	"github.com/antinvestor/service-commerce/apps/procurement/tests"
)

type ConnectTestSuite struct {
	tests.ProcurementBaseTestSuite
}

func TestConnectSuite(t *testing.T) {
	suite.Run(t, new(ConnectTestSuite))
}

// subjectHeader names the caller of a test request; the server binds it as
// the authenticated subject, standing in for the JWT interceptors.
const subjectHeader = "X-Test-Subject"

// propertyACL is an authz.Middleware that lets each subject act only on the
// properties listed for it.
type propertyACL map[string][]string

func (a propertyACL) allow(ctx context.Context, propertyID string) error {
	claims := security.ClaimsFromContext(ctx)
	if claims != nil {
		for _, p := range a[claims.Subject] {
			if p == propertyID {
				return nil
			}
		}
	}
	return authorizer.NewPermissionDeniedError(
		security.ObjectRef{Namespace: authz.NamespaceProperty, ID: propertyID}, "any",
		security.SubjectRef{Namespace: authz.NamespaceProfile}, "not listed")
}

func (a propertyACL) CanPropertyView(ctx context.Context, p string) error   { return a.allow(ctx, p) }
func (a propertyACL) CanPropertyUpdate(ctx context.Context, p string) error { return a.allow(ctx, p) }
func (a propertyACL) CanPurchaseOrderManage(ctx context.Context, p string) error {
	return a.allow(ctx, p)
}
func (a propertyACL) CanPurchaseOrderView(ctx context.Context, p string) error {
	return a.allow(ctx, p)
}
func (a propertyACL) CanGoodsReceiptManage(ctx context.Context, p string) error {
	return a.allow(ctx, p)
}
func (a propertyACL) CanGoodsReceiptView(ctx context.Context, p string) error { return a.allow(ctx, p) }
func (propertyACL) AddPropertyMember(context.Context, string, string, string) error {
	return nil
}
func (propertyACL) RemovePropertyMember(context.Context, string, string) error { return nil }
func (propertyACL) UpdatePropertyMemberRole(context.Context, string, string, string, string) error {
	return nil
}

// Every published RPC is served by name through a real Connect client, and a
// goods receipt is authorised on its purchase order's property, not on the
// property_id the caller sends.
func (cs *ConnectTestSuite) TestRPCsServedAndReceiptAuthorisedOnPOProperty() {
	t := cs.T()

	cs.WithTestDependancies(t, func(t *testing.T, dep *definition.DependencyOption) {
		ctx, svc := cs.CreateService(t, dep)

		acl := propertyACL{"buyer-a": {"property-a"}, "buyer-b": {"property-b"}}
		server := connect.NewServer()
		procurementv1connect.RegisterProcurementServiceHandler(server,
			handlers.NewProcurementServer(ctx, svc, acl, nil, nil, nil))
		mux := http.NewServeMux()
		connecthttp.Mount(mux, server)
		srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			claims := &security.AuthenticationClaims{TenantID: "tenant-1", PartitionID: "partition-1"}
			claims.Subject = r.Header.Get(subjectHeader)
			mux.ServeHTTP(w, r.WithContext(claims.ClaimsToContext(r.Context())))
		}))
		t.Cleanup(srv.Close)

		client := procurementv1connect.NewProcurementServiceClient(
			connect.NewClient(connecthttp.NewTransport(srv.Client(), srv.URL)))
		as := func(subject string) context.Context {
			callCtx, info := connect.NewClientContext(ctx)
			info.RequestHeader().Set(subjectHeader, subject)
			return callCtx
		}
		a := as("buyer-a")

		supplier, err := client.SupplierSave(a, &procurementv1.SupplierSaveRequest{
			Name: "Supplier " + util.RandomAlphaNumericString(6), Currency: "USD",
		})
		require.NoError(t, err)
		_, err = client.SupplierGet(a, &procurementv1.SupplierGetRequest{Id: supplier.GetSupplier().GetId()})
		require.NoError(t, err)
		_, err = client.SupplierSearch(a, &procurementv1.SupplierSearchRequest{})
		require.NoError(t, err)

		item, err := client.SupplierItemSave(a, &procurementv1.SupplierItemSaveRequest{
			SupplierId:      supplier.GetSupplier().GetId(),
			InventoryItemId: "inv-" + util.RandomAlphaNumericString(6),
			SupplierSku:     "SKU-" + util.RandomAlphaNumericString(6),
			UnitPrice:       &commonv1.Money{CurrencyCode: "USD", Units: 10},
			Unit:            "kg",
		})
		require.NoError(t, err)
		_, err = client.SupplierItemSearch(a, &procurementv1.SupplierItemSearchRequest{
			SupplierId: supplier.GetSupplier().GetId(),
		})
		require.NoError(t, err)

		newPO := func() *procurementv1.PurchaseOrder {
			created, createErr := client.PurchaseOrderCreate(a, &procurementv1.PurchaseOrderCreateRequest{
				PropertyId: "property-a",
				SupplierId: supplier.GetSupplier().GetId(),
				Lines: []*procurementv1.PurchaseOrderLineInput{
					{SupplierItemId: item.GetSupplierItem().GetId(), OrderedQuantity: 10},
				},
			})
			require.NoError(t, createErr)
			return created.GetPurchaseOrder()
		}
		po := newPO()
		_, err = client.PurchaseOrderGet(a, &procurementv1.PurchaseOrderGetRequest{Id: po.GetId()})
		require.NoError(t, err)
		_, err = client.PurchaseOrderSearch(a, &procurementv1.PurchaseOrderSearchRequest{PropertyId: "property-a"})
		require.NoError(t, err)
		submitted, err := client.PurchaseOrderSubmit(a, &procurementv1.PurchaseOrderSubmitRequest{Id: po.GetId()})
		require.NoError(t, err)
		lineID := submitted.GetPurchaseOrder().GetLines()[0].GetId()

		// buyer-b manages property-b and names it, but the order is property-a's.
		b := as("buyer-b")
		_, err = client.GoodsReceiptCreate(b, &procurementv1.GoodsReceiptCreateRequest{
			PurchaseOrderId: po.GetId(),
			PropertyId:      "property-b",
			Lines: []*procurementv1.GoodsReceiptLineInput{
				{PurchaseOrderLineId: lineID, ReceivedQuantity: 1},
			},
		})
		require.Equal(t, connect.CodePermissionDenied, connect.CodeOf(err))
		// Reads of another property's records look like reads of missing ones.
		_, err = client.GoodsReceiptSearch(b, &procurementv1.GoodsReceiptSearchRequest{
			PropertyId: "property-b", PurchaseOrderId: po.GetId(),
		})
		require.Equal(t, connect.CodeNotFound, connect.CodeOf(err))
		_, err = client.PurchaseOrderGet(b, &procurementv1.PurchaseOrderGetRequest{Id: po.GetId()})
		require.Equal(t, connect.CodeNotFound, connect.CodeOf(err))

		key := "receipt-" + util.RandomAlphaNumericString(8)
		receipt, err := client.GoodsReceiptCreate(a, &procurementv1.GoodsReceiptCreateRequest{
			PurchaseOrderId: po.GetId(),
			IdempotencyKey:  key,
			Lines: []*procurementv1.GoodsReceiptLineInput{
				{PurchaseOrderLineId: lineID, ReceivedQuantity: 4},
			},
		})
		require.NoError(t, err)
		_, err = client.GoodsReceiptGet(a, &procurementv1.GoodsReceiptGetRequest{
			Id: receipt.GetGoodsReceipt().GetId(),
		})
		require.NoError(t, err)
		_, err = client.GoodsReceiptSearch(a, &procurementv1.GoodsReceiptSearchRequest{PurchaseOrderId: po.GetId()})
		require.NoError(t, err)

		// Resolving a line is authorised on the receipt's stored property:
		// another property's receipt looks missing.
		resolveReq := &procurementv1.GoodsReceiptLineResolveRequest{
			GoodsReceiptId: receipt.GetGoodsReceipt().GetId(),
			LineId:         receipt.GetGoodsReceipt().GetLines()[0].GetId(),
			Resolution:     procurementv1.GoodsReceiptLineResolution_GOODS_RECEIPT_LINE_RESOLUTION_BOOKED_MANUALLY,
			Note:           "booked by hand",
		}
		_, err = client.GoodsReceiptLineResolve(b, resolveReq)
		require.Equal(t, connect.CodeNotFound, connect.CodeOf(err))
		resolved, err := client.GoodsReceiptLineResolve(a, resolveReq)
		require.NoError(t, err)
		require.Equal(t, procurementv1.StockDeliveryStatus_STOCK_DELIVERY_STATUS_RESOLVED,
			resolved.GetGoodsReceipt().GetLines()[0].GetDeliveryStatus())
		require.Equal(t, "buyer-a", resolved.GetGoodsReceipt().GetLines()[0].GetResolvedBy())

		// The same key on another order never returns the first receipt.
		other := newPO()
		otherSubmitted, err := client.PurchaseOrderSubmit(a, &procurementv1.PurchaseOrderSubmitRequest{
			Id: other.GetId(),
		})
		require.NoError(t, err)
		_, err = client.GoodsReceiptCreate(a, &procurementv1.GoodsReceiptCreateRequest{
			PurchaseOrderId: other.GetId(),
			IdempotencyKey:  key,
			Lines: []*procurementv1.GoodsReceiptLineInput{
				{PurchaseOrderLineId: otherSubmitted.GetPurchaseOrder().GetLines()[0].GetId(), ReceivedQuantity: 1},
			},
		})
		require.Equal(t, connect.CodeAlreadyExists, connect.CodeOf(err))

		_, err = client.PurchaseOrderCancel(a, &procurementv1.PurchaseOrderCancelRequest{Id: other.GetId()})
		require.NoError(t, err)
		// Closing short needs a partially received order; a cancelled one is
		// refused, and another property's order looks missing.
		_, err = client.PurchaseOrderClose(a, &procurementv1.PurchaseOrderCloseRequest{Id: other.GetId()})
		require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
		_, err = client.PurchaseOrderClose(b, &procurementv1.PurchaseOrderCloseRequest{Id: po.GetId()})
		require.Equal(t, connect.CodeNotFound, connect.CodeOf(err))
		closed, err := client.PurchaseOrderClose(a, &procurementv1.PurchaseOrderCloseRequest{Id: po.GetId()})
		require.NoError(t, err)
		require.Equal(t, procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_CLOSED,
			closed.GetPurchaseOrder().GetStatus())

		delivered, err := client.GoodsReceiptDeliver(a, &procurementv1.GoodsReceiptDeliverRequest{Limit: 10})
		require.NoError(t, err)
		require.Zero(t, delivered.GetDelivered(), "raw materials are not pushed to commerce")

		// Without a material source suggestions are unavailable, but the RPC
		// is served rather than Unimplemented.
		_, err = client.SuggestPurchaseOrders(a, &procurementv1.SuggestPurchaseOrdersRequest{
			PropertyId: "property-a",
		})
		require.NotEqual(t, connect.CodeUnimplemented, connect.CodeOf(err))
	})
}
