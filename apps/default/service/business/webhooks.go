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
	"bytes"
	"context"
	"crypto/hmac"
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"fmt"
	"io"
	"net"
	"net/http"
	"net/netip"
	"net/url"
	"strings"
	"syscall"
	"time"

	"connectrpc.com/connect/v2"
	"github.com/pitabwire/frame/v3/client"
)

// Webhook request headers.
const (
	HeaderWebhookEvent     = "X-Commerce-Event"
	HeaderWebhookDelivery  = "X-Commerce-Delivery"
	HeaderWebhookSignature = "X-Commerce-Signature"

	webhookTimeout      = 5 * time.Second
	maxWebhookURLLength = 1024
	maxResponseDrain    = 64 << 10
)

// WebhookDelivery is one signed POST of an order event.
type WebhookDelivery struct {
	URL        string
	Secret     string
	EventType  string
	DeliveryID string
	Body       []byte
}

// WebhookSender posts order events to shops. A 2xx response is success.
type WebhookSender interface {
	Send(ctx context.Context, delivery WebhookDelivery) error
}

// SignWebhook is the X-Commerce-Signature value for body: the hex
// HMAC-SHA256 under secret, prefixed "sha256=". Receivers recompute it over
// the raw body to authenticate the call.
func SignWebhook(secret string, body []byte) string {
	mac := hmac.New(sha256.New, []byte(secret))
	mac.Write(body)
	return "sha256=" + hex.EncodeToString(mac.Sum(nil))
}

// validateWebhookURL accepts only absolute https URLs to a named or public
// host, so a shop cannot point commerce at the platform's own network.
func validateWebhookURL(raw string) error {
	if raw == "" {
		return nil
	}
	invalid := func(reason string) error {
		return connect.NewError(connect.CodeInvalidArgument, fmt.Sprintf("webhook_url %s", reason))
	}
	if len(raw) > maxWebhookURLLength {
		return invalid("is too long")
	}
	u, err := url.Parse(raw)
	if err != nil || u.Host == "" {
		return invalid("must be an absolute URL")
	}
	if u.Scheme != schemeHTTPS {
		return invalid("must use https")
	}
	if u.User != nil {
		return invalid("must not carry credentials")
	}
	host := strings.ToLower(u.Hostname())
	if host == "localhost" || strings.HasSuffix(host, ".localhost") || strings.HasSuffix(host, ".internal") {
		return invalid("must point at a public host")
	}
	if addr, parseErr := netip.ParseAddr(host); parseErr == nil && !publicAddr(addr) {
		return invalid("must point at a public address")
	}
	return nil
}

// publicAddr reports whether addr is routable on the public internet.
func publicAddr(addr netip.Addr) bool {
	addr = addr.Unmap()
	return addr.IsGlobalUnicast() && !addr.IsPrivate() && !addr.IsLoopback() &&
		!addr.IsLinkLocalUnicast() && !addr.IsUnspecified() &&
		!netip.MustParsePrefix("100.64.0.0/10").Contains(addr) // carrier-grade NAT
}

var errBlockedAddress = errors.New("webhook host resolves to a non-public address")

// NewHTTPWebhookSender posts with a client that refuses to connect to
// non-public addresses at dial time (covering DNS that resolves inward) and
// never follows redirects.
func NewHTTPWebhookSender(ctx context.Context) WebhookSender {
	dialer := &net.Dialer{
		Timeout: webhookTimeout,
		Control: func(_, address string, _ syscall.RawConn) error {
			host, _, err := net.SplitHostPort(address)
			if err != nil {
				return err
			}
			addr, err := netip.ParseAddr(host)
			if err != nil || !publicAddr(addr) {
				return errBlockedAddress
			}
			return nil
		},
	}
	transport := &http.Transport{
		DialContext:         dialer.DialContext,
		TLSHandshakeTimeout: webhookTimeout,
		MaxIdleConns:        10, //nolint:mnd // small pool; webhooks are infrequent
		IdleConnTimeout:     time.Minute,
	}
	httpClient := client.NewHTTPClient(ctx,
		client.WithHTTPTransport(transport),
		client.WithHTTPTimeout(webhookTimeout),
		client.WithHTTPNoAuth(),
		client.WithHTTPCheckRedirect(func(*http.Request, []*http.Request) error { return http.ErrUseLastResponse }),
	)
	return &httpWebhookSender{client: httpClient}
}

type httpWebhookSender struct {
	client *http.Client
}

func (s *httpWebhookSender) Send(ctx context.Context, delivery WebhookDelivery) error {
	if err := validateWebhookURL(delivery.URL); err != nil {
		return err
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, delivery.URL, bytes.NewReader(delivery.Body))
	if err != nil {
		return fmt.Errorf("build webhook request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set(HeaderWebhookEvent, delivery.EventType)
	req.Header.Set(HeaderWebhookDelivery, delivery.DeliveryID)
	if delivery.Secret != "" {
		req.Header.Set(HeaderWebhookSignature, SignWebhook(delivery.Secret, delivery.Body))
	}
	resp, err := s.client.Do(req)
	if err != nil {
		return fmt.Errorf("post webhook: %w", err)
	}
	defer resp.Body.Close()
	_, _ = io.Copy(io.Discard, io.LimitReader(resp.Body, maxResponseDrain))
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return fmt.Errorf("webhook answered %s", resp.Status)
	}
	return nil
}
