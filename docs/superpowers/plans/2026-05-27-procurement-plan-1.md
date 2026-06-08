# Procurement & Supplier Management — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a procurement application to service-commerce that manages suppliers, purchase orders, goods receiving, and purchase order suggestions from manufacturing material shortages.

**Architecture:** New app at `service-commerce/apps/procurement/` following the identical Frame blueprint pattern as the existing `apps/default/`. Separate Connect RPC proto (`ProcurementService`), separate binary, separate auth namespace. Shares the go.mod and `pkg/` with the commerce default app. Communicates with service-manufacturing via typed Connect RPC client for stock-in movements after goods acceptance.

**Tech Stack:** Go 1.26, Frame v1.97.6, Connect RPC, PostgreSQL, GORM, Ory Keto (ReBAC), testcontainers, buf.build for proto.

**Spec:** See `docs/superpowers/specs/2026-05-27-yoghurt-business-gaps-design.md` sections 3.1–3.12.

**Dependencies:** None — this is Phase 1. Other plans (Quality Control, Costing, Traceability) depend on this.

---

## File Structure

```text
service-commerce/
├── apps/
│   ├── default/                          (existing — unchanged)
│   └── procurement/                      (NEW)
│       ├── cmd/main.go
│       ├── config/config.go
│       ├── service/
│       │   ├── authz/
│       │   │   ├── constants.go
│       │   │   ├── interfaces.go
│       │   │   └── middleware.go
│       │   ├── business/
│       │   │   ├── suppliers.go
│       │   │   ├── purchase_orders.go
│       │   │   └── goods_receipts.go
│       │   ├── handlers/
│       │   │   └── procurement.go
│       │   ├── models/
│       │   │   └── models.go
│       │   └── repository/
│       │       ├── interfaces.go
│       │       ├── migrate.go
│       │       ├── suppliers.go
│       │       ├── purchase_orders.go
│       │       └── goods_receipts.go
│       ├── migrations/
│       │   └── 0001/
│       │       └── 20260527_initial.sql
│       └── tests/
│           ├── base_testsuite.go
│           ├── testketo/keto.go
│           ├── supplier_test.go
│           ├── purchase_order_test.go
│           └── goods_receipt_test.go
├── proto/
│   └── procurement/v1/
│       └── procurement.proto             (NEW)
├── opl/
│   └── procurement/                      (NEW)
├── pkg/
│   └── errorutil/                        (existing — shared)
└── go.mod                                (add buf.build procurement deps)
```

---

## Task 1: Proto Definition

**Files:**
- Create: `proto/procurement/v1/procurement.proto`
- Create: `proto/buf.gen.procurement.yaml` (if separate gen config needed)

- [ ] **Step 1: Create the proto directory**

```bash
mkdir -p proto/procurement/v1
```

- [ ] **Step 2: Write the proto file**

Create `proto/procurement/v1/procurement.proto`:

```protobuf
syntax = "proto3";

package procurement.v1;

import "buf/validate/validate.proto";
import "common/v1/common.proto";
import "common/v1/money.proto";
import "common/v1/permissions.proto";
import "gnostic/openapi/v3/annotations.proto";
import "google/protobuf/field_mask.proto";
import "google/protobuf/timestamp.proto";

option go_package = "github.com/antinvestor/apis/go/procurement/v1;procurementv1";
option java_multiple_files = true;
option java_package = "procurementv1";
option (gnostic.openapi.v3.document) = {
  info: {
    title: "Procurement API"
    version: "v1.0.0"
    description: "Procurement API for supplier management, purchase orders, and goods receiving."
    contact: {
      name: "Ant Investor Ltd"
      url: "https://github.com/antinvestor/service-commerce"
      email: "info@antinvestor.com"
    }
    license: {
      name: "Apache License"
      url: "https://github.com/antinvestor/apis/blob/master/LICENSE"
    }
  }
  components: {
    security_schemes: {
      additional_properties: [
        {
          name: "BearerAuth"
          value: {
            security_scheme: {
              type: "http"
              scheme: "bearer"
              bearer_format: "JWT"
            }
          }
        }
      ]
    }
  }
};

service ProcurementService {
  option (common.v1.service_permissions) = {
    namespace: "service_procurement"
    permissions: [
      "supplier_view",
      "supplier_manage",
      "purchase_order_view",
      "purchase_order_create",
      "purchase_order_submit",
      "purchase_order_cancel",
      "goods_receipt_view",
      "goods_receipt_create"
    ]
    role_bindings: [
      {
        role: ROLE_OWNER
        permissions: [
          "supplier_view", "supplier_manage",
          "purchase_order_view", "purchase_order_create",
          "purchase_order_submit", "purchase_order_cancel",
          "goods_receipt_view", "goods_receipt_create"
        ]
      },
      {
        role: ROLE_ADMIN
        permissions: [
          "supplier_view", "supplier_manage",
          "purchase_order_view", "purchase_order_create",
          "purchase_order_submit", "purchase_order_cancel",
          "goods_receipt_view", "goods_receipt_create"
        ]
      },
      {
        role: ROLE_OPERATOR
        permissions: [
          "supplier_view",
          "purchase_order_view", "purchase_order_create",
          "purchase_order_submit",
          "goods_receipt_view", "goods_receipt_create"
        ]
      },
      {
        role: ROLE_VIEWER
        permissions: [
          "supplier_view",
          "purchase_order_view",
          "goods_receipt_view"
        ]
      },
      {
        role: ROLE_SERVICE
        permissions: [
          "supplier_view", "supplier_manage",
          "purchase_order_view", "purchase_order_create",
          "purchase_order_submit", "purchase_order_cancel",
          "goods_receipt_view", "goods_receipt_create"
        ]
      }
    ]
  };

  // ---- Suppliers ----

  rpc SupplierSave(SupplierSaveRequest) returns (SupplierSaveResponse) {
    option (common.v1.method_permissions) = { permissions: ["supplier_manage"] };
  }
  rpc SupplierGet(SupplierGetRequest) returns (SupplierGetResponse) {
    option (common.v1.method_permissions) = { permissions: ["supplier_view"] };
  }
  rpc SupplierSearch(SupplierSearchRequest) returns (SupplierSearchResponse) {
    option (common.v1.method_permissions) = { permissions: ["supplier_view"] };
  }

  // ---- Supplier Items ----

  rpc SupplierItemSave(SupplierItemSaveRequest) returns (SupplierItemSaveResponse) {
    option (common.v1.method_permissions) = { permissions: ["supplier_manage"] };
  }
  rpc SupplierItemSearch(SupplierItemSearchRequest) returns (SupplierItemSearchResponse) {
    option (common.v1.method_permissions) = { permissions: ["supplier_view"] };
  }

  // ---- Purchase Orders ----

  rpc PurchaseOrderCreate(PurchaseOrderCreateRequest) returns (PurchaseOrderCreateResponse) {
    option (common.v1.method_permissions) = { permissions: ["purchase_order_create"] };
  }
  rpc PurchaseOrderGet(PurchaseOrderGetRequest) returns (PurchaseOrderGetResponse) {
    option (common.v1.method_permissions) = { permissions: ["purchase_order_view"] };
  }
  rpc PurchaseOrderSearch(PurchaseOrderSearchRequest) returns (PurchaseOrderSearchResponse) {
    option (common.v1.method_permissions) = { permissions: ["purchase_order_view"] };
  }
  rpc PurchaseOrderSubmit(PurchaseOrderSubmitRequest) returns (PurchaseOrderSubmitResponse) {
    option (common.v1.method_permissions) = { permissions: ["purchase_order_submit"] };
  }
  rpc PurchaseOrderCancel(PurchaseOrderCancelRequest) returns (PurchaseOrderCancelResponse) {
    option (common.v1.method_permissions) = { permissions: ["purchase_order_cancel"] };
  }

  // ---- Goods Receipts ----

  rpc GoodsReceiptCreate(GoodsReceiptCreateRequest) returns (GoodsReceiptCreateResponse) {
    option (common.v1.method_permissions) = { permissions: ["goods_receipt_create"] };
  }
  rpc GoodsReceiptGet(GoodsReceiptGetRequest) returns (GoodsReceiptGetResponse) {
    option (common.v1.method_permissions) = { permissions: ["goods_receipt_view"] };
  }
  rpc GoodsReceiptSearch(GoodsReceiptSearchRequest) returns (GoodsReceiptSearchResponse) {
    option (common.v1.method_permissions) = { permissions: ["goods_receipt_view"] };
  }

  // ---- Suggestions ----

  rpc SuggestPurchaseOrders(SuggestPurchaseOrdersRequest) returns (SuggestPurchaseOrdersResponse) {
    option (common.v1.method_permissions) = { permissions: ["purchase_order_create"] };
  }
}

// ---- Enums ----

enum SupplierType {
  SUPPLIER_TYPE_UNSPECIFIED = 0;
  SUPPLIER_TYPE_RAW_MATERIAL = 1;
  SUPPLIER_TYPE_PACKAGING = 2;
  SUPPLIER_TYPE_SERVICE = 3;
  SUPPLIER_TYPE_EQUIPMENT = 4;
}

enum SupplierStatus {
  SUPPLIER_STATUS_UNSPECIFIED = 0;
  SUPPLIER_STATUS_ACTIVE = 1;
  SUPPLIER_STATUS_SUSPENDED = 2;
  SUPPLIER_STATUS_INACTIVE = 3;
}

enum SupplierRating {
  SUPPLIER_RATING_UNSPECIFIED = 0;
  SUPPLIER_RATING_UNRATED = 1;
  SUPPLIER_RATING_APPROVED = 2;
  SUPPLIER_RATING_PREFERRED = 3;
  SUPPLIER_RATING_PROBATION = 4;
}

enum SupplierItemStatus {
  SUPPLIER_ITEM_STATUS_UNSPECIFIED = 0;
  SUPPLIER_ITEM_STATUS_ACTIVE = 1;
  SUPPLIER_ITEM_STATUS_DISCONTINUED = 2;
}

enum PurchaseOrderStatus {
  PURCHASE_ORDER_STATUS_UNSPECIFIED = 0;
  PURCHASE_ORDER_STATUS_DRAFT = 1;
  PURCHASE_ORDER_STATUS_SUBMITTED = 2;
  PURCHASE_ORDER_STATUS_CONFIRMED = 3;
  PURCHASE_ORDER_STATUS_PARTIALLY_RECEIVED = 4;
  PURCHASE_ORDER_STATUS_RECEIVED = 5;
  PURCHASE_ORDER_STATUS_CANCELLED = 6;
}

enum PurchaseOrderLineStatus {
  PURCHASE_ORDER_LINE_STATUS_UNSPECIFIED = 0;
  PURCHASE_ORDER_LINE_STATUS_PENDING = 1;
  PURCHASE_ORDER_LINE_STATUS_PARTIALLY_RECEIVED = 2;
  PURCHASE_ORDER_LINE_STATUS_RECEIVED = 3;
  PURCHASE_ORDER_LINE_STATUS_CANCELLED = 4;
}

enum GoodsReceiptStatus {
  GOODS_RECEIPT_STATUS_UNSPECIFIED = 0;
  GOODS_RECEIPT_STATUS_PENDING_INSPECTION = 1;
  GOODS_RECEIPT_STATUS_ACCEPTED = 2;
  GOODS_RECEIPT_STATUS_PARTIALLY_ACCEPTED = 3;
  GOODS_RECEIPT_STATUS_REJECTED = 4;
}

// ---- Messages ----

message Supplier {
  string id = 1;
  string profile_id = 2;
  string name = 3;
  SupplierType supplier_type = 4;
  SupplierStatus status = 5;
  int32 payment_terms_days = 6;
  string currency = 7;
  int32 lead_time_days = 8;
  SupplierRating rating = 9;
  string notes = 10;
  google.protobuf.Timestamp created_at = 15;
}

message SupplierItem {
  string id = 1;
  string supplier_id = 2;
  string inventory_item_id = 3;
  string supplier_sku = 4;
  common.v1.Money unit_price = 5;
  double min_order_quantity = 6;
  string unit = 7;
  int32 lead_time_days = 8;
  SupplierItemStatus status = 9;
  google.protobuf.Timestamp created_at = 15;
}

message PurchaseOrder {
  string id = 1;
  string property_id = 2;
  string supplier_id = 3;
  string order_number = 4;
  PurchaseOrderStatus status = 5;
  google.protobuf.Timestamp expected_delivery_date = 6;
  google.protobuf.Timestamp submitted_at = 7;
  string submitted_by = 8;
  common.v1.Money total_amount = 9;
  string notes = 10;
  string plan_id = 11;
  repeated PurchaseOrderLine lines = 12;
  google.protobuf.Timestamp created_at = 15;
}

message PurchaseOrderLine {
  string id = 1;
  string purchase_order_id = 2;
  string supplier_item_id = 3;
  string inventory_item_id = 4;
  double ordered_quantity = 5;
  double received_quantity = 6;
  common.v1.Money unit_price = 7;
  string unit = 8;
  PurchaseOrderLineStatus status = 9;
}

message GoodsReceipt {
  string id = 1;
  string purchase_order_id = 2;
  string property_id = 3;
  string received_by = 4;
  google.protobuf.Timestamp received_at = 5;
  GoodsReceiptStatus status = 6;
  string notes = 7;
  repeated GoodsReceiptLine lines = 8;
  google.protobuf.Timestamp created_at = 15;
}

message GoodsReceiptLine {
  string id = 1;
  string goods_receipt_id = 2;
  string purchase_order_line_id = 3;
  string inventory_item_id = 4;
  double received_quantity = 5;
  double accepted_quantity = 6;
  double rejected_quantity = 7;
  string rejection_reason = 8;
  string lot_number = 9;
  google.protobuf.Timestamp expiry_date = 10;
  string unit = 11;
}

message PurchaseOrderSuggestion {
  string supplier_id = 1;
  string supplier_name = 2;
  repeated PurchaseOrderSuggestionLine lines = 3;
  common.v1.Money estimated_total = 4;
}

message PurchaseOrderSuggestionLine {
  string inventory_item_id = 1;
  string item_name = 2;
  double shortage_quantity = 3;
  string unit = 4;
  string supplier_item_id = 5;
  common.v1.Money unit_price = 6;
}

// ---- Requests / Responses ----

// Supplier
message SupplierSaveRequest {
  string id = 1;
  string profile_id = 2;
  string name = 3;
  SupplierType supplier_type = 4;
  SupplierStatus status = 5;
  int32 payment_terms_days = 6;
  string currency = 7;
  int32 lead_time_days = 8;
  SupplierRating rating = 9;
  string notes = 10;
}

message SupplierSaveResponse {
  Supplier supplier = 1;
}

message SupplierGetRequest {
  string id = 1;
}

message SupplierGetResponse {
  Supplier supplier = 1;
}

message SupplierSearchRequest {
  common.v1.SearchRequest search = 1;
  SupplierType supplier_type = 2;
  SupplierStatus status = 3;
}

message SupplierSearchResponse {
  repeated Supplier suppliers = 1;
  string next_page = 2;
}

// Supplier Item
message SupplierItemSaveRequest {
  string id = 1;
  string supplier_id = 2;
  string inventory_item_id = 3;
  string supplier_sku = 4;
  common.v1.Money unit_price = 5;
  double min_order_quantity = 6;
  string unit = 7;
  int32 lead_time_days = 8;
  SupplierItemStatus status = 9;
}

message SupplierItemSaveResponse {
  SupplierItem supplier_item = 1;
}

message SupplierItemSearchRequest {
  string supplier_id = 1;
  string inventory_item_id = 2;
  common.v1.SearchRequest search = 3;
}

message SupplierItemSearchResponse {
  repeated SupplierItem supplier_items = 1;
  string next_page = 2;
}

// Purchase Order
message PurchaseOrderCreateRequest {
  string idempotency_key = 1;
  string property_id = 2;
  string supplier_id = 3;
  google.protobuf.Timestamp expected_delivery_date = 4;
  string notes = 5;
  string plan_id = 6;
  repeated PurchaseOrderLineInput lines = 7;
}

message PurchaseOrderLineInput {
  string supplier_item_id = 1;
  string inventory_item_id = 2;
  double ordered_quantity = 3;
  string unit = 4;
}

message PurchaseOrderCreateResponse {
  PurchaseOrder purchase_order = 1;
}

message PurchaseOrderGetRequest {
  string id = 1;
}

message PurchaseOrderGetResponse {
  PurchaseOrder purchase_order = 1;
}

message PurchaseOrderSearchRequest {
  string property_id = 1;
  string supplier_id = 2;
  PurchaseOrderStatus status = 3;
  common.v1.SearchRequest search = 4;
}

message PurchaseOrderSearchResponse {
  repeated PurchaseOrder purchase_orders = 1;
  string next_page = 2;
}

message PurchaseOrderSubmitRequest {
  string id = 1;
}

message PurchaseOrderSubmitResponse {
  PurchaseOrder purchase_order = 1;
}

message PurchaseOrderCancelRequest {
  string id = 1;
  string reason = 2;
}

message PurchaseOrderCancelResponse {
  PurchaseOrder purchase_order = 1;
}

// Goods Receipt
message GoodsReceiptCreateRequest {
  string idempotency_key = 1;
  string purchase_order_id = 2;
  string property_id = 3;
  string notes = 4;
  repeated GoodsReceiptLineInput lines = 5;
}

message GoodsReceiptLineInput {
  string purchase_order_line_id = 1;
  string inventory_item_id = 2;
  double received_quantity = 3;
  string lot_number = 4;
  google.protobuf.Timestamp expiry_date = 5;
  string unit = 6;
}

message GoodsReceiptCreateResponse {
  GoodsReceipt goods_receipt = 1;
}

message GoodsReceiptGetRequest {
  string id = 1;
}

message GoodsReceiptGetResponse {
  GoodsReceipt goods_receipt = 1;
}

message GoodsReceiptSearchRequest {
  string purchase_order_id = 1;
  string property_id = 2;
  GoodsReceiptStatus status = 3;
  common.v1.SearchRequest search = 4;
}

message GoodsReceiptSearchResponse {
  repeated GoodsReceipt goods_receipts = 1;
  string next_page = 2;
}

// Suggestions
message SuggestPurchaseOrdersRequest {
  string property_id = 1;
  string plan_id = 2;
}

message SuggestPurchaseOrdersResponse {
  repeated PurchaseOrderSuggestion suggestions = 1;
}
```

- [ ] **Step 3: Generate Go code from proto**

```bash
cd proto && buf generate procurement
```

Verify generated packages appear at the expected buf.build import paths.

- [ ] **Step 4: Update go.mod with new buf.build dependencies**

```bash
go get buf.build/gen/go/antinvestor/procurement/connectrpc/go@latest
go get buf.build/gen/go/antinvestor/procurement/protocolbuffers/go@latest
go mod tidy
```

- [ ] **Step 5: Commit**

```bash
git add proto/procurement/ go.mod go.sum
git commit -m "feat(procurement): add ProcurementService proto definition"
```

---

## Task 2: Models

**Files:**
- Create: `apps/procurement/service/models/models.go`

- [ ] **Step 1: Create directory structure**

```bash
mkdir -p apps/procurement/service/{models,repository,business,handlers,authz}
mkdir -p apps/procurement/{cmd,config,migrations/0001,tests/testketo}
```

- [ ] **Step 2: Write all procurement models**

Create `apps/procurement/service/models/models.go`:

```go
package models

import (
	"time"

	procurementv1 "buf.build/gen/go/antinvestor/procurement/protocolbuffers/go/v1"
	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"github.com/pitabwire/frame/data"
	"google.golang.org/protobuf/types/known/timestamppb"
)

// Supplier represents a material or service provider.
type Supplier struct {
	data.BaseModel
	ProfileID       string `gorm:"type:varchar(50)"`
	Name            string `gorm:"type:varchar(255)"`
	SupplierType    int32  `gorm:"default:0;index:idx_supplier_type"`
	Status          int32  `gorm:"default:1;index:idx_supplier_status"`
	PaymentTermsDays int32
	Currency        string `gorm:"type:varchar(3)"`
	LeadTimeDays    int32
	Rating          int32  `gorm:"default:1"`
	Notes           string `gorm:"type:text"`
}

func (s *Supplier) ToAPI() *procurementv1.Supplier {
	return &procurementv1.Supplier{
		Id:               s.ID,
		ProfileId:        s.ProfileID,
		Name:             s.Name,
		SupplierType:     procurementv1.SupplierType(s.SupplierType),
		Status:           procurementv1.SupplierStatus(s.Status),
		PaymentTermsDays: s.PaymentTermsDays,
		Currency:         s.Currency,
		LeadTimeDays:     s.LeadTimeDays,
		Rating:           procurementv1.SupplierRating(s.Rating),
		Notes:            s.Notes,
		CreatedAt:        timestamppb.New(s.CreatedAt),
	}
}

// SupplierItem links a supplier to an inventory item with pricing.
type SupplierItem struct {
	data.BaseModel
	SupplierID       string  `gorm:"type:varchar(50);index:idx_si_supplier_id"`
	InventoryItemID  string  `gorm:"type:varchar(50);index:idx_si_inventory_item_id"`
	SupplierSKU      string  `gorm:"type:varchar(255)"`
	CurrencyCode     string  `gorm:"type:varchar(3)"`
	PriceUnits       int64
	PriceNanos       int32
	MinOrderQuantity float64
	Unit             string `gorm:"type:varchar(50)"`
	LeadTimeDays     int32
	Status           int32  `gorm:"default:1"`

	Supplier *Supplier `gorm:"foreignKey:SupplierID"`
}

func (si *SupplierItem) ToAPI() *procurementv1.SupplierItem {
	return &procurementv1.SupplierItem{
		Id:               si.ID,
		SupplierId:       si.SupplierID,
		InventoryItemId:  si.InventoryItemID,
		SupplierSku:      si.SupplierSKU,
		UnitPrice:        MoneyToProto(si.CurrencyCode, si.PriceUnits, si.PriceNanos),
		MinOrderQuantity: si.MinOrderQuantity,
		Unit:             si.Unit,
		LeadTimeDays:     si.LeadTimeDays,
		Status:           procurementv1.SupplierItemStatus(si.Status),
		CreatedAt:        timestamppb.New(si.CreatedAt),
	}
}

// PurchaseOrder represents a request to buy materials from a supplier.
type PurchaseOrder struct {
	data.BaseModel
	PropertyID           string     `gorm:"type:varchar(50);index:idx_po_property_id"`
	SupplierID           string     `gorm:"type:varchar(50);index:idx_po_supplier_id"`
	OrderNumber          string     `gorm:"type:varchar(100);uniqueIndex"`
	Status               int32      `gorm:"default:1;index:idx_po_status"`
	ExpectedDeliveryDate *time.Time
	SubmittedAt          *time.Time
	SubmittedBy          string `gorm:"type:varchar(50)"`
	TotalCurrencyCode    string `gorm:"type:varchar(3)"`
	TotalUnits           int64
	TotalNanos           int32
	Notes                string `gorm:"type:text"`
	PlanID               string `gorm:"type:varchar(50)"`
	IdempotencyKey       string `gorm:"type:varchar(255);uniqueIndex"`

	Lines    []*PurchaseOrderLine `gorm:"foreignKey:PurchaseOrderID"`
	Supplier *Supplier            `gorm:"foreignKey:SupplierID"`
}

func (po *PurchaseOrder) ToAPI() *procurementv1.PurchaseOrder {
	var lines []*procurementv1.PurchaseOrderLine
	for _, l := range po.Lines {
		lines = append(lines, l.ToAPI())
	}

	var expectedDate *timestamppb.Timestamp
	if po.ExpectedDeliveryDate != nil {
		expectedDate = timestamppb.New(*po.ExpectedDeliveryDate)
	}

	var submittedAt *timestamppb.Timestamp
	if po.SubmittedAt != nil {
		submittedAt = timestamppb.New(*po.SubmittedAt)
	}

	return &procurementv1.PurchaseOrder{
		Id:                   po.ID,
		PropertyId:           po.PropertyID,
		SupplierId:           po.SupplierID,
		OrderNumber:          po.OrderNumber,
		Status:               procurementv1.PurchaseOrderStatus(po.Status),
		ExpectedDeliveryDate: expectedDate,
		SubmittedAt:          submittedAt,
		SubmittedBy:          po.SubmittedBy,
		TotalAmount:          MoneyToProto(po.TotalCurrencyCode, po.TotalUnits, po.TotalNanos),
		Notes:                po.Notes,
		PlanId:               po.PlanID,
		Lines:                lines,
		CreatedAt:            timestamppb.New(po.CreatedAt),
	}
}

// PurchaseOrderLine represents a line item in a purchase order.
type PurchaseOrderLine struct {
	data.BaseModel
	PurchaseOrderID  string  `gorm:"type:varchar(50);index:idx_pol_po_id"`
	SupplierItemID   string  `gorm:"type:varchar(50)"`
	InventoryItemID  string  `gorm:"type:varchar(50)"`
	OrderedQuantity  float64
	ReceivedQuantity float64
	CurrencyCode     string `gorm:"type:varchar(3)"`
	PriceUnits       int64
	PriceNanos       int32
	Unit             string `gorm:"type:varchar(50)"`
	Status           int32  `gorm:"default:1"`

	PurchaseOrder *PurchaseOrder `gorm:"foreignKey:PurchaseOrderID"`
	SupplierItem  *SupplierItem  `gorm:"foreignKey:SupplierItemID"`
}

func (pol *PurchaseOrderLine) ToAPI() *procurementv1.PurchaseOrderLine {
	return &procurementv1.PurchaseOrderLine{
		Id:               pol.ID,
		PurchaseOrderId:  pol.PurchaseOrderID,
		SupplierItemId:   pol.SupplierItemID,
		InventoryItemId:  pol.InventoryItemID,
		OrderedQuantity:  pol.OrderedQuantity,
		ReceivedQuantity: pol.ReceivedQuantity,
		UnitPrice:        MoneyToProto(pol.CurrencyCode, pol.PriceUnits, pol.PriceNanos),
		Unit:             pol.Unit,
		Status:           procurementv1.PurchaseOrderLineStatus(pol.Status),
	}
}

// GoodsReceipt records a delivery against a purchase order.
type GoodsReceipt struct {
	data.BaseModel
	PurchaseOrderID string     `gorm:"type:varchar(50);index:idx_gr_po_id"`
	PropertyID      string     `gorm:"type:varchar(50);index:idx_gr_property_id"`
	ReceivedBy      string     `gorm:"type:varchar(50)"`
	ReceivedAt      *time.Time
	Status          int32      `gorm:"default:1"`
	Notes           string     `gorm:"type:text"`
	IdempotencyKey  string     `gorm:"type:varchar(255);uniqueIndex"`

	Lines         []*GoodsReceiptLine `gorm:"foreignKey:GoodsReceiptID"`
	PurchaseOrder *PurchaseOrder      `gorm:"foreignKey:PurchaseOrderID"`
}

func (gr *GoodsReceipt) ToAPI() *procurementv1.GoodsReceipt {
	var lines []*procurementv1.GoodsReceiptLine
	for _, l := range gr.Lines {
		lines = append(lines, l.ToAPI())
	}

	var receivedAt *timestamppb.Timestamp
	if gr.ReceivedAt != nil {
		receivedAt = timestamppb.New(*gr.ReceivedAt)
	}

	return &procurementv1.GoodsReceipt{
		Id:              gr.ID,
		PurchaseOrderId: gr.PurchaseOrderID,
		PropertyId:      gr.PropertyID,
		ReceivedBy:      gr.ReceivedBy,
		ReceivedAt:      receivedAt,
		Status:          procurementv1.GoodsReceiptStatus(gr.Status),
		Notes:           gr.Notes,
		Lines:           lines,
		CreatedAt:       timestamppb.New(gr.CreatedAt),
	}
}

// GoodsReceiptLine represents a line item in a goods receipt.
type GoodsReceiptLine struct {
	data.BaseModel
	GoodsReceiptID      string     `gorm:"type:varchar(50);index:idx_grl_gr_id"`
	PurchaseOrderLineID string     `gorm:"type:varchar(50)"`
	InventoryItemID     string     `gorm:"type:varchar(50)"`
	ReceivedQuantity    float64
	AcceptedQuantity    float64
	RejectedQuantity    float64
	RejectionReason     string     `gorm:"type:text"`
	LotNumber           string     `gorm:"type:varchar(100)"`
	ExpiryDate          *time.Time
	Unit                string     `gorm:"type:varchar(50)"`

	GoodsReceipt      *GoodsReceipt      `gorm:"foreignKey:GoodsReceiptID"`
	PurchaseOrderLine *PurchaseOrderLine `gorm:"foreignKey:PurchaseOrderLineID"`
}

func (grl *GoodsReceiptLine) ToAPI() *procurementv1.GoodsReceiptLine {
	var expiryDate *timestamppb.Timestamp
	if grl.ExpiryDate != nil {
		expiryDate = timestamppb.New(*grl.ExpiryDate)
	}

	return &procurementv1.GoodsReceiptLine{
		Id:                  grl.ID,
		GoodsReceiptId:      grl.GoodsReceiptID,
		PurchaseOrderLineId: grl.PurchaseOrderLineID,
		InventoryItemId:     grl.InventoryItemID,
		ReceivedQuantity:    grl.ReceivedQuantity,
		AcceptedQuantity:    grl.AcceptedQuantity,
		RejectedQuantity:    grl.RejectedQuantity,
		RejectionReason:     grl.RejectionReason,
		LotNumber:           grl.LotNumber,
		ExpiryDate:          expiryDate,
		Unit:                grl.Unit,
	}
}

// MoneyToProto converts currency fields to the common Money proto message.
func MoneyToProto(currencyCode string, units int64, nanos int32) *commonv1.Money {
	if currencyCode == "" {
		return nil
	}
	return &commonv1.Money{
		CurrencyCode: currencyCode,
		Units:        units,
		Nanos:        nanos,
	}
}

// MoneyFromProto extracts currency fields from the common Money proto message.
func MoneyFromProto(m *commonv1.Money) (string, int64, int32) {
	if m == nil {
		return "", 0, 0
	}
	return m.GetCurrencyCode(), m.GetUnits(), m.GetNanos()
}
```

- [ ] **Step 3: Verify it compiles**

```bash
go build ./apps/procurement/service/models/
```

- [ ] **Step 4: Commit**

```bash
git add apps/procurement/service/models/
git commit -m "feat(procurement): add domain models"
```

---

## Task 3: Repository Interfaces and Implementations

**Files:**
- Create: `apps/procurement/service/repository/interfaces.go`
- Create: `apps/procurement/service/repository/suppliers.go`
- Create: `apps/procurement/service/repository/purchase_orders.go`
- Create: `apps/procurement/service/repository/goods_receipts.go`
- Create: `apps/procurement/service/repository/migrate.go`

- [ ] **Step 1: Write repository interfaces**

Create `apps/procurement/service/repository/interfaces.go`:

```go
package repository

import (
	"context"

	"github.com/pitabwire/frame/datastore"

	"github.com/antinvestor/service-commerce/apps/procurement/service/models"
)

type SupplierRepository interface {
	datastore.BaseRepository[*models.Supplier]
	ListByStatus(ctx context.Context, status int32, limit, offset int) ([]*models.Supplier, error)
	ListByType(ctx context.Context, supplierType int32, limit, offset int) ([]*models.Supplier, error)
}

type SupplierItemRepository interface {
	datastore.BaseRepository[*models.SupplierItem]
	ListBySupplierID(ctx context.Context, supplierID string, limit, offset int) ([]*models.SupplierItem, error)
	ListByInventoryItemID(ctx context.Context, itemID string) ([]*models.SupplierItem, error)
	GetBySupplierAndItem(ctx context.Context, supplierID, inventoryItemID string) (*models.SupplierItem, error)
}

type PurchaseOrderRepository interface {
	datastore.BaseRepository[*models.PurchaseOrder]
	GetWithLines(ctx context.Context, id string) (*models.PurchaseOrder, error)
	GetByIdempotencyKey(ctx context.Context, key string) (*models.PurchaseOrder, error)
	ListByPropertyID(ctx context.Context, propertyID string, limit, offset int) ([]*models.PurchaseOrder, error)
	ListBySupplierID(ctx context.Context, supplierID string, limit, offset int) ([]*models.PurchaseOrder, error)
	ListByStatus(ctx context.Context, status int32, limit, offset int) ([]*models.PurchaseOrder, error)
}

type PurchaseOrderLineRepository interface {
	datastore.BaseRepository[*models.PurchaseOrderLine]
	ListByPurchaseOrderID(ctx context.Context, poID string) ([]*models.PurchaseOrderLine, error)
}

type GoodsReceiptRepository interface {
	datastore.BaseRepository[*models.GoodsReceipt]
	GetWithLines(ctx context.Context, id string) (*models.GoodsReceipt, error)
	GetByIdempotencyKey(ctx context.Context, key string) (*models.GoodsReceipt, error)
	ListByPurchaseOrderID(ctx context.Context, poID string) ([]*models.GoodsReceipt, error)
	ListByPropertyID(ctx context.Context, propertyID string, limit, offset int) ([]*models.GoodsReceipt, error)
}

type GoodsReceiptLineRepository interface {
	datastore.BaseRepository[*models.GoodsReceiptLine]
	ListByGoodsReceiptID(ctx context.Context, grID string) ([]*models.GoodsReceiptLine, error)
	ListByPurchaseOrderLineID(ctx context.Context, polID string) ([]*models.GoodsReceiptLine, error)
}
```

- [ ] **Step 2: Write supplier repository implementation**

Create `apps/procurement/service/repository/suppliers.go`:

```go
package repository

import (
	"context"

	"github.com/pitabwire/frame/datastore"
	"github.com/pitabwire/frame/datastore/pool"
	"github.com/pitabwire/frame/workerpool"

	"github.com/antinvestor/service-commerce/apps/procurement/service/models"
)

type supplierRepository struct {
	datastore.BaseRepository[*models.Supplier]
}

func NewSupplierRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) SupplierRepository {
	return &supplierRepository{
		BaseRepository: datastore.NewBaseRepository[*models.Supplier](
			ctx, dbPool, workMan, func() *models.Supplier { return &models.Supplier{} },
		),
	}
}

func (r *supplierRepository) ListByStatus(ctx context.Context, status int32, limit, offset int) ([]*models.Supplier, error) {
	var suppliers []*models.Supplier
	err := r.Pool().DB(ctx, true).Where("status = ?", status).Limit(limit).Offset(offset).Find(&suppliers).Error
	return suppliers, err
}

func (r *supplierRepository) ListByType(ctx context.Context, supplierType int32, limit, offset int) ([]*models.Supplier, error) {
	var suppliers []*models.Supplier
	err := r.Pool().DB(ctx, true).Where("supplier_type = ?", supplierType).Limit(limit).Offset(offset).Find(&suppliers).Error
	return suppliers, err
}

type supplierItemRepository struct {
	datastore.BaseRepository[*models.SupplierItem]
}

func NewSupplierItemRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) SupplierItemRepository {
	return &supplierItemRepository{
		BaseRepository: datastore.NewBaseRepository[*models.SupplierItem](
			ctx, dbPool, workMan, func() *models.SupplierItem { return &models.SupplierItem{} },
		),
	}
}

func (r *supplierItemRepository) ListBySupplierID(ctx context.Context, supplierID string, limit, offset int) ([]*models.SupplierItem, error) {
	var items []*models.SupplierItem
	err := r.Pool().DB(ctx, true).Where("supplier_id = ?", supplierID).Limit(limit).Offset(offset).Find(&items).Error
	return items, err
}

func (r *supplierItemRepository) ListByInventoryItemID(ctx context.Context, itemID string) ([]*models.SupplierItem, error) {
	var items []*models.SupplierItem
	err := r.Pool().DB(ctx, true).Where("inventory_item_id = ?", itemID).Find(&items).Error
	return items, err
}

func (r *supplierItemRepository) GetBySupplierAndItem(ctx context.Context, supplierID, inventoryItemID string) (*models.SupplierItem, error) {
	item := &models.SupplierItem{}
	err := r.Pool().DB(ctx, true).Where("supplier_id = ? AND inventory_item_id = ?", supplierID, inventoryItemID).First(item).Error
	return item, err
}
```

- [ ] **Step 3: Write purchase order repository implementation**

Create `apps/procurement/service/repository/purchase_orders.go`:

```go
package repository

import (
	"context"

	"github.com/pitabwire/frame/datastore"
	"github.com/pitabwire/frame/datastore/pool"
	"github.com/pitabwire/frame/workerpool"

	"github.com/antinvestor/service-commerce/apps/procurement/service/models"
)

type purchaseOrderRepository struct {
	datastore.BaseRepository[*models.PurchaseOrder]
}

func NewPurchaseOrderRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) PurchaseOrderRepository {
	return &purchaseOrderRepository{
		BaseRepository: datastore.NewBaseRepository[*models.PurchaseOrder](
			ctx, dbPool, workMan, func() *models.PurchaseOrder { return &models.PurchaseOrder{} },
		),
	}
}

func (r *purchaseOrderRepository) GetWithLines(ctx context.Context, id string) (*models.PurchaseOrder, error) {
	po := &models.PurchaseOrder{}
	err := r.Pool().DB(ctx, true).Preload("Lines").Where("id = ?", id).First(po).Error
	return po, err
}

func (r *purchaseOrderRepository) GetByIdempotencyKey(ctx context.Context, key string) (*models.PurchaseOrder, error) {
	po := &models.PurchaseOrder{}
	err := r.Pool().DB(ctx, true).Preload("Lines").Where("idempotency_key = ?", key).First(po).Error
	return po, err
}

func (r *purchaseOrderRepository) ListByPropertyID(ctx context.Context, propertyID string, limit, offset int) ([]*models.PurchaseOrder, error) {
	var orders []*models.PurchaseOrder
	err := r.Pool().DB(ctx, true).Where("property_id = ?", propertyID).
		Order("created_at DESC").Limit(limit).Offset(offset).Find(&orders).Error
	return orders, err
}

func (r *purchaseOrderRepository) ListBySupplierID(ctx context.Context, supplierID string, limit, offset int) ([]*models.PurchaseOrder, error) {
	var orders []*models.PurchaseOrder
	err := r.Pool().DB(ctx, true).Where("supplier_id = ?", supplierID).
		Order("created_at DESC").Limit(limit).Offset(offset).Find(&orders).Error
	return orders, err
}

func (r *purchaseOrderRepository) ListByStatus(ctx context.Context, status int32, limit, offset int) ([]*models.PurchaseOrder, error) {
	var orders []*models.PurchaseOrder
	err := r.Pool().DB(ctx, true).Where("status = ?", status).
		Order("created_at DESC").Limit(limit).Offset(offset).Find(&orders).Error
	return orders, err
}

type purchaseOrderLineRepository struct {
	datastore.BaseRepository[*models.PurchaseOrderLine]
}

func NewPurchaseOrderLineRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) PurchaseOrderLineRepository {
	return &purchaseOrderLineRepository{
		BaseRepository: datastore.NewBaseRepository[*models.PurchaseOrderLine](
			ctx, dbPool, workMan, func() *models.PurchaseOrderLine { return &models.PurchaseOrderLine{} },
		),
	}
}

func (r *purchaseOrderLineRepository) ListByPurchaseOrderID(ctx context.Context, poID string) ([]*models.PurchaseOrderLine, error) {
	var lines []*models.PurchaseOrderLine
	err := r.Pool().DB(ctx, true).Where("purchase_order_id = ?", poID).Find(&lines).Error
	return lines, err
}
```

- [ ] **Step 4: Write goods receipt repository implementation**

Create `apps/procurement/service/repository/goods_receipts.go`:

```go
package repository

import (
	"context"

	"github.com/pitabwire/frame/datastore"
	"github.com/pitabwire/frame/datastore/pool"
	"github.com/pitabwire/frame/workerpool"

	"github.com/antinvestor/service-commerce/apps/procurement/service/models"
)

type goodsReceiptRepository struct {
	datastore.BaseRepository[*models.GoodsReceipt]
}

func NewGoodsReceiptRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) GoodsReceiptRepository {
	return &goodsReceiptRepository{
		BaseRepository: datastore.NewBaseRepository[*models.GoodsReceipt](
			ctx, dbPool, workMan, func() *models.GoodsReceipt { return &models.GoodsReceipt{} },
		),
	}
}

func (r *goodsReceiptRepository) GetWithLines(ctx context.Context, id string) (*models.GoodsReceipt, error) {
	gr := &models.GoodsReceipt{}
	err := r.Pool().DB(ctx, true).Preload("Lines").Where("id = ?", id).First(gr).Error
	return gr, err
}

func (r *goodsReceiptRepository) GetByIdempotencyKey(ctx context.Context, key string) (*models.GoodsReceipt, error) {
	gr := &models.GoodsReceipt{}
	err := r.Pool().DB(ctx, true).Preload("Lines").Where("idempotency_key = ?", key).First(gr).Error
	return gr, err
}

func (r *goodsReceiptRepository) ListByPurchaseOrderID(ctx context.Context, poID string) ([]*models.GoodsReceipt, error) {
	var receipts []*models.GoodsReceipt
	err := r.Pool().DB(ctx, true).Where("purchase_order_id = ?", poID).Order("created_at DESC").Find(&receipts).Error
	return receipts, err
}

func (r *goodsReceiptRepository) ListByPropertyID(ctx context.Context, propertyID string, limit, offset int) ([]*models.GoodsReceipt, error) {
	var receipts []*models.GoodsReceipt
	err := r.Pool().DB(ctx, true).Where("property_id = ?", propertyID).
		Order("created_at DESC").Limit(limit).Offset(offset).Find(&receipts).Error
	return receipts, err
}

type goodsReceiptLineRepository struct {
	datastore.BaseRepository[*models.GoodsReceiptLine]
}

func NewGoodsReceiptLineRepository(ctx context.Context, dbPool pool.Pool, workMan workerpool.Manager) GoodsReceiptLineRepository {
	return &goodsReceiptLineRepository{
		BaseRepository: datastore.NewBaseRepository[*models.GoodsReceiptLine](
			ctx, dbPool, workMan, func() *models.GoodsReceiptLine { return &models.GoodsReceiptLine{} },
		),
	}
}

func (r *goodsReceiptLineRepository) ListByGoodsReceiptID(ctx context.Context, grID string) ([]*models.GoodsReceiptLine, error) {
	var lines []*models.GoodsReceiptLine
	err := r.Pool().DB(ctx, true).Where("goods_receipt_id = ?", grID).Find(&lines).Error
	return lines, err
}

func (r *goodsReceiptLineRepository) ListByPurchaseOrderLineID(ctx context.Context, polID string) ([]*models.GoodsReceiptLine, error) {
	var lines []*models.GoodsReceiptLine
	err := r.Pool().DB(ctx, true).Where("purchase_order_line_id = ?", polID).Find(&lines).Error
	return lines, err
}
```

- [ ] **Step 5: Write migration setup**

Create `apps/procurement/service/repository/migrate.go`:

```go
package repository

import (
	"context"

	"github.com/pitabwire/frame/datastore"

	"github.com/antinvestor/service-commerce/apps/procurement/service/models"
)

func Migrate(ctx context.Context, dbManager datastore.Manager, migrationPath string) error {
	dbPool := dbManager.GetPool(ctx, datastore.DefaultMigrationPoolName)

	return dbManager.Migrate(
		ctx,
		dbPool,
		migrationPath,
		&models.Supplier{},
		&models.SupplierItem{},
		&models.PurchaseOrder{},
		&models.PurchaseOrderLine{},
		&models.GoodsReceipt{},
		&models.GoodsReceiptLine{},
	)
}
```

Create empty migration file `apps/procurement/migrations/0001/20260527_initial.sql`:

```sql
-- GORM auto-migration handles schema creation.
-- Add custom indexes here after initial migration.
```

- [ ] **Step 6: Verify compilation**

```bash
go build ./apps/procurement/service/repository/
```

- [ ] **Step 7: Commit**

```bash
git add apps/procurement/service/repository/ apps/procurement/migrations/
git commit -m "feat(procurement): add repository interfaces and implementations"
```

---

## Task 4: Business Logic — Suppliers

**Files:**
- Create: `apps/procurement/service/business/suppliers.go`

- [ ] **Step 1: Write supplier business logic**

Create `apps/procurement/service/business/suppliers.go`:

```go
package business

import (
	"context"
	"errors"
	"strings"

	procurementv1 "buf.build/gen/go/antinvestor/procurement/protocolbuffers/go/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/data"

	"github.com/antinvestor/service-commerce/apps/procurement/service/models"
	"github.com/antinvestor/service-commerce/apps/procurement/service/repository"
)

type SupplierBusiness interface {
	SaveSupplier(ctx context.Context, req *procurementv1.SupplierSaveRequest) (*procurementv1.Supplier, error)
	GetSupplier(ctx context.Context, id string) (*procurementv1.Supplier, error)
	SearchSuppliers(ctx context.Context, req *procurementv1.SupplierSearchRequest) ([]*procurementv1.Supplier, error)
	SaveSupplierItem(ctx context.Context, req *procurementv1.SupplierItemSaveRequest) (*procurementv1.SupplierItem, error)
	SearchSupplierItems(ctx context.Context, req *procurementv1.SupplierItemSearchRequest) ([]*procurementv1.SupplierItem, error)
}

func NewSupplierBusiness(
	_ context.Context,
	supplierRepo repository.SupplierRepository,
	supplierItemRepo repository.SupplierItemRepository,
) SupplierBusiness {
	return &supplierBusiness{
		supplierRepo:     supplierRepo,
		supplierItemRepo: supplierItemRepo,
	}
}

type supplierBusiness struct {
	supplierRepo     repository.SupplierRepository
	supplierItemRepo repository.SupplierItemRepository
}

func (sb *supplierBusiness) SaveSupplier(ctx context.Context, req *procurementv1.SupplierSaveRequest) (*procurementv1.Supplier, error) {
	name := strings.TrimSpace(req.GetName())
	if name == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("supplier name is required"))
	}

	if req.GetId() != "" {
		existing, err := sb.supplierRepo.GetByID(ctx, req.GetId())
		if err != nil {
			return nil, data.ErrorConvertToAPI(err)
		}
		existing.ProfileID = req.GetProfileId()
		existing.Name = name
		existing.SupplierType = int32(req.GetSupplierType())
		existing.Status = int32(req.GetStatus())
		existing.PaymentTermsDays = req.GetPaymentTermsDays()
		existing.Currency = req.GetCurrency()
		existing.LeadTimeDays = req.GetLeadTimeDays()
		existing.Rating = int32(req.GetRating())
		existing.Notes = req.GetNotes()

		if err := sb.supplierRepo.Update(ctx, existing); err != nil {
			return nil, data.ErrorConvertToAPI(err)
		}
		return existing.ToAPI(), nil
	}

	supplier := &models.Supplier{
		ProfileID:        req.GetProfileId(),
		Name:             name,
		SupplierType:     int32(req.GetSupplierType()),
		Status:           int32(procurementv1.SupplierStatus_SUPPLIER_STATUS_ACTIVE),
		PaymentTermsDays: req.GetPaymentTermsDays(),
		Currency:         req.GetCurrency(),
		LeadTimeDays:     req.GetLeadTimeDays(),
		Rating:           int32(procurementv1.SupplierRating_SUPPLIER_RATING_UNRATED),
		Notes:            req.GetNotes(),
	}

	if err := sb.supplierRepo.Create(ctx, supplier); err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	return supplier.ToAPI(), nil
}

func (sb *supplierBusiness) GetSupplier(ctx context.Context, id string) (*procurementv1.Supplier, error) {
	supplier, err := sb.supplierRepo.GetByID(ctx, id)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	return supplier.ToAPI(), nil
}

func (sb *supplierBusiness) SearchSuppliers(ctx context.Context, req *procurementv1.SupplierSearchRequest) ([]*procurementv1.Supplier, error) {
	limit, offset := 20, 0
	if req.GetSearch() != nil {
		if req.GetSearch().GetCount() > 0 {
			limit = int(req.GetSearch().GetCount())
		}
	}

	var suppliers []*models.Supplier
	var err error

	if req.GetSupplierType() != procurementv1.SupplierType_SUPPLIER_TYPE_UNSPECIFIED {
		suppliers, err = sb.supplierRepo.ListByType(ctx, int32(req.GetSupplierType()), limit, offset)
	} else if req.GetStatus() != procurementv1.SupplierStatus_SUPPLIER_STATUS_UNSPECIFIED {
		suppliers, err = sb.supplierRepo.ListByStatus(ctx, int32(req.GetStatus()), limit, offset)
	} else {
		suppliers, err = sb.supplierRepo.ListByStatus(ctx, int32(procurementv1.SupplierStatus_SUPPLIER_STATUS_ACTIVE), limit, offset)
	}

	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	result := make([]*procurementv1.Supplier, 0, len(suppliers))
	for _, s := range suppliers {
		result = append(result, s.ToAPI())
	}
	return result, nil
}

func (sb *supplierBusiness) SaveSupplierItem(ctx context.Context, req *procurementv1.SupplierItemSaveRequest) (*procurementv1.SupplierItem, error) {
	if req.GetSupplierId() == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("supplier_id is required"))
	}
	if req.GetInventoryItemId() == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("inventory_item_id is required"))
	}

	currencyCode, priceUnits, priceNanos := models.MoneyFromProto(req.GetUnitPrice())

	if req.GetId() != "" {
		existing, err := sb.supplierItemRepo.GetByID(ctx, req.GetId())
		if err != nil {
			return nil, data.ErrorConvertToAPI(err)
		}
		existing.SupplierSKU = req.GetSupplierSku()
		existing.CurrencyCode = currencyCode
		existing.PriceUnits = priceUnits
		existing.PriceNanos = priceNanos
		existing.MinOrderQuantity = req.GetMinOrderQuantity()
		existing.Unit = req.GetUnit()
		existing.LeadTimeDays = req.GetLeadTimeDays()
		existing.Status = int32(req.GetStatus())

		if err := sb.supplierItemRepo.Update(ctx, existing); err != nil {
			return nil, data.ErrorConvertToAPI(err)
		}
		return existing.ToAPI(), nil
	}

	item := &models.SupplierItem{
		SupplierID:       req.GetSupplierId(),
		InventoryItemID:  req.GetInventoryItemId(),
		SupplierSKU:      req.GetSupplierSku(),
		CurrencyCode:     currencyCode,
		PriceUnits:       priceUnits,
		PriceNanos:       priceNanos,
		MinOrderQuantity: req.GetMinOrderQuantity(),
		Unit:             req.GetUnit(),
		LeadTimeDays:     req.GetLeadTimeDays(),
		Status:           int32(procurementv1.SupplierItemStatus_SUPPLIER_ITEM_STATUS_ACTIVE),
	}

	if err := sb.supplierItemRepo.Create(ctx, item); err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	return item.ToAPI(), nil
}

func (sb *supplierBusiness) SearchSupplierItems(ctx context.Context, req *procurementv1.SupplierItemSearchRequest) ([]*procurementv1.SupplierItem, error) {
	limit, offset := 20, 0
	if req.GetSearch() != nil {
		if req.GetSearch().GetCount() > 0 {
			limit = int(req.GetSearch().GetCount())
		}
	}

	var items []*models.SupplierItem
	var err error

	if req.GetSupplierId() != "" {
		items, err = sb.supplierItemRepo.ListBySupplierID(ctx, req.GetSupplierId(), limit, offset)
	} else if req.GetInventoryItemId() != "" {
		items, err = sb.supplierItemRepo.ListByInventoryItemID(ctx, req.GetInventoryItemId())
	} else {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("supplier_id or inventory_item_id required"))
	}

	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	result := make([]*procurementv1.SupplierItem, 0, len(items))
	for _, item := range items {
		result = append(result, item.ToAPI())
	}
	return result, nil
}
```

- [ ] **Step 2: Verify compilation**

```bash
go build ./apps/procurement/service/business/
```

- [ ] **Step 3: Commit**

```bash
git add apps/procurement/service/business/suppliers.go
git commit -m "feat(procurement): add supplier business logic"
```

---

## Task 5: Business Logic — Purchase Orders

**Files:**
- Create: `apps/procurement/service/business/purchase_orders.go`

- [ ] **Step 1: Write purchase order business logic**

Create `apps/procurement/service/business/purchase_orders.go`:

```go
package business

import (
	"context"
	"errors"
	"fmt"
	"time"

	procurementv1 "buf.build/gen/go/antinvestor/procurement/protocolbuffers/go/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/data"
	"github.com/pitabwire/frame/security"

	"github.com/antinvestor/service-commerce/apps/procurement/service/models"
	"github.com/antinvestor/service-commerce/apps/procurement/service/repository"
)

type PurchaseOrderBusiness interface {
	CreatePurchaseOrder(ctx context.Context, req *procurementv1.PurchaseOrderCreateRequest) (*procurementv1.PurchaseOrder, error)
	GetPurchaseOrder(ctx context.Context, id string) (*procurementv1.PurchaseOrder, error)
	SearchPurchaseOrders(ctx context.Context, req *procurementv1.PurchaseOrderSearchRequest) ([]*procurementv1.PurchaseOrder, error)
	SubmitPurchaseOrder(ctx context.Context, id string) (*procurementv1.PurchaseOrder, error)
	CancelPurchaseOrder(ctx context.Context, id string, reason string) (*procurementv1.PurchaseOrder, error)
}

func NewPurchaseOrderBusiness(
	_ context.Context,
	poRepo repository.PurchaseOrderRepository,
	polRepo repository.PurchaseOrderLineRepository,
	supplierItemRepo repository.SupplierItemRepository,
) PurchaseOrderBusiness {
	return &purchaseOrderBusiness{
		poRepo:           poRepo,
		polRepo:          polRepo,
		supplierItemRepo: supplierItemRepo,
	}
}

type purchaseOrderBusiness struct {
	poRepo           repository.PurchaseOrderRepository
	polRepo          repository.PurchaseOrderLineRepository
	supplierItemRepo repository.SupplierItemRepository
}

func (pb *purchaseOrderBusiness) CreatePurchaseOrder(
	ctx context.Context,
	req *procurementv1.PurchaseOrderCreateRequest,
) (*procurementv1.PurchaseOrder, error) {
	if req.GetPropertyId() == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("property_id is required"))
	}
	if req.GetSupplierId() == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("supplier_id is required"))
	}
	if len(req.GetLines()) == 0 {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("at least one line is required"))
	}

	if req.GetIdempotencyKey() != "" {
		existing, err := pb.poRepo.GetByIdempotencyKey(ctx, req.GetIdempotencyKey())
		if err == nil && existing != nil {
			return existing.ToAPI(), nil
		}
	}

	var expectedDate *time.Time
	if req.GetExpectedDeliveryDate() != nil {
		t := req.GetExpectedDeliveryDate().AsTime()
		expectedDate = &t
	}

	po := &models.PurchaseOrder{
		PropertyID:           req.GetPropertyId(),
		SupplierID:           req.GetSupplierId(),
		OrderNumber:          generateOrderNumber(),
		Status:               int32(procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_DRAFT),
		ExpectedDeliveryDate: expectedDate,
		Notes:                req.GetNotes(),
		PlanID:               req.GetPlanId(),
		IdempotencyKey:       req.GetIdempotencyKey(),
	}

	if err := pb.poRepo.Create(ctx, po); err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	var totalUnits int64
	var totalNanos int32
	var currency string

	for _, lineReq := range req.GetLines() {
		var currencyCode string
		var priceUnits int64
		var priceNanos int32

		if lineReq.GetSupplierItemId() != "" {
			si, err := pb.supplierItemRepo.GetByID(ctx, lineReq.GetSupplierItemId())
			if err != nil {
				return nil, connect.NewError(connect.CodeNotFound,
					fmt.Errorf("supplier item %s not found", lineReq.GetSupplierItemId()))
			}
			currencyCode = si.CurrencyCode
			priceUnits = si.PriceUnits
			priceNanos = si.PriceNanos
			currency = currencyCode
		}

		line := &models.PurchaseOrderLine{
			PurchaseOrderID: po.ID,
			SupplierItemID:  lineReq.GetSupplierItemId(),
			InventoryItemID: lineReq.GetInventoryItemId(),
			OrderedQuantity: lineReq.GetOrderedQuantity(),
			ReceivedQuantity: 0,
			CurrencyCode:    currencyCode,
			PriceUnits:      priceUnits,
			PriceNanos:      priceNanos,
			Unit:            lineReq.GetUnit(),
			Status:          int32(procurementv1.PurchaseOrderLineStatus_PURCHASE_ORDER_LINE_STATUS_PENDING),
		}

		if err := pb.polRepo.Create(ctx, line); err != nil {
			return nil, data.ErrorConvertToAPI(err)
		}

		lineTotal := int64(lineReq.GetOrderedQuantity()) * priceUnits
		totalUnits += lineTotal
	}

	po.TotalCurrencyCode = currency
	po.TotalUnits = totalUnits
	po.TotalNanos = totalNanos
	if err := pb.poRepo.Update(ctx, po); err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	result, err := pb.poRepo.GetWithLines(ctx, po.ID)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	return result.ToAPI(), nil
}

func (pb *purchaseOrderBusiness) GetPurchaseOrder(ctx context.Context, id string) (*procurementv1.PurchaseOrder, error) {
	po, err := pb.poRepo.GetWithLines(ctx, id)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	return po.ToAPI(), nil
}

func (pb *purchaseOrderBusiness) SearchPurchaseOrders(
	ctx context.Context,
	req *procurementv1.PurchaseOrderSearchRequest,
) ([]*procurementv1.PurchaseOrder, error) {
	limit, offset := 20, 0
	if req.GetSearch() != nil && req.GetSearch().GetCount() > 0 {
		limit = int(req.GetSearch().GetCount())
	}

	var orders []*models.PurchaseOrder
	var err error

	if req.GetPropertyId() != "" {
		orders, err = pb.poRepo.ListByPropertyID(ctx, req.GetPropertyId(), limit, offset)
	} else if req.GetSupplierId() != "" {
		orders, err = pb.poRepo.ListBySupplierID(ctx, req.GetSupplierId(), limit, offset)
	} else if req.GetStatus() != procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_UNSPECIFIED {
		orders, err = pb.poRepo.ListByStatus(ctx, int32(req.GetStatus()), limit, offset)
	} else {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("property_id, supplier_id, or status filter required"))
	}

	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	result := make([]*procurementv1.PurchaseOrder, 0, len(orders))
	for _, o := range orders {
		result = append(result, o.ToAPI())
	}
	return result, nil
}

func (pb *purchaseOrderBusiness) SubmitPurchaseOrder(ctx context.Context, id string) (*procurementv1.PurchaseOrder, error) {
	po, err := pb.poRepo.GetWithLines(ctx, id)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	if po.Status != int32(procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_DRAFT) {
		return nil, connect.NewError(connect.CodeFailedPrecondition,
			fmt.Errorf("purchase order is %s, expected DRAFT", procurementv1.PurchaseOrderStatus(po.Status).String()))
	}

	now := time.Now()
	po.Status = int32(procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_SUBMITTED)
	po.SubmittedAt = &now

	claims := security.ClaimsFromContext(ctx)
	if claims != nil {
		if sub, subErr := claims.GetSubject(); subErr == nil {
			po.SubmittedBy = sub
		}
	}

	if err := pb.poRepo.Update(ctx, po); err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	return po.ToAPI(), nil
}

func (pb *purchaseOrderBusiness) CancelPurchaseOrder(ctx context.Context, id string, reason string) (*procurementv1.PurchaseOrder, error) {
	po, err := pb.poRepo.GetWithLines(ctx, id)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	if po.Status == int32(procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_RECEIVED) {
		return nil, connect.NewError(connect.CodeFailedPrecondition, errors.New("cannot cancel a fully received purchase order"))
	}

	po.Status = int32(procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_CANCELLED)
	for _, line := range po.Lines {
		line.Status = int32(procurementv1.PurchaseOrderLineStatus_PURCHASE_ORDER_LINE_STATUS_CANCELLED)
		if err := pb.polRepo.Update(ctx, line); err != nil {
			return nil, data.ErrorConvertToAPI(err)
		}
	}

	if err := pb.poRepo.Update(ctx, po); err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	return po.ToAPI(), nil
}

func generateOrderNumber() string {
	return fmt.Sprintf("PO-%d", time.Now().UnixMilli())
}
```

- [ ] **Step 2: Verify compilation**

```bash
go build ./apps/procurement/service/business/
```

- [ ] **Step 3: Commit**

```bash
git add apps/procurement/service/business/purchase_orders.go
git commit -m "feat(procurement): add purchase order business logic"
```

---

## Task 6: Business Logic — Goods Receipts

**Files:**
- Create: `apps/procurement/service/business/goods_receipts.go`

- [ ] **Step 1: Write goods receipt business logic**

Create `apps/procurement/service/business/goods_receipts.go`:

```go
package business

import (
	"context"
	"errors"
	"fmt"
	"time"

	procurementv1 "buf.build/gen/go/antinvestor/procurement/protocolbuffers/go/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/data"
	"github.com/pitabwire/frame/security"

	"github.com/antinvestor/service-commerce/apps/procurement/service/models"
	"github.com/antinvestor/service-commerce/apps/procurement/service/repository"
)

type GoodsReceiptBusiness interface {
	CreateGoodsReceipt(ctx context.Context, req *procurementv1.GoodsReceiptCreateRequest) (*procurementv1.GoodsReceipt, error)
	GetGoodsReceipt(ctx context.Context, id string) (*procurementv1.GoodsReceipt, error)
	SearchGoodsReceipts(ctx context.Context, req *procurementv1.GoodsReceiptSearchRequest) ([]*procurementv1.GoodsReceipt, error)
}

func NewGoodsReceiptBusiness(
	_ context.Context,
	grRepo repository.GoodsReceiptRepository,
	grlRepo repository.GoodsReceiptLineRepository,
	poRepo repository.PurchaseOrderRepository,
	polRepo repository.PurchaseOrderLineRepository,
) GoodsReceiptBusiness {
	return &goodsReceiptBusiness{
		grRepo:  grRepo,
		grlRepo: grlRepo,
		poRepo:  poRepo,
		polRepo: polRepo,
	}
}

type goodsReceiptBusiness struct {
	grRepo  repository.GoodsReceiptRepository
	grlRepo repository.GoodsReceiptLineRepository
	poRepo  repository.PurchaseOrderRepository
	polRepo repository.PurchaseOrderLineRepository
}

func (gb *goodsReceiptBusiness) CreateGoodsReceipt(
	ctx context.Context,
	req *procurementv1.GoodsReceiptCreateRequest,
) (*procurementv1.GoodsReceipt, error) {
	if req.GetPurchaseOrderId() == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("purchase_order_id is required"))
	}
	if len(req.GetLines()) == 0 {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("at least one line is required"))
	}

	if req.GetIdempotencyKey() != "" {
		existing, err := gb.grRepo.GetByIdempotencyKey(ctx, req.GetIdempotencyKey())
		if err == nil && existing != nil {
			return existing.ToAPI(), nil
		}
	}

	po, err := gb.poRepo.GetWithLines(ctx, req.GetPurchaseOrderId())
	if err != nil {
		return nil, connect.NewError(connect.CodeNotFound, fmt.Errorf("purchase order %s not found", req.GetPurchaseOrderId()))
	}

	if po.Status == int32(procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_CANCELLED) {
		return nil, connect.NewError(connect.CodeFailedPrecondition, errors.New("cannot receive against a cancelled purchase order"))
	}
	if po.Status == int32(procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_RECEIVED) {
		return nil, connect.NewError(connect.CodeFailedPrecondition, errors.New("purchase order is already fully received"))
	}

	receivedBy := ""
	claims := security.ClaimsFromContext(ctx)
	if claims != nil {
		if sub, subErr := claims.GetSubject(); subErr == nil {
			receivedBy = sub
		}
	}

	now := time.Now()
	gr := &models.GoodsReceipt{
		PurchaseOrderID: req.GetPurchaseOrderId(),
		PropertyID:      req.GetPropertyId(),
		ReceivedBy:      receivedBy,
		ReceivedAt:      &now,
		Status:          int32(procurementv1.GoodsReceiptStatus_GOODS_RECEIPT_STATUS_PENDING_INSPECTION),
		Notes:           req.GetNotes(),
		IdempotencyKey:  req.GetIdempotencyKey(),
	}

	if err := gb.grRepo.Create(ctx, gr); err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	polMap := make(map[string]*models.PurchaseOrderLine, len(po.Lines))
	for _, line := range po.Lines {
		polMap[line.ID] = line
	}

	for _, lineReq := range req.GetLines() {
		pol, ok := polMap[lineReq.GetPurchaseOrderLineId()]
		if !ok {
			return nil, connect.NewError(connect.CodeInvalidArgument,
				fmt.Errorf("purchase order line %s not found on this PO", lineReq.GetPurchaseOrderLineId()))
		}

		remaining := pol.OrderedQuantity - pol.ReceivedQuantity
		if lineReq.GetReceivedQuantity() > remaining {
			return nil, connect.NewError(connect.CodeInvalidArgument,
				fmt.Errorf("received quantity %.2f exceeds remaining %.2f for line %s",
					lineReq.GetReceivedQuantity(), remaining, pol.ID))
		}

		var expiryDate *time.Time
		if lineReq.GetExpiryDate() != nil {
			t := lineReq.GetExpiryDate().AsTime()
			expiryDate = &t
		}

		grl := &models.GoodsReceiptLine{
			GoodsReceiptID:      gr.ID,
			PurchaseOrderLineID: lineReq.GetPurchaseOrderLineId(),
			InventoryItemID:     lineReq.GetInventoryItemId(),
			ReceivedQuantity:    lineReq.GetReceivedQuantity(),
			AcceptedQuantity:    0,
			RejectedQuantity:    0,
			LotNumber:           lineReq.GetLotNumber(),
			ExpiryDate:          expiryDate,
			Unit:                lineReq.GetUnit(),
		}

		if err := gb.grlRepo.Create(ctx, grl); err != nil {
			return nil, data.ErrorConvertToAPI(err)
		}

		pol.ReceivedQuantity += lineReq.GetReceivedQuantity()
		if pol.ReceivedQuantity >= pol.OrderedQuantity {
			pol.Status = int32(procurementv1.PurchaseOrderLineStatus_PURCHASE_ORDER_LINE_STATUS_RECEIVED)
		} else {
			pol.Status = int32(procurementv1.PurchaseOrderLineStatus_PURCHASE_ORDER_LINE_STATUS_PARTIALLY_RECEIVED)
		}
		if err := gb.polRepo.Update(ctx, pol); err != nil {
			return nil, data.ErrorConvertToAPI(err)
		}
	}

	allReceived := true
	anyReceived := false
	for _, line := range po.Lines {
		if line.ReceivedQuantity > 0 {
			anyReceived = true
		}
		if line.ReceivedQuantity < line.OrderedQuantity &&
			line.Status != int32(procurementv1.PurchaseOrderLineStatus_PURCHASE_ORDER_LINE_STATUS_CANCELLED) {
			allReceived = false
		}
	}

	if allReceived {
		po.Status = int32(procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_RECEIVED)
	} else if anyReceived {
		po.Status = int32(procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_PARTIALLY_RECEIVED)
	}
	if err := gb.poRepo.Update(ctx, po); err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	result, err := gb.grRepo.GetWithLines(ctx, gr.ID)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	return result.ToAPI(), nil
}

func (gb *goodsReceiptBusiness) GetGoodsReceipt(ctx context.Context, id string) (*procurementv1.GoodsReceipt, error) {
	gr, err := gb.grRepo.GetWithLines(ctx, id)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	return gr.ToAPI(), nil
}

func (gb *goodsReceiptBusiness) SearchGoodsReceipts(
	ctx context.Context,
	req *procurementv1.GoodsReceiptSearchRequest,
) ([]*procurementv1.GoodsReceipt, error) {
	limit, offset := 20, 0
	if req.GetSearch() != nil && req.GetSearch().GetCount() > 0 {
		limit = int(req.GetSearch().GetCount())
	}

	var receipts []*models.GoodsReceipt
	var err error

	if req.GetPurchaseOrderId() != "" {
		receipts, err = gb.grRepo.ListByPurchaseOrderID(ctx, req.GetPurchaseOrderId())
	} else if req.GetPropertyId() != "" {
		receipts, err = gb.grRepo.ListByPropertyID(ctx, req.GetPropertyId(), limit, offset)
	} else {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("purchase_order_id or property_id required"))
	}

	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	result := make([]*procurementv1.GoodsReceipt, 0, len(receipts))
	for _, r := range receipts {
		result = append(result, r.ToAPI())
	}
	return result, nil
}
```

- [ ] **Step 2: Verify compilation**

```bash
go build ./apps/procurement/service/business/
```

- [ ] **Step 3: Commit**

```bash
git add apps/procurement/service/business/goods_receipts.go
git commit -m "feat(procurement): add goods receipt business logic with PO status transitions"
```

---

## Task 7: Authz Setup

**Files:**
- Create: `apps/procurement/service/authz/constants.go`
- Create: `apps/procurement/service/authz/interfaces.go`
- Create: `apps/procurement/service/authz/middleware.go`

- [ ] **Step 1: Write authz constants**

Create `apps/procurement/service/authz/constants.go`:

```go
package authz

import "slices"

const (
	NamespaceProcurement   = "service_procurement"
	NamespaceTenancyAccess = "tenancy_access"
	NamespaceProfile       = "profile_user"
)

const (
	PermissionSupplierView        = "supplier_view"
	PermissionSupplierManage      = "supplier_manage"
	PermissionPurchaseOrderView   = "purchase_order_view"
	PermissionPurchaseOrderCreate = "purchase_order_create"
	PermissionPurchaseOrderSubmit = "purchase_order_submit"
	PermissionPurchaseOrderCancel = "purchase_order_cancel"
	PermissionGoodsReceiptView    = "goods_receipt_view"
	PermissionGoodsReceiptCreate  = "goods_receipt_create"
)

const (
	RoleOwner    = "owner"
	RoleAdmin    = "admin"
	RoleOperator = "operator"
	RoleViewer   = "viewer"
	RoleService  = "service"
)

func GrantedRelation(permission string) string {
	return "granted_" + permission
}

var RolePermissions = map[string][]string{ //nolint:gochecknoglobals
	RoleOwner: {
		PermissionSupplierView, PermissionSupplierManage,
		PermissionPurchaseOrderView, PermissionPurchaseOrderCreate,
		PermissionPurchaseOrderSubmit, PermissionPurchaseOrderCancel,
		PermissionGoodsReceiptView, PermissionGoodsReceiptCreate,
	},
	RoleAdmin: {
		PermissionSupplierView, PermissionSupplierManage,
		PermissionPurchaseOrderView, PermissionPurchaseOrderCreate,
		PermissionPurchaseOrderSubmit, PermissionPurchaseOrderCancel,
		PermissionGoodsReceiptView, PermissionGoodsReceiptCreate,
	},
	RoleOperator: {
		PermissionSupplierView,
		PermissionPurchaseOrderView, PermissionPurchaseOrderCreate,
		PermissionPurchaseOrderSubmit,
		PermissionGoodsReceiptView, PermissionGoodsReceiptCreate,
	},
	RoleViewer: {
		PermissionSupplierView,
		PermissionPurchaseOrderView,
		PermissionGoodsReceiptView,
	},
	RoleService: {
		PermissionSupplierView, PermissionSupplierManage,
		PermissionPurchaseOrderView, PermissionPurchaseOrderCreate,
		PermissionPurchaseOrderSubmit, PermissionPurchaseOrderCancel,
		PermissionGoodsReceiptView, PermissionGoodsReceiptCreate,
	},
}

func ValidRoles() []string {
	return []string{RoleOwner, RoleAdmin, RoleOperator, RoleViewer}
}

func IsValidRole(role string) bool {
	return slices.Contains(ValidRoles(), role)
}
```

- [ ] **Step 2: Write authz interfaces**

Create `apps/procurement/service/authz/interfaces.go`:

```go
package authz

import "context"

type Middleware interface {
	CanSupplierView(ctx context.Context) error
	CanSupplierManage(ctx context.Context) error
	CanPurchaseOrderView(ctx context.Context) error
	CanPurchaseOrderCreate(ctx context.Context) error
	CanGoodsReceiptView(ctx context.Context) error
	CanGoodsReceiptCreate(ctx context.Context) error
}
```

- [ ] **Step 3: Write authz middleware**

Create `apps/procurement/service/authz/middleware.go`:

```go
package authz

import (
	"context"

	"github.com/pitabwire/frame/security"
)

type middleware struct {
	authorizer security.Authorizer
}

func NewMiddleware(authorizer security.Authorizer) Middleware {
	return &middleware{authorizer: authorizer}
}

func (m *middleware) checkPermission(ctx context.Context, permission string) error {
	claims := security.ClaimsFromContext(ctx)
	if claims == nil {
		return security.ErrUnauthenticated
	}
	subject, err := claims.GetSubject()
	if err != nil {
		return security.ErrUnauthenticated
	}
	return m.authorizer.Check(ctx, NamespaceProcurement, "", permission, NamespaceProfile, subject)
}

func (m *middleware) CanSupplierView(ctx context.Context) error {
	return m.checkPermission(ctx, PermissionSupplierView)
}

func (m *middleware) CanSupplierManage(ctx context.Context) error {
	return m.checkPermission(ctx, PermissionSupplierManage)
}

func (m *middleware) CanPurchaseOrderView(ctx context.Context) error {
	return m.checkPermission(ctx, PermissionPurchaseOrderView)
}

func (m *middleware) CanPurchaseOrderCreate(ctx context.Context) error {
	return m.checkPermission(ctx, PermissionPurchaseOrderCreate)
}

func (m *middleware) CanGoodsReceiptView(ctx context.Context) error {
	return m.checkPermission(ctx, PermissionGoodsReceiptView)
}

func (m *middleware) CanGoodsReceiptCreate(ctx context.Context) error {
	return m.checkPermission(ctx, PermissionGoodsReceiptCreate)
}
```

- [ ] **Step 4: Commit**

```bash
git add apps/procurement/service/authz/
git commit -m "feat(procurement): add ReBAC authz constants and middleware"
```

---

## Task 8: Handlers and Server Wiring

**Files:**
- Create: `apps/procurement/service/handlers/procurement.go`

- [ ] **Step 1: Write the handler that wires all RPCs**

Create `apps/procurement/service/handlers/procurement.go`:

```go
package handlers

import (
	"context"

	procurementv1connect "buf.build/gen/go/antinvestor/procurement/connectrpc/go/v1/procurementv1connect"
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
	authz       authz.Middleware
	supplierBiz business.SupplierBusiness
	poBiz       business.PurchaseOrderBusiness
	grBiz       business.GoodsReceiptBusiness

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
		authz:       authzMiddleware,
		supplierBiz: business.NewSupplierBusiness(ctx, supplierRepo, supplierItemRepo),
		poBiz:       business.NewPurchaseOrderBusiness(ctx, poRepo, polRepo, supplierItemRepo),
		grBiz:       business.NewGoodsReceiptBusiness(ctx, grRepo, grlRepo, poRepo, polRepo),
	}
}

// ---- Suppliers ----

func (ps *ProcurementServer) SupplierSave(
	ctx context.Context,
	req *connect.Request[procurementv1.SupplierSaveRequest],
) (*connect.Response[procurementv1.SupplierSaveResponse], error) {
	result, err := ps.supplierBiz.SaveSupplier(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &connect.Response[procurementv1.SupplierSaveResponse]{
		Msg: &procurementv1.SupplierSaveResponse{Supplier: result},
	}, nil
}

func (ps *ProcurementServer) SupplierGet(
	ctx context.Context,
	req *connect.Request[procurementv1.SupplierGetRequest],
) (*connect.Response[procurementv1.SupplierGetResponse], error) {
	result, err := ps.supplierBiz.GetSupplier(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &connect.Response[procurementv1.SupplierGetResponse]{
		Msg: &procurementv1.SupplierGetResponse{Supplier: result},
	}, nil
}

func (ps *ProcurementServer) SupplierSearch(
	ctx context.Context,
	req *connect.Request[procurementv1.SupplierSearchRequest],
) (*connect.Response[procurementv1.SupplierSearchResponse], error) {
	result, err := ps.supplierBiz.SearchSuppliers(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &connect.Response[procurementv1.SupplierSearchResponse]{
		Msg: &procurementv1.SupplierSearchResponse{Suppliers: result},
	}, nil
}

// ---- Supplier Items ----

func (ps *ProcurementServer) SupplierItemSave(
	ctx context.Context,
	req *connect.Request[procurementv1.SupplierItemSaveRequest],
) (*connect.Response[procurementv1.SupplierItemSaveResponse], error) {
	result, err := ps.supplierBiz.SaveSupplierItem(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &connect.Response[procurementv1.SupplierItemSaveResponse]{
		Msg: &procurementv1.SupplierItemSaveResponse{SupplierItem: result},
	}, nil
}

func (ps *ProcurementServer) SupplierItemSearch(
	ctx context.Context,
	req *connect.Request[procurementv1.SupplierItemSearchRequest],
) (*connect.Response[procurementv1.SupplierItemSearchResponse], error) {
	result, err := ps.supplierBiz.SearchSupplierItems(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &connect.Response[procurementv1.SupplierItemSearchResponse]{
		Msg: &procurementv1.SupplierItemSearchResponse{SupplierItems: result},
	}, nil
}

// ---- Purchase Orders ----

func (ps *ProcurementServer) PurchaseOrderCreate(
	ctx context.Context,
	req *connect.Request[procurementv1.PurchaseOrderCreateRequest],
) (*connect.Response[procurementv1.PurchaseOrderCreateResponse], error) {
	result, err := ps.poBiz.CreatePurchaseOrder(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &connect.Response[procurementv1.PurchaseOrderCreateResponse]{
		Msg: &procurementv1.PurchaseOrderCreateResponse{PurchaseOrder: result},
	}, nil
}

func (ps *ProcurementServer) PurchaseOrderGet(
	ctx context.Context,
	req *connect.Request[procurementv1.PurchaseOrderGetRequest],
) (*connect.Response[procurementv1.PurchaseOrderGetResponse], error) {
	result, err := ps.poBiz.GetPurchaseOrder(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &connect.Response[procurementv1.PurchaseOrderGetResponse]{
		Msg: &procurementv1.PurchaseOrderGetResponse{PurchaseOrder: result},
	}, nil
}

func (ps *ProcurementServer) PurchaseOrderSearch(
	ctx context.Context,
	req *connect.Request[procurementv1.PurchaseOrderSearchRequest],
) (*connect.Response[procurementv1.PurchaseOrderSearchResponse], error) {
	result, err := ps.poBiz.SearchPurchaseOrders(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &connect.Response[procurementv1.PurchaseOrderSearchResponse]{
		Msg: &procurementv1.PurchaseOrderSearchResponse{PurchaseOrders: result},
	}, nil
}

func (ps *ProcurementServer) PurchaseOrderSubmit(
	ctx context.Context,
	req *connect.Request[procurementv1.PurchaseOrderSubmitRequest],
) (*connect.Response[procurementv1.PurchaseOrderSubmitResponse], error) {
	result, err := ps.poBiz.SubmitPurchaseOrder(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &connect.Response[procurementv1.PurchaseOrderSubmitResponse]{
		Msg: &procurementv1.PurchaseOrderSubmitResponse{PurchaseOrder: result},
	}, nil
}

func (ps *ProcurementServer) PurchaseOrderCancel(
	ctx context.Context,
	req *connect.Request[procurementv1.PurchaseOrderCancelRequest],
) (*connect.Response[procurementv1.PurchaseOrderCancelResponse], error) {
	result, err := ps.poBiz.CancelPurchaseOrder(ctx, req.Msg.GetId(), req.Msg.GetReason())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &connect.Response[procurementv1.PurchaseOrderCancelResponse]{
		Msg: &procurementv1.PurchaseOrderCancelResponse{PurchaseOrder: result},
	}, nil
}

// ---- Goods Receipts ----

func (ps *ProcurementServer) GoodsReceiptCreate(
	ctx context.Context,
	req *connect.Request[procurementv1.GoodsReceiptCreateRequest],
) (*connect.Response[procurementv1.GoodsReceiptCreateResponse], error) {
	result, err := ps.grBiz.CreateGoodsReceipt(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &connect.Response[procurementv1.GoodsReceiptCreateResponse]{
		Msg: &procurementv1.GoodsReceiptCreateResponse{GoodsReceipt: result},
	}, nil
}

func (ps *ProcurementServer) GoodsReceiptGet(
	ctx context.Context,
	req *connect.Request[procurementv1.GoodsReceiptGetRequest],
) (*connect.Response[procurementv1.GoodsReceiptGetResponse], error) {
	result, err := ps.grBiz.GetGoodsReceipt(ctx, req.Msg.GetId())
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &connect.Response[procurementv1.GoodsReceiptGetResponse]{
		Msg: &procurementv1.GoodsReceiptGetResponse{GoodsReceipt: result},
	}, nil
}

func (ps *ProcurementServer) GoodsReceiptSearch(
	ctx context.Context,
	req *connect.Request[procurementv1.GoodsReceiptSearchRequest],
) (*connect.Response[procurementv1.GoodsReceiptSearchResponse], error) {
	result, err := ps.grBiz.SearchGoodsReceipts(ctx, req.Msg)
	if err != nil {
		return nil, errorutil.CleanErr(err)
	}
	return &connect.Response[procurementv1.GoodsReceiptSearchResponse]{
		Msg: &procurementv1.GoodsReceiptSearchResponse{GoodsReceipts: result},
	}, nil
}

// ---- Suggestions (placeholder — depends on manufacturing client) ----

func (ps *ProcurementServer) SuggestPurchaseOrders(
	ctx context.Context,
	req *connect.Request[procurementv1.SuggestPurchaseOrdersRequest],
) (*connect.Response[procurementv1.SuggestPurchaseOrdersResponse], error) {
	return &connect.Response[procurementv1.SuggestPurchaseOrdersResponse]{
		Msg: &procurementv1.SuggestPurchaseOrdersResponse{Suggestions: nil},
	}, nil
}
```

- [ ] **Step 2: Commit**

```bash
git add apps/procurement/service/handlers/
git commit -m "feat(procurement): add Connect RPC handler wiring all RPCs"
```

---

## Task 9: Config and Main Entry Point

**Files:**
- Create: `apps/procurement/config/config.go`
- Create: `apps/procurement/cmd/main.go`

- [ ] **Step 1: Write config**

Create `apps/procurement/config/config.go`:

```go
package config

import "github.com/pitabwire/frame/config"

type ProcurementConfig struct {
	config.ConfigurationDefault
}
```

- [ ] **Step 2: Write main.go**

Create `apps/procurement/cmd/main.go`:

```go
package main

import (
	"context"
	"net/http"

	procurementv1connect "buf.build/gen/go/antinvestor/procurement/connectrpc/go/v1/procurementv1connect"
	procurementpb "buf.build/gen/go/antinvestor/procurement/protocolbuffers/go/v1"
	"connectrpc.com/connect"
	"github.com/antinvestor/common/permissions"
	"github.com/pitabwire/frame"
	"github.com/pitabwire/frame/config"
	"github.com/pitabwire/frame/datastore"
	"github.com/pitabwire/frame/security/authorizer"
	connectInterceptors "github.com/pitabwire/frame/security/interceptors/connect"
	"github.com/pitabwire/util"

	aconfig "github.com/antinvestor/service-commerce/apps/procurement/config"
	"github.com/antinvestor/service-commerce/apps/procurement/service/authz"
	"github.com/antinvestor/service-commerce/apps/procurement/service/handlers"
	"github.com/antinvestor/service-commerce/apps/procurement/service/repository"
)

func main() {
	ctx := context.Background()

	cfg, err := config.LoadWithOIDC[aconfig.ProcurementConfig](ctx)
	if err != nil {
		util.Log(ctx).WithError(err).Error("could not process configs")
		return
	}

	if cfg.Name() == "" {
		cfg.ServiceName = "service_procurement"
	}

	ctx, svc := frame.NewServiceWithContext(
		ctx,
		frame.WithConfig(&cfg),
		frame.WithDatastore(),
	)
	defer svc.Stop(ctx)
	log := svc.Log(ctx)

	dbManager := svc.DatastoreManager()

	if handleDatabaseMigration(ctx, dbManager, cfg) {
		return
	}

	connectHandler := setupConnectServer(ctx, svc)

	sd := procurementpb.File_v1_procurement_proto.Services().ByName("ProcurementService")
	serviceOptions := []frame.Option{
		frame.WithHTTPHandler(connectHandler),
		frame.WithPermissionRegistration(sd),
	}

	svc.Init(ctx, serviceOptions...)

	err = svc.Run(ctx, "")
	if err != nil {
		log.WithError(err).Fatal("could not run Server")
	}
}

func handleDatabaseMigration(
	ctx context.Context,
	dbManager datastore.Manager,
	cfg aconfig.ProcurementConfig,
) bool {
	if cfg.DoDatabaseMigrate() {
		err := repository.Migrate(ctx, dbManager, cfg.GetDatabaseMigrationPath())
		if err != nil {
			util.Log(ctx).WithError(err).Fatal("main -- Could not migrate successfully")
		}
		return true
	}
	return false
}

func setupConnectServer(ctx context.Context, svc *frame.Service) http.Handler {
	securityMan := svc.SecurityManager()
	auth := securityMan.GetAuthorizer(ctx)

	tenancyAccessChecker := authorizer.NewTenancyAccessChecker(auth, authz.NamespaceTenancyAccess)
	tenancyAccessInterceptor := connectInterceptors.NewTenancyAccessInterceptor(tenancyAccessChecker)

	sd := procurementpb.File_v1_procurement_proto.Services().ByName("ProcurementService")
	procMap := permissions.BuildProcedureMap(sd)
	svcPerms := permissions.ForService(sd)
	functionChecker := authorizer.NewFunctionChecker(auth, svcPerms.Namespace)
	functionAccessInterceptor := connectInterceptors.NewFunctionAccessInterceptor(functionChecker, procMap)

	defaultInterceptorList, err := connectInterceptors.DefaultList(
		ctx, securityMan.GetAuthenticator(ctx),
		tenancyAccessInterceptor, functionAccessInterceptor)
	if err != nil {
		util.Log(ctx).WithError(err).Fatal("main -- Could not create default interceptors")
	}

	authzMiddleware := authz.NewMiddleware(securityMan.GetAuthorizer(ctx))
	implementation := handlers.NewProcurementServer(ctx, svc, authzMiddleware)

	_, serverHandler := procurementv1connect.NewProcurementServiceHandler(
		implementation, connect.WithInterceptors(defaultInterceptorList...))

	mux := http.NewServeMux()
	mux.Handle("/", serverHandler)
	return mux
}
```

- [ ] **Step 3: Verify build**

```bash
go build ./apps/procurement/cmd/
```

- [ ] **Step 4: Commit**

```bash
git add apps/procurement/config/ apps/procurement/cmd/
git commit -m "feat(procurement): add app config and main entry point"
```

---

## Task 10: Test Suite

**Files:**
- Create: `apps/procurement/tests/base_testsuite.go`
- Create: `apps/procurement/tests/supplier_test.go`
- Create: `apps/procurement/tests/purchase_order_test.go`
- Create: `apps/procurement/tests/goods_receipt_test.go`

- [ ] **Step 1: Write the base test suite**

Create `apps/procurement/tests/base_testsuite.go`:

```go
package tests

import (
	"context"
	"fmt"
	"testing"

	"github.com/pitabwire/frame"
	"github.com/pitabwire/frame/datastore/pool"
	"github.com/pitabwire/frame/security"
	frametests "github.com/pitabwire/frame/tests"
	"github.com/pitabwire/frame/tests/definition"
	testpostgres "github.com/pitabwire/frame/tests/testcontainers/postgres"
	"github.com/stretchr/testify/require"

	aconfig "github.com/antinvestor/service-commerce/apps/procurement/config"
	"github.com/antinvestor/service-commerce/apps/procurement/service/repository"
)

type ProcurementBaseTestSuite struct {
	frametests.FrameBaseTestSuite
}

func initResources(_ context.Context) []definition.TestResource {
	pg := testpostgres.NewWithOpts("service_procurement", definition.WithUserName("ant"))
	return []definition.TestResource{pg}
}

func (bs *ProcurementBaseTestSuite) SetupSuite() {
	bs.InitResourceFunc = initResources
	bs.FrameBaseTestSuite.SetupSuite()
}

func (bs *ProcurementBaseTestSuite) CreateService(
	t *testing.T,
	depOpts *definition.DependencyOption,
) (context.Context, *frame.Service) {
	cfg, err := aconfig.ProcurementConfig{}, error(nil)
	_ = err

	cfg.LogLevel = "debug"
	cfg.RunServiceSecurely = false
	cfg.ServerPort = ""
	cfg.DatabaseMigrate = true

	if depOpts != nil {
		if depOpts.DatabaseURL != "" {
			cfg.DatabaseURL = depOpts.DatabaseURL
		}
	}

	ctx, svc := frame.NewServiceWithContext(
		t.Context(),
		frame.WithName("procurement tests"),
		frame.WithConfig(&cfg),
		frame.WithDatastore(pool.WithTraceConfig(&cfg)),
		frametests.WithNoopDriver(),
	)

	svc.Init(ctx)
	err = repository.Migrate(ctx, svc.DatastoreManager(), "../../migrations/0001")
	require.NoError(t, err)

	return ctx, svc
}

func (bs *ProcurementBaseTestSuite) WithAuthClaims(
	ctx context.Context,
	tenantID, partitionID, profileID string,
) context.Context {
	claims := &security.AuthenticationClaims{}
	claims.TenantID = tenantID
	claims.PartitionID = partitionID
	claims.Subject = profileID
	return claims.ClaimsToContext(ctx)
}
```

- [ ] **Step 2: Write supplier integration tests**

Create `apps/procurement/tests/supplier_test.go`:

```go
package tests

import (
	"testing"

	procurementv1 "buf.build/gen/go/antinvestor/procurement/protocolbuffers/go/v1"
	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"github.com/stretchr/testify/suite"

	"github.com/antinvestor/service-commerce/apps/procurement/service/business"
	"github.com/antinvestor/service-commerce/apps/procurement/service/repository"
	"github.com/pitabwire/frame/datastore"
)

type SupplierTestSuite struct {
	ProcurementBaseTestSuite
}

func TestSupplierSuite(t *testing.T) {
	suite.Run(t, new(SupplierTestSuite))
}

func (s *SupplierTestSuite) TestCreateSupplier() {
	depOpts := s.GetDependencyOptions()
	ctx, svc := s.CreateService(s.T(), depOpts)
	defer svc.Stop(ctx)

	workMan := svc.WorkManager()
	dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)

	supplierRepo := repository.NewSupplierRepository(ctx, dbPool, workMan)
	supplierItemRepo := repository.NewSupplierItemRepository(ctx, dbPool, workMan)
	biz := business.NewSupplierBusiness(ctx, supplierRepo, supplierItemRepo)

	result, err := biz.SaveSupplier(ctx, &procurementv1.SupplierSaveRequest{
		Name:             "Fresh Dairy Farm",
		ProfileId:        "profile-123",
		SupplierType:     procurementv1.SupplierType_SUPPLIER_TYPE_RAW_MATERIAL,
		PaymentTermsDays: 30,
		Currency:         "KES",
		LeadTimeDays:     2,
	})

	s.Require().NoError(err)
	s.Require().NotEmpty(result.GetId())
	s.Equal("Fresh Dairy Farm", result.GetName())
	s.Equal(procurementv1.SupplierStatus_SUPPLIER_STATUS_ACTIVE, result.GetStatus())
	s.Equal(procurementv1.SupplierRating_SUPPLIER_RATING_UNRATED, result.GetRating())
}

func (s *SupplierTestSuite) TestUpdateSupplier() {
	depOpts := s.GetDependencyOptions()
	ctx, svc := s.CreateService(s.T(), depOpts)
	defer svc.Stop(ctx)

	workMan := svc.WorkManager()
	dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)

	supplierRepo := repository.NewSupplierRepository(ctx, dbPool, workMan)
	supplierItemRepo := repository.NewSupplierItemRepository(ctx, dbPool, workMan)
	biz := business.NewSupplierBusiness(ctx, supplierRepo, supplierItemRepo)

	created, err := biz.SaveSupplier(ctx, &procurementv1.SupplierSaveRequest{
		Name:     "Old Name",
		Currency: "KES",
	})
	s.Require().NoError(err)

	updated, err := biz.SaveSupplier(ctx, &procurementv1.SupplierSaveRequest{
		Id:       created.GetId(),
		Name:     "New Name",
		Currency: "USD",
		Rating:   procurementv1.SupplierRating_SUPPLIER_RATING_PREFERRED,
	})
	s.Require().NoError(err)
	s.Equal("New Name", updated.GetName())
	s.Equal("USD", updated.GetCurrency())
}

func (s *SupplierTestSuite) TestCreateSupplierItem() {
	depOpts := s.GetDependencyOptions()
	ctx, svc := s.CreateService(s.T(), depOpts)
	defer svc.Stop(ctx)

	workMan := svc.WorkManager()
	dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)

	supplierRepo := repository.NewSupplierRepository(ctx, dbPool, workMan)
	supplierItemRepo := repository.NewSupplierItemRepository(ctx, dbPool, workMan)
	biz := business.NewSupplierBusiness(ctx, supplierRepo, supplierItemRepo)

	supplier, err := biz.SaveSupplier(ctx, &procurementv1.SupplierSaveRequest{
		Name:     "Milk Farm",
		Currency: "KES",
	})
	s.Require().NoError(err)

	item, err := biz.SaveSupplierItem(ctx, &procurementv1.SupplierItemSaveRequest{
		SupplierId:      supplier.GetId(),
		InventoryItemId: "inv-milk-001",
		SupplierSku:     "MILK-WHL-1L",
		UnitPrice:       &commonv1.Money{CurrencyCode: "KES", Units: 65, Nanos: 0},
		MinOrderQuantity: 50,
		Unit:            "liters",
	})
	s.Require().NoError(err)
	s.Require().NotEmpty(item.GetId())
	s.Equal(supplier.GetId(), item.GetSupplierId())
	s.Equal("MILK-WHL-1L", item.GetSupplierSku())
}

func (s *SupplierTestSuite) TestSearchSupplierItems() {
	depOpts := s.GetDependencyOptions()
	ctx, svc := s.CreateService(s.T(), depOpts)
	defer svc.Stop(ctx)

	workMan := svc.WorkManager()
	dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)

	supplierRepo := repository.NewSupplierRepository(ctx, dbPool, workMan)
	supplierItemRepo := repository.NewSupplierItemRepository(ctx, dbPool, workMan)
	biz := business.NewSupplierBusiness(ctx, supplierRepo, supplierItemRepo)

	supplier, _ := biz.SaveSupplier(ctx, &procurementv1.SupplierSaveRequest{
		Name: "Farm", Currency: "KES",
	})

	_, _ = biz.SaveSupplierItem(ctx, &procurementv1.SupplierItemSaveRequest{
		SupplierId: supplier.GetId(), InventoryItemId: "inv-1", Unit: "kg",
		UnitPrice: &commonv1.Money{CurrencyCode: "KES", Units: 100},
	})
	_, _ = biz.SaveSupplierItem(ctx, &procurementv1.SupplierItemSaveRequest{
		SupplierId: supplier.GetId(), InventoryItemId: "inv-2", Unit: "liters",
		UnitPrice: &commonv1.Money{CurrencyCode: "KES", Units: 200},
	})

	items, err := biz.SearchSupplierItems(ctx, &procurementv1.SupplierItemSearchRequest{
		SupplierId: supplier.GetId(),
	})
	s.Require().NoError(err)
	s.Len(items, 2)
}
```

- [ ] **Step 3: Write purchase order integration tests**

Create `apps/procurement/tests/purchase_order_test.go`:

```go
package tests

import (
	"testing"

	procurementv1 "buf.build/gen/go/antinvestor/procurement/protocolbuffers/go/v1"
	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"github.com/stretchr/testify/suite"
	"google.golang.org/protobuf/types/known/timestamppb"
	"time"

	"github.com/antinvestor/service-commerce/apps/procurement/service/business"
	"github.com/antinvestor/service-commerce/apps/procurement/service/repository"
	"github.com/pitabwire/frame/datastore"
)

type PurchaseOrderTestSuite struct {
	ProcurementBaseTestSuite
}

func TestPurchaseOrderSuite(t *testing.T) {
	suite.Run(t, new(PurchaseOrderTestSuite))
}

func (s *PurchaseOrderTestSuite) setupBusiness(ctx context.Context, svc interface{ WorkManager() interface{} }) (
	business.SupplierBusiness, business.PurchaseOrderBusiness,
) {
	// helper extracted for readability — actual code in the test
	return nil, nil
}

func (s *PurchaseOrderTestSuite) TestCreatePurchaseOrder() {
	depOpts := s.GetDependencyOptions()
	ctx, svc := s.CreateService(s.T(), depOpts)
	defer svc.Stop(ctx)

	workMan := svc.WorkManager()
	dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)

	supplierRepo := repository.NewSupplierRepository(ctx, dbPool, workMan)
	supplierItemRepo := repository.NewSupplierItemRepository(ctx, dbPool, workMan)
	poRepo := repository.NewPurchaseOrderRepository(ctx, dbPool, workMan)
	polRepo := repository.NewPurchaseOrderLineRepository(ctx, dbPool, workMan)

	supplierBiz := business.NewSupplierBusiness(ctx, supplierRepo, supplierItemRepo)
	poBiz := business.NewPurchaseOrderBusiness(ctx, poRepo, polRepo, supplierItemRepo)

	supplier, err := supplierBiz.SaveSupplier(ctx, &procurementv1.SupplierSaveRequest{
		Name: "Milk Farm", Currency: "KES",
	})
	s.Require().NoError(err)

	si, err := supplierBiz.SaveSupplierItem(ctx, &procurementv1.SupplierItemSaveRequest{
		SupplierId: supplier.GetId(), InventoryItemId: "inv-milk",
		UnitPrice: &commonv1.Money{CurrencyCode: "KES", Units: 65}, Unit: "liters",
	})
	s.Require().NoError(err)

	po, err := poBiz.CreatePurchaseOrder(ctx, &procurementv1.PurchaseOrderCreateRequest{
		IdempotencyKey:       "test-po-001",
		PropertyId:           "property-001",
		SupplierId:           supplier.GetId(),
		ExpectedDeliveryDate: timestamppb.New(time.Now().Add(48 * time.Hour)),
		Lines: []*procurementv1.PurchaseOrderLineInput{
			{
				SupplierItemId:  si.GetId(),
				InventoryItemId: "inv-milk",
				OrderedQuantity: 100,
				Unit:            "liters",
			},
		},
	})

	s.Require().NoError(err)
	s.Require().NotEmpty(po.GetId())
	s.Equal(procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_DRAFT, po.GetStatus())
	s.Len(po.GetLines(), 1)
	s.Equal(float64(100), po.GetLines()[0].GetOrderedQuantity())
}

func (s *PurchaseOrderTestSuite) TestIdempotentCreate() {
	depOpts := s.GetDependencyOptions()
	ctx, svc := s.CreateService(s.T(), depOpts)
	defer svc.Stop(ctx)

	workMan := svc.WorkManager()
	dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)

	supplierRepo := repository.NewSupplierRepository(ctx, dbPool, workMan)
	supplierItemRepo := repository.NewSupplierItemRepository(ctx, dbPool, workMan)
	poRepo := repository.NewPurchaseOrderRepository(ctx, dbPool, workMan)
	polRepo := repository.NewPurchaseOrderLineRepository(ctx, dbPool, workMan)

	supplierBiz := business.NewSupplierBusiness(ctx, supplierRepo, supplierItemRepo)
	poBiz := business.NewPurchaseOrderBusiness(ctx, poRepo, polRepo, supplierItemRepo)

	supplier, _ := supplierBiz.SaveSupplier(ctx, &procurementv1.SupplierSaveRequest{
		Name: "Farm", Currency: "KES",
	})

	req := &procurementv1.PurchaseOrderCreateRequest{
		IdempotencyKey: "idem-key-001",
		PropertyId:     "prop-001",
		SupplierId:     supplier.GetId(),
		Lines: []*procurementv1.PurchaseOrderLineInput{
			{InventoryItemId: "inv-1", OrderedQuantity: 50, Unit: "kg"},
		},
	}

	po1, err := poBiz.CreatePurchaseOrder(ctx, req)
	s.Require().NoError(err)

	po2, err := poBiz.CreatePurchaseOrder(ctx, req)
	s.Require().NoError(err)

	s.Equal(po1.GetId(), po2.GetId())
}

func (s *PurchaseOrderTestSuite) TestSubmitAndCancel() {
	depOpts := s.GetDependencyOptions()
	ctx, svc := s.CreateService(s.T(), depOpts)
	defer svc.Stop(ctx)

	workMan := svc.WorkManager()
	dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)

	supplierRepo := repository.NewSupplierRepository(ctx, dbPool, workMan)
	supplierItemRepo := repository.NewSupplierItemRepository(ctx, dbPool, workMan)
	poRepo := repository.NewPurchaseOrderRepository(ctx, dbPool, workMan)
	polRepo := repository.NewPurchaseOrderLineRepository(ctx, dbPool, workMan)

	supplierBiz := business.NewSupplierBusiness(ctx, supplierRepo, supplierItemRepo)
	poBiz := business.NewPurchaseOrderBusiness(ctx, poRepo, polRepo, supplierItemRepo)

	supplier, _ := supplierBiz.SaveSupplier(ctx, &procurementv1.SupplierSaveRequest{
		Name: "Farm", Currency: "KES",
	})

	po, _ := poBiz.CreatePurchaseOrder(ctx, &procurementv1.PurchaseOrderCreateRequest{
		PropertyId: "prop-001", SupplierId: supplier.GetId(),
		Lines: []*procurementv1.PurchaseOrderLineInput{
			{InventoryItemId: "inv-1", OrderedQuantity: 50, Unit: "kg"},
		},
	})

	submitted, err := poBiz.SubmitPurchaseOrder(ctx, po.GetId())
	s.Require().NoError(err)
	s.Equal(procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_SUBMITTED, submitted.GetStatus())
	s.NotNil(submitted.GetSubmittedAt())

	cancelled, err := poBiz.CancelPurchaseOrder(ctx, po.GetId(), "no longer needed")
	s.Require().NoError(err)
	s.Equal(procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_CANCELLED, cancelled.GetStatus())
}
```

- [ ] **Step 4: Write goods receipt integration tests**

Create `apps/procurement/tests/goods_receipt_test.go`:

```go
package tests

import (
	"testing"

	procurementv1 "buf.build/gen/go/antinvestor/procurement/protocolbuffers/go/v1"
	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"github.com/stretchr/testify/suite"
	"google.golang.org/protobuf/types/known/timestamppb"
	"time"

	"github.com/antinvestor/service-commerce/apps/procurement/service/business"
	"github.com/antinvestor/service-commerce/apps/procurement/service/repository"
	"github.com/pitabwire/frame/datastore"
)

type GoodsReceiptTestSuite struct {
	ProcurementBaseTestSuite
}

func TestGoodsReceiptSuite(t *testing.T) {
	suite.Run(t, new(GoodsReceiptTestSuite))
}

func (s *GoodsReceiptTestSuite) TestCreateGoodsReceipt() {
	depOpts := s.GetDependencyOptions()
	ctx, svc := s.CreateService(s.T(), depOpts)
	defer svc.Stop(ctx)

	workMan := svc.WorkManager()
	dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)

	supplierRepo := repository.NewSupplierRepository(ctx, dbPool, workMan)
	supplierItemRepo := repository.NewSupplierItemRepository(ctx, dbPool, workMan)
	poRepo := repository.NewPurchaseOrderRepository(ctx, dbPool, workMan)
	polRepo := repository.NewPurchaseOrderLineRepository(ctx, dbPool, workMan)
	grRepo := repository.NewGoodsReceiptRepository(ctx, dbPool, workMan)
	grlRepo := repository.NewGoodsReceiptLineRepository(ctx, dbPool, workMan)

	supplierBiz := business.NewSupplierBusiness(ctx, supplierRepo, supplierItemRepo)
	poBiz := business.NewPurchaseOrderBusiness(ctx, poRepo, polRepo, supplierItemRepo)
	grBiz := business.NewGoodsReceiptBusiness(ctx, grRepo, grlRepo, poRepo, polRepo)

	supplier, _ := supplierBiz.SaveSupplier(ctx, &procurementv1.SupplierSaveRequest{
		Name: "Farm", Currency: "KES",
	})

	si, _ := supplierBiz.SaveSupplierItem(ctx, &procurementv1.SupplierItemSaveRequest{
		SupplierId: supplier.GetId(), InventoryItemId: "inv-milk",
		UnitPrice: &commonv1.Money{CurrencyCode: "KES", Units: 65}, Unit: "liters",
	})

	po, _ := poBiz.CreatePurchaseOrder(ctx, &procurementv1.PurchaseOrderCreateRequest{
		PropertyId: "prop-001", SupplierId: supplier.GetId(),
		Lines: []*procurementv1.PurchaseOrderLineInput{
			{SupplierItemId: si.GetId(), InventoryItemId: "inv-milk", OrderedQuantity: 100, Unit: "liters"},
		},
	})

	gr, err := grBiz.CreateGoodsReceipt(ctx, &procurementv1.GoodsReceiptCreateRequest{
		IdempotencyKey:  "gr-001",
		PurchaseOrderId: po.GetId(),
		PropertyId:      "prop-001",
		Lines: []*procurementv1.GoodsReceiptLineInput{
			{
				PurchaseOrderLineId: po.GetLines()[0].GetId(),
				InventoryItemId:     "inv-milk",
				ReceivedQuantity:    80,
				LotNumber:           "LOT-2026-001",
				ExpiryDate:          timestamppb.New(time.Now().Add(72 * time.Hour)),
				Unit:                "liters",
			},
		},
	})

	s.Require().NoError(err)
	s.Require().NotEmpty(gr.GetId())
	s.Equal(procurementv1.GoodsReceiptStatus_GOODS_RECEIPT_STATUS_PENDING_INSPECTION, gr.GetStatus())
	s.Len(gr.GetLines(), 1)
	s.Equal(float64(80), gr.GetLines()[0].GetReceivedQuantity())

	updatedPO, _ := poBiz.GetPurchaseOrder(ctx, po.GetId())
	s.Equal(procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_PARTIALLY_RECEIVED, updatedPO.GetStatus())
	s.Equal(float64(80), updatedPO.GetLines()[0].GetReceivedQuantity())
}

func (s *GoodsReceiptTestSuite) TestFullReceive() {
	depOpts := s.GetDependencyOptions()
	ctx, svc := s.CreateService(s.T(), depOpts)
	defer svc.Stop(ctx)

	workMan := svc.WorkManager()
	dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)

	supplierRepo := repository.NewSupplierRepository(ctx, dbPool, workMan)
	supplierItemRepo := repository.NewSupplierItemRepository(ctx, dbPool, workMan)
	poRepo := repository.NewPurchaseOrderRepository(ctx, dbPool, workMan)
	polRepo := repository.NewPurchaseOrderLineRepository(ctx, dbPool, workMan)
	grRepo := repository.NewGoodsReceiptRepository(ctx, dbPool, workMan)
	grlRepo := repository.NewGoodsReceiptLineRepository(ctx, dbPool, workMan)

	supplierBiz := business.NewSupplierBusiness(ctx, supplierRepo, supplierItemRepo)
	poBiz := business.NewPurchaseOrderBusiness(ctx, poRepo, polRepo, supplierItemRepo)
	grBiz := business.NewGoodsReceiptBusiness(ctx, grRepo, grlRepo, poRepo, polRepo)

	supplier, _ := supplierBiz.SaveSupplier(ctx, &procurementv1.SupplierSaveRequest{
		Name: "Farm", Currency: "KES",
	})

	po, _ := poBiz.CreatePurchaseOrder(ctx, &procurementv1.PurchaseOrderCreateRequest{
		PropertyId: "prop-001", SupplierId: supplier.GetId(),
		Lines: []*procurementv1.PurchaseOrderLineInput{
			{InventoryItemId: "inv-milk", OrderedQuantity: 100, Unit: "liters"},
		},
	})

	_, err := grBiz.CreateGoodsReceipt(ctx, &procurementv1.GoodsReceiptCreateRequest{
		PurchaseOrderId: po.GetId(), PropertyId: "prop-001",
		Lines: []*procurementv1.GoodsReceiptLineInput{
			{PurchaseOrderLineId: po.GetLines()[0].GetId(), InventoryItemId: "inv-milk",
				ReceivedQuantity: 100, Unit: "liters"},
		},
	})
	s.Require().NoError(err)

	updatedPO, _ := poBiz.GetPurchaseOrder(ctx, po.GetId())
	s.Equal(procurementv1.PurchaseOrderStatus_PURCHASE_ORDER_STATUS_RECEIVED, updatedPO.GetStatus())
	s.Equal(procurementv1.PurchaseOrderLineStatus_PURCHASE_ORDER_LINE_STATUS_RECEIVED, updatedPO.GetLines()[0].GetStatus())
}

func (s *GoodsReceiptTestSuite) TestOverReceiveBlocked() {
	depOpts := s.GetDependencyOptions()
	ctx, svc := s.CreateService(s.T(), depOpts)
	defer svc.Stop(ctx)

	workMan := svc.WorkManager()
	dbPool := svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)

	supplierRepo := repository.NewSupplierRepository(ctx, dbPool, workMan)
	supplierItemRepo := repository.NewSupplierItemRepository(ctx, dbPool, workMan)
	poRepo := repository.NewPurchaseOrderRepository(ctx, dbPool, workMan)
	polRepo := repository.NewPurchaseOrderLineRepository(ctx, dbPool, workMan)
	grRepo := repository.NewGoodsReceiptRepository(ctx, dbPool, workMan)
	grlRepo := repository.NewGoodsReceiptLineRepository(ctx, dbPool, workMan)

	supplierBiz := business.NewSupplierBusiness(ctx, supplierRepo, supplierItemRepo)
	poBiz := business.NewPurchaseOrderBusiness(ctx, poRepo, polRepo, supplierItemRepo)
	grBiz := business.NewGoodsReceiptBusiness(ctx, grRepo, grlRepo, poRepo, polRepo)

	supplier, _ := supplierBiz.SaveSupplier(ctx, &procurementv1.SupplierSaveRequest{
		Name: "Farm", Currency: "KES",
	})

	po, _ := poBiz.CreatePurchaseOrder(ctx, &procurementv1.PurchaseOrderCreateRequest{
		PropertyId: "prop-001", SupplierId: supplier.GetId(),
		Lines: []*procurementv1.PurchaseOrderLineInput{
			{InventoryItemId: "inv-milk", OrderedQuantity: 50, Unit: "liters"},
		},
	})

	_, err := grBiz.CreateGoodsReceipt(ctx, &procurementv1.GoodsReceiptCreateRequest{
		PurchaseOrderId: po.GetId(), PropertyId: "prop-001",
		Lines: []*procurementv1.GoodsReceiptLineInput{
			{PurchaseOrderLineId: po.GetLines()[0].GetId(), InventoryItemId: "inv-milk",
				ReceivedQuantity: 60, Unit: "liters"},
		},
	})
	s.Require().Error(err)
	s.Contains(err.Error(), "exceeds remaining")
}
```

- [ ] **Step 5: Run all tests**

```bash
go test -v -count=1 -race ./apps/procurement/tests/...
```

Expected: all tests pass.

- [ ] **Step 6: Commit**

```bash
git add apps/procurement/tests/
git commit -m "feat(procurement): add integration test suite with supplier, PO, and goods receipt tests"
```

---

## Task 11: Verify Full Build and Final Commit

- [ ] **Step 1: Build all apps**

```bash
go build ./...
```

- [ ] **Step 2: Run linter**

```bash
golangci-lint run ./apps/procurement/...
```

- [ ] **Step 3: Run all tests**

```bash
go test -v -count=1 -race ./apps/procurement/tests/...
```

- [ ] **Step 4: Final commit if any fixes needed**

```bash
git add -A
git commit -m "fix(procurement): lint and build fixes"
```
