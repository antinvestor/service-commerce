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

package dbrole

import (
	"context"
	"errors"

	"github.com/pitabwire/frame/v3"
	"github.com/pitabwire/frame/v3/tenancy"
)

// systemPrincipal is the one principal the tenancy provider lets read across
// tenants once it fails closed.
const systemPrincipal = "service_commerce_system"

// ErrNoTenancyProvider is returned when the service has no tenancy provider
// that can be made to fail closed.
var ErrNoTenancyProvider = errors.New("tenancy provider does not support a secure mode")

// FailClosed makes row-level security refuse a query that names no tenant,
// rather than let it read every tenant's rows. Only AcrossTenants may still
// read everything. Frame v3.0.0 pings each new connection without a tenant,
// so a secure mode set through frame.WithTenancySecurityMode stops the pools
// from opening at all; the mode is set on the provider instead, once the
// pools are open and before the service takes traffic.
func FailClosed(svc *frame.Service) error {
	provider := svc.TenancyProvider()
	modal, ok := provider.(tenancy.ModeAware)
	if !ok {
		return ErrNoTenancyProvider
	}
	global, ok := provider.(tenancy.AllowGlobalAware)
	if !ok {
		return ErrNoTenancyProvider
	}
	global.SetAllowGlobalServices(systemPrincipal)
	modal.SetSecurityMode(tenancy.ModeHybrid)
	return nil
}

// AcrossTenants lets ctx read every tenant's rows. It is for the few flows
// that run before a tenant is known or across all of them: the scheduled
// sweeps, the storefront's slug lookup and the payment return page. reason
// is for logs only.
func AcrossTenants(ctx context.Context, reason string) context.Context {
	return tenancy.WithSystemPrincipal(ctx, tenancy.SystemPrincipal{
		ServiceName: systemPrincipal,
		Reason:      reason,
		AllowGlobal: true,
	})
}
