import { Namespace, Context } from "@ory/keto-namespace-types"

class profile implements Namespace {}

class commerce_tenant implements Namespace {
  related: {
    owner: profile[]
    admin: profile[]
    member: profile[]

    create_shop: profile[]
    view_shops: profile[]
  }

  permits = {
    create_shop: (ctx: Context): boolean =>
      this.related.owner.includes(ctx.subject) ||
      this.related.admin.includes(ctx.subject) ||
      this.related.create_shop.includes(ctx.subject),

    view_shops: (ctx: Context): boolean =>
      this.permits.create_shop(ctx) ||
      this.related.member.includes(ctx.subject) ||
      this.related.view_shops.includes(ctx.subject),
  }
}

class commerce_shop implements Namespace {
  related: {
    owner: profile[]
    admin: profile[]
    operator: profile[]
    viewer: profile[]

    view: profile[]
    update: profile[]
    manage_products: profile[]
    view_products: profile[]
    manage_orders: profile[]
    view_orders: profile[]
    manage_fulfilment: profile[]
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
