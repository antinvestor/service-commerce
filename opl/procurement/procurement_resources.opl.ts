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

// Hand-authored resource-plane (Plane 3) OPL for per-property access control in
// procurement. Complements the generated service_procurement.opl.ts (Plane 2).
// Enforced in handlers via authz.Middleware (procurement_property namespace).

import { Namespace, Context } from "@ory/keto-namespace-types"

class profile_user implements Namespace {}

class procurement_property implements Namespace {
  related: {
    owner: profile_user[]
    admin: profile_user[]
    operator: profile_user[]
    viewer: profile_user[]
    member: profile_user[]
    service: profile_user[]

    granted_property_view: profile_user[]
    granted_property_update: profile_user[]
    granted_purchase_order_manage: profile_user[]
    granted_purchase_order_property_view: profile_user[]
    granted_goods_receipt_manage: profile_user[]
    granted_goods_receipt_view: profile_user[]
  }

  permits = {
    // --- View permits: any role on the property ---
    property_view: (ctx: Context): boolean =>
      this.related.owner.includes(ctx.subject) ||
      this.related.admin.includes(ctx.subject) ||
      this.related.operator.includes(ctx.subject) ||
      this.related.viewer.includes(ctx.subject) ||
      this.related.member.includes(ctx.subject) ||
      this.related.service.includes(ctx.subject) ||
      this.related.granted_property_view.includes(ctx.subject),

    purchase_order_property_view: (ctx: Context): boolean =>
      this.related.owner.includes(ctx.subject) ||
      this.related.admin.includes(ctx.subject) ||
      this.related.operator.includes(ctx.subject) ||
      this.related.viewer.includes(ctx.subject) ||
      this.related.member.includes(ctx.subject) ||
      this.related.service.includes(ctx.subject) ||
      this.related.granted_purchase_order_property_view.includes(ctx.subject),

    goods_receipt_view: (ctx: Context): boolean =>
      this.related.owner.includes(ctx.subject) ||
      this.related.admin.includes(ctx.subject) ||
      this.related.operator.includes(ctx.subject) ||
      this.related.viewer.includes(ctx.subject) ||
      this.related.member.includes(ctx.subject) ||
      this.related.service.includes(ctx.subject) ||
      this.related.granted_goods_receipt_view.includes(ctx.subject),

    // --- Manage permits: owner/admin/operator ---
    property_update: (ctx: Context): boolean =>
      this.related.owner.includes(ctx.subject) ||
      this.related.admin.includes(ctx.subject) ||
      this.related.service.includes(ctx.subject) ||
      this.related.granted_property_update.includes(ctx.subject),

    purchase_order_manage: (ctx: Context): boolean =>
      this.related.owner.includes(ctx.subject) ||
      this.related.admin.includes(ctx.subject) ||
      this.related.operator.includes(ctx.subject) ||
      this.related.service.includes(ctx.subject) ||
      this.related.granted_purchase_order_manage.includes(ctx.subject),

    goods_receipt_manage: (ctx: Context): boolean =>
      this.related.owner.includes(ctx.subject) ||
      this.related.admin.includes(ctx.subject) ||
      this.related.operator.includes(ctx.subject) ||
      this.related.service.includes(ctx.subject) ||
      this.related.granted_goods_receipt_manage.includes(ctx.subject),
  }
}
