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
	"crypto/rand"
	"crypto/rsa"
	"crypto/sha256"
	"crypto/x509"
	"encoding/base32"
	"encoding/base64"
	"encoding/json"
	"encoding/pem"
	"errors"
	"fmt"
	"html/template"
	"math/big"
	"net/http"
	"net/url"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/pitabwire/util"
)

const (
	rsaKeyBits       = 2048
	accessTokenTTL   = time.Hour
	authCodeTTL      = 2 * time.Minute
	signingKeyID     = "devstack"
	profileIDLength  = 20
	keyFilePerm      = 0o600
	stateDirPerm     = 0o700
	tokenTypeBearer  = "Bearer"
	grantAuthCode    = "authorization_code"
	grantRefresh     = "refresh_token"
	grantClient      = "client_credentials"
	challengeS256    = "S256"
	maxTokenFormSize = 16 << 10
)

// identity is who signs in: a staff member of the one dev tenant.
type identity struct {
	ProfileID string
	ContactID string
	Name      string
	Email     string
}

// grant is what an authorization code or refresh token stands for.
type grant struct {
	who       identity
	clientID  string
	redirect  string
	challenge string
	nonce     string
	expires   time.Time
}

// issuer is a minimal OpenID provider for local development. Anyone can sign
// in as anyone: the form asks for a name and email and issues tokens for
// them in the dev tenant, granting them the owner role there.
type issuer struct {
	url         string
	audience    string
	tenantID    string
	partitionID string
	key         *rsa.PrivateKey
	provision   func(who identity) error

	mu      sync.Mutex
	codes   map[string]*grant
	refresh map[string]*grant
}

// loadSigningKey reads the RSA key in dir, creating it on first run so
// tokens survive restarts.
func loadSigningKey(dir string) (*rsa.PrivateKey, error) {
	path := filepath.Join(dir, "signing-key.pem")
	if raw, err := os.ReadFile(path); err == nil {
		block, _ := pem.Decode(raw)
		if block == nil {
			return nil, fmt.Errorf("%s holds no PEM block", path)
		}
		return x509.ParsePKCS1PrivateKey(block.Bytes)
	} else if !errors.Is(err, os.ErrNotExist) {
		return nil, err
	}

	key, err := rsa.GenerateKey(rand.Reader, rsaKeyBits)
	if err != nil {
		return nil, err
	}
	if err = os.MkdirAll(dir, stateDirPerm); err != nil {
		return nil, err
	}
	encoded := pem.EncodeToMemory(&pem.Block{Type: "RSA PRIVATE KEY", Bytes: x509.MarshalPKCS1PrivateKey(key)})
	return key, os.WriteFile(path, encoded, keyFilePerm)
}

func (is *issuer) mount(mux *http.ServeMux) {
	mux.HandleFunc("GET /.well-known/openid-configuration", is.discovery)
	mux.HandleFunc("GET /.well-known/jwks.json", is.jwks)
	mux.HandleFunc("GET /oauth2/auth", is.authorizeForm)
	mux.HandleFunc("POST /oauth2/auth", is.authorize)
	mux.HandleFunc("POST /oauth2/token", is.token)
	mux.HandleFunc("POST /oauth2/revoke", is.revoke)
	mux.HandleFunc("GET /oauth2/sessions/logout", is.logout)
	mux.HandleFunc("GET /userinfo", is.userinfo)
	mux.HandleFunc("GET /dev/token", is.devToken)
}

func (is *issuer) discovery(w http.ResponseWriter, _ *http.Request) {
	writeJSON(w, http.StatusOK, map[string]any{
		"issuer":                                is.url,
		"authorization_endpoint":                is.url + "/oauth2/auth",
		"token_endpoint":                        is.url + "/oauth2/token",
		"revocation_endpoint":                   is.url + "/oauth2/revoke",
		"end_session_endpoint":                  is.url + "/oauth2/sessions/logout",
		"userinfo_endpoint":                     is.url + "/userinfo",
		"jwks_uri":                              is.url + "/.well-known/jwks.json",
		"response_types_supported":              []string{"code"},
		"grant_types_supported":                 []string{grantAuthCode, grantRefresh, grantClient},
		"code_challenge_methods_supported":      []string{challengeS256},
		"id_token_signing_alg_values_supported": []string{jwt.SigningMethodRS256.Alg()},
		"subject_types_supported":               []string{"public"},
		"token_endpoint_auth_methods_supported": []string{"none", "client_secret_basic", "client_secret_post"},
		"scopes_supported":                      []string{"openid", "profile", "offline_access"},
	})
}

func (is *issuer) jwks(w http.ResponseWriter, _ *http.Request) {
	pub := is.key.PublicKey
	writeJSON(w, http.StatusOK, map[string]any{"keys": []map[string]string{{
		"kty": "RSA",
		"use": "sig",
		"alg": jwt.SigningMethodRS256.Alg(),
		"kid": signingKeyID,
		"n":   base64.RawURLEncoding.EncodeToString(pub.N.Bytes()),
		"e":   base64.RawURLEncoding.EncodeToString(big.NewInt(int64(pub.E)).Bytes()),
	}}})
}

//nolint:gochecknoglobals // parsed once, immutable afterwards
var signInPage = template.Must(template.New("signin").Parse(`<!doctype html>
<html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Dev sign in</title>
<style>
body{font-family:system-ui,sans-serif;max-width:24rem;margin:3rem auto;padding:0 1rem;color:#1f2937}
.banner{background:#fef3c7;border:1px solid #f59e0b;padding:.5rem .75rem;border-radius:6px;font-size:.875rem}
label{display:block;margin:.75rem 0 .25rem}input{width:100%;padding:.5rem;font-size:1rem;box-sizing:border-box}
button{margin-top:1rem;font-size:1rem;padding:.6rem 1.2rem;border:0;border-radius:6px;background:#2563eb;color:#fff}
.error{color:#b91c1c}
</style></head><body>
<p class="banner">Local development sign-in. Whoever signs in owns the dev tenant.</p>
<h1>Sign in</h1>
{{if .Error}}<p class="error">{{.Error}}</p>{{end}}
<form method="post">
{{range $k, $v := .Params}}<input type="hidden" name="{{$k}}" value="{{$v}}">{{end}}
<label for="name">Name</label><input id="name" name="name" value="{{.Name}}" required>
<label for="email">Email</label><input id="email" name="email" type="email" value="{{.Email}}" required>
<button>Sign in</button>
</form></body></html>`))

type signInView struct {
	Params map[string]string
	Name   string
	Email  string
	Error  string
}

// authorizeParams are the request parameters carried through the form.
var authorizeParams = []string{ //nolint:gochecknoglobals // fixed protocol parameter list
	"client_id", "redirect_uri", "state", "nonce", "code_challenge", "code_challenge_method", "response_type",
}

func (is *issuer) authorizeForm(w http.ResponseWriter, r *http.Request) {
	view := signInView{Params: map[string]string{}, Name: "Dev Owner", Email: "owner@dev.local"}
	for _, p := range authorizeParams {
		view.Params[p] = r.URL.Query().Get(p)
	}
	renderSignIn(w, http.StatusOK, view)
}

func renderSignIn(w http.ResponseWriter, status int, view signInView) {
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	w.Header().Set("Cache-Control", "no-store")
	w.WriteHeader(status)
	_ = signInPage.Execute(w, view)
}

func (is *issuer) authorize(w http.ResponseWriter, r *http.Request) {
	r.Body = http.MaxBytesReader(w, r.Body, maxTokenFormSize)
	if err := r.ParseForm(); err != nil {
		http.Error(w, "bad form", http.StatusBadRequest)
		return
	}
	view := signInView{Params: map[string]string{}, Name: r.PostForm.Get("name"), Email: r.PostForm.Get("email")}
	for _, p := range authorizeParams {
		view.Params[p] = r.PostForm.Get(p)
	}
	redirect, err := url.Parse(view.Params["redirect_uri"])
	switch {
	case err != nil || redirect.Host == "" || (redirect.Scheme != "http" && redirect.Scheme != "https"):
		view.Error = "redirect_uri must be an absolute http(s) URL"
	case view.Params["response_type"] != "code":
		view.Error = "only response_type=code is supported"
	case view.Params["code_challenge_method"] != challengeS256 || view.Params["code_challenge"] == "":
		view.Error = "PKCE with S256 is required"
	case strings.TrimSpace(view.Name) == "" || !strings.Contains(view.Email, "@"):
		view.Error = "enter a name and an email address"
	}
	if view.Error != "" {
		renderSignIn(w, http.StatusBadRequest, view)
		return
	}

	who := is.identityFor(view.Name, view.Email)
	if err = is.provision(who); err != nil {
		view.Error = "could not grant access: " + err.Error()
		renderSignIn(w, http.StatusBadGateway, view)
		return
	}

	code := randomToken()
	is.mu.Lock()
	is.codes[code] = &grant{
		who:       who,
		clientID:  view.Params["client_id"],
		redirect:  view.Params["redirect_uri"],
		challenge: view.Params["code_challenge"],
		nonce:     view.Params["nonce"],
		expires:   time.Now().Add(authCodeTTL),
	}
	is.mu.Unlock()

	query := redirect.Query()
	query.Set("code", code)
	query.Set("state", view.Params["state"])
	redirect.RawQuery = query.Encode()
	w.Header().Set("Location", redirect.String())
	w.WriteHeader(http.StatusSeeOther)
}

// identityFor derives stable ids from the email, so signing in again after
// a restart is the same person.
func (is *issuer) identityFor(name, email string) identity {
	email = strings.ToLower(strings.TrimSpace(email))
	return identity{
		ProfileID: stableID("profile:" + email),
		ContactID: stableID("contact:" + email),
		Name:      strings.TrimSpace(name),
		Email:     email,
	}
}

func stableID(seed string) string {
	sum := sha256.Sum256([]byte(seed))
	return strings.ToLower(base32.HexEncoding.EncodeToString(sum[:]))[:profileIDLength]
}

func (is *issuer) token(w http.ResponseWriter, r *http.Request) {
	r.Body = http.MaxBytesReader(w, r.Body, maxTokenFormSize)
	if err := r.ParseForm(); err != nil {
		oauthError(w, "invalid_request", "bad form")
		return
	}
	var g *grant
	switch r.PostForm.Get("grant_type") {
	case grantAuthCode:
		is.mu.Lock()
		g = is.codes[r.PostForm.Get("code")]
		delete(is.codes, r.PostForm.Get("code"))
		is.mu.Unlock()
		if g == nil || time.Now().After(g.expires) || g.redirect != r.PostForm.Get("redirect_uri") ||
			!pkceMatches(g.challenge, r.PostForm.Get("code_verifier")) {
			oauthError(w, "invalid_grant", "the code is unknown, expired or does not match")
			return
		}
	case grantRefresh:
		is.mu.Lock()
		g = is.refresh[r.PostForm.Get("refresh_token")]
		delete(is.refresh, r.PostForm.Get("refresh_token"))
		is.mu.Unlock()
		if g == nil {
			oauthError(w, "invalid_grant", "the refresh token is unknown")
			return
		}
	case grantClient:
		is.serviceToken(w, r)
		return
	default:
		oauthError(w, "unsupported_grant_type", "use authorization_code, refresh_token or client_credentials")
		return
	}

	access, err := is.accessToken(g.who)
	if err != nil {
		oauthError(w, "server_error", err.Error())
		return
	}
	idToken, err := is.idToken(g)
	if err != nil {
		oauthError(w, "server_error", err.Error())
		return
	}
	refresh := randomToken()
	is.mu.Lock()
	is.refresh[refresh] = g
	is.mu.Unlock()

	body := tokenResponse(access)
	body["id_token"] = idToken
	body["refresh_token"] = refresh
	body["scope"] = "openid profile offline_access"
	writeJSON(w, http.StatusOK, body)
}

// serviceToken answers a service account's client credentials grant. Any
// client and secret are accepted: the peers devstack simulates do not check.
func (is *issuer) serviceToken(w http.ResponseWriter, r *http.Request) {
	clientID, _, ok := r.BasicAuth()
	if !ok {
		clientID = r.PostForm.Get("client_id")
	}
	if clientID == "" {
		oauthError(w, "invalid_client", "client credentials are required")
		return
	}
	audience := strings.FieldsFunc(r.PostForm.Get("audience"), func(c rune) bool { return c == ' ' || c == ',' })
	access, err := is.sign(is.claims(clientID, audience))
	if err != nil {
		oauthError(w, "server_error", err.Error())
		return
	}
	writeJSON(w, http.StatusOK, tokenResponse(access))
}

func pkceMatches(challenge, verifier string) bool {
	sum := sha256.Sum256([]byte(verifier))
	return verifier != "" && base64.RawURLEncoding.EncodeToString(sum[:]) == challenge
}

// accessToken is what commerce verifies: the tenancy claims Frame reads and
// the resource audience it expects.
func (is *issuer) accessToken(who identity) (string, error) {
	claims := is.personClaims(who, []string{is.audience})
	claims["access_id"] = stableID("access:" + who.ProfileID)
	claims["session_id"] = util.IDString()
	claims["roles"] = []string{"user"}
	return is.sign(claims)
}

func (is *issuer) idToken(g *grant) (string, error) {
	claims := is.personClaims(g.who, g.clientID)
	claims["name"] = g.who.Name
	claims["email"] = g.who.Email
	if g.nonce != "" {
		claims["nonce"] = g.nonce
	}
	return is.sign(claims)
}

// claims are the registered claims every token carries.
func (is *issuer) claims(subject string, audience any) jwt.MapClaims {
	now := time.Now()
	return jwt.MapClaims{
		"iss": is.url,
		"sub": subject,
		"aud": audience,
		"iat": now.Unix(),
		"exp": now.Add(accessTokenTTL).Unix(),
		"jti": util.IDString(),
	}
}

// personClaims add the dev tenancy a signed-in person acts in.
func (is *issuer) personClaims(who identity, audience any) jwt.MapClaims {
	claims := is.claims(who.ProfileID, audience)
	claims["tenant_id"] = is.tenantID
	claims["partition_id"] = is.partitionID
	claims["contact_id"] = who.ContactID
	return claims
}

func tokenResponse(access string) map[string]any {
	return map[string]any{
		"access_token": access,
		"token_type":   tokenTypeBearer,
		"expires_in":   int(accessTokenTTL.Seconds()),
	}
}

func (is *issuer) sign(claims jwt.MapClaims) (string, error) {
	token := jwt.NewWithClaims(jwt.SigningMethodRS256, claims)
	token.Header["kid"] = signingKeyID
	return token.SignedString(is.key)
}

func (is *issuer) revoke(w http.ResponseWriter, r *http.Request) {
	r.Body = http.MaxBytesReader(w, r.Body, maxTokenFormSize)
	if err := r.ParseForm(); err == nil {
		is.mu.Lock()
		delete(is.refresh, r.PostForm.Get("token"))
		is.mu.Unlock()
	}
	w.WriteHeader(http.StatusOK)
}

func (is *issuer) logout(w http.ResponseWriter, _ *http.Request) {
	w.Header().Set("Content-Type", "text/plain; charset=utf-8")
	_, _ = w.Write([]byte("Signed out.\n"))
}

func (is *issuer) userinfo(w http.ResponseWriter, r *http.Request) {
	claims := jwt.MapClaims{}
	raw := strings.TrimPrefix(r.Header.Get("Authorization"), tokenTypeBearer+" ")
	_, err := jwt.ParseWithClaims(raw, claims, func(*jwt.Token) (any, error) { return &is.key.PublicKey, nil },
		jwt.WithValidMethods([]string{jwt.SigningMethodRS256.Alg()}), jwt.WithIssuer(is.url))
	if err != nil {
		w.Header().Set("WWW-Authenticate", tokenTypeBearer)
		http.Error(w, "invalid token", http.StatusUnauthorized)
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{"sub": claims["sub"]})
}

// devToken mints an access token for scripts and curl:
// GET /dev/token?email=a@b.c&name=A. The caller is provisioned like a
// browser sign-in.
func (is *issuer) devToken(w http.ResponseWriter, r *http.Request) {
	email, name := r.URL.Query().Get("email"), r.URL.Query().Get("name")
	if !strings.Contains(email, "@") {
		http.Error(w, "email is required", http.StatusBadRequest)
		return
	}
	if name == "" {
		name = email
	}
	who := is.identityFor(name, email)
	if err := is.provision(who); err != nil {
		http.Error(w, "could not grant access: "+err.Error(), http.StatusBadGateway)
		return
	}
	access, err := is.accessToken(who)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	body := tokenResponse(access)
	body["profile_id"] = who.ProfileID
	writeJSON(w, http.StatusOK, body)
}

func randomToken() string {
	b := make([]byte, 32) //nolint:mnd // 256 bits
	_, _ = rand.Read(b)
	return base64.RawURLEncoding.EncodeToString(b)
}

func oauthError(w http.ResponseWriter, code, description string) {
	writeJSON(w, http.StatusBadRequest, map[string]string{"error": code, "error_description": description})
}

func writeJSON(w http.ResponseWriter, status int, body any) {
	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Cache-Control", "no-store")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(body)
}
