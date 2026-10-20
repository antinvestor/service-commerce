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

package main

import (
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"net/url"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"testing"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	checkoutv1 "buf.build/gen/go/antinvestor/payment/protocolbuffers/go/checkout/v1"
	"github.com/golang-jwt/jwt/v5"
	"github.com/stretchr/testify/require"
)

// stack runs devstack against a recording Keto and a stand-in commerce.
type stack struct {
	srv      *httptest.Server
	commerce *httptest.Server

	mu       sync.Mutex
	tuples   []ketoTuple
	upstream []string
}

func newStack(t *testing.T) *stack {
	t.Helper()
	s := &stack{}
	keto := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var tuple ketoTuple
		if err := json.NewDecoder(r.Body).Decode(&tuple); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}
		s.mu.Lock()
		s.tuples = append(s.tuples, tuple)
		s.mu.Unlock()
		w.WriteHeader(http.StatusCreated)
	}))
	t.Cleanup(keto.Close)
	s.commerce = httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		s.mu.Lock()
		s.upstream = append(s.upstream, r.URL.Path)
		s.mu.Unlock()
		w.WriteHeader(http.StatusTeapot)
	}))
	t.Cleanup(s.commerce.Close)

	var handler http.Handler
	s.srv = httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		handler.ServeHTTP(w, r)
	}))
	t.Cleanup(s.srv.Close)
	var err error
	handler, err = newHandler(settings{
		publicURL: s.srv.URL,
		commerce:  s.commerce.URL,
		ketoWrite: keto.URL,
		audience:  "https://commerce.dev.local",
		stateDir:  t.TempDir(),
	})
	require.NoError(t, err)
	return s
}

func noRedirects(*http.Request, []*http.Request) error { return http.ErrUseLastResponse }

func TestSignInIssuesTokensCommerceAccepts(t *testing.T) {
	t.Parallel()
	s := newStack(t)
	client := &http.Client{CheckRedirect: noRedirects}

	verifier := "a-verifier-long-enough-for-pkce-0123456789"
	sum := sha256.Sum256([]byte(verifier))
	challenge := base64.RawURLEncoding.EncodeToString(sum[:])

	resp, err := client.PostForm(s.srv.URL+"/oauth2/auth", url.Values{
		"client_id": {"console-dev"}, "redirect_uri": {"http://localhost:5173/auth/callback"},
		"state": {"st-1"}, "nonce": {"n-1"}, "response_type": {"code"},
		"code_challenge": {challenge}, "code_challenge_method": {"S256"},
		"name": {"Amina"}, "email": {"Amina@Example.com"},
	})
	require.NoError(t, err)
	require.NoError(t, resp.Body.Close())
	require.Equal(t, http.StatusSeeOther, resp.StatusCode)
	back, err := url.Parse(resp.Header.Get("Location"))
	require.NoError(t, err)
	require.Equal(t, "st-1", back.Query().Get("state"))

	// The code only works once, with the verifier that matches.
	exchange := func(v string) (*http.Response, map[string]any) {
		r, postErr := http.PostForm(s.srv.URL+"/oauth2/token", url.Values{
			"grant_type": {"authorization_code"}, "code": {back.Query().Get("code")},
			"redirect_uri": {"http://localhost:5173/auth/callback"}, "code_verifier": {v},
		})
		require.NoError(t, postErr)
		defer r.Body.Close()
		body := map[string]any{}
		require.NoError(t, json.NewDecoder(r.Body).Decode(&body))
		return r, body
	}
	r, tokens := exchange(verifier)
	require.Equal(t, http.StatusOK, r.StatusCode, tokens)
	r, _ = exchange(verifier)
	require.Equal(t, http.StatusBadRequest, r.StatusCode, "codes are single use")

	claims := jwt.MapClaims{}
	_, _, err = jwt.NewParser().ParseUnverified(tokens["access_token"].(string), claims)
	require.NoError(t, err)
	require.Equal(t, devTenantID, claims["tenant_id"])
	require.Equal(t, devPartitionID, claims["partition_id"])
	require.Equal(t, []any{"https://commerce.dev.local"}, claims["aud"])
	require.Equal(t, s.srv.URL, claims["iss"])

	id := jwt.MapClaims{}
	_, _, err = jwt.NewParser().ParseUnverified(tokens["id_token"].(string), id)
	require.NoError(t, err)
	require.Equal(t, "amina@example.com", id["email"])
	require.Equal(t, "n-1", id["nonce"])
	require.Equal(t, claims["sub"], id["sub"])

	// Signing in grants what identity grants staff: membership and owner.
	s.mu.Lock()
	defer s.mu.Unlock()
	require.Len(t, s.tuples, 2)
	require.Equal(t, "tenancy_access", s.tuples[0].Namespace)
	require.Equal(t, "owner", s.tuples[1].Relation)
	require.Equal(t, claims["sub"], s.tuples[1].SubjectID)
}

func TestSignInRequiresPKCE(t *testing.T) {
	t.Parallel()
	s := newStack(t)
	resp, err := http.PostForm(s.srv.URL+"/oauth2/auth", url.Values{
		"redirect_uri": {"http://localhost:5173/"}, "response_type": {"code"},
		"name": {"A"}, "email": {"a@b.c"},
	})
	require.NoError(t, err)
	require.NoError(t, resp.Body.Close())
	require.Equal(t, http.StatusBadRequest, resp.StatusCode)
}

func TestHostedCheckoutPaysAndReturns(t *testing.T) {
	t.Parallel()
	checkout := newCheckoutService("http://localhost:8090")
	created, err := checkout.CreateCheckoutSession(t.Context(), checkoutv1.CreateCheckoutSessionRequest_builder{
		Name:      "Corner order 1",
		Amount:    &commonv1.Money{CurrencyCode: "KES", Units: 400},
		ReturnUrl: "http://localhost:8090/commerce/payments/return?order=o-1",
	}.Build())
	require.NoError(t, err)
	session := created.GetData()
	require.Equal(t, "http://localhost:8090/pay/"+session.GetRef(), session.GetPageUrl())

	mux := http.NewServeMux()
	mux.Handle("/pay/{ref}", checkout.payHandler())
	page := httptest.NewRecorder()
	mux.ServeHTTP(page, httptest.NewRequest(http.MethodGet, "/pay/"+session.GetRef(), nil))
	require.Contains(t, page.Body.String(), "KES 400.00")

	paid := httptest.NewRecorder()
	form := httptest.NewRequest(http.MethodPost, "/pay/"+session.GetRef(), strings.NewReader("action=pay"))
	form.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	mux.ServeHTTP(paid, form)
	require.Equal(t, http.StatusSeeOther, paid.Code)
	require.Equal(t, "http://localhost:8090/commerce/payments/return?order=o-1&session="+session.GetRef(),
		paid.Header().Get("Location"))

	got, err := checkout.GetCheckoutSession(t.Context(),
		checkoutv1.GetCheckoutSessionRequest_builder{Ref: session.GetRef()}.Build())
	require.NoError(t, err)
	require.Equal(t, checkoutv1.SessionStatus_SESSION_STATUS_COMPLETED, got.GetData().GetStatus())
	require.NotEmpty(t, got.GetData().GetPaymentId())

	again := httptest.NewRecorder()
	form = httptest.NewRequest(http.MethodPost, "/pay/"+session.GetRef(), strings.NewReader("action=cancel"))
	form.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	mux.ServeHTTP(again, form)
	require.Equal(t, http.StatusConflict, again.Code, "a settled payment stays settled")
}

func TestGatewayStripsThePrefixAndAllowsLocalApps(t *testing.T) {
	t.Parallel()
	s := newStack(t)

	req, err := http.NewRequestWithContext(t.Context(), http.MethodOptions,
		s.srv.URL+"/commerce/commerce.v1.CommerceService/ListShops", nil)
	require.NoError(t, err)
	req.Header.Set("Origin", "http://localhost:5173")
	req.Header.Set("Access-Control-Request-Method", "POST")
	req.Header.Set("Access-Control-Request-Headers", "authorization,content-type")
	resp, err := http.DefaultClient.Do(req)
	require.NoError(t, err)
	require.NoError(t, resp.Body.Close())
	require.Equal(t, http.StatusNoContent, resp.StatusCode)
	require.Equal(t, "http://localhost:5173", resp.Header.Get("Access-Control-Allow-Origin"))

	resp, err = http.Post(s.srv.URL+"/commerce/shop/corner", "text/plain", nil)
	require.NoError(t, err)
	_, _ = io.Copy(io.Discard, resp.Body)
	require.NoError(t, resp.Body.Close())
	require.Equal(t, http.StatusTeapot, resp.StatusCode)
	s.mu.Lock()
	defer s.mu.Unlock()
	require.Equal(t, []string{"/shop/corner"}, s.upstream)

	require.False(t, localOrigin("https://evil.example"))
}

func TestConsoleServesFilesCallbackAndRoutes(t *testing.T) {
	t.Parallel()
	dir := t.TempDir()
	require.NoError(t, os.WriteFile(filepath.Join(dir, "index.html"), []byte("app"), 0o600))
	require.NoError(t, os.MkdirAll(filepath.Join(dir, "auth", "callback"), 0o700))
	require.NoError(t, os.WriteFile(filepath.Join(dir, "auth", "callback", "index.html"), []byte("callback"), 0o600))
	require.NoError(t, os.WriteFile(filepath.Join(dir, "main.js"), []byte("js"), 0o600))

	get := func(target string) (int, string) {
		rec := httptest.NewRecorder()
		spa(dir).ServeHTTP(rec, httptest.NewRequest(http.MethodGet, target, nil))
		return rec.Code, rec.Body.String()
	}
	code, body := get("/main.js")
	require.Equal(t, http.StatusOK, code)
	require.Equal(t, "js", body)
	_, body = get("/auth/callback?code=x")
	require.Equal(t, "callback", body)
	_, body = get("/orders/123")
	require.Equal(t, "app", body, "app routes fall back to the app")
	code, _ = get("/missing.js")
	require.Equal(t, http.StatusNotFound, code)
	_, body = get("/../../etc/passwd")
	require.NotContains(t, body, "root:", "nothing outside the build is served")
}
