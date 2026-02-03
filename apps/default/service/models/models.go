package models

import (
	"database/sql/driver"
	"encoding/json"
	"fmt"

	commercev1 "buf.build/gen/go/antinvestor/commerce/protocolbuffers/go/commerce/v1"
	"github.com/pitabwire/frame/data"
	money "google.golang.org/genproto/googleapis/type/money"
	"google.golang.org/protobuf/types/known/timestamppb"
	"gorm.io/gorm"
	"gorm.io/gorm/schema"
)

// StringArray stores string slices as JSONB in PostgreSQL.
type StringArray []string

func (s StringArray) ToStringSlice() []string {
	if s == nil {
		return nil
	}
	return []string(s)
}

func (s StringArray) Value() (driver.Value, error) {
	if s == nil {
		return nil, nil
	}
	return json.Marshal(s)
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

func (StringArray) GormDataType() string { return "jsonb" }

func (StringArray) GormDBDataType(db *gorm.DB, _ *schema.Field) string {
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
	MediaIDs    StringArray
	Properties  data.JSONMap
}

func (s *Shop) ToAPI() *commercev1.Shop {
	return &commercev1.Shop{
		Id:          s.ID,
		Name:        s.Name,
		Slug:        s.Slug,
		Description: s.Description,
		Status:      commercev1.ShopStatus(s.Status),
		MediaIds:    s.MediaIDs.ToStringSlice(),
		CreatedAt:   timestamppb.New(s.CreatedAt),
		Extra:       s.Properties.ToProtoStruct(),
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

	Shop     *Shop            `gorm:"foreignKey:ShopID"`
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
	ShopID           string `gorm:"type:varchar(50);index:idx_order_shop_id"`
	OrderNumber      string `gorm:"type:varchar(100);uniqueIndex"`
	IdempotencyKey   string `gorm:"type:varchar(255);uniqueIndex"`
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

	Lines []*OrderLine `gorm:"foreignKey:OrderID"`
	Shop  *Shop        `gorm:"foreignKey:ShopID"`
}

func (o *Order) ToAPI() *commercev1.Order {
	var lines []*commercev1.OrderLine
	for _, line := range o.Lines {
		lines = append(lines, line.ToAPI())
	}

	return &commercev1.Order{
		Id:               o.ID,
		ShopId:           o.ShopID,
		OrderNumber:      o.OrderNumber,
		Status:           commercev1.OrderStatus(o.Status),
		PaymentStatus:    commercev1.PaymentStatus(o.PaymentStatus),
		FulfilmentStatus: commercev1.FulfilmentStatus(o.FulfilmentStatus),
		ProfileId:        o.ProfileID,
		ContactId:        o.ContactID,
		AddressId:        o.AddressID,
		Subtotal:         MoneyToProto(o.SubtotalCurrency, o.SubtotalUnits, o.SubtotalNanos),
		Total:            MoneyToProto(o.TotalCurrency, o.TotalUnits, o.TotalNanos),
		Lines:            lines,
		CreatedAt:        timestamppb.New(o.CreatedAt),
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

// Fulfilment represents a shipment/delivery for an order.
type Fulfilment struct {
	data.BaseModel
	OrderID        string `gorm:"type:varchar(50);index:idx_fulfilment_order_id"`
	Status         int32  `gorm:"default:1"`
	Carrier        string `gorm:"type:varchar(255)"`
	TrackingNumber string `gorm:"type:varchar(255)"`

	Lines []*FulfilmentLine `gorm:"foreignKey:FulfilmentID"`
	Order *Order            `gorm:"foreignKey:OrderID"`
}

func (f *Fulfilment) ToAPI() *commercev1.Fulfilment {
	var lines []*commercev1.FulfilmentLine
	for _, line := range f.Lines {
		lines = append(lines, line.ToAPI())
	}

	return &commercev1.Fulfilment{
		Id:             f.ID,
		OrderId:        f.OrderID,
		Status:         commercev1.FulfilmentStatus(f.Status),
		Carrier:        f.Carrier,
		TrackingNumber: f.TrackingNumber,
		Lines:          lines,
		CreatedAt:      timestamppb.New(f.CreatedAt),
	}
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
func MoneyToProto(currencyCode string, units int64, nanos int32) *money.Money {
	if currencyCode == "" {
		return nil
	}
	return &money.Money{
		CurrencyCode: currencyCode,
		Units:        units,
		Nanos:        nanos,
	}
}

// MoneyFromProto extracts currency/units/nanos from google.type.Money.
func MoneyFromProto(m *money.Money) (string, int64, int32) {
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
