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
	"errors"
	"fmt"
	"time"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	ledgerv1 "buf.build/gen/go/antinvestor/ledger/protocolbuffers/go/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame/v2"
	"github.com/pitabwire/frame/v2/data"
	"github.com/pitabwire/util"
	"google.golang.org/protobuf/types/known/structpb"

	"github.com/antinvestor/service-commerce/apps/default/service/models"
	"github.com/antinvestor/service-commerce/apps/default/service/notifications"
	"github.com/antinvestor/service-commerce/apps/default/service/repository"
	commercev1 "github.com/antinvestor/service-commerce/gen/go/commerce/v1"
)

// LedgerGateway is the slice of the ledger service end-of-day posting uses.
type LedgerGateway interface {
	// EnsureShopBook makes sure the shop's book, ledgers, and the two
	// accounts commerce posts to exist, returning the account ids.
	EnsureShopBook(ctx context.Context, shop *models.Shop, bookType string) (*ShopAccounts, error)
	// PostTransaction records one balanced transaction and returns its id.
	PostTransaction(ctx context.Context, req *ledgerv1.CreateTransactionRequest) (string, error)
}

// ShopAccounts are the ledger accounts a shop's takings move between.
type ShopAccounts struct {
	BookID string
	// Receivable is the asset account for money collected by the payment
	// rail on the shop's behalf.
	ReceivableAccountID string
	// Sales is the income account credited with the day's sales.
	SalesAccountID string
}

// LedgerPolicy carries the deployment knobs for end-of-day posting.
type LedgerPolicy struct {
	BookType string
	// Timezone decides where a trading day starts and ends.
	Timezone string
}

type LedgerBusiness interface {
	// RunEndOfDayLedger merges each shop's paid and refunded orders for a
	// trading day into one ledger transaction. Empty shopID means every
	// shop; empty date means yesterday.
	RunEndOfDayLedger(ctx context.Context, shopID, date string) ([]*commercev1.LedgerPosting, error)
}

func NewLedgerBusiness(
	_ context.Context,
	orderRepo repository.OrderRepository,
	shopRepo repository.ShopRepository,
	postingRepo repository.LedgerPostingRepository,
	gateway LedgerGateway,
	notifier notifications.Notifier,
	policy LedgerPolicy,
) LedgerBusiness {
	if policy.BookType == "" {
		policy.BookType = defaultBookType
	}
	return &ledgerBusiness{
		orderRepo:   orderRepo,
		shopRepo:    shopRepo,
		postingRepo: postingRepo,
		gateway:     gateway,
		notifier:    notifier,
		policy:      policy,
	}
}

const (
	defaultBookType    = "merchant"
	tradingDayLayout   = "2006-01-02"
	maxShopsPerRun     = 500
	metadataTradingDay = "trading_day"
)

type ledgerBusiness struct {
	orderRepo   repository.OrderRepository
	shopRepo    repository.ShopRepository
	postingRepo repository.LedgerPostingRepository
	gateway     LedgerGateway
	notifier    notifications.Notifier
	policy      LedgerPolicy
}

func (lb *ledgerBusiness) RunEndOfDayLedger(
	ctx context.Context,
	shopID, date string,
) ([]*commercev1.LedgerPosting, error) {
	if lb.gateway == nil {
		return nil, connect.NewError(connect.CodeUnimplemented, errors.New("ledger posting is not configured"))
	}

	loc, err := lb.location()
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}
	day, from, to, err := tradingDayBounds(date, loc)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err)
	}

	shops, err := lb.targetShops(ctx, shopID)
	if err != nil {
		return nil, err
	}

	results := make([]*commercev1.LedgerPosting, 0, len(shops))
	for _, shop := range shops {
		if ctx.Err() != nil {
			return results, ctx.Err()
		}
		posting := lb.postShopDay(ctx, shop, day, from, to)
		results = append(results, posting.ToAPI())
	}
	return results, nil
}

func (lb *ledgerBusiness) location() (*time.Location, error) {
	if lb.policy.Timezone == "" {
		return time.UTC, nil
	}
	loc, err := time.LoadLocation(lb.policy.Timezone)
	if err != nil {
		return nil, fmt.Errorf("ledger timezone %q: %w", lb.policy.Timezone, err)
	}
	return loc, nil
}

// tradingDayBounds returns the day label and its [from, to) window. Without a
// date the previous calendar day is used, which is what a nightly run wants.
func tradingDayBounds(date string, loc *time.Location) (string, time.Time, time.Time, error) {
	var start time.Time
	if date == "" {
		now := time.Now().In(loc)
		y, m, d := now.Date()
		start = time.Date(y, m, d, 0, 0, 0, 0, loc).AddDate(0, 0, -1)
	} else {
		parsed, err := time.ParseInLocation(tradingDayLayout, date, loc)
		if err != nil {
			return "", time.Time{}, time.Time{}, fmt.Errorf("date must be YYYY-MM-DD: %w", err)
		}
		start = parsed
	}
	return start.Format(tradingDayLayout), start, start.AddDate(0, 0, 1), nil
}

func (lb *ledgerBusiness) targetShops(ctx context.Context, shopID string) ([]*models.Shop, error) {
	if shopID != "" {
		shop, err := lb.shopRepo.GetByID(ctx, shopID)
		if err != nil {
			return nil, data.ErrorConvertToAPI(err)
		}
		return []*models.Shop{shop}, nil
	}
	shops, _, err := lb.shopRepo.List(ctx, repository.Page{Limit: maxShopsPerRun})
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	return shops, nil
}

// postShopDay is idempotent per (shop, day): an existing posting is returned
// as-is, a failed one is retried, and a day with nothing to post is recorded
// as skipped so later runs do not re-scan it.
func (lb *ledgerBusiness) postShopDay(
	ctx context.Context,
	shop *models.Shop,
	day string,
	from, to time.Time,
) *models.LedgerPosting {
	log := util.Log(ctx).WithFields(map[string]any{metadataShopID: shop.GetID(), metadataTradingDay: day})

	existing, err := lb.postingRepo.GetByShopAndDay(ctx, shop.GetID(), day)
	if err == nil && existing.Status != models.LedgerPostingFailed {
		return existing
	}
	if err != nil && !frame.ErrorIsNotFound(err) {
		return lb.recordFailure(ctx, shop, day, nil, fmt.Errorf("load posting: %w", err))
	}
	if err != nil {
		existing = nil
	}

	paid, err := lb.orderRepo.ListPaidBetween(ctx, shop.GetID(), from, to)
	if err != nil {
		return lb.recordFailure(ctx, shop, day, existing, fmt.Errorf("list paid orders: %w", err))
	}
	refunded, err := lb.orderRepo.ListRefundedBetween(ctx, shop.GetID(), from, to)
	if err != nil {
		return lb.recordFailure(ctx, shop, day, existing, fmt.Errorf("list refunded orders: %w", err))
	}

	posting := existing
	if posting == nil {
		posting = &models.LedgerPosting{ShopID: shop.GetID(), TradingDay: day}
	}
	posting.Currency, posting.SalesNanos, posting.RefundNanos, err = sumOrders(paid, refunded)
	if err != nil {
		return lb.recordFailure(ctx, shop, day, existing, err)
	}
	posting.OrderCount = int32(distinctOrders(paid, refunded)) //nolint:gosec // bounded by a day's orders
	posting.Error = ""

	if posting.SalesNanos == 0 && posting.RefundNanos == 0 {
		posting.Status = models.LedgerPostingSkipped
		lb.save(ctx, posting, existing != nil)
		return posting
	}
	if posting.Currency == "" {
		posting.Currency = shop.Currency
	}

	accounts, err := lb.gateway.EnsureShopBook(ctx, shop, lb.policy.BookType)
	if err != nil {
		return lb.recordFailure(ctx, shop, day, existing, fmt.Errorf("ensure shop book: %w", err))
	}

	txnID, err := lb.gateway.PostTransaction(ctx, buildDayTransaction(shop, day, to, accounts, posting))
	if err != nil {
		return lb.recordFailure(ctx, shop, day, existing, fmt.Errorf("post transaction: %w", err))
	}

	posting.TransactionID = txnID
	posting.Status = models.LedgerPostingPosted
	lb.save(ctx, posting, existing != nil)

	// Stamp both sides so neither the sale nor the refund is merged twice,
	// even when they fall on different trading days.
	if stampErr := lb.orderRepo.SetLedgerTransaction(ctx, orderIDs(paid), txnID); stampErr != nil {
		log.WithError(stampErr).Error("posted to ledger but could not stamp paid orders")
	}
	if stampErr := lb.orderRepo.SetRefundLedgerTransaction(ctx, orderIDs(refunded), txnID); stampErr != nil {
		log.WithError(stampErr).Error("posted to ledger but could not stamp refunded orders")
	}

	lb.notifier.LedgerDayPosted(ctx, shop, posting)
	return posting
}

// distinctOrders counts orders touched by the day, so a sale refunded the
// same day is one order, not two.
func distinctOrders(groups ...[]*models.Order) int {
	seen := map[string]struct{}{}
	for _, g := range groups {
		for _, o := range g {
			seen[o.GetID()] = struct{}{}
		}
	}
	return len(seen)
}

func orderIDs(orders []*models.Order) []string {
	ids := make([]string, 0, len(orders))
	for _, o := range orders {
		ids = append(ids, o.GetID())
	}
	return ids
}

// sumOrders totals sales and refunds in nanos and rejects mixed currencies,
// which would make a single balanced transaction meaningless.
func sumOrders(paid, refunded []*models.Order) (string, int64, int64, error) {
	currency := ""
	var sales, refunds int64
	for _, o := range paid {
		if currency == "" {
			currency = o.TotalCurrency
		} else if o.TotalCurrency != currency {
			return "", 0, 0, fmt.Errorf(
				"order %s is in %s but the day is in %s",
				o.OrderNumber,
				o.TotalCurrency,
				currency,
			)
		}
		sales += o.TotalNanosValue()
	}
	for _, o := range refunded {
		if currency == "" {
			currency = o.TotalCurrency
		} else if o.TotalCurrency != currency {
			return "", 0, 0, fmt.Errorf(
				"order %s is in %s but the day is in %s",
				o.OrderNumber,
				o.TotalCurrency,
				currency,
			)
		}
		refunds += o.TotalNanosValue()
	}
	return currency, sales, refunds, nil
}

// buildDayTransaction debits the receivable account and credits sales with
// the net of the day. A net refund day posts the mirror image.
func buildDayTransaction(
	shop *models.Shop,
	day string,
	transactedAt time.Time,
	accounts *ShopAccounts,
	posting *models.LedgerPosting,
) *ledgerv1.CreateTransactionRequest {
	net := posting.SalesNanos - posting.RefundNanos
	debitReceivable := net >= 0
	if net < 0 {
		net = -net
	}
	amount := &commonv1.Money{
		CurrencyCode: posting.Currency,
		Units:        net / nanosPerUnit,
		Nanos:        int32(net % nanosPerUnit),
	}
	at := transactedAt.Add(-time.Second).UTC().Format(time.RFC3339)

	meta, _ := structpb.NewStruct(map[string]any{
		"description":      fmt.Sprintf("%s daily takings %s", shop.Name, day),
		metadataShopID:     shop.GetID(),
		metadataTradingDay: day,
		"orders":           int(posting.OrderCount),
		metadataSource:     sourceCommerce,
		"sales":            posting.SalesNanos,
		"refunds":          posting.RefundNanos,
	})

	return ledgerv1.CreateTransactionRequest_builder{
		Id:           fmt.Sprintf("commerce-eod-%s-%s", shop.GetID(), day),
		Currency:     posting.Currency,
		TransactedAt: at,
		Data:         meta,
		Cleared:      true,
		Type:         ledgerv1.TransactionType_NORMAL,
		Entries: []*ledgerv1.TransactionEntry{
			ledgerv1.TransactionEntry_builder{
				AccountId: accounts.ReceivableAccountID,
				Amount:    amount,
				Credit:    !debitReceivable,
			}.Build(),
			ledgerv1.TransactionEntry_builder{
				AccountId: accounts.SalesAccountID,
				Amount:    amount,
				Credit:    debitReceivable,
			}.Build(),
		},
	}.Build()
}

func (lb *ledgerBusiness) recordFailure(
	ctx context.Context,
	shop *models.Shop,
	day string,
	existing *models.LedgerPosting,
	cause error,
) *models.LedgerPosting {
	util.Log(ctx).WithError(cause).WithFields(map[string]any{
		metadataShopID: shop.GetID(), metadataTradingDay: day,
	}).Error("end-of-day ledger posting failed")

	posting := existing
	if posting == nil {
		posting = &models.LedgerPosting{ShopID: shop.GetID(), TradingDay: day, Currency: shop.Currency}
	}
	posting.Status = models.LedgerPostingFailed
	posting.Error = cause.Error()
	lb.save(ctx, posting, existing != nil)
	return posting
}

func (lb *ledgerBusiness) save(ctx context.Context, posting *models.LedgerPosting, update bool) {
	var err error
	if update {
		_, err = lb.postingRepo.Update(ctx, posting,
			"transaction_id", "currency", "sales_nanos", "refund_nanos", "order_count", "status", "error")
	} else {
		err = lb.postingRepo.Create(ctx, posting)
	}
	if err != nil {
		util.Log(ctx).WithError(err).WithField(metadataShopID, posting.ShopID).Error("could not save ledger posting")
	}
}

// --- Connect-backed gateway ---

// ledgerClient is the subset of the generated ledger client used here.
type ledgerClient interface {
	GetBook(
		context.Context,
		*connect.Request[ledgerv1.GetBookRequest],
	) (*connect.Response[ledgerv1.GetBookResponse], error)
	CreateBook(
		context.Context,
		*connect.Request[ledgerv1.CreateBookRequest],
	) (*connect.Response[ledgerv1.CreateBookResponse], error)
	CreateLedger(
		context.Context,
		*connect.Request[ledgerv1.CreateLedgerRequest],
	) (*connect.Response[ledgerv1.CreateLedgerResponse], error)
	CreateAccount(
		context.Context,
		*connect.Request[ledgerv1.CreateAccountRequest],
	) (*connect.Response[ledgerv1.CreateAccountResponse], error)
	CreateTransaction(
		context.Context,
		*connect.Request[ledgerv1.CreateTransactionRequest],
	) (*connect.Response[ledgerv1.CreateTransactionResponse], error)
}

type connectLedgerGateway struct {
	cli ledgerClient
}

// NewConnectLedgerGateway wraps a generated ledger client; nil in, nil out.
func NewConnectLedgerGateway(cli ledgerClient) LedgerGateway {
	if cli == nil {
		return nil
	}
	return &connectLedgerGateway{cli: cli}
}

// Deterministic ids let every call be a no-op after the first.
func shopBookID(shopID string) string         { return "commerce-shop-" + shopID }
func shopLedgerID(shopID, kind string) string { return "commerce-" + kind + "-" + shopID }
func shopAccountID(shopID, kind string) string {
	return "commerce-" + kind + "-acct-" + shopID
}

func (g *connectLedgerGateway) EnsureShopBook(
	ctx context.Context,
	shop *models.Shop,
	bookType string,
) (*ShopAccounts, error) {
	bookID := shopBookID(shop.GetID())
	if _, err := g.cli.GetBook(
		ctx,
		connect.NewRequest(ledgerv1.GetBookRequest_builder{Id: bookID}.Build()),
	); err != nil {
		if !frame.ErrorIsNotFound(err) && connect.CodeOf(err) != connect.CodeNotFound {
			return nil, fmt.Errorf("get book: %w", err)
		}
		meta, _ := structpb.NewStruct(map[string]any{metadataShopID: shop.GetID(), metadataSource: sourceCommerce})
		_, err = g.cli.CreateBook(ctx, connect.NewRequest(ledgerv1.CreateBookRequest_builder{
			Id:       bookID,
			Name:     shop.Name,
			Type:     bookType,
			Currency: shop.Currency,
			Data:     meta,
		}.Build()))
		if err != nil && !isAlreadyExists(err) {
			return nil, fmt.Errorf("create book: %w", err)
		}
	}

	receivable, err := g.ensureAccount(ctx, shop, bookID, "receivable", ledgerv1.LedgerType_ASSET)
	if err != nil {
		return nil, err
	}
	sales, err := g.ensureAccount(ctx, shop, bookID, "sales", ledgerv1.LedgerType_INCOME)
	if err != nil {
		return nil, err
	}
	return &ShopAccounts{BookID: bookID, ReceivableAccountID: receivable, SalesAccountID: sales}, nil
}

func (g *connectLedgerGateway) ensureAccount(
	ctx context.Context,
	shop *models.Shop,
	bookID, kind string,
	ledgerType ledgerv1.LedgerType,
) (string, error) {
	ledgerID := shopLedgerID(shop.GetID(), kind)
	meta, _ := structpb.NewStruct(map[string]any{
		"name": shop.Name + " " + kind, metadataShopID: shop.GetID(), "book_id": bookID, metadataSource: sourceCommerce,
	})
	if _, err := g.cli.CreateLedger(ctx, connect.NewRequest(ledgerv1.CreateLedgerRequest_builder{
		Id: ledgerID, Type: ledgerType, Data: meta,
	}.Build())); err != nil && !isAlreadyExists(err) {
		return "", fmt.Errorf("create %s ledger: %w", kind, err)
	}

	accountID := shopAccountID(shop.GetID(), kind)
	if _, err := g.cli.CreateAccount(ctx, connect.NewRequest(ledgerv1.CreateAccountRequest_builder{
		Id: accountID, LedgerId: ledgerID, Currency: shop.Currency, Data: meta,
	}.Build())); err != nil && !isAlreadyExists(err) {
		return "", fmt.Errorf("create %s account: %w", kind, err)
	}
	return accountID, nil
}

func (g *connectLedgerGateway) PostTransaction(
	ctx context.Context,
	req *ledgerv1.CreateTransactionRequest,
) (string, error) {
	resp, err := g.cli.CreateTransaction(ctx, connect.NewRequest(req))
	if err != nil {
		if isAlreadyExists(err) {
			// A retry after a lost response: the id is deterministic, so the
			// earlier post stands.
			return req.GetId(), nil
		}
		return "", err
	}
	return resp.Msg.GetData().GetId(), nil
}

func isAlreadyExists(err error) bool {
	return connect.CodeOf(err) == connect.CodeAlreadyExists || data.ErrorIsDuplicateKey(err)
}
