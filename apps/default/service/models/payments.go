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
	"slices"
	"time"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"github.com/pitabwire/frame/v2/data"
	"google.golang.org/protobuf/types/known/timestamppb"
	"gorm.io/gorm"
	"gorm.io/gorm/schema"

	commercev1 "github.com/antinvestor/service-commerce/gen/go/commerce/v1"
)

// PaymentPolicy is the stored form of commercev1.PaymentPolicy. A nil
// *PaymentPolicy column means "not set".
type PaymentPolicy struct {
	AllowInstalments     bool    `json:"allow_instalments,omitempty"`
	MinDepositPercent    int32   `json:"min_deposit_percent,omitempty"`
	MinInstalmentPercent int32   `json:"min_instalment_percent,omitempty"`
	BalanceDueDays       int32   `json:"balance_due_days,omitempty"`
	FulfilAtPercent      int32   `json:"fulfil_at_percent,omitempty"`
	SignalThresholds     []int32 `json:"signal_thresholds,omitempty"`
	CancelWhenOverdue    bool    `json:"cancel_when_overdue,omitempty"`
}

func (*PaymentPolicy) GormDataType() string { return "jsonb" }

func (*PaymentPolicy) GormDBDataType(db *gorm.DB, _ *schema.Field) string {
	if db.Dialector.Name() == "postgres" {
		return "JSONB"
	}
	return "JSON"
}

func (p *PaymentPolicy) Value() (driver.Value, error) {
	if p == nil {
		return nil, nil //nolint:nilnil // SQL NULL
	}
	return json.Marshal(p)
}

func (p *PaymentPolicy) Scan(value any) error {
	if value == nil {
		return nil
	}
	var b []byte
	switch v := value.(type) {
	case []byte:
		b = v
	case string:
		b = []byte(v)
	default:
		return fmt.Errorf("PaymentPolicy.Scan: expected []byte, got %T", value)
	}
	return json.Unmarshal(b, p)
}

// PaymentPolicyFromAPI converts the API form; nil stays nil. Thresholds are
// sorted and deduplicated.
func PaymentPolicyFromAPI(p *commercev1.PaymentPolicy) *PaymentPolicy {
	if p == nil {
		return nil
	}
	thresholds := slices.Clone(p.GetSignalThresholds())
	slices.Sort(thresholds)
	return &PaymentPolicy{
		AllowInstalments:     p.GetAllowInstalments(),
		MinDepositPercent:    p.GetMinDepositPercent(),
		MinInstalmentPercent: p.GetMinInstalmentPercent(),
		BalanceDueDays:       p.GetBalanceDueDays(),
		FulfilAtPercent:      p.GetFulfilAtPercent(),
		SignalThresholds:     slices.Compact(thresholds),
		CancelWhenOverdue:    p.GetCancelWhenOverdue(),
	}
}

// ToAPI converts to the API form; nil stays nil.
func (p *PaymentPolicy) ToAPI() *commercev1.PaymentPolicy {
	if p == nil {
		return nil
	}
	return &commercev1.PaymentPolicy{
		AllowInstalments:     p.AllowInstalments,
		MinDepositPercent:    p.MinDepositPercent,
		MinInstalmentPercent: p.MinInstalmentPercent,
		BalanceDueDays:       p.BalanceDueDays,
		FulfilAtPercent:      p.FulfilAtPercent,
		SignalThresholds:     slices.Clone(p.SignalThresholds),
		CancelWhenOverdue:    p.CancelWhenOverdue,
	}
}

// OrderPayment is one instalment applied to an order. SessionRef or
// Reference is unique per order so a payment is never applied twice.
type OrderPayment struct {
	data.BaseModel
	OrderID  string `gorm:"type:varchar(50);index:idx_order_payment_order;uniqueIndex:idx_order_payment_reference"`
	ShopID   string `gorm:"type:varchar(50);index:idx_order_payment_shop_paid"`
	Source   int32
	Currency string `gorm:"type:varchar(3)"`
	// AmountNanos is the instalment in nanos of Currency.
	AmountNanos int64
	// Reference is the checkout session ref or the shop's receipt reference.
	Reference  string    `gorm:"type:varchar(100);uniqueIndex:idx_order_payment_reference"`
	PaymentID  string    `gorm:"type:varchar(64)"`
	PaidAt     time.Time `gorm:"index:idx_order_payment_shop_paid"`
	RecordedBy string    `gorm:"type:varchar(50)"`
	Note       string    `gorm:"type:varchar(500)"`
	// LedgerTransactionID is the end-of-day transaction the instalment was
	// merged into.
	LedgerTransactionID string `gorm:"type:varchar(64);index:idx_order_payment_ledger"`
}

func (op *OrderPayment) ToAPI() *commercev1.OrderPayment {
	return &commercev1.OrderPayment{
		Id:         op.ID,
		Amount:     MoneyFromNanos(op.Currency, op.AmountNanos),
		Source:     commercev1.OrderPaymentSource(op.Source),
		Reference:  op.Reference,
		PaymentId:  op.PaymentID,
		PaidAt:     timestamppb.New(op.PaidAt),
		RecordedBy: op.RecordedBy,
		Note:       op.Note,
	}
}

// Order event delivery states, mirroring commercev1.OrderEventDelivery.
const (
	EventDeliveryNotRequired = int32(commercev1.OrderEventDelivery_ORDER_EVENT_DELIVERY_NOT_REQUIRED)
	EventDeliveryPending     = int32(commercev1.OrderEventDelivery_ORDER_EVENT_DELIVERY_PENDING)
	EventDeliveryDelivered   = int32(commercev1.OrderEventDelivery_ORDER_EVENT_DELIVERY_DELIVERED)
	EventDeliveryFailed      = int32(commercev1.OrderEventDelivery_ORDER_EVENT_DELIVERY_FAILED)
)

// OrderEvent is a signal about an order, stored in the same transaction as
// the change that raised it so it is never lost; webhook delivery is tracked
// on the row (a transactional outbox).
type OrderEvent struct {
	data.BaseModel
	ShopID           string `gorm:"type:varchar(50);index:idx_order_event_shop"`
	OrderID          string `gorm:"type:varchar(50);index:idx_order_event_order"`
	OrderNumber      string `gorm:"type:varchar(100)"`
	Type             int32
	ThresholdPercent int32
	PaidPercent      int32
	Currency         string `gorm:"type:varchar(3)"`
	AmountPaidNanos  int64
	BalanceNanos     int64
	PaymentNanos     int64

	Delivery         int32 `gorm:"index:idx_order_event_delivery"`
	DeliveryAttempts int32
	NextAttemptAt    *time.Time `gorm:"index:idx_order_event_delivery"`
	DeliveredAt      *time.Time
	LastError        string `gorm:"type:text"`
}

func (e *OrderEvent) ToAPI() *commercev1.OrderEvent {
	api := &commercev1.OrderEvent{
		Id:               e.ID,
		ShopId:           e.ShopID,
		OrderId:          e.OrderID,
		OrderNumber:      e.OrderNumber,
		Type:             commercev1.OrderEventType(e.Type),
		ThresholdPercent: e.ThresholdPercent,
		PaidPercent:      e.PaidPercent,
		AmountPaid:       MoneyFromNanos(e.Currency, e.AmountPaidNanos),
		Balance:          MoneyFromNanos(e.Currency, e.BalanceNanos),
		CreatedAt:        timestamppb.New(e.CreatedAt),
		Delivery:         commercev1.OrderEventDelivery(e.Delivery),
	}
	if e.PaymentNanos != 0 {
		api.PaymentAmount = MoneyFromNanos(e.Currency, e.PaymentNanos)
	}
	return api
}

// MoneyFromNanos converts a nanos amount to the API money type.
func MoneyFromNanos(currency string, nanos int64) *commonv1.Money {
	return MoneyToProto(currency, nanos/nanosPerUnit, int32(nanos%nanosPerUnit))
}

// MoneyNanos folds units and nanos into one nanos integer.
func MoneyNanos(units int64, nanos int32) int64 {
	return units*nanosPerUnit + int64(nanos)
}
