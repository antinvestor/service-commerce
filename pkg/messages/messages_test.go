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

package messages_test

import (
	"testing"

	"github.com/antinvestor/common/notification"
	"github.com/stretchr/testify/require"

	"github.com/antinvestor/service-commerce/pkg/messages"
)

// Every template must be well formed and render in every channel, and in its
// subject, from exactly the variables it declares. A body that references a
// variable the template does not declare renders "<no value>" and fails here
// rather than in a buyer's inbox.
func TestTemplatesRenderFromDeclaredVariables(t *testing.T) {
	t.Parallel()
	reg := messages.Registry()
	require.Equal(t, messages.Owner, reg.Owner())
	require.NotZero(t, reg.Len())

	for _, tpl := range reg.All() {
		t.Run(tpl.Name, func(t *testing.T) {
			t.Parallel()
			require.NoError(t, tpl.Validate())
			vars := map[string]any{}
			for _, v := range tpl.Variables {
				vars[v] = "x"
			}
			for _, channel := range []string{notification.ChannelSMS, notification.ChannelEmail} {
				out, err := tpl.Render(channel, vars)
				require.NoError(t, err, channel)
				require.NotContains(t, out, "<no value>", channel)
				require.NotEmpty(t, out, channel)
			}
			subject, err := tpl.RenderSubject(vars)
			require.NoError(t, err)
			require.NotContains(t, subject, "<no value>")
			require.NotEmpty(t, subject)
		})
	}
}

func TestEveryTemplateNameIsRegistered(t *testing.T) {
	t.Parallel()
	reg := messages.Registry()
	for _, name := range []string{
		messages.OrderPlacedBuyer, messages.OrderPlacedSeller, messages.OrderPaidBuyer, messages.OrderPaidSeller,
		messages.OrderPaymentExpired, messages.OrderCancelledBuyer, messages.OrderCancelledSeller,
		messages.OrderShipped, messages.OrderDelivered, messages.LedgerDayPosted,
		messages.InstalmentReceivedBuyer, messages.InstalmentReceivedSeller, messages.PaymentThresholdSeller,
		messages.BalanceOverdueBuyer, messages.BalanceOverdueSeller,
	} {
		require.True(t, reg.Has(name), name)
	}
	require.Len(t, reg.Names(), 15, "a new template needs a constant and a line here")
}
