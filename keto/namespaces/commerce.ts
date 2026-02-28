import { Namespace, Context } from "@ory/keto-namespace-types"

class profile_user implements Namespace {}

class tenancy_access implements Namespace {
  related: {
    member: (profile_user | tenancy_access)[]
    service: profile_user[]
  }
}

class service_commerce implements Namespace {
  related: {
    owner: profile_user[]
    admin: profile_user[]
    member: profile_user[]
    service: (profile_user | tenancy_access)[]

    // Direct permission grants use granted_ prefix to avoid name conflicts with permits
    granted_shop_create: (profile_user | service_commerce)[]
    granted_shops_view: (profile_user | service_commerce)[]
  }

  permits = {
    shop_create: (ctx: Context): boolean =>
      this.related.service.includes(ctx.subject) ||
      this.related.owner.includes(ctx.subject) ||
      this.related.admin.includes(ctx.subject) ||
      this.related.granted_shop_create.includes(ctx.subject),

    shops_view: (ctx: Context): boolean =>
      this.related.service.includes(ctx.subject) ||
      this.permits.shop_create(ctx) ||
      this.related.member.includes(ctx.subject) ||
      this.related.granted_shops_view.includes(ctx.subject),
  }
}

class commerce_shop implements Namespace {
  related: {
    owner: profile_user[]
    admin: profile_user[]
    operator: profile_user[]
    viewer: profile_user[]

    // Direct permission grants use granted_ prefix to avoid name conflicts with permits
    granted_shop_view: profile_user[]
    granted_shop_update: profile_user[]
    granted_products_manage: profile_user[]
    granted_products_view: profile_user[]
    granted_orders_manage: profile_user[]
    granted_orders_view: profile_user[]
    granted_fulfilment_manage: profile_user[]
  }

  permits = {
    shop_view: (ctx: Context): boolean =>
      this.related.owner.includes(ctx.subject) ||
      this.related.admin.includes(ctx.subject) ||
      this.related.operator.includes(ctx.subject) ||
      this.related.viewer.includes(ctx.subject) ||
      this.related.granted_shop_view.includes(ctx.subject),

    shop_update: (ctx: Context): boolean =>
      this.related.owner.includes(ctx.subject) ||
      this.related.admin.includes(ctx.subject) ||
      this.related.granted_shop_update.includes(ctx.subject),

    products_manage: (ctx: Context): boolean =>
      this.related.owner.includes(ctx.subject) ||
      this.related.admin.includes(ctx.subject) ||
      this.related.operator.includes(ctx.subject) ||
      this.related.granted_products_manage.includes(ctx.subject),

    products_view: (ctx: Context): boolean =>
      this.permits.products_manage(ctx) ||
      this.related.viewer.includes(ctx.subject) ||
      this.related.granted_products_view.includes(ctx.subject),

    orders_manage: (ctx: Context): boolean =>
      this.related.owner.includes(ctx.subject) ||
      this.related.admin.includes(ctx.subject) ||
      this.related.operator.includes(ctx.subject) ||
      this.related.granted_orders_manage.includes(ctx.subject),

    orders_view: (ctx: Context): boolean =>
      this.permits.orders_manage(ctx) ||
      this.related.viewer.includes(ctx.subject) ||
      this.related.granted_orders_view.includes(ctx.subject),

    fulfilment_manage: (ctx: Context): boolean =>
      this.related.owner.includes(ctx.subject) ||
      this.related.admin.includes(ctx.subject) ||
      this.related.operator.includes(ctx.subject) ||
      this.related.granted_fulfilment_manage.includes(ctx.subject),
  }
}
