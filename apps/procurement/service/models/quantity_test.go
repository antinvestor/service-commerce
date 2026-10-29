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

package models_test

import (
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/antinvestor/service-commerce/apps/procurement/service/models"
)

func TestQuantity_ExactDecimal(t *testing.T) {
	t.Parallel()

	tenth, err := models.QuantityFromFloat(0.1)
	require.NoError(t, err)
	var sum models.Quantity
	for range 10 {
		sum += tenth
	}
	require.Equal(t, models.WholeQuantity(1), sum)
	require.Equal(t, 1.0, sum.Float()) //nolint:testifylint // exact on purpose
	require.True(t, sum.IsWhole())

	noisy, err := models.QuantityFromFloat(0.1 + 0.2) // 0.30000000000000004
	require.NoError(t, err)
	require.Equal(t, "0.300000", noisy.String())

	for _, bad := range []float64{0.0000001, 1e12} {
		_, err = models.QuantityFromFloat(bad)
		require.ErrorIs(t, err, models.ErrQuantity, bad)
	}

	var scanned models.Quantity
	require.NoError(t, scanned.Scan("12.500000"))
	require.Equal(t, 12.5, scanned.Float()) //nolint:testifylint // exact on purpose
	require.NoError(t, scanned.Scan([]byte("3")))
	require.Equal(t, models.WholeQuantity(3), scanned)
	require.Error(t, scanned.Scan("1.0000001"))
	value, err := models.Quantity(-1_500_000).Value()
	require.NoError(t, err)
	require.Equal(t, "-1.500000", value)
}
