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

// Hand-authored resource-plane (Plane 3) OPL for per-shop access control.
// Complements the generated service_commerce.opl.ts (Plane 2 / tenant-level
// functional permissions). The commerce service enforces these per-resource
// permits in handlers via authz.Middleware (commerce_shop namespace) after the
// FunctionAccessInterceptor has already validated the tenant-level permission.
//
// Role hierarchy (per shop): owner ⊇ admin ⊇ operator ⊇ viewer/member.
// Direct grants use granted_<permission> relations so a profile can be given a
// single capability without a full role.

import { Namespace, Context } from "@ory/keto-namespace-types"

class profile_user implements Namespace {}

class commerce_shop implements Namespace {
  related: {
    owner: profile_user[]
    admin: profile_user[]
    operator: profile_user[]
    viewer: profile_user[]
    member: profile_user[]
    service: profile_user[]

    granted_shop_view: profile_user[]
    granted_shop_update: profile_user[]
    granted_products_view: profile_user[]
    granted_products_manage: profile_user[]
    granted_orders_view: profile_user[]
    granted_orders_manage: profile_user[]
    granted_fulfilment_view: profile_user[]
    granted_fulfilment_manage: profile_user[]
    granted_price_list_view: profile_user[]
    granted_price_list_manage: profile_user[]
    granted_customer_price_override: profile_user[]
    granted_discount_manage: profile_user[]
    granted_discount_approve: profile_user[]
  }

  permits = {
    // --- View permits: any role on the shop (incl. viewer/member) ---
    shop_view: (ctx: Context): boolean =>
      this.related.owner.includes(ctx.subject) ||
      this.related.admin.includes(ctx.subject) ||
      this.related.operator.includes(ctx.subject) ||
      this.related.viewer.includes(ctx.subject) ||
      this.related.member.includes(ctx.subject) ||
      this.related.service.includes(ctx.subject) ||
      this.related.granted_shop_view.includes(ctx.subject),

    products_view: (ctx: Context): boolean =>
      this.related.owner.includes(ctx.subject) ||
      this.related.admin.includes(ctx.subject) ||
      this.related.operator.includes(ctx.subject) ||
      this.related.viewer.includes(ctx.subject) ||
      this.related.member.includes(ctx.subject) ||
      this.related.service.includes(ctx.subject) ||
      this.related.granted_products_view.includes(ctx.subject),

    orders_view: (ctx: Context): boolean =>
      this.related.owner.includes(ctx.subject) ||
      this.related.admin.includes(ctx.subject) ||
      this.related.operator.includes(ctx.subject) ||
      this.related.viewer.includes(ctx.subject) ||
      this.related.member.includes(ctx.subject) ||
      this.related.service.includes(ctx.subject) ||
      this.related.granted_orders_view.includes(ctx.subject),

    fulfilment_view: (ctx: Context): boolean =>
      this.related.owner.includes(ctx.subject) ||
      this.related.admin.includes(ctx.subject) ||
      this.related.operator.includes(ctx.subject) ||
      this.related.viewer.includes(ctx.subject) ||
      this.related.member.includes(ctx.subject) ||
      this.related.service.includes(ctx.subject) ||
      this.related.granted_fulfilment_view.includes(ctx.subject),

    price_list_view: (ctx: Context): boolean =>
      this.related.owner.includes(ctx.subject) ||
      this.related.admin.includes(ctx.subject) ||
      this.related.operator.includes(ctx.subject) ||
      this.related.viewer.includes(ctx.subject) ||
      this.related.member.includes(ctx.subject) ||
      this.related.service.includes(ctx.subject) ||
      this.related.granted_price_list_view.includes(ctx.subject),

    // --- Manage permits: owner/admin/operator (operational roles) ---
    shop_update: (ctx: Context): boolean =>
      this.related.owner.includes(ctx.subject) ||
      this.related.admin.includes(ctx.subject) ||
      this.related.service.includes(ctx.subject) ||
      this.related.granted_shop_update.includes(ctx.subject),

    products_manage: (ctx: Context): boolean =>
      this.related.owner.includes(ctx.subject) ||
      this.related.admin.includes(ctx.subject) ||
      this.related.operator.includes(ctx.subject) ||
      this.related.service.includes(ctx.subject) ||
      this.related.granted_products_manage.includes(ctx.subject),

    orders_manage: (ctx: Context): boolean =>
      this.related.owner.includes(ctx.subject) ||
      this.related.admin.includes(ctx.subject) ||
      this.related.operator.includes(ctx.subject) ||
      this.related.service.includes(ctx.subject) ||
      this.related.granted_orders_manage.includes(ctx.subject),

    fulfilment_manage: (ctx: Context): boolean =>
      this.related.owner.includes(ctx.subject) ||
      this.related.admin.includes(ctx.subject) ||
      this.related.operator.includes(ctx.subject) ||
      this.related.service.includes(ctx.subject) ||
      this.related.granted_fulfilment_manage.includes(ctx.subject),

    price_list_manage: (ctx: Context): boolean =>
      this.related.owner.includes(ctx.subject) ||
      this.related.admin.includes(ctx.subject) ||
      this.related.operator.includes(ctx.subject) ||
      this.related.service.includes(ctx.subject) ||
      this.related.granted_price_list_manage.includes(ctx.subject),

    // --- Sensitive permits: owner/admin only ---
    customer_price_override: (ctx: Context): boolean =>
      this.related.owner.includes(ctx.subject) ||
      this.related.admin.includes(ctx.subject) ||
      this.related.service.includes(ctx.subject) ||
      this.related.granted_customer_price_override.includes(ctx.subject),

    discount_manage: (ctx: Context): boolean =>
      this.related.owner.includes(ctx.subject) ||
      this.related.admin.includes(ctx.subject) ||
      this.related.service.includes(ctx.subject) ||
      this.related.granted_discount_manage.includes(ctx.subject),

    discount_approve: (ctx: Context): boolean =>
      this.related.owner.includes(ctx.subject) ||
      this.related.admin.includes(ctx.subject) ||
      this.related.service.includes(ctx.subject) ||
      this.related.granted_discount_approve.includes(ctx.subject),
  }
}
