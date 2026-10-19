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

package business_test

import (
	"context"
	"errors"
	"testing"

	"github.com/pitabwire/frame/v3/security"
	"github.com/stretchr/testify/require"

	"github.com/antinvestor/service-commerce/apps/default/service/business"
	commercev1 "github.com/antinvestor/service-commerce/gen/go/commerce/v1"
)

type fakeCurrencyDirectory struct {
	preferred, device, country string
	preferredErr, deviceErr    error

	deviceID, sessionID string
}

func (f *fakeCurrencyDirectory) PreferredCurrency(_ context.Context, _ string) (string, error) {
	return f.preferred, f.preferredErr
}

func (f *fakeCurrencyDirectory) DeviceCurrency(_ context.Context, deviceID, sessionID string) (string, error) {
	f.deviceID, f.sessionID = deviceID, sessionID
	return f.device, f.deviceErr
}

func (f *fakeCurrencyDirectory) AddressCountry(_ context.Context, _ string) (string, error) {
	return f.country, nil
}

func callerContext(deviceID, sessionID string) context.Context {
	claims := &security.AuthenticationClaims{DeviceID: deviceID, SessionID: sessionID}
	claims.Subject = "p1"
	return claims.ClaimsToContext(context.Background())
}

func TestDefaultCurrency(t *testing.T) {
	t.Parallel()

	tests := []struct {
		name       string
		directory  *fakeCurrencyDirectory
		ctx        context.Context
		wantCode   string
		wantSource commercev1.CurrencySource
	}{
		{
			name:       "preference wins over device and address",
			directory:  &fakeCurrencyDirectory{preferred: "usd", device: "UGX", country: "Kenya"},
			ctx:        callerContext("d1", ""),
			wantCode:   "USD",
			wantSource: commercev1.CurrencySource_CURRENCY_SOURCE_PREFERENCE,
		},
		{
			name:       "JSON-encoded preference is accepted",
			directory:  &fakeCurrencyDirectory{preferred: `"TZS"`},
			ctx:        callerContext("", ""),
			wantCode:   "TZS",
			wantSource: commercev1.CurrencySource_CURRENCY_SOURCE_PREFERENCE,
		},
		{
			name:       "invalid preference falls through to device",
			directory:  &fakeCurrencyDirectory{preferred: "shillings", device: "UGX"},
			ctx:        callerContext("d1", ""),
			wantCode:   "UGX",
			wantSource: commercev1.CurrencySource_CURRENCY_SOURCE_DEVICE,
		},
		{
			name:       "settings outage falls through to device",
			directory:  &fakeCurrencyDirectory{preferredErr: errors.New("down"), device: "RWF"},
			ctx:        callerContext("", "s1"),
			wantCode:   "RWF",
			wantSource: commercev1.CurrencySource_CURRENCY_SOURCE_DEVICE,
		},
		{
			name:       "address country by name",
			directory:  &fakeCurrencyDirectory{deviceErr: errors.New("down"), country: "Kenya"},
			ctx:        callerContext("d1", ""),
			wantCode:   "KES",
			wantSource: commercev1.CurrencySource_CURRENCY_SOURCE_ADDRESS,
		},
		{
			name:       "address country by alpha-3 code",
			directory:  &fakeCurrencyDirectory{country: "NGA"},
			ctx:        callerContext("", ""),
			wantCode:   "NGN",
			wantSource: commercev1.CurrencySource_CURRENCY_SOURCE_ADDRESS,
		},
		{
			name:       "address country by alpha-2 code",
			directory:  &fakeCurrencyDirectory{country: "gb"},
			ctx:        callerContext("", ""),
			wantCode:   "GBP",
			wantSource: commercev1.CurrencySource_CURRENCY_SOURCE_ADDRESS,
		},
		{
			name:       "unknown country uses the platform default",
			directory:  &fakeCurrencyDirectory{country: "Atlantis"},
			ctx:        callerContext("", ""),
			wantCode:   "KES",
			wantSource: commercev1.CurrencySource_CURRENCY_SOURCE_PLATFORM_DEFAULT,
		},
		{
			name:       "no caller uses the platform default",
			directory:  &fakeCurrencyDirectory{preferred: "USD"},
			ctx:        context.Background(),
			wantCode:   "KES",
			wantSource: commercev1.CurrencySource_CURRENCY_SOURCE_PLATFORM_DEFAULT,
		},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()
			code, source := business.NewCurrencyResolver(tc.directory).DefaultCurrency(tc.ctx)
			require.Equal(t, tc.wantCode, code)
			require.Equal(t, tc.wantSource, source)
		})
	}
}

func TestDefaultCurrencyPassesDeviceAndSession(t *testing.T) {
	t.Parallel()
	directory := &fakeCurrencyDirectory{device: "EUR"}
	code, _ := business.NewCurrencyResolver(directory).DefaultCurrency(callerContext("d1", "s1"))
	require.Equal(t, "EUR", code)
	require.Equal(t, "d1", directory.deviceID)
	require.Equal(t, "s1", directory.sessionID)
}

func TestDefaultCurrencyWithoutDirectory(t *testing.T) {
	t.Parallel()
	code, source := business.NewCurrencyResolver(nil).DefaultCurrency(callerContext("d1", ""))
	require.Equal(t, "KES", code)
	require.Equal(t, commercev1.CurrencySource_CURRENCY_SOURCE_PLATFORM_DEFAULT, source)
}
