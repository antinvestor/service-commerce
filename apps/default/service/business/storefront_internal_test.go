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
	"net/url"
	"testing"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"github.com/stretchr/testify/require"

	commercev1 "github.com/antinvestor/service-commerce/gen/go/commerce/v1"

	"github.com/antinvestor/service-commerce/apps/default/service/models"
)

func TestSecurePaymentPage(t *testing.T) {
	t.Parallel()
	for raw, want := range map[string]bool{
		"https://pay.example/c/1":       true,
		"http://localhost:8090/pay/1":   true,
		"http://127.0.0.1:8090/pay/1":   true,
		"http://[::1]:8090/pay/1":       true,
		"http://pay.example/c/1":        false,
		"http://localhost.evil.io/c/1":  false,
		"http://127.0.0.1.nip.io/pay/1": false,
		"javascript://localhost/x":      false,
	} {
		u, err := url.Parse(raw)
		require.NoError(t, err)
		require.Equal(t, want, securePaymentPage(u), raw)
	}
}

func TestVisitorGroup(t *testing.T) {
	t.Parallel()
	for address, want := range map[string]string{
		"203.0.113.7":          "203.0.113.7",
		"::ffff:203.0.113.7":   "203.0.113.7",
		"2001:db8:1:2::1":      "2001:db8:1:2::/64",
		"2001:db8:1:2:ffff::9": "2001:db8:1:2::/64",
		"2001:db8:1:3::1":      "2001:db8:1:3::/64",
		"":                     "unknown",
		"not an address":       "unknown",
		" 198.51.100.2 ":       "198.51.100.2",
	} {
		require.Equal(t, want, VisitorGroup(address), address)
	}
}

func TestContactDigestIgnoresHowItWasTyped(t *testing.T) {
	t.Parallel()
	require.Equal(t, contactDigest("Jane@Example.com "), contactDigest("jane@example.com"))
	require.Equal(t, contactDigest("+254 700-000 001"), contactDigest("+254700000001"))
	require.NotContains(t, contactDigest("jane@example.com"), "jane")
}

func TestFixedDiscountOnlyInItsOwnCurrency(t *testing.T) {
	t.Parallel()
	rule := &models.DiscountRule{
		DiscountType:   int32(commercev1.DiscountType_DISCOUNT_TYPE_FIXED_AMOUNT),
		Value:          2.5,
		AmountCurrency: "USD", AmountUnits: 2, AmountNanos: 500_000_000,
	}
	require.Equal(t, int64(2_500_000_000), calculateDiscount(rule, &commonv1.Money{CurrencyCode: "USD", Units: 10}))
	require.Zero(t, calculateDiscount(rule, &commonv1.Money{CurrencyCode: "KES", Units: 10}),
		"2.50 USD is not 2.50 KES")
	rule.AmountCurrency = ""
	require.Zero(t, calculateDiscount(rule, &commonv1.Money{CurrencyCode: "USD", Units: 10}),
		"an amount with no currency gives nothing away")
}
