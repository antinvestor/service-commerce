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

    // Direct permission grants (accept service_commerce subject sets for service role bridging)
    create_shop: (profile_user | service_commerce)[]
    view_shops: (profile_user | service_commerce)[]
  }

  permits = {
    create_shop: (ctx: Context): boolean =>
      this.related.service.includes(ctx.subject) ||
      this.related.owner.includes(ctx.subject) ||
      this.related.admin.includes(ctx.subject) ||
      this.related.create_shop.includes(ctx.subject),

    view_shops: (ctx: Context): boolean =>
      this.related.service.includes(ctx.subject) ||
      this.permits.create_shop(ctx) ||
      this.related.member.includes(ctx.subject) ||
      this.related.view_shops.includes(ctx.subject),
  }
}

class commerce_shop implements Namespace {
  related: {
    owner: profile_user[]
    admin: profile_user[]
    operator: profile_user[]
    viewer: profile_user[]

    view: profile_user[]
    update: profile_user[]
    manage_products: profile_user[]
    view_products: profile_user[]
    manage_orders: profile_user[]
    view_orders: profile_user[]
    manage_fulfilment: profile_user[]
  }

  permits = {
    view: (ctx: Context): boolean =>
      this.related.owner.includes(ctx.subject) ||
      this.related.admin.includes(ctx.subject) ||
      this.related.operator.includes(ctx.subject) ||
      this.related.viewer.includes(ctx.subject) ||
      this.related.view.includes(ctx.subject),

    update: (ctx: Context): boolean =>
      this.related.owner.includes(ctx.subject) ||
      this.related.admin.includes(ctx.subject) ||
      this.related.update.includes(ctx.subject),

    manage_products: (ctx: Context): boolean =>
      this.related.owner.includes(ctx.subject) ||
      this.related.admin.includes(ctx.subject) ||
      this.related.operator.includes(ctx.subject) ||
      this.related.manage_products.includes(ctx.subject),

    view_products: (ctx: Context): boolean =>
      this.permits.manage_products(ctx) ||
      this.related.viewer.includes(ctx.subject) ||
      this.related.view_products.includes(ctx.subject),

    manage_orders: (ctx: Context): boolean =>
      this.related.owner.includes(ctx.subject) ||
      this.related.admin.includes(ctx.subject) ||
      this.related.operator.includes(ctx.subject) ||
      this.related.manage_orders.includes(ctx.subject),

    view_orders: (ctx: Context): boolean =>
      this.permits.manage_orders(ctx) ||
      this.related.viewer.includes(ctx.subject) ||
      this.related.view_orders.includes(ctx.subject),

    manage_fulfilment: (ctx: Context): boolean =>
      this.related.owner.includes(ctx.subject) ||
      this.related.admin.includes(ctx.subject) ||
      this.related.operator.includes(ctx.subject) ||
      this.related.manage_fulfilment.includes(ctx.subject),
  }
}
