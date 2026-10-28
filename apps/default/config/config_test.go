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

package config_test

import (
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/antinvestor/service-commerce/apps/default/config"
)

func TestValidateRequiresSecretsWhenRunSecurely(t *testing.T) {
	cfg := &config.CommerceConfig{CommerceServiceURI: "https://commerce.example"}
	cfg.RunServiceSecurely = true
	err := cfg.Validate()
	require.ErrorContains(t, err, "WEBHOOK_SECRET_KEY")
	require.ErrorContains(t, err, "PROFILE_SERVICE_URI")

	cfg.WebhookSecretKey = "key"
	cfg.ProfileServiceURI = "https://profile.example"
	require.NoError(t, cfg.Validate())

	// A local run may leave both unset.
	local := &config.CommerceConfig{CommerceServiceURI: "https://commerce.example"}
	local.RunServiceSecurely = false
	require.NoError(t, local.Validate())
}
