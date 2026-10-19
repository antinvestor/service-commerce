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
	"strings"
	"sync"

	devicev1 "buf.build/gen/go/antinvestor/device/protocolbuffers/go/device/v1"
	profilev1 "buf.build/gen/go/antinvestor/profile/protocolbuffers/go/profile/v1"
	settingsv1 "buf.build/gen/go/antinvestor/settingz/protocolbuffers/go/settings/v1"
	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/util"
	"golang.org/x/text/currency"
	"golang.org/x/text/language"
	"golang.org/x/text/language/display"

	commercev1 "github.com/antinvestor/service-commerce/gen/go/commerce/v1"
)

// The caller's currency preference lives in the settings service under this
// key, scoped to their profile, so every product reads the same value.
const (
	currencySettingName   = "currency"
	currencySettingObject = "profile"
)

// CurrencyDirectory is what the profile services know about a caller's
// currency. Each lookup returns "" when it has nothing to say.
type CurrencyDirectory interface {
	// PreferredCurrency is the profile's "currency" setting.
	PreferredCurrency(ctx context.Context, profileID string) (string, error)
	// DeviceCurrency is the currency of the locale recorded for the device
	// or session the caller is signed in on.
	DeviceCurrency(ctx context.Context, deviceID, sessionID string) (string, error)
	// AddressCountry is the country of the profile's first address.
	AddressCountry(ctx context.Context, profileID string) (string, error)
}

// CurrencyResolver picks the currency the authenticated caller most likely
// trades in.
type CurrencyResolver interface {
	DefaultCurrency(ctx context.Context) (string, commercev1.CurrencySource)
}

// NewCurrencyResolver builds a resolver over directory. A nil directory
// resolves every caller to the platform default.
func NewCurrencyResolver(directory CurrencyDirectory) CurrencyResolver {
	return &currencyResolver{directory: directory}
}

type currencyResolver struct {
	directory CurrencyDirectory
}

// DefaultCurrency tries the caller's setting, then their device locale, then
// their address country. A peer that is down or knows nothing is skipped: the
// default is a convenience and must never block the caller.
func (r *currencyResolver) DefaultCurrency(ctx context.Context) (string, commercev1.CurrencySource) {
	claims := security.ClaimsFromContext(ctx)
	if r.directory == nil || claims == nil {
		return defaultShopCurrency, commercev1.CurrencySource_CURRENCY_SOURCE_PLATFORM_DEFAULT
	}
	profileID, _ := claims.GetSubject()
	log := util.Log(ctx).WithField("profile_id", profileID)

	if profileID != "" {
		preferred, err := r.directory.PreferredCurrency(ctx, profileID)
		if err != nil {
			log.WithError(err).Warn("could not read currency setting")
		}
		if code := normalizeCurrency(preferred); code != "" {
			return code, commercev1.CurrencySource_CURRENCY_SOURCE_PREFERENCE
		}
	}

	if deviceID, sessionID := claims.GetDeviceID(), claims.GetSessionID(); deviceID != "" || sessionID != "" {
		deviceCurrency, err := r.directory.DeviceCurrency(ctx, deviceID, sessionID)
		if err != nil {
			log.WithError(err).Warn("could not read device locale")
		}
		if code := normalizeCurrency(deviceCurrency); code != "" {
			return code, commercev1.CurrencySource_CURRENCY_SOURCE_DEVICE
		}
	}

	if profileID != "" {
		country, err := r.directory.AddressCountry(ctx, profileID)
		if err != nil {
			log.WithError(err).Warn("could not read profile address")
		}
		if code := currencyForCountry(country); code != "" {
			return code, commercev1.CurrencySource_CURRENCY_SOURCE_ADDRESS
		}
	}

	return defaultShopCurrency, commercev1.CurrencySource_CURRENCY_SOURCE_PLATFORM_DEFAULT
}

// normalizeCurrency returns value as an ISO 4217 code, or "" when it is not
// one. Settings may store the code JSON-encoded, so quotes are stripped.
func normalizeCurrency(value string) string {
	code := strings.ToUpper(strings.Trim(strings.TrimSpace(value), `"`))
	if len(code) != currencyCodeLength {
		return ""
	}
	unit, err := currency.ParseISO(code)
	if err != nil {
		return ""
	}
	return unit.String()
}

// currencyForCountry maps a country given as an ISO 3166 code (alpha-2,
// alpha-3 or numeric) or an English name to the currency used there.
func currencyForCountry(country string) string {
	country = strings.TrimSpace(country)
	if country == "" {
		return ""
	}
	region, err := language.ParseRegion(country)
	if err != nil {
		var ok bool
		if region, ok = countriesByName()[strings.ToLower(country)]; !ok {
			return ""
		}
	}
	unit, ok := currency.FromRegion(region)
	if !ok {
		return ""
	}
	return unit.String()
}

// countriesByName indexes every country by its English display name, built
// once on first use.
//
//nolint:gochecknoglobals // immutable lookup table computed lazily
var countriesByName = sync.OnceValue(func() map[string]language.Region {
	names := display.English.Regions()
	byName := make(map[string]language.Region)
	for first := 'A'; first <= 'Z'; first++ {
		for second := 'A'; second <= 'Z'; second++ {
			region, err := language.ParseRegion(string([]rune{first, second}))
			if err != nil || !region.IsCountry() {
				continue
			}
			if name := names.Name(region); name != "" {
				byName[strings.ToLower(name)] = region
			}
		}
	}
	return byName
})

// --- Connect-backed directory ---

// SettingsClient is the subset of the generated settings client the
// directory uses.
type SettingsClient interface {
	Get(
		context.Context,
		*settingsv1.GetRequest,
	) (*settingsv1.GetResponse, error)
}

// DeviceClient is the subset of the generated device client the directory
// uses.
type DeviceClient interface {
	GetById(
		context.Context,
		*devicev1.GetByIdRequest,
	) (*devicev1.GetByIdResponse, error)
	GetBySessionId(
		context.Context,
		*devicev1.GetBySessionIdRequest,
	) (*devicev1.GetBySessionIdResponse, error)
}

// ProfileClient is the subset of the generated profile client the
// directory uses.
type ProfileClient interface {
	GetById(
		context.Context,
		*profilev1.GetByIdRequest,
	) (*profilev1.GetByIdResponse, error)
}

// NewConnectCurrencyDirectory wraps the generated peer clients. Any of them
// may be nil, which skips that source; all nil yields a nil directory.
func NewConnectCurrencyDirectory(
	settings SettingsClient,
	devices DeviceClient,
	profiles ProfileClient,
) CurrencyDirectory {
	if settings == nil && devices == nil && profiles == nil {
		return nil
	}
	return &connectCurrencyDirectory{settings: settings, devices: devices, profiles: profiles}
}

type connectCurrencyDirectory struct {
	settings SettingsClient
	devices  DeviceClient
	profiles ProfileClient
}

func (d *connectCurrencyDirectory) PreferredCurrency(ctx context.Context, profileID string) (string, error) {
	if d.settings == nil {
		return "", nil
	}
	resp, err := d.settings.Get(ctx, settingsv1.GetRequest_builder{
		Key: settingsv1.Setting_builder{
			Name:     currencySettingName,
			Object:   currencySettingObject,
			ObjectId: profileID,
		}.Build(),
	}.Build())
	if err != nil {
		return "", err
	}
	return resp.GetData().GetValue(), nil
}

func (d *connectCurrencyDirectory) DeviceCurrency(ctx context.Context, deviceID, sessionID string) (string, error) {
	if d.devices == nil {
		return "", nil
	}
	if deviceID != "" {
		resp, err := d.devices.GetById(ctx, devicev1.GetByIdRequest_builder{
			Id: []string{deviceID},
		}.Build())
		if err != nil {
			return "", err
		}
		for _, device := range resp.GetData() {
			if code := device.GetLocale().GetCurrency(); code != "" {
				return code, nil
			}
		}
	}
	if sessionID == "" {
		return "", nil
	}
	resp, err := d.devices.GetBySessionId(ctx, devicev1.GetBySessionIdRequest_builder{
		Id: sessionID,
	}.Build())
	if err != nil {
		return "", err
	}
	return resp.GetData().GetLocale().GetCurrency(), nil
}

func (d *connectCurrencyDirectory) AddressCountry(ctx context.Context, profileID string) (string, error) {
	if d.profiles == nil {
		return "", nil
	}
	resp, err := d.profiles.GetById(ctx, profilev1.GetByIdRequest_builder{
		Id: profileID,
	}.Build())
	if err != nil {
		return "", err
	}
	for _, address := range resp.GetData().GetAddresses() {
		if country := strings.TrimSpace(address.GetCountry()); country != "" {
			return country, nil
		}
	}
	return "", nil
}
