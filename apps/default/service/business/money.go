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
	"context"
	"fmt"
	"math"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"connectrpc.com/connect/v2"

	"github.com/antinvestor/service-commerce/apps/default/service/repository"
)

// maxPriceUnits bounds a price so that it and its line totals fit the
// integers they are kept in.
const maxPriceUnits = 1_000_000_000

// validateMoney checks a price a caller set: a known ISO 4217 currency,
// equal to shopCurrency when the shop has one, never negative, nanos in
// [0, 1e9), and below maxPriceUnits. what names the field in errors. It
// returns the money with its currency code normalised.
func validateMoney(m *commonv1.Money, shopCurrency, what string) (*commonv1.Money, error) {
	invalid := func(format string, args ...any) error {
		return connect.NewError(connect.CodeInvalidArgument, fmt.Sprintf(format, args...))
	}
	if m == nil {
		return nil, invalid("%s is required", what)
	}
	code := normalizeCurrency(m.GetCurrencyCode())
	if code == "" {
		return nil, invalid("%s needs an ISO 4217 currency", what)
	}
	if shopCurrency != "" && code != shopCurrency {
		return nil, invalid("%s must be in the shop's currency, %s", what, shopCurrency)
	}
	if m.GetUnits() < 0 || m.GetNanos() < 0 || m.GetNanos() >= int32(nanosPerUnit) {
		return nil, invalid("%s must be a positive amount or zero", what)
	}
	if m.GetUnits() >= maxPriceUnits {
		return nil, invalid("%s is too large", what)
	}
	return &commonv1.Money{CurrencyCode: code, Units: m.GetUnits(), Nanos: m.GetNanos()}, nil
}

// moneyFromDecimal converts an amount entered as a decimal number to money
// in currency, rounded to the cent.
func moneyFromDecimal(value float64, currency, what string) (*commonv1.Money, error) {
	if math.IsNaN(value) || math.IsInf(value, 0) || value < 0 || value >= maxPriceUnits {
		return nil, connect.NewError(connect.CodeInvalidArgument,
			fmt.Sprintf("%s must be a positive amount or zero", what))
	}
	cents := int64(math.Round(value * 100)) //nolint:mnd // cents
	return &commonv1.Money{
		CurrencyCode: currency,
		Units:        cents / 100,                            //nolint:mnd // cents
		Nanos:        int32(cents%100) * int32(nanosPerCent), //nolint:mnd // cents
	}, nil
}

// shopCurrency is the currency the shop prices in; "" when it has none.
func shopCurrency(ctx context.Context, shops repository.ShopRepository, shopID string) (string, error) {
	shop, err := shops.GetByID(ctx, shopID)
	if err != nil {
		return "", connect.NewError(connect.CodeNotFound, "shop not found")
	}
	return normalizeCurrency(shop.Currency), nil
}
