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

	"github.com/stretchr/testify/require"
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
