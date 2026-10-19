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

package business

import (
	"testing"
	"time"

	"github.com/stretchr/testify/require"

	"github.com/antinvestor/service-commerce/apps/default/service/models"
	commercev1 "github.com/antinvestor/service-commerce/gen/go/commerce/v1"
)

func TestMergePolicies(t *testing.T) {
	t.Parallel()

	require.Nil(t, mergePolicies([]*models.PaymentPolicy{nil, nil}), "no policy anywhere means pay in full")

	shop := &models.PaymentPolicy{
		AllowInstalments: true, MinDepositPercent: 20, MinInstalmentPercent: 10,
		BalanceDueDays: 30, FulfilAtPercent: 50, SignalThresholds: []int32{50},
	}
	product := &models.PaymentPolicy{
		AllowInstalments: true, MinDepositPercent: 40, BalanceDueDays: 7,
		SignalThresholds: []int32{25, 50}, CancelWhenOverdue: true,
	}
	merged := mergePolicies([]*models.PaymentPolicy{shop, product})
	require.True(t, merged.AllowInstalments)
	require.Equal(t, int32(40), merged.MinDepositPercent)
	require.Equal(t, int32(10), merged.MinInstalmentPercent)
	require.Equal(t, int32(7), merged.BalanceDueDays)
	require.Equal(t, int32(0), merged.FulfilAtPercent, "a line needing full payment wins")
	require.Equal(t, []int32{25, 50}, merged.SignalThresholds)
	require.True(t, merged.CancelWhenOverdue)

	mixed := mergePolicies([]*models.PaymentPolicy{shop, nil})
	require.False(t, mixed.AllowInstalments, "a pay-in-full line forbids instalments for the order")
}

func TestPercentOfCeilCents(t *testing.T) {
	t.Parallel()
	const unit = int64(1_000_000_000)
	require.Equal(t, 6*unit+300_000_000, percentOfCeilCents(21*unit, 30))
	// 33% of 10.01 is 3.3033, rounded up to 3.31.
	require.Equal(t, 3*unit+310_000_000, percentOfCeilCents(10*unit+10_000_000, 33))
	require.Equal(t, int64(0), percentOfCeilCents(21*unit, 0))
	// Large totals do not overflow.
	require.Equal(t, 4_000_000_000*unit, percentOfCeilCents(8_000_000_000*unit, 50))
}

func TestInstalmentRange(t *testing.T) {
	t.Parallel()
	const unit = int64(1_000_000_000)
	order := &models.Order{TotalCurrency: "USD", TotalUnits: 21}
	minimum, maximum := instalmentRange(order)
	require.Equal(t, 21*unit, minimum, "without a policy the whole balance is due")
	require.Equal(t, 21*unit, maximum)

	order.PaymentPolicy = &models.PaymentPolicy{AllowInstalments: true, MinDepositPercent: 30, MinInstalmentPercent: 20}
	minimum, _ = instalmentRange(order)
	require.Equal(t, 6*unit+300_000_000, minimum)

	order.AmountPaidNanos = 18 * unit
	minimum, maximum = instalmentRange(order)
	require.Equal(t, 3*unit, minimum, "the minimum never exceeds the balance")
	require.Equal(t, 3*unit, maximum)
}

func TestPaymentTransitionOnCancelledOrderSignalsOverpayment(t *testing.T) {
	t.Parallel()
	order := &models.Order{
		TotalCurrency: "USD", TotalUnits: 10,
		Status: int32(commercev1.OrderStatus_ORDER_STATUS_CANCELLED),
	}
	payment := &models.OrderPayment{AmountNanos: 10_000_000_000, Reference: "cs_late"}
	order.AmountPaidNanos = payment.AmountNanos
	events := paymentTransition(&models.Shop{}, time.Now())(order, payment)
	require.Len(t, events, 2)
	require.Equal(t, int32(commercev1.OrderEventType_ORDER_EVENT_TYPE_OVERPAID), events[1].Type)
	require.Equal(t, int32(commercev1.OrderStatus_ORDER_STATUS_CANCELLED), order.Status, "state is left alone")
}

func TestValidateWebhookURL(t *testing.T) {
	t.Parallel()
	for raw, ok := range map[string]bool{
		"":                                 true,
		"https://hooks.example.com/x":      true,
		"http://hooks.example.com/x":       false,
		"https://localhost/x":              false,
		"https://10.0.0.5/x":               false,
		"https://169.254.169.254/latest":   false,
		"https://[::1]/x":                  false,
		"https://user:pw@hooks.example/x":  false,
		"https://8.8.8.8/x":                true,
		"https://metadata.google.internal": false,
	} {
		err := validateWebhookURL(raw)
		if ok {
			require.NoError(t, err, raw)
		} else {
			require.Error(t, err, raw)
		}
	}
}

func TestRetryDelay(t *testing.T) {
	t.Parallel()
	require.Equal(t, time.Minute, retryDelay(1))
	require.Equal(t, 4*time.Minute, retryDelay(3))
	require.Equal(t, maxRetryDelay, retryDelay(30))
}
