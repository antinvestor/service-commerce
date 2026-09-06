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
	"database/sql/driver"
	"encoding/json"
	"fmt"
	"time"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"github.com/pitabwire/frame/v2/data"
	"google.golang.org/protobuf/types/known/timestamppb"
	"gorm.io/gorm"
	"gorm.io/gorm/schema"

	commercev1 "github.com/antinvestor/service-commerce/gen/go/commerce/v1"
)

// StringArray stores string slices as JSONB in PostgreSQL.
type StringArray []string

func (s *StringArray) ToStringSlice() []string {
	if s == nil || *s == nil {
		return nil
	}
	return []string(*s)
}

func (s *StringArray) Value() (driver.Value, error) {
	if s == nil || *s == nil {
		return "[]", nil
	}
	return json.Marshal(*s)
}

func (s *StringArray) Scan(value any) error {
	if value == nil {
		*s = nil
		return nil
	}
	b, ok := value.([]byte)
	if !ok {
		return fmt.Errorf("StringArray.Scan: expected []byte, got %T", value)
	}
	return json.Unmarshal(b, s)
}

func (*StringArray) GormDataType() string { return "jsonb" }

func (*StringArray) GormDBDataType(db *gorm.DB, _ *schema.Field) string {
	switch db.Dialector.Name() {
	case "postgres":
		return "JSONB"
	default:
		return "JSON"
	}
}

// Shop represents a storefront entity.
type Shop struct {
	data.BaseModel
	Name        string `gorm:"type:varchar(255)"`
	Slug        string `gorm:"type:varchar(255);uniqueIndex"`
	Description string `gorm:"type:text"`
	Status      int32  `gorm:"default:1"`
	// Currency is the ISO 4217 code every variant in the shop is priced in.
	Currency string `gorm:"type:varchar(3)"`
	// ContactID receives seller-side notifications.
	ContactID string `gorm:"type:varchar(50)"`
	// CheckoutReturnURL overrides the service default return page.
	CheckoutReturnURL string `gorm:"type:varchar(1024)"`
	MediaIDs          StringArray
	Properties        data.JSONMap
}

func (s *Shop) ToAPI() *commercev1.Shop {
	return &commercev1.Shop{
		Id:                s.ID,
		Name:              s.Name,
		Slug:              s.Slug,
		Description:       s.Description,
		Status:            commercev1.ShopStatus(s.Status),
		Currency:          s.Currency,
		ContactId:         s.ContactID,
		CheckoutReturnUrl: s.CheckoutReturnURL,
		MediaIds:          s.MediaIDs.ToStringSlice(),
		CreatedAt:         timestamppb.New(s.CreatedAt),
		Extra:             s.Properties.ToProtoStruct(),
	}
}

// Product represents a catalog item.
type Product struct {
	data.BaseModel
	ShopID         string `gorm:"type:varchar(50);index:idx_product_shop_id"`
	Name           string `gorm:"type:varchar(255)"`
	Description    string `gorm:"type:text"`
	Attributes     data.JSONMap
	FulfilmentType int32 `gorm:"default:0"`
	Status         int32 `gorm:"default:1"`
	MediaIDs       StringArray

	Shop     *Shop             `gorm:"foreignKey:ShopID"`
	Variants []*ProductVariant `gorm:"foreignKey:ProductID"`
}

func (p *Product) ToAPI() *commercev1.Product {
	attrs := mapFromJSONMap(p.Attributes)

	return &commercev1.Product{
		Id:             p.ID,
		ShopId:         p.ShopID,
		Name:           p.Name,
		Description:    p.Description,
		Attributes:     attrs,
		FulfilmentType: commercev1.FulfilmentType(p.FulfilmentType),
		Status:         commercev1.ProductStatus(p.Status),
		MediaIds:       p.MediaIDs.ToStringSlice(),
		CreatedAt:      timestamppb.New(p.CreatedAt),
	}
}

// ProductVariant represents a specific variant of a product.
type ProductVariant struct {
	data.BaseModel
	ProductID     string `gorm:"type:varchar(50);index:idx_variant_product_id"`
	SKU           string `gorm:"type:varchar(255);uniqueIndex"`
	Name          string `gorm:"type:varchar(255)"`
	CurrencyCode  string `gorm:"type:varchar(3)"`
	PriceUnits    int64
	PriceNanos    int32
	StockQuantity int64
	Attributes    data.JSONMap
	MediaIDs      StringArray
	Status        int32 `gorm:"default:1"`

	Product *Product `gorm:"foreignKey:ProductID"`
}

func (pv *ProductVariant) ToAPI() *commercev1.ProductVariant {
	attrs := mapFromJSONMap(pv.Attributes)

	return &commercev1.ProductVariant{
		Id:            pv.ID,
		ProductId:     pv.ProductID,
		Sku:           pv.SKU,
		Name:          pv.Name,
		Price:         MoneyToProto(pv.CurrencyCode, pv.PriceUnits, pv.PriceNanos),
		StockQuantity: pv.StockQuantity,
		Attributes:    attrs,
		MediaIds:      pv.MediaIDs.ToStringSlice(),
		Status:        commercev1.ProductVariantStatus(pv.Status),
		CreatedAt:     timestamppb.New(pv.CreatedAt),
	}
}

// Cart represents a shopping cart.
type Cart struct {
	data.BaseModel
	ShopID    string `gorm:"type:varchar(50);index:idx_cart_shop_id"`
	Status    int32  `gorm:"default:1"`
	ProfileID string `gorm:"type:varchar(50);index:idx_cart_profile_id"`
	ContactID string `gorm:"type:varchar(50)"`

	Lines []*CartLine `gorm:"foreignKey:CartID"`
	Shop  *Shop       `gorm:"foreignKey:ShopID"`
}

func (c *Cart) ToAPI() *commercev1.Cart {
	var lines []*commercev1.CartLine
	for _, line := range c.Lines {
		lines = append(lines, line.ToAPI())
	}

	return &commercev1.Cart{
		Id:        c.ID,
		ShopId:    c.ShopID,
		Status:    commercev1.CartStatus(c.Status),
		ProfileId: c.ProfileID,
		ContactId: c.ContactID,
		Lines:     lines,
		CreatedAt: timestamppb.New(c.CreatedAt),
		UpdatedAt: timestamppb.New(c.ModifiedAt),
	}
}

// CartLine represents a line item in a cart.
type CartLine struct {
	data.BaseModel
	CartID           string `gorm:"type:varchar(50);index:idx_cartline_cart_id"`
	ProductVariantID string `gorm:"type:varchar(50)"`
	Quantity         int64

	Cart           *Cart           `gorm:"foreignKey:CartID"`
	ProductVariant *ProductVariant `gorm:"foreignKey:ProductVariantID"`
}

func (cl *CartLine) ToAPI() *commercev1.CartLine {
	return &commercev1.CartLine{
		Id:               cl.ID,
		ProductVariantId: cl.ProductVariantID,
		Quantity:         cl.Quantity,
	}
}

// Order represents a completed order.
type Order struct {
	data.BaseModel
	ShopID      string `gorm:"type:varchar(50);index:idx_order_shop_id;uniqueIndex:idx_order_shop_number"`
	OrderNumber string `gorm:"type:varchar(100);uniqueIndex:idx_order_shop_number"`
	// IdempotencyKey deduplicates retried creates. RequestHash fingerprints the
	// request so a reused key with different content is rejected instead of
	// silently returning an unrelated order.
	IdempotencyKey   string `gorm:"type:varchar(255);uniqueIndex"`
	RequestHash      string `gorm:"type:varchar(64)"`
	Status           int32  `gorm:"default:1"`
	PaymentStatus    int32  `gorm:"default:1"`
	FulfilmentStatus int32  `gorm:"default:0"`
	ProfileID        string `gorm:"type:varchar(50);index:idx_order_profile_id"`
	ContactID        string `gorm:"type:varchar(50)"`
	AddressID        string `gorm:"type:varchar(50)"`
	SubtotalCurrency string `gorm:"type:varchar(3)"`
	SubtotalUnits    int64
	SubtotalNanos    int32
	TotalCurrency    string `gorm:"type:varchar(3)"`
	TotalUnits       int64
	TotalNanos       int32

	// Payment lifecycle. PaymentSessionRef is the hosted checkout session;
	// PaymentID arrives when that session completes. PaymentDueAt bounds the
	// stock reservation for an unpaid order.
	PaymentSessionRef   string `gorm:"type:varchar(64);index:idx_order_payment_session"`
	CheckoutURL         string `gorm:"type:varchar(1024)"`
	PaymentID           string `gorm:"type:varchar(64)"`
	PaymentDueAt        *time.Time
	PaidAt              *time.Time `gorm:"index:idx_order_paid_at"`
	CancelledAt         *time.Time
	CancelReason        string `gorm:"type:varchar(255)"`
	LedgerTransactionID string `gorm:"type:varchar(64);index:idx_order_ledger_txn"`
	// RefundLedgerTransactionID is set separately because a refund may be
	// merged on a later trading day than the sale it reverses.
	RefundLedgerTransactionID string `gorm:"type:varchar(64)"`

	Lines []*OrderLine `gorm:"foreignKey:OrderID"`
	Shop  *Shop        `gorm:"foreignKey:ShopID"`
}

func (o *Order) ToAPI() *commercev1.Order {
	var lines []*commercev1.OrderLine
	for _, line := range o.Lines {
		lines = append(lines, line.ToAPI())
	}

	api := &commercev1.Order{
		Id:                  o.ID,
		ShopId:              o.ShopID,
		OrderNumber:         o.OrderNumber,
		Status:              commercev1.OrderStatus(o.Status),
		PaymentStatus:       commercev1.PaymentStatus(o.PaymentStatus),
		FulfilmentStatus:    commercev1.FulfilmentStatus(o.FulfilmentStatus),
		ProfileId:           o.ProfileID,
		ContactId:           o.ContactID,
		AddressId:           o.AddressID,
		Subtotal:            MoneyToProto(o.SubtotalCurrency, o.SubtotalUnits, o.SubtotalNanos),
		Total:               MoneyToProto(o.TotalCurrency, o.TotalUnits, o.TotalNanos),
		Lines:               lines,
		CreatedAt:           timestamppb.New(o.CreatedAt),
		PaymentSessionRef:   o.PaymentSessionRef,
		CheckoutUrl:         o.CheckoutURL,
		PaymentId:           o.PaymentID,
		CancelReason:        o.CancelReason,
		LedgerTransactionId: o.LedgerTransactionID,
	}
	if o.PaidAt != nil {
		api.PaidAt = timestamppb.New(*o.PaidAt)
	}
	if o.CancelledAt != nil {
		api.CancelledAt = timestamppb.New(*o.CancelledAt)
	}
	return api
}

// TotalNanosValue is the order total as a single nanos integer.
func (o *Order) TotalNanosValue() int64 {
	return o.TotalUnits*nanosPerUnit + int64(o.TotalNanos)
}

const nanosPerUnit int64 = 1_000_000_000

// LedgerPosting records one end-of-day merge for a shop and trading day, so
// a re-run is idempotent and the ledger transaction can be traced back.
type LedgerPosting struct {
	data.BaseModel
	ShopID        string `gorm:"type:varchar(50);uniqueIndex:idx_ledger_posting_shop_day"`
	TradingDay    string `gorm:"type:varchar(10);uniqueIndex:idx_ledger_posting_shop_day"`
	TransactionID string `gorm:"type:varchar(64)"`
	Currency      string `gorm:"type:varchar(3)"`
	SalesNanos    int64
	RefundNanos   int64
	OrderCount    int32
	Status        int32  `gorm:"default:1"`
	Error         string `gorm:"type:text"`
}

// LedgerPosting statuses.
const (
	LedgerPostingPosted  int32 = 1
	LedgerPostingSkipped int32 = 2
	LedgerPostingFailed  int32 = 3
)

func (lp *LedgerPosting) ToAPI() *commercev1.LedgerPosting {
	return &commercev1.LedgerPosting{
		ShopId:        lp.ShopID,
		Date:          lp.TradingDay,
		TransactionId: lp.TransactionID,
		Sales:         MoneyToProto(lp.Currency, lp.SalesNanos/nanosPerUnit, int32(lp.SalesNanos%nanosPerUnit)),
		Refunds:       MoneyToProto(lp.Currency, lp.RefundNanos/nanosPerUnit, int32(lp.RefundNanos%nanosPerUnit)),
		Orders:        lp.OrderCount,
		Skipped:       lp.Status == LedgerPostingSkipped,
		Error:         lp.Error,
	}
}

// OrderLine represents a line item in an order with snapshotted prices.
type OrderLine struct {
	data.BaseModel
	OrderID            string `gorm:"type:varchar(50);index:idx_orderline_order_id"`
	ProductVariantID   string `gorm:"type:varchar(50)"`
	SKUSnapshot        string `gorm:"type:varchar(255)"`
	NameSnapshot       string `gorm:"type:varchar(255)"`
	UnitPriceCurrency  string `gorm:"type:varchar(3)"`
	UnitPriceUnits     int64
	UnitPriceNanos     int32
	Quantity           int64
	TotalPriceCurrency string `gorm:"type:varchar(3)"`
	TotalPriceUnits    int64
	TotalPriceNanos    int32

	Order *Order `gorm:"foreignKey:OrderID"`
}

func (ol *OrderLine) ToAPI() *commercev1.OrderLine {
	return &commercev1.OrderLine{
		Id:               ol.ID,
		ProductVariantId: ol.ProductVariantID,
		SkuSnapshot:      ol.SKUSnapshot,
		NameSnapshot:     ol.NameSnapshot,
		UnitPrice:        MoneyToProto(ol.UnitPriceCurrency, ol.UnitPriceUnits, ol.UnitPriceNanos),
		Quantity:         ol.Quantity,
		TotalPrice:       MoneyToProto(ol.TotalPriceCurrency, ol.TotalPriceUnits, ol.TotalPriceNanos),
	}
}

// OrderSequence hands out per-shop, human-readable order numbers. One row per
// shop; the counter is advanced under a row lock inside the order transaction.
type OrderSequence struct {
	data.BaseModel
	ShopID     string `gorm:"type:varchar(50);uniqueIndex"`
	LastNumber int64
}

// Fulfilment represents a shipment/delivery for an order.
type Fulfilment struct {
	data.BaseModel
	OrderID        string `gorm:"type:varchar(50);index:idx_fulfilment_order_id"`
	Status         int32  `gorm:"default:1"`
	Carrier        string `gorm:"type:varchar(255)"`
	TrackingNumber string `gorm:"type:varchar(255)"`
	ShippedAt      *time.Time

	Lines []*FulfilmentLine `gorm:"foreignKey:FulfilmentID"`
	Order *Order            `gorm:"foreignKey:OrderID"`
}

func (f *Fulfilment) ToAPI() *commercev1.Fulfilment {
	var lines []*commercev1.FulfilmentLine
	for _, line := range f.Lines {
		lines = append(lines, line.ToAPI())
	}

	api := &commercev1.Fulfilment{
		Id:             f.ID,
		OrderId:        f.OrderID,
		Status:         commercev1.FulfilmentStatus(f.Status),
		Carrier:        f.Carrier,
		TrackingNumber: f.TrackingNumber,
		Lines:          lines,
		CreatedAt:      timestamppb.New(f.CreatedAt),
	}
	if f.ShippedAt != nil {
		api.ShippedAt = timestamppb.New(*f.ShippedAt)
	}
	return api
}

// FulfilmentLine represents a line item in a fulfilment.
type FulfilmentLine struct {
	data.BaseModel
	FulfilmentID string `gorm:"type:varchar(50);index:idx_fulfilmentline_fulfilment_id"`
	OrderLineID  string `gorm:"type:varchar(50)"`
	Quantity     int64

	Fulfilment *Fulfilment `gorm:"foreignKey:FulfilmentID"`
}

func (fl *FulfilmentLine) ToAPI() *commercev1.FulfilmentLine {
	return &commercev1.FulfilmentLine{
		OrderLineId: fl.OrderLineID,
		Quantity:    fl.Quantity,
	}
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

// mapFromJSONMap converts data.JSONMap to map[string]string.
func mapFromJSONMap(jm data.JSONMap) map[string]string {
	result := make(map[string]string, len(jm))
	for k, v := range jm {
		result[k] = fmt.Sprintf("%v", v)
	}
	return result
}

// MapToJSONMap converts map[string]string to data.JSONMap.
func MapToJSONMap(m map[string]string) data.JSONMap {
	result := make(data.JSONMap, len(m))
	for k, v := range m {
		result[k] = v
	}
	return result
}
