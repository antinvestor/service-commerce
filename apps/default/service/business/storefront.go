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
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"net/netip"
	"net/url"
	"regexp"
	"strconv"
	"strings"
	"time"
	"unicode/utf8"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3/security"
	"github.com/pitabwire/util"

	commercev1 "github.com/antinvestor/service-commerce/gen/go/commerce/v1"

	"github.com/antinvestor/service-commerce/apps/default/service/models"
	"github.com/antinvestor/service-commerce/apps/default/service/repository"
	"github.com/antinvestor/service-commerce/pkg/dbrole"
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

// Storefront checkout limits a deployment does not set.
const (
	defaultStorefrontWindow     = 10 * time.Minute
	defaultCheckoutsPerVisitor  = 10
	defaultCheckoutsPerContact  = 5
	defaultCheckoutsPerShop     = 120
	storefrontVisitorV6PrefixLn = 64
)

// StorefrontPolicy bounds anonymous checkouts. Every instance counts in the
// same place, so the limits hold across the deployment.
type StorefrontPolicy struct {
	// Window is the fixed window checkouts are counted in.
	Window time.Duration
	// PerVisitor, PerContact and PerShop are how many checkouts one visitor
	// address (an IPv6 /64), one typed contact and one shop may start in a
	// window.
	PerVisitor int64
	PerContact int64
	PerShop    int64
}

func (p StorefrontPolicy) withDefaults() StorefrontPolicy {
	if p.Window <= 0 {
		p.Window = defaultStorefrontWindow
	}
	if p.PerVisitor <= 0 {
		p.PerVisitor = defaultCheckoutsPerVisitor
	}
	if p.PerContact <= 0 {
		p.PerContact = defaultCheckoutsPerContact
	}
	if p.PerShop <= 0 {
		p.PerShop = defaultCheckoutsPerShop
	}
	return p
}

// StorefrontError is a checkout failure a shopper may be shown as is: its
// message is fixed text, or about only what they typed.
type StorefrontError struct {
	Code    connect.Code
	Message string
	// KeepKey means the order may already exist: sending the form again
	// with the same key carries on with it rather than placing another.
	KeepKey bool
}

func (e *StorefrontError) Error() string { return e.Message }

// Unwrap lets connect.CodeOf read the failure's code.
func (e *StorefrontError) Unwrap() error { return connect.NewError(e.Code, e.Message) }

// Shopper-facing messages.
const (
	msgShopNotFound    = "This shop is not available."
	msgTooMany         = "Too many orders have been started just now. Please wait a few minutes and try again."
	msgUnavailable     = "We could not take your order just now. Please try again in a moment."
	msgPaymentDown     = "We could not start your payment just now. Please try again."
	msgItemsChanged    = "Some of those items are no longer available in the quantities chosen. Please check your order."
	msgShopBusy        = "This shop has too many unpaid orders just now. Please try again a little later."
	msgFormReused      = "Your order changed after it was first sent. Please check it and continue."
	msgNotTakingOrders = "This shop is not taking online orders right now."
	msgNoPaymentPage   = "This order has no payment page to send you to."
)

func shopperError(code connect.Code, message string) *StorefrontError {
	return &StorefrontError{Code: code, Message: message}
}

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
	// Visitor is the address the form came from, as infrastructure
	// commerce trusts reported it.
	Visitor string
}

// StorefrontBusiness serves shops' public pages: anyone may browse a shop
// that has opted in and buy from it without an account. The buyer becomes
// (or is matched to) a profile in the profile service; commerce keeps only
// the ids it hands back.
type StorefrontBusiness interface {
	// Storefront returns the shop with slug and its active products.
	Storefront(ctx context.Context, slug string) (*Storefront, error)
	// Checkout places order and returns the hosted checkout page to send
	// the buyer to. Every failure is a *StorefrontError.
	Checkout(ctx context.Context, slug string, order StorefrontOrder) (string, error)
}

// NewStorefrontBusiness builds the public storefront. A nil buyer directory
// leaves pages browsable but checkout unavailable; a nil limits repository
// refuses every checkout, since anonymous orders are only taken counted.
func NewStorefrontBusiness(
	shopRepo repository.ShopRepository,
	catalog CatalogBusiness,
	orders OrderBusiness,
	payments PaymentBusiness,
	buyers BuyerDirectory,
	limits repository.LimitRepository,
	policy StorefrontPolicy,
	baseURL string,
) StorefrontBusiness {
	return &storefrontBusiness{
		shopRepo: shopRepo, catalog: catalog, orders: orders, payments: payments, buyers: buyers,
		limits: limits, policy: policy.withDefaults(), baseURL: baseURL,
	}
}

type storefrontBusiness struct {
	shopRepo repository.ShopRepository
	catalog  CatalogBusiness
	orders   OrderBusiness
	payments PaymentBusiness
	buyers   BuyerDirectory
	limits   repository.LimitRepository
	policy   StorefrontPolicy
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
	productIDs := make([]string, 0, len(page.Products))
	for _, product := range page.Products {
		productIDs = append(productIDs, product.GetId())
	}
	variants, err := sb.catalog.ListVariantsByProduct(ctx, productIDs)
	if err != nil {
		return nil, err
	}
	for _, product := range page.Products {
		item := StorefrontItem{Product: product}
		for _, v := range variants[product.GetId()] {
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
		return "", shopperError(connect.CodeUnimplemented, msgNotTakingOrders)
	}
	lines, err := validateStorefrontOrder(&order)
	if err != nil {
		return "", shopperError(connect.CodeInvalidArgument, sentence(messageOf(err)))
	}

	ctx, shop, err := sb.openShop(ctx, slug, "")
	if err != nil {
		return "", shopperError(connect.CodeNotFound, msgShopNotFound)
	}
	if err = sb.admit(ctx, shop.GetID(), order); err != nil {
		return "", err
	}
	deposit, err := parseStorefrontAmount(shop.Currency, order.Deposit)
	if err != nil {
		return "", shopperError(connect.CodeInvalidArgument, sentence(messageOf(err)))
	}
	// The contact goes to the profile service as typed; commerce keeps
	// only the ids it answers with.
	buyer, err := sb.buyers.Resolve(ctx, order.Name, order.Contact)
	if err != nil {
		util.Log(ctx).WithError(err).WithField("shop_id", shop.GetID()).Warn("storefront buyer lookup failed")
		return "", shopperError(connect.CodeUnavailable, msgUnavailable)
	}

	// Act as the buyer from here on, so the order is theirs.
	ctx, _, err = sb.openShop(ctx, slug, buyer.ProfileID)
	if err != nil {
		return "", shopperError(connect.CodeNotFound, msgShopNotFound)
	}
	placed, err := sb.orders.CreateGuestOrder(ctx, &commercev1.CreateOrderRequest{
		ShopId:         shop.GetID(),
		ProfileId:      buyer.ProfileID,
		ContactId:      buyer.ContactID,
		Lines:          lines,
		IdempotencyKey: storefrontKeyPrefix + order.Key,
	}, deposit)
	if err != nil {
		return "", orderFailure(ctx, shop.GetID(), err)
	}

	result, err := sb.payments.CheckoutOrder(ctx, &commercev1.CheckoutOrderRequest{
		OrderId:   placed.GetId(),
		ReturnUrl: StorefrontURL(sb.baseURL, shop.Slug),
		Amount:    deposit,
	})
	if err != nil {
		failure := paymentFailure(ctx, placed.GetId(), err)
		failure.KeepKey = true
		return "", failure
	}
	target, err := url.Parse(result.Order.GetCheckoutUrl())
	if err != nil || target.Host == "" || !securePaymentPage(target) {
		return "", &StorefrontError{Code: connect.CodeFailedPrecondition, Message: msgNoPaymentPage, KeepKey: true}
	}
	return target.String(), nil
}

// admit counts the checkout against the visitor, the contact and the shop
// and refuses it when any is over its limit. When the count cannot be
// taken the checkout is refused too: anonymous orders are only taken
// counted.
func (sb *storefrontBusiness) admit(ctx context.Context, shopID string, order StorefrontOrder) error {
	if sb.limits == nil {
		return shopperError(connect.CodeUnavailable, msgUnavailable)
	}
	now := time.Now().UTC()
	window := now.Truncate(sb.policy.Window)
	visitor := "visitor:" + VisitorGroup(order.Visitor)
	contact := "contact:" + contactDigest(order.Contact)
	shop := "shop:" + shopID
	counts, err := sb.limits.Hit(ctx, []string{visitor, contact, shop}, window, window)
	if err != nil {
		util.Log(ctx).WithError(err).WithField("shop_id", shopID).Error("storefront checkout limit unavailable")
		return shopperError(connect.CodeUnavailable, msgUnavailable)
	}
	if counts[visitor] > sb.policy.PerVisitor || counts[contact] > sb.policy.PerContact ||
		counts[shop] > sb.policy.PerShop {
		util.Log(ctx).WithField("shop_id", shopID).
			WithField("visitor_hits", counts[visitor]).
			WithField("contact_hits", counts[contact]).
			WithField("shop_hits", counts[shop]).
			Warn("storefront checkout over its limit")
		return shopperError(connect.CodeResourceExhausted, msgTooMany)
	}
	return nil
}

// VisitorGroup is the unit a visitor is counted by: their IPv4 address, or
// the /64 their IPv6 address is in, since one subscriber holds a whole /64.
// Anything unreadable counts as one shared visitor.
func VisitorGroup(address string) string {
	addr, err := netip.ParseAddr(strings.TrimSpace(address))
	if err != nil {
		return "unknown"
	}
	addr = addr.Unmap()
	if addr.Is4() {
		return addr.String()
	}
	prefix, err := addr.Prefix(storefrontVisitorV6PrefixLn)
	if err != nil {
		return "unknown"
	}
	return prefix.String()
}

// contactDigest identifies a typed contact for counting without keeping
// it.
func contactDigest(contact string) string {
	sum := sha256.Sum256([]byte(normaliseContact(contact)))
	return hex.EncodeToString(sum[:16])
}

// orderFailure says why a guest order could not be placed without telling
// an anonymous caller about stock levels or record ids.
func orderFailure(ctx context.Context, shopID string, err error) *StorefrontError {
	var connectErr *connect.Error
	switch code := connect.CodeOf(err); {
	case errors.Is(err, ErrDepositRefused) && errors.As(err, &connectErr):
		return shopperError(code, sentence(connectErr.Message()))
	case code == connect.CodeAlreadyExists:
		return shopperError(code, msgFormReused)
	case code == connect.CodeResourceExhausted:
		return shopperError(code, msgShopBusy)
	case code == connect.CodeNotFound, code == connect.CodeInvalidArgument, code == connect.CodeFailedPrecondition:
		return shopperError(connect.CodeFailedPrecondition, msgItemsChanged)
	default:
		util.Log(ctx).WithError(err).WithField("shop_id", shopID).Warn("storefront order failed")
		return shopperError(connect.CodeUnavailable, msgUnavailable)
	}
}

// paymentFailure says why payment could not be started for a placed guest
// order.
func paymentFailure(ctx context.Context, orderID string, err error) *StorefrontError {
	var connectErr *connect.Error
	switch code := connect.CodeOf(err); {
	case errors.Is(err, ErrDepositRefused) && errors.As(err, &connectErr):
		return shopperError(code, sentence(connectErr.Message()))
	case code == connect.CodeUnimplemented:
		return shopperError(code, msgNotTakingOrders)
	default:
		util.Log(ctx).WithError(err).WithField("order_id", orderID).Warn("storefront payment could not start")
		return shopperError(connect.CodeUnavailable, msgPaymentDown)
	}
}

// messageOf is err's message without its code.
func messageOf(err error) string {
	var connectErr *connect.Error
	if errors.As(err, &connectErr) {
		return connectErr.Message()
	}
	return err.Error()
}

// sentence capitalises a message for display.
func sentence(message string) string {
	message = strings.TrimSpace(message)
	if message == "" {
		return "Please check your order and try again."
	}
	message = strings.ToUpper(message[:1]) + message[1:]
	if !strings.HasSuffix(message, ".") {
		message += "."
	}
	return message
}

// securePaymentPage reports whether buyers may be sent to target to pay: it
// must use https, unless it is on this machine, which only a local payment
// simulator is.
func securePaymentPage(target *url.URL) bool {
	if target.Scheme == schemeHTTPS {
		return true
	}
	if target.Scheme != "http" {
		return false
	}
	host := target.Hostname()
	if host == "localhost" {
		return true
	}
	ip, err := netip.ParseAddr(host)
	return err == nil && ip.IsLoopback()
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
	shop, err := sb.shopRepo.GetBySlug(dbrole.AcrossTenants(ctx, "storefront slug lookup"), slug)
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
