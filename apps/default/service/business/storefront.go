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
	"context"
	"net/url"
	"regexp"
	"strconv"
	"strings"
	"unicode/utf8"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/frame/v3/tenancy"
	"github.com/pitabwire/util"

	commercev1 "github.com/antinvestor/service-commerce/gen/go/commerce/v1"

	"github.com/antinvestor/service-commerce/apps/default/service/models"
	"github.com/antinvestor/service-commerce/apps/default/service/repository"
)

// Storefront limits keep an anonymous page cheap to render and an anonymous
// order small enough to need no review.
const (
	storefrontMaxProducts = 50
	storefrontMaxLines    = 50
	storefrontMaxQuantity = 99
	storefrontMaxName     = 100
	storefrontKeyPrefix   = "storefront:"
)

var (
	storefrontEmailPattern  = regexp.MustCompile(`^[^\s@]{1,64}@[^\s@]{1,190}\.[^\s@]{2,63}$`)
	storefrontPhonePattern  = regexp.MustCompile(`^\+?[0-9]{7,15}$`)
	storefrontKeyPattern    = regexp.MustCompile(`^[0-9A-Za-z_-]{8,64}$`)
	storefrontIDPattern     = regexp.MustCompile(`^[0-9a-z_-]{3,40}$`)
	storefrontAmountPattern = regexp.MustCompile(`^([0-9]{1,9})(?:\.([0-9]{1,2}))?$`)
)

// StorefrontURL is the public page of the shop with slug under base, or ""
// when there is no base.
func StorefrontURL(base, slug string) string {
	base = strings.TrimRight(strings.TrimSpace(base), "/")
	if base == "" {
		return ""
	}
	return base + StorefrontPath + url.PathEscape(slug)
}

// Storefront is what a shop's public page shows.
type Storefront struct {
	Shop  *commercev1.Shop
	Items []StorefrontItem
}

// StorefrontItem is a product with the variants a buyer can order.
type StorefrontItem struct {
	Product  *commercev1.Product
	Variants []*commercev1.ProductVariant
}

// StorefrontOrder is a guest's order from a shop's public page.
type StorefrontOrder struct {
	Name    string
	Contact string
	// Quantities by variant ID.
	Quantities map[string]int64
	// Deposit is the instalment to pay now in the shop's currency, such as
	// "500" or "12.50"; empty pays the whole order.
	Deposit string
	// Key makes resubmitting the same form place one order.
	Key string
}

// StorefrontBusiness serves shops' public pages: anyone may browse a shop
// that has opted in and buy from it without an account. The buyer becomes
// (or is matched to) a profile in the profile service.
type StorefrontBusiness interface {
	// Storefront returns the shop with slug and its active products.
	Storefront(ctx context.Context, slug string) (*Storefront, error)
	// Checkout places order and returns the hosted checkout page to send
	// the buyer to.
	Checkout(ctx context.Context, slug string, order StorefrontOrder) (string, error)
}

// NewStorefrontBusiness builds the public storefront. A nil buyer directory
// leaves pages browsable but checkout unavailable.
func NewStorefrontBusiness(
	shopRepo repository.ShopRepository,
	catalog CatalogBusiness,
	orders OrderBusiness,
	payments PaymentBusiness,
	buyers BuyerDirectory,
	baseURL string,
) StorefrontBusiness {
	return &storefrontBusiness{
		shopRepo: shopRepo, catalog: catalog, orders: orders, payments: payments, buyers: buyers,
		baseURL: baseURL,
	}
}

type storefrontBusiness struct {
	shopRepo repository.ShopRepository
	catalog  CatalogBusiness
	orders   OrderBusiness
	payments PaymentBusiness
	buyers   BuyerDirectory
	baseURL  string
}

func (sb *storefrontBusiness) Storefront(ctx context.Context, slug string) (*Storefront, error) {
	ctx, shop, err := sb.openShop(ctx, slug, "")
	if err != nil {
		return nil, err
	}

	page, err := sb.catalog.ListProducts(ctx, &commercev1.ListProductsRequest{
		ShopId: shop.GetID(),
		Search: &commonv1.SearchRequest{
			Query:  queryStatusActive,
			Cursor: &commonv1.PageCursor{Limit: storefrontMaxProducts},
		},
	})
	if err != nil {
		return nil, err
	}

	front := &Storefront{Shop: shop.ToAPI()}
	front.Shop.StorefrontUrl = StorefrontURL(sb.baseURL, shop.Slug)
	for _, product := range page.Products {
		variants, listErr := sb.catalog.ListProductVariants(ctx, product.GetId())
		if listErr != nil {
			return nil, listErr
		}
		item := StorefrontItem{Product: product}
		for _, v := range variants {
			if v.GetStatus() == commercev1.ProductVariantStatus_PRODUCT_VARIANT_STATUS_ACTIVE && v.GetPrice() != nil {
				item.Variants = append(item.Variants, v)
			}
		}
		if len(item.Variants) > 0 {
			front.Items = append(front.Items, item)
		}
	}
	return front, nil
}

func (sb *storefrontBusiness) Checkout(ctx context.Context, slug string, order StorefrontOrder) (string, error) {
	if sb.buyers == nil {
		return "", connect.NewError(connect.CodeUnimplemented, "checkout is not available for this shop")
	}
	lines, err := validateStorefrontOrder(&order)
	if err != nil {
		return "", err
	}

	ctx, shop, err := sb.openShop(ctx, slug, "")
	if err != nil {
		return "", err
	}
	deposit, err := parseStorefrontAmount(shop.Currency, order.Deposit)
	if err != nil {
		return "", err
	}
	buyer, err := sb.buyers.Resolve(ctx, order.Name, order.Contact)
	if err != nil {
		util.Log(ctx).WithError(err).WithField("shop_id", shop.GetID()).Warn("storefront buyer lookup failed")
		return "", connect.NewError(connect.CodeUnavailable, "we could not take your details just now; try again").
			WithCause(err)
	}

	// Act as the buyer from here on, so the order is theirs.
	ctx, _, err = sb.openShop(ctx, slug, buyer.ProfileID)
	if err != nil {
		return "", err
	}
	placed, err := sb.orders.CreateBuyerOrder(ctx, &commercev1.CreateOrderRequest{
		ShopId:         shop.GetID(),
		ProfileId:      buyer.ProfileID,
		ContactId:      buyer.ContactID,
		Lines:          lines,
		IdempotencyKey: storefrontKeyPrefix + order.Key,
	})
	if err != nil {
		return "", err
	}

	result, err := sb.payments.CheckoutOrder(ctx, &commercev1.CheckoutOrderRequest{
		OrderId:   placed.GetId(),
		ReturnUrl: StorefrontURL(sb.baseURL, shop.Slug),
		Amount:    deposit,
	})
	if err != nil {
		return "", err
	}
	target, err := url.Parse(result.Order.GetCheckoutUrl())
	if err != nil || target.Scheme != schemeHTTPS || target.Host == "" {
		return "", connect.NewError(connect.CodeFailedPrecondition, "this order has no payment page to send you to")
	}
	return target.String(), nil
}

// openShop finds the public shop with slug and returns a context bound to
// its tenancy, acting as buyerProfileID when set. Shops that are not active
// or have not opted in look missing.
func (sb *storefrontBusiness) openShop(
	ctx context.Context,
	slug, buyerProfileID string,
) (context.Context, *models.Shop, error) {
	notFound := connect.NewError(connect.CodeNotFound, "shop not found")
	slug = strings.TrimSpace(slug)
	if slug == "" {
		return nil, nil, notFound
	}

	// Slugs are unique across tenants; the lookup runs before the tenant is
	// known.
	shop, err := sb.shopRepo.GetBySlug(tenancy.WithSkipEnforcement(ctx), slug)
	if err != nil || shop == nil {
		return nil, nil, notFound
	}
	if !shop.PublicStorefront || shop.Status != int32(commercev1.ShopStatus_SHOP_STATUS_ACTIVE) {
		return nil, nil, notFound
	}

	claims := &security.AuthenticationClaims{TenantID: shop.TenantID, PartitionID: shop.PartitionID}
	claims.Subject = buyerProfileID
	ctx = claims.ClaimsToContext(ctx)
	// Peer services (profile, checkout) see the shop's tenancy too.
	ctx = util.SetTenancy(ctx, claims)
	return ctx, shop, nil
}

// validateStorefrontOrder checks what an anonymous form can get wrong and
// returns the order lines.
func validateStorefrontOrder(order *StorefrontOrder) ([]*commercev1.CreateOrderLine, error) {
	invalid := func(msg string) error { return connect.NewError(connect.CodeInvalidArgument, msg) }

	order.Name = strings.TrimSpace(order.Name)
	if order.Name == "" || utf8.RuneCountInString(order.Name) > storefrontMaxName {
		return nil, invalid("enter your name")
	}
	order.Contact = normaliseContact(order.Contact)
	if !storefrontEmailPattern.MatchString(order.Contact) && !storefrontPhonePattern.MatchString(order.Contact) {
		return nil, invalid("enter a valid email address or phone number")
	}
	if !storefrontKeyPattern.MatchString(order.Key) {
		return nil, invalid("this form has expired; reload the page and try again")
	}

	lines := make([]*commercev1.CreateOrderLine, 0, len(order.Quantities))
	for variantID, quantity := range order.Quantities {
		switch {
		case quantity == 0:
			continue
		case !storefrontIDPattern.MatchString(variantID):
			return nil, invalid("that item is no longer available")
		case quantity < 0 || quantity > storefrontMaxQuantity:
			return nil, invalid("quantities must be between 1 and 99")
		}
		lines = append(lines, &commercev1.CreateOrderLine{VariantId: variantID, Quantity: quantity})
	}
	switch {
	case len(lines) == 0:
		return nil, invalid("choose at least one item")
	case len(lines) > storefrontMaxLines:
		return nil, invalid("too many items in one order")
	}
	return lines, nil
}

// parseStorefrontAmount reads a decimal amount with at most two decimals.
// Empty means no amount.
func parseStorefrontAmount(currency, raw string) (*commonv1.Money, error) {
	raw = strings.TrimSpace(strings.ReplaceAll(raw, ",", ""))
	if raw == "" {
		return nil, nil //nolint:nilnil // no amount is a valid answer
	}
	match := storefrontAmountPattern.FindStringSubmatch(raw)
	if match == nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, "enter the amount to pay now as a number")
	}
	// The pattern bounds both parts, so neither parse can fail or overflow.
	units, _ := strconv.ParseInt(match[1], 10, 64)
	cents := int64(0)
	if match[2] != "" {
		cents, _ = strconv.ParseInt((match[2] + "0")[:2], 10, 64)
	}
	const nanosPerUnit, nanosPerCent = 1_000_000_000, 10_000_000
	nanos := units*nanosPerUnit + cents*nanosPerCent
	if nanos == 0 {
		return nil, connect.NewError(connect.CodeInvalidArgument, "the amount to pay now must be more than zero")
	}
	return models.MoneyFromNanos(currency, nanos), nil
}

// normaliseContact trims the contact and, for phone numbers, drops the
// spaces and dashes people type.
func normaliseContact(contact string) string {
	contact = strings.TrimSpace(contact)
	if strings.Contains(contact, "@") {
		return strings.ToLower(contact)
	}
	return strings.NewReplacer(" ", "", "-", "", "(", "", ")", "").Replace(contact)
}
