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
	"errors"
	"fmt"
	"math"
	"strconv"
	"strings"
)

// QuantityScale is how many decimal places a quantity keeps; it matches the
// NUMERIC(20,6) columns quantities are stored in.
const QuantityScale = 6

const quantityUnit = 1_000_000 // 10^QuantityScale

// maxQuantity keeps a quantity's integer part within NUMERIC(20,6).
const maxQuantity = 1e12

// ErrQuantity is returned for a quantity that cannot be stored exactly.
var ErrQuantity = errors.New("invalid quantity")

// Quantity is an exact decimal quantity in millionths. Quantities are added,
// compared and stored without binary floating point, so ten receipts of 0.1
// make exactly 1.
type Quantity int64 //nolint:recvcheck // Scan needs a pointer receiver; values elsewhere

// QuantityFromFloat converts an API quantity. It refuses NaN, infinities,
// values beyond 10^12 and more than six decimal places.
func QuantityFromFloat(f float64) (Quantity, error) {
	if math.IsNaN(f) || math.IsInf(f, 0) || math.Abs(f) >= maxQuantity {
		return 0, fmt.Errorf("%w: %v", ErrQuantity, f)
	}
	scaled := f * quantityUnit
	rounded := math.Round(scaled)
	// A double carries ~15 significant digits; anything further from a whole
	// number of millionths than that noise had more than six places.
	if math.Abs(scaled-rounded) > 1e-6*math.Max(1, math.Abs(scaled)) {
		return 0, fmt.Errorf("%w: %v has more than %d decimal places", ErrQuantity, f, QuantityScale)
	}
	return Quantity(rounded), nil
}

// WholeQuantity is n whole units.
func WholeQuantity(n int64) Quantity { return Quantity(n * quantityUnit) }

// Float is the quantity for the API.
func (q Quantity) Float() float64 {
	whole := int64(q) / quantityUnit
	frac := int64(q) % quantityUnit
	return float64(whole) + float64(frac)/quantityUnit
}

// IsWhole reports whether the quantity is a whole number of units.
func (q Quantity) IsWhole() bool { return int64(q)%quantityUnit == 0 }

// Units is the whole number of units (the fraction truncated).
func (q Quantity) Units() int64 { return int64(q) / quantityUnit }

// Micros is the quantity in millionths.
func (q Quantity) Micros() int64 { return int64(q) }

func (q Quantity) String() string {
	sign := ""
	v := int64(q)
	if v < 0 {
		sign = "-"
		v = -v
	}
	return fmt.Sprintf("%s%d.%06d", sign, v/quantityUnit, v%quantityUnit)
}

// Value stores the quantity as an exact decimal string.
func (q Quantity) Value() (driver.Value, error) { return q.String(), nil }

// Scan reads a NUMERIC (as text) or, for rows not yet migrated, a float.
func (q *Quantity) Scan(src any) error {
	switch v := src.(type) {
	case nil:
		*q = 0
		return nil
	case string:
		return q.parse(v)
	case []byte:
		return q.parse(string(v))
	case float64:
		parsed, err := QuantityFromFloat(v)
		if err != nil {
			// Legacy float rows may carry binary noise; round to the scale.
			parsed = Quantity(math.Round(v * quantityUnit))
		}
		*q = parsed
		return nil
	case int64:
		*q = WholeQuantity(v)
		return nil
	default:
		return fmt.Errorf("%w: cannot scan %T", ErrQuantity, src)
	}
}

func (q *Quantity) parse(text string) error {
	text = strings.TrimSpace(text)
	negative := strings.HasPrefix(text, "-")
	text = strings.TrimPrefix(text, "-")
	whole, frac, _ := strings.Cut(text, ".")
	if len(frac) > QuantityScale {
		// NUMERIC(20,6) never has more; tolerate trailing zeros only.
		if strings.Trim(frac[QuantityScale:], "0") != "" {
			return fmt.Errorf("%w: %q has more than %d decimal places", ErrQuantity, text, QuantityScale)
		}
		frac = frac[:QuantityScale]
	}
	frac += strings.Repeat("0", QuantityScale-len(frac))
	if whole == "" {
		whole = "0"
	}
	w, err := strconv.ParseInt(whole, 10, 64)
	if err != nil {
		return fmt.Errorf("%w: %q: %w", ErrQuantity, text, err)
	}
	f, err := strconv.ParseInt(frac, 10, 64)
	if err != nil {
		return fmt.Errorf("%w: %q: %w", ErrQuantity, text, err)
	}
	v := w*quantityUnit + f
	if negative {
		v = -v
	}
	*q = Quantity(v)
	return nil
}
