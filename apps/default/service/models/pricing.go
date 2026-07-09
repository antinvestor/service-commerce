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

	commercev1 "buf.build/gen/go/antinvestor/commerce/protocolbuffers/go/v1"
	"github.com/pitabwire/frame/v2/data"
	"google.golang.org/protobuf/types/known/timestamppb"
)

// PriceList represents a named collection of prices for a shop.
type PriceList struct {
	data.BaseModel
	ShopID     string     `gorm:"type:varchar(50);index:idx_pricelist_shop_id"`
	Name       string     `gorm:"type:varchar(255)"`
	Currency   string     `gorm:"type:varchar(3)"`
	Priority   int32      `gorm:"default:0"`
	ValidFrom  *time.Time `gorm:"index:idx_pricelist_validity"`
	ValidUntil *time.Time `gorm:"index:idx_pricelist_validity"`
	Status     int32      `gorm:"default:1"`

	Shop *Shop `gorm:"foreignKey:ShopID"`
}

func (pl *PriceList) ToAPI() *commercev1.PriceList {
	api := &commercev1.PriceList{
		Id:        pl.ID,
		ShopId:    pl.ShopID,
		Name:      pl.Name,
		Currency:  pl.Currency,
		Priority:  pl.Priority,
		Status:    commercev1.PriceListStatus(pl.Status),
		CreatedAt: timestamppb.New(pl.CreatedAt),
	}
	if pl.ValidFrom != nil {
		api.ValidFrom = timestamppb.New(*pl.ValidFrom)
	}
	if pl.ValidUntil != nil {
		api.ValidUntil = timestamppb.New(*pl.ValidUntil)
	}
	return api
}

// PriceListEntry represents a single price entry within a price list.
type PriceListEntry struct {
	data.BaseModel
	PriceListID      string `gorm:"type:varchar(50);index:idx_ple_pricelist_id"`
	ProductVariantID string `gorm:"type:varchar(50);index:idx_ple_variant_id"`
	CurrencyCode     string `gorm:"type:varchar(3)"`
	PriceUnits       int64
	PriceNanos       int32
	MinQuantity      int32 `gorm:"default:0"`
	MaxQuantity      int32 `gorm:"default:0"`

	PriceList *PriceList `gorm:"foreignKey:PriceListID"`
}

func (e *PriceListEntry) ToAPI() *commercev1.PriceListEntry {
	return &commercev1.PriceListEntry{
		Id:               e.ID,
		PriceListId:      e.PriceListID,
		ProductVariantId: e.ProductVariantID,
		UnitPrice:        MoneyToProto(e.CurrencyCode, e.PriceUnits, e.PriceNanos),
		MinQuantity:      e.MinQuantity,
		MaxQuantity:      e.MaxQuantity,
	}
}

// CustomerPriceListAssignment links a customer to a price list.
type CustomerPriceListAssignment struct {
	data.BaseModel
	CustomerID  string `gorm:"type:varchar(50);index:idx_cpla_customer_id"`
	PriceListID string `gorm:"type:varchar(50);index:idx_cpla_pricelist_id"`
	AssignedBy  string `gorm:"type:varchar(50)"`
	Status      int32  `gorm:"default:1"`

	PriceList *PriceList `gorm:"foreignKey:PriceListID"`
}

func (a *CustomerPriceListAssignment) ToAPI() *commercev1.CustomerPriceListAssignment {
	return &commercev1.CustomerPriceListAssignment{
		Id:          a.ID,
		CustomerId:  a.CustomerID,
		PriceListId: a.PriceListID,
		AssignedBy:  a.AssignedBy,
		Status:      commercev1.CustomerPriceListAssignmentStatus(a.Status),
		CreatedAt:   timestamppb.New(a.CreatedAt),
	}
}

// CustomerPriceOverride represents a customer-specific price for a product variant.
type CustomerPriceOverride struct {
	data.BaseModel
	CustomerID       string `gorm:"type:varchar(50);index:idx_cpo_customer_id"`
	ProductVariantID string `gorm:"type:varchar(50);index:idx_cpo_variant_id"`
	CurrencyCode     string `gorm:"type:varchar(3)"`
	PriceUnits       int64
	PriceNanos       int32
	ValidFrom        *time.Time `gorm:"index:idx_cpo_validity"`
	ValidUntil       *time.Time `gorm:"index:idx_cpo_validity"`
	ApprovedBy       string     `gorm:"type:varchar(50)"`
	Status           int32      `gorm:"default:1"`
}

func (o *CustomerPriceOverride) ToAPI() *commercev1.CustomerPriceOverride {
	api := &commercev1.CustomerPriceOverride{
		Id:               o.ID,
		CustomerId:       o.CustomerID,
		ProductVariantId: o.ProductVariantID,
		UnitPrice:        MoneyToProto(o.CurrencyCode, o.PriceUnits, o.PriceNanos),
		ApprovedBy:       o.ApprovedBy,
		Status:           commercev1.CustomerPriceOverrideStatus(o.Status),
		CreatedAt:        timestamppb.New(o.CreatedAt),
	}
	if o.ValidFrom != nil {
		api.ValidFrom = timestamppb.New(*o.ValidFrom)
	}
	if o.ValidUntil != nil {
		api.ValidUntil = timestamppb.New(*o.ValidUntil)
	}
	return api
}

// DiscountRule represents a rule that applies discounts to orders or line items.
type DiscountRule struct {
	data.BaseModel
	ShopID             string `gorm:"type:varchar(50);index:idx_discount_shop_id"`
	Name               string `gorm:"type:varchar(255)"`
	DiscountType       int32  `gorm:"default:0"`
	Value              float64
	AppliesTo          int32 `gorm:"default:0"`
	Conditions         data.JSONMap
	RequiresApproval   bool    `gorm:"default:false"`
	MaxDiscountPercent float64 `gorm:"default:0"`
	ValidFrom          *time.Time
	ValidUntil         *time.Time
	Status             int32 `gorm:"default:1"`

	Shop *Shop `gorm:"foreignKey:ShopID"`
}

func (dr *DiscountRule) ToAPI() *commercev1.DiscountRule {
	api := &commercev1.DiscountRule{
		Id:                 dr.ID,
		ShopId:             dr.ShopID,
		Name:               dr.Name,
		DiscountType:       commercev1.DiscountType(dr.DiscountType),
		Value:              dr.Value,
		AppliesTo:          commercev1.DiscountAppliesTo(dr.AppliesTo),
		Conditions:         dr.Conditions.ToProtoStruct(),
		RequiresApproval:   dr.RequiresApproval,
		MaxDiscountPercent: dr.MaxDiscountPercent,
		Status:             commercev1.DiscountRuleStatus(dr.Status),
		CreatedAt:          timestamppb.New(dr.CreatedAt),
	}
	if dr.ValidFrom != nil {
		api.ValidFrom = timestamppb.New(*dr.ValidFrom)
	}
	if dr.ValidUntil != nil {
		api.ValidUntil = timestamppb.New(*dr.ValidUntil)
	}
	return api
}
