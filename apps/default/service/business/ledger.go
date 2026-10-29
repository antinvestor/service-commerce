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
	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3"
	"github.com/pitabwire/frame/v3/data"
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
	// Clock tells the time; nil is the system clock.
	Clock func() time.Time
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
	if policy.Clock == nil {
		policy.Clock = time.Now
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
	metadataTradingDay = "trading_day"
	// failedRetryDays is how far back each run retries failed postings.
	failedRetryDays = 7
	// maxFailedRetries caps the failed postings retried in one run.
	maxFailedRetries = 500
)

// shopsPerPage is how many shops an all-shops run loads at a time.
var shopsPerPage = 200 //nolint:gochecknoglobals // tests page with a smaller size

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
		return nil, connect.NewError(connect.CodeUnimplemented, "ledger posting is not configured")
	}

	loc, err := lb.location()
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
	}
	now := lb.policy.Clock()
	day, to, err := tradingDayBounds(date, loc, now)
	if err != nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
	}

	// Days that failed earlier are retried first, so what they had claimed
	// is posted on its own day.
	results, err := lb.retryFailed(ctx, shopID, day, loc, now)
	if err != nil {
		return results, err
	}

	err = lb.eachShop(ctx, shopID, func(shop *models.Shop) {
		results = append(results, lb.postShopDay(ctx, shop, day, to).ToAPI())
	})
	return results, err
}

// eachShop calls fn for the one shop asked for, or for every shop, a page
// at a time.
func (lb *ledgerBusiness) eachShop(ctx context.Context, shopID string, fn func(*models.Shop)) error {
	if shopID != "" {
		shop, err := lb.shopRepo.GetByID(ctx, shopID)
		if err != nil {
			return data.ErrorConvertToAPI(err)
		}
		fn(shop)
		return nil
	}
	page := repository.Page{Limit: shopsPerPage}
	for {
		shops, next, err := lb.shopRepo.List(ctx, page)
		if err != nil {
			return data.ErrorConvertToAPI(err)
		}
		for _, shop := range shops {
			if ctx.Err() != nil {
				return ctx.Err()
			}
			fn(shop)
		}
		if next == nil {
			return nil
		}
		page.After = next
	}
}

// retryFailed posts again every failed day of the last failedRetryDays
// before day.
func (lb *ledgerBusiness) retryFailed(
	ctx context.Context,
	shopID, day string,
	loc *time.Location,
	now time.Time,
) ([]*commercev1.LedgerPosting, error) {
	since := now.In(loc).AddDate(0, 0, -failedRetryDays-1).Format(tradingDayLayout)
	failed, err := lb.postingRepo.ListFailedSince(ctx, shopID, since, maxFailedRetries)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	var results []*commercev1.LedgerPosting
	for _, posting := range failed {
		if ctx.Err() != nil {
			return results, ctx.Err()
		}
		if posting.TradingDay == day {
			continue // posted below
		}
		failedDay, to, boundsErr := tradingDayBounds(posting.TradingDay, loc, now)
		if boundsErr != nil {
			continue
		}
		shop, shopErr := lb.shopRepo.GetByID(ctx, posting.ShopID)
		if shopErr != nil {
			util.Log(ctx).WithError(shopErr).WithField(metadataShopID, posting.ShopID).
				Warn("could not load the shop of a failed ledger posting")
			continue
		}
		results = append(results, lb.postShopDay(ctx, shop, failedDay, to).ToAPI())
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

// tradingDayBounds returns the day label and the end of the day. Without a
// date the previous calendar day is used, which is what a nightly run wants.
// A day that has not ended yet is refused: posting it early would close it
// before its takings are in.
func tradingDayBounds(date string, loc *time.Location, now time.Time) (string, time.Time, error) {
	y, m, d := now.In(loc).Date()
	today := time.Date(y, m, d, 0, 0, 0, 0, loc)
	start := today.AddDate(0, 0, -1)
	if date != "" {
		parsed, err := time.ParseInLocation(tradingDayLayout, date, loc)
		if err != nil {
			return "", time.Time{}, fmt.Errorf("date must be YYYY-MM-DD: %w", err)
		}
		start = parsed
	}
	if !start.Before(today) {
		return "", time.Time{}, errors.New("a trading day can only be posted once it has ended")
	}
	return start.Format(tradingDayLayout), start.AddDate(0, 0, 1), nil
}

// dayTransactionID is the ledger transaction id of a shop's trading day.
func dayTransactionID(shopID, day string) string {
	return fmt.Sprintf("commerce-eod-%s-%s", shopID, day)
}

// postShopDay is idempotent per (shop, day): an existing posting is returned
// as-is, a failed one is retried with exactly what it first claimed, and a
// day whose takings net to nothing is recorded as skipped.
func (lb *ledgerBusiness) postShopDay(
	ctx context.Context,
	shop *models.Shop,
	day string,
	to time.Time,
) *models.LedgerPosting {
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

	txnID := dayTransactionID(shop.GetID(), day)
	items, err := lb.orderRepo.ClaimLedgerItems(ctx, shop.GetID(), to, txnID)
	if err != nil {
		return lb.recordFailure(ctx, shop, day, existing, fmt.Errorf("claim the day's takings: %w", err))
	}

	posting := existing
	if posting == nil {
		posting = &models.LedgerPosting{ShopID: shop.GetID(), TradingDay: day}
		// The scheduler runs as a service account; postings belong to the shop.
		posting.CopyPartitionInfo(&shop.BaseModel)
	}
	posting.Currency, posting.SalesNanos, posting.RefundNanos, err = sumDay(items)
	if err != nil {
		return lb.recordFailure(ctx, shop, day, existing, err)
	}
	posting.OrderCount = int32(distinctOrders(items)) //nolint:gosec // bounded by a day's orders
	posting.Error = ""
	if posting.Currency == "" {
		posting.Currency = shop.Currency
	}

	// Nothing to move: no takings, or a sale refunded within the day.
	if posting.SalesNanos == posting.RefundNanos {
		posting.Status = models.LedgerPostingSkipped
		lb.save(ctx, posting, existing != nil)
		return posting
	}

	accounts, err := lb.gateway.EnsureShopBook(ctx, shop, lb.policy.BookType)
	if err != nil {
		return lb.recordFailure(ctx, shop, day, existing, fmt.Errorf("ensure shop book: %w", err))
	}

	posted, err := lb.gateway.PostTransaction(ctx, buildDayTransaction(shop, day, txnID, to, accounts, posting))
	if err != nil {
		return lb.recordFailure(ctx, shop, day, existing, fmt.Errorf("post transaction: %w", err))
	}

	posting.TransactionID = posted
	posting.Status = models.LedgerPostingPosted
	lb.save(ctx, posting, existing != nil)

	// Orders paid in instalments show the transaction of their latest one.
	if stampErr := lb.orderRepo.SetLedgerTransaction(ctx, paymentOrderIDs(items.Payments), posted); stampErr != nil {
		util.Log(ctx).WithError(stampErr).WithField(metadataShopID, shop.GetID()).
			Warn("posted to ledger but could not stamp the paid orders")
	}

	lb.notifier.LedgerDayPosted(ctx, shop, posting)
	return posting
}

// distinctOrders counts orders touched by the day, so a sale refunded the
// same day, or several instalments on one order, count once.
func distinctOrders(items *repository.LedgerItems) int {
	seen := map[string]struct{}{}
	for _, p := range items.Payments {
		seen[p.OrderID] = struct{}{}
	}
	for _, o := range items.Orders {
		seen[o.GetID()] = struct{}{}
	}
	for _, r := range items.Refunds {
		seen[r.OrderID] = struct{}{}
	}
	return len(seen)
}

func paymentOrderIDs(payments []*models.OrderPayment) []string {
	ids := make([]string, 0, len(payments))
	for _, p := range payments {
		ids = append(ids, p.OrderID)
	}
	return ids
}

// sumDay totals the sales (the sale part of each payment, plus orders paid
// in full before payments were recorded one by one) and the refunds of
// sales, in nanos, and rejects mixed currencies, which would make a single
// balanced transaction meaningless. Excess payments, and their refunds, are
// owed to the buyer and never booked.
func sumDay(items *repository.LedgerItems) (string, int64, int64, error) {
	currency := ""
	same := func(c, what string) error {
		if currency == "" {
			currency = c
			return nil
		}
		if c != currency {
			return fmt.Errorf("%s is in %s but the day is in %s", what, c, currency)
		}
		return nil
	}
	var sales, refunds int64
	for _, o := range items.Orders {
		if err := same(o.TotalCurrency, "order "+o.OrderNumber); err != nil {
			return "", 0, 0, err
		}
		sales += o.TotalNanosValue()
	}
	for _, p := range items.Payments {
		if p.SaleNanos() == 0 {
			continue
		}
		if err := same(p.Currency, "payment "+p.Reference); err != nil {
			return "", 0, 0, err
		}
		sales += p.SaleNanos()
	}
	for _, r := range items.Refunds {
		if err := same(r.Currency, "refund "+r.Reference); err != nil {
			return "", 0, 0, err
		}
		refunds += r.AmountNanos
	}
	return currency, sales, refunds, nil
}

// buildDayTransaction debits the receivable account and credits sales with
// the net of the day. A net refund day posts the mirror image.
func buildDayTransaction(
	shop *models.Shop,
	day, transactionID string,
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
		Id:           transactionID,
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
		// The scheduler runs as a service account; postings belong to the shop.
		posting.CopyPartitionInfo(&shop.BaseModel)
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
		*ledgerv1.GetBookRequest,
	) (*ledgerv1.GetBookResponse, error)
	CreateBook(
		context.Context,
		*ledgerv1.CreateBookRequest,
	) (*ledgerv1.CreateBookResponse, error)
	CreateLedger(
		context.Context,
		*ledgerv1.CreateLedgerRequest,
	) (*ledgerv1.CreateLedgerResponse, error)
	CreateAccount(
		context.Context,
		*ledgerv1.CreateAccountRequest,
	) (*ledgerv1.CreateAccountResponse, error)
	CreateTransaction(
		context.Context,
		*ledgerv1.CreateTransactionRequest,
	) (*ledgerv1.CreateTransactionResponse, error)
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
		ledgerv1.GetBookRequest_builder{Id: bookID}.Build(),
	); err != nil {
		if !frame.ErrorIsNotFound(err) && connect.CodeOf(err) != connect.CodeNotFound {
			return nil, fmt.Errorf("get book: %w", err)
		}
		meta, _ := structpb.NewStruct(map[string]any{metadataShopID: shop.GetID(), metadataSource: sourceCommerce})
		_, err = g.cli.CreateBook(ctx, ledgerv1.CreateBookRequest_builder{
			Id:       bookID,
			Name:     shop.Name,
			Type:     bookType,
			Currency: shop.Currency,
			Data:     meta,
		}.Build())
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
	if _, err := g.cli.CreateLedger(ctx, ledgerv1.CreateLedgerRequest_builder{
		Id: ledgerID, Type: ledgerType, Data: meta,
	}.Build()); err != nil && !isAlreadyExists(err) {
		return "", fmt.Errorf("create %s ledger: %w", kind, err)
	}

	accountID := shopAccountID(shop.GetID(), kind)
	if _, err := g.cli.CreateAccount(ctx, ledgerv1.CreateAccountRequest_builder{
		Id: accountID, LedgerId: ledgerID, Currency: shop.Currency, Data: meta,
	}.Build()); err != nil && !isAlreadyExists(err) {
		return "", fmt.Errorf("create %s account: %w", kind, err)
	}
	return accountID, nil
}

func (g *connectLedgerGateway) PostTransaction(
	ctx context.Context,
	req *ledgerv1.CreateTransactionRequest,
) (string, error) {
	resp, err := g.cli.CreateTransaction(ctx, req)
	if err != nil {
		if isAlreadyExists(err) {
			// A retry after a lost response. The id is the shop's day and
			// the day's items were fixed when first claimed, so the earlier
			// post carried exactly this content and stands.
			return req.GetId(), nil
		}
		return "", err
	}
	return resp.GetData().GetId(), nil
}

func isAlreadyExists(err error) bool {
	return connect.CodeOf(err) == connect.CodeAlreadyExists || data.ErrorIsDuplicateKey(err)
}
