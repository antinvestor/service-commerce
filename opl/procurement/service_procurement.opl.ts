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

import { Namespace, Context } from "@ory/keto-namespace-types"

class profile_user implements Namespace {}

class tenancy_access implements Namespace {
  related: {
    member: (profile_user | tenancy_access)[]
    service: profile_user[]
  }
}

class service_procurement implements Namespace {
  related: {
    owner: profile_user[]
    admin: profile_user[]
    operator: profile_user[]
    viewer: profile_user[]
    member: profile_user[]
    service: (profile_user | tenancy_access)[]

    granted_supplier_view: (profile_user | service_procurement)[]
    granted_supplier_manage: (profile_user | service_procurement)[]
    granted_purchase_order_view: (profile_user | service_procurement)[]
    granted_purchase_order_create: (profile_user | service_procurement)[]
    granted_purchase_order_submit: (profile_user | service_procurement)[]
    granted_purchase_order_cancel: (profile_user | service_procurement)[]
    granted_goods_receipt_view: (profile_user | service_procurement)[]
    granted_goods_receipt_create: (profile_user | service_procurement)[]
  }

  permits = {
    supplier_view: (ctx: Context): boolean =>
      this.related.admin.includes(ctx.subject) ||
      this.related.operator.includes(ctx.subject) ||
      this.related.owner.includes(ctx.subject) ||
      this.related.service.includes(ctx.subject) ||
      this.related.viewer.includes(ctx.subject) ||
      this.related.granted_supplier_view.includes(ctx.subject),

    supplier_manage: (ctx: Context): boolean =>
      this.related.admin.includes(ctx.subject) ||
      this.related.owner.includes(ctx.subject) ||
      this.related.service.includes(ctx.subject) ||
      this.related.granted_supplier_manage.includes(ctx.subject),

    purchase_order_view: (ctx: Context): boolean =>
      this.related.admin.includes(ctx.subject) ||
      this.related.operator.includes(ctx.subject) ||
      this.related.owner.includes(ctx.subject) ||
      this.related.service.includes(ctx.subject) ||
      this.related.viewer.includes(ctx.subject) ||
      this.related.granted_purchase_order_view.includes(ctx.subject),

    purchase_order_create: (ctx: Context): boolean =>
      this.related.admin.includes(ctx.subject) ||
      this.related.operator.includes(ctx.subject) ||
      this.related.owner.includes(ctx.subject) ||
      this.related.service.includes(ctx.subject) ||
      this.related.granted_purchase_order_create.includes(ctx.subject),

    purchase_order_submit: (ctx: Context): boolean =>
      this.related.admin.includes(ctx.subject) ||
      this.related.operator.includes(ctx.subject) ||
      this.related.owner.includes(ctx.subject) ||
      this.related.service.includes(ctx.subject) ||
      this.related.granted_purchase_order_submit.includes(ctx.subject),

    purchase_order_cancel: (ctx: Context): boolean =>
      this.related.admin.includes(ctx.subject) ||
      this.related.owner.includes(ctx.subject) ||
      this.related.service.includes(ctx.subject) ||
      this.related.granted_purchase_order_cancel.includes(ctx.subject),

    goods_receipt_view: (ctx: Context): boolean =>
      this.related.admin.includes(ctx.subject) ||
      this.related.operator.includes(ctx.subject) ||
      this.related.owner.includes(ctx.subject) ||
      this.related.service.includes(ctx.subject) ||
      this.related.viewer.includes(ctx.subject) ||
      this.related.granted_goods_receipt_view.includes(ctx.subject),

    goods_receipt_create: (ctx: Context): boolean =>
      this.related.admin.includes(ctx.subject) ||
      this.related.operator.includes(ctx.subject) ||
      this.related.owner.includes(ctx.subject) ||
      this.related.service.includes(ctx.subject) ||
      this.related.granted_goods_receipt_create.includes(ctx.subject),
  }
}
