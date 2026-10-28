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
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"math/big"
	"strings"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"connectrpc.com/connect/v2"
	"golang.org/x/text/currency"
	"google.golang.org/protobuf/proto"

	"github.com/antinvestor/service-commerce/apps/procurement/service/models"
)

const nanosPerUnit = 1_000_000_000

// unitPrice checks a supplier price: a known ISO 4217 currency, not
// negative, nanos within a unit and of the same sign as units.
func unitPrice(m *commonv1.Money) (string, int64, int32, error) {
	if m == nil {
		return "", 0, 0, connect.NewError(connect.CodeInvalidArgument, "unit_price is required")
	}
	code := strings.ToUpper(strings.TrimSpace(m.GetCurrencyCode()))
	if _, err := currency.ParseISO(code); err != nil || len(code) != 3 {
		return "", 0, 0, connect.NewError(connect.CodeInvalidArgument,
			fmt.Sprintf("unit_price currency %q is not an ISO 4217 code", m.GetCurrencyCode()))
	}
	if m.GetUnits() < 0 || m.GetNanos() < 0 || m.GetNanos() >= nanosPerUnit {
		return "", 0, 0, connect.NewError(connect.CodeInvalidArgument,
			"unit_price must not be negative and nanos must be below one unit")
	}
	if m.GetUnits() > (1<<63-1)/nanosPerUnit-1 {
		return "", 0, 0, connect.NewError(connect.CodeInvalidArgument, "unit_price is too large")
	}
	return code, m.GetUnits(), m.GetNanos(), nil
}

// quantityArg converts an API quantity, which must not be negative.
func quantityArg(field string, f float64) (models.Quantity, error) {
	q, err := models.QuantityFromFloat(f)
	if err != nil || q < 0 {
		return 0, connect.NewError(connect.CodeInvalidArgument,
			fmt.Sprintf("%s must be a non-negative number with at most %d decimal places", field, models.QuantityScale))
	}
	return q, nil
}

// lineTotal is quantity × price in nanos, rounded half up to the nano, in
// arbitrary precision.
func lineTotal(units int64, nanos int32, quantity models.Quantity) *big.Int {
	const microsPerUnit, halfMicros = 1_000_000, 500_000
	price := new(big.Int).Mul(big.NewInt(units), big.NewInt(nanosPerUnit))
	price.Add(price, big.NewInt(int64(nanos)))
	total := price.Mul(price, big.NewInt(quantity.Micros()))
	total.Add(total, big.NewInt(halfMicros))
	return total.Quo(total, big.NewInt(microsPerUnit))
}

// moneyFromNanos splits a total in nanos into units and nanos, refusing a
// total whose units overflow.
func moneyFromNanos(total *big.Int) (int64, int32, error) {
	q, r := new(big.Int).QuoRem(total, big.NewInt(nanosPerUnit), new(big.Int))
	if !q.IsInt64() {
		return 0, 0, connect.NewError(connect.CodeInvalidArgument, "order total is too large")
	}
	return q.Int64(), int32(r.Int64()), nil //nolint:gosec // a remainder of division by 10^9 fits
}

// keyed is a create request carrying an idempotency key.
type keyed interface {
	proto.Message
	SetIdempotencyKey(string)
}

// fingerprint identifies a request's content, ignoring its idempotency key,
// so a replayed key is answered only for the same request.
func fingerprint[M keyed](msg M) string {
	clone := proto.CloneOf(msg)
	clone.SetIdempotencyKey("")
	raw, err := proto.MarshalOptions{Deterministic: true}.Marshal(clone)
	if err != nil {
		return ""
	}
	sum := sha256.Sum256(raw)
	return hex.EncodeToString(sum[:])
}

// samePrint compares fingerprints; a row written before they were recorded
// has none and is accepted on its other checks.
func samePrint(stored, current string) bool {
	return stored == "" || stored == current
}
