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

package models

import (
	"time"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	procurementv1 "buf.build/gen/go/antinvestor/procurement/protocolbuffers/go/v1"
	"github.com/pitabwire/frame/data"
	"google.golang.org/protobuf/types/known/timestamppb"
)

// Supplier represents a vendor or supplier entity.
type Supplier struct {
	data.BaseModel
	ProfileID        string `gorm:"type:varchar(50);index:idx_supplier_profile_id"`
	Name             string `gorm:"type:varchar(255)"`
	SupplierType     int32  `gorm:"default:0"`
	Status           int32  `gorm:"default:1"`
	PaymentTermsDays int32
	Currency         string `gorm:"type:varchar(3)"`
	LeadTimeDays     int32
	Rating           int32  `gorm:"default:0"`
	Notes            string `gorm:"type:text"`
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

// SupplierItem represents an item offered by a supplier.
type SupplierItem struct {
	data.BaseModel
	SupplierID       string `gorm:"type:varchar(50);index:idx_supplier_item_supplier_id"`
	InventoryItemID  string `gorm:"type:varchar(50);index:idx_supplier_item_inventory_id"`
	SupplierSKU      string `gorm:"type:varchar(255)"`
	CurrencyCode     string `gorm:"type:varchar(3)"`
	PriceUnits       int64
	PriceNanos       int32
	MinOrderQuantity float64
	Unit             string `gorm:"type:varchar(50)"`
	LeadTimeDays     int32
	Status           int32 `gorm:"default:1"`

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

// PurchaseOrder represents a purchase order to a supplier.
type PurchaseOrder struct {
	data.BaseModel
	PropertyID           string `gorm:"type:varchar(50);index:idx_po_property_id"`
	SupplierID           string `gorm:"type:varchar(50);index:idx_po_supplier_id"`
	OrderNumber          string `gorm:"type:varchar(100);uniqueIndex"`
	Status               int32  `gorm:"default:1"`
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
	for _, line := range po.Lines {
		lines = append(lines, line.ToAPI())
	}

	result := &procurementv1.PurchaseOrder{
		Id:          po.ID,
		PropertyId:  po.PropertyID,
		SupplierId:  po.SupplierID,
		OrderNumber: po.OrderNumber,
		Status:      procurementv1.PurchaseOrderStatus(po.Status),
		SubmittedBy: po.SubmittedBy,
		TotalAmount: MoneyToProto(po.TotalCurrencyCode, po.TotalUnits, po.TotalNanos),
		Notes:       po.Notes,
		PlanId:      po.PlanID,
		Lines:       lines,
		CreatedAt:   timestamppb.New(po.CreatedAt),
	}

	if po.ExpectedDeliveryDate != nil {
		result.ExpectedDeliveryDate = timestamppb.New(*po.ExpectedDeliveryDate)
	}
	if po.SubmittedAt != nil {
		result.SubmittedAt = timestamppb.New(*po.SubmittedAt)
	}

	return result
}

// PurchaseOrderLine represents a line item in a purchase order.
type PurchaseOrderLine struct {
	data.BaseModel
	PurchaseOrderID  string `gorm:"type:varchar(50);index:idx_pol_po_id"`
	SupplierItemID   string `gorm:"type:varchar(50)"`
	InventoryItemID  string `gorm:"type:varchar(50)"`
	OrderedQuantity  float64
	ReceivedQuantity float64
	CurrencyCode     string `gorm:"type:varchar(3)"`
	PriceUnits       int64
	PriceNanos       int32
	Unit             string `gorm:"type:varchar(50)"`
	Status           int32  `gorm:"default:1"`

	PurchaseOrder *PurchaseOrder `gorm:"foreignKey:PurchaseOrderID"`
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

// GoodsReceipt represents a receipt of goods against a purchase order.
type GoodsReceipt struct {
	data.BaseModel
	PurchaseOrderID string `gorm:"type:varchar(50);index:idx_gr_po_id"`
	PropertyID      string `gorm:"type:varchar(50);index:idx_gr_property_id"`
	ReceivedBy      string `gorm:"type:varchar(50)"`
	ReceivedAt      *time.Time
	Status          int32  `gorm:"default:1"`
	Notes           string `gorm:"type:text"`
	IdempotencyKey  string `gorm:"type:varchar(255);uniqueIndex"`

	Lines         []*GoodsReceiptLine `gorm:"foreignKey:GoodsReceiptID"`
	PurchaseOrder *PurchaseOrder      `gorm:"foreignKey:PurchaseOrderID"`
}

func (gr *GoodsReceipt) ToAPI() *procurementv1.GoodsReceipt {
	var lines []*procurementv1.GoodsReceiptLine
	for _, line := range gr.Lines {
		lines = append(lines, line.ToAPI())
	}

	result := &procurementv1.GoodsReceipt{
		Id:              gr.ID,
		PurchaseOrderId: gr.PurchaseOrderID,
		PropertyId:      gr.PropertyID,
		ReceivedBy:      gr.ReceivedBy,
		Status:          procurementv1.GoodsReceiptStatus(gr.Status),
		Notes:           gr.Notes,
		Lines:           lines,
		CreatedAt:       timestamppb.New(gr.CreatedAt),
	}

	if gr.ReceivedAt != nil {
		result.ReceivedAt = timestamppb.New(*gr.ReceivedAt)
	}

	return result
}

// GoodsReceiptLine represents a line item in a goods receipt.
type GoodsReceiptLine struct {
	data.BaseModel
	GoodsReceiptID      string `gorm:"type:varchar(50);index:idx_grl_gr_id"`
	PurchaseOrderLineID string `gorm:"type:varchar(50)"`
	InventoryItemID     string `gorm:"type:varchar(50)"`
	ReceivedQuantity    float64
	AcceptedQuantity    float64
	RejectedQuantity    float64
	RejectionReason     string `gorm:"type:text"`
	LotNumber           string `gorm:"type:varchar(255)"`
	ExpiryDate          *time.Time
	Unit                string `gorm:"type:varchar(50)"`

	GoodsReceipt *GoodsReceipt `gorm:"foreignKey:GoodsReceiptID"`
}

func (grl *GoodsReceiptLine) ToAPI() *procurementv1.GoodsReceiptLine {
	result := &procurementv1.GoodsReceiptLine{
		Id:                  grl.ID,
		GoodsReceiptId:      grl.GoodsReceiptID,
		PurchaseOrderLineId: grl.PurchaseOrderLineID,
		InventoryItemId:     grl.InventoryItemID,
		ReceivedQuantity:    grl.ReceivedQuantity,
		AcceptedQuantity:    grl.AcceptedQuantity,
		RejectedQuantity:    grl.RejectedQuantity,
		RejectionReason:     grl.RejectionReason,
		LotNumber:           grl.LotNumber,
		Unit:                grl.Unit,
	}

	if grl.ExpiryDate != nil {
		result.ExpiryDate = timestamppb.New(*grl.ExpiryDate)
	}

	return result
}

// MoneyToProto converts currency/units/nanos to google.type.Money.
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

// MoneyFromProto extracts currency/units/nanos from google.type.Money.
func MoneyFromProto(m *commonv1.Money) (string, int64, int32) {
	if m == nil {
		return "", 0, 0
	}
	return m.GetCurrencyCode(), m.GetUnits(), m.GetNanos()
}
