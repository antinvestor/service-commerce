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

// Command devstack stands in for the platform around commerce so the service,
// the console and the storefront can be run and tried end to end on one
// machine. It serves, on one address:
//
//   - an OpenID provider anyone can sign in to as anyone (/oauth2/...),
//     granting them the owner role in the dev tenant through Keto;
//   - hosted checkout (checkout.v1.CheckoutService) with a payment page that
//     pays or cancels on a click;
//   - the profile calls commerce makes (profile.v1.ProfileService);
//   - the API gateway: /commerce/... is proxied to the commerce service with
//     the prefix stripped and CORS for local browser apps.
//
// "devstack seed" creates a demo shop with products through the running
// stack.
//
// It is for local development only and holds everything but its signing key
// in memory.
package main

import (
	"context"
	"errors"
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"
	"os"
	"os/signal"
	"strings"
	"syscall"
	"time"

	"buf.build/gen/go/antinvestor/payment/connectrpc/go/v2/checkout/v1/checkoutv1connect"
	"buf.build/gen/go/antinvestor/profile/connectrpc/go/v2/profile/v1/profilev1connect"
	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connecthttp"
)

// The dev tenant and partition every sign-in belongs to. Fixed so data
// created in one session is visible in the next.
const (
	devTenantID    = "d0devtenant000000000"
	devPartitionID = "d0devpartition000000"
)

const (
	readHeaderTimeout = 10 * time.Second
	shutdownTimeout   = 5 * time.Second
	corsMaxAgeSeconds = "600"
)

type settings struct {
	addr      string
	publicURL string
	commerce  string
	ketoWrite string
	audience  string
	stateDir  string
	// consoleAddr and consoleDir serve a built console; both are optional.
	consoleAddr string
	consoleDir  string
}

func env(key, fallback string) string {
	if v := strings.TrimSpace(os.Getenv(key)); v != "" {
		return v
	}
	return fallback
}

func main() {
	cfg := settings{
		addr:      env("DEVSTACK_ADDR", "127.0.0.1:8090"),
		publicURL: strings.TrimRight(env("DEVSTACK_URL", "http://localhost:8090"), "/"),
		commerce:  env("DEVSTACK_COMMERCE_UPSTREAM", "http://127.0.0.1:8081"),
		ketoWrite: strings.TrimRight(env("DEVSTACK_KETO_WRITE_URL", "http://127.0.0.1:4467"), "/"),
		audience:  env("DEVSTACK_AUDIENCE", "https://commerce.dev.local"),
		stateDir:  env("DEVSTACK_STATE_DIR", ".tmp/devstack"),

		consoleAddr: env("DEVSTACK_CONSOLE_ADDR", "127.0.0.1:5173"),
		consoleDir:  env("DEVSTACK_CONSOLE_DIR", ""),
	}

	if len(os.Args) > 1 && os.Args[1] == "seed" {
		if err := seed(cfg); err != nil {
			log.Fatalf("seed: %v", err)
		}
		return
	}

	if err := serve(cfg); err != nil {
		log.Fatalf("devstack: %v", err)
	}
}

// serve runs devstack, and the console when one is configured, until
// interrupted.
func serve(cfg settings) error {
	handler, err := newHandler(cfg)
	if err != nil {
		return err
	}

	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	servers := []*http.Server{{Addr: cfg.addr, Handler: handler, ReadHeaderTimeout: readHeaderTimeout}}
	if cfg.consoleDir != "" {
		servers = append(servers, &http.Server{
			Addr: cfg.consoleAddr, Handler: spa(cfg.consoleDir), ReadHeaderTimeout: readHeaderTimeout,
		})
		log.Printf("console from %s on http://%s", cfg.consoleDir, cfg.consoleAddr)
	}
	go func() {
		<-ctx.Done()
		shutdown, cancel := context.WithTimeout(context.Background(), shutdownTimeout)
		defer cancel()
		for _, srv := range servers {
			_ = srv.Shutdown(shutdown)
		}
	}()

	log.Printf("devstack on %s (issuer %s, commerce upstream %s, tenant %s/%s)",
		cfg.addr, cfg.publicURL, cfg.commerce, devTenantID, devPartitionID)
	failed := make(chan error, len(servers))
	for _, srv := range servers {
		go func() {
			if serveErr := srv.ListenAndServe(); serveErr != nil && !errors.Is(serveErr, http.ErrServerClosed) {
				failed <- serveErr
				stop()
				return
			}
			failed <- nil
		}()
	}
	var firstErr error
	for range servers {
		if serveErr := <-failed; serveErr != nil && firstErr == nil {
			firstErr = serveErr
		}
	}
	return firstErr
}

func newHandler(cfg settings) (http.Handler, error) {
	key, err := loadSigningKey(cfg.stateDir)
	if err != nil {
		return nil, err
	}
	upstream, err := url.Parse(cfg.commerce)
	if err != nil {
		return nil, err
	}

	keto := &ketoProvisioner{
		writeURL:    cfg.ketoWrite,
		tenancyPath: devTenantID + "/" + devPartitionID,
		client:      &http.Client{Timeout: ketoTimeout},
	}
	profiles := newProfileService()
	is := &issuer{
		url:         cfg.publicURL,
		audience:    cfg.audience,
		tenantID:    devTenantID,
		partitionID: devPartitionID,
		key:         key,
		codes:       map[string]*grant{},
		refresh:     map[string]*grant{},
		provision: func(who identity) error {
			profiles.ensure(who.ProfileID, who.Name, who.Email)
			return keto.provision(who)
		},
	}
	checkout := newCheckoutService(cfg.publicURL)

	mux := http.NewServeMux()
	is.mount(mux)
	mux.Handle("/pay/{ref}", checkout.payHandler())

	server := connect.NewServer()
	checkoutv1connect.RegisterCheckoutServiceHandler(server, checkout)
	profilev1connect.RegisterProfileServiceHandler(server, profiles)
	connecthttp.Mount(mux, server)

	mux.Handle("/commerce/", gateway(upstream, "/commerce"))
	mux.HandleFunc("GET /{$}", func(w http.ResponseWriter, _ *http.Request) {
		w.Header().Set("Content-Type", "text/plain; charset=utf-8")
		_, _ = w.Write([]byte("devstack: issuer, hosted checkout, profiles and the /commerce gateway\n"))
	})
	return withCORS(mux), nil
}

// gateway proxies prefix/... to upstream/..., as the platform API gateway
// does, so the storefront and console see the paths they see in production.
func gateway(upstream *url.URL, prefix string) http.Handler {
	proxy := &httputil.ReverseProxy{
		Rewrite: func(r *httputil.ProxyRequest) {
			r.SetURL(upstream)
			r.Out.URL.Path = strings.TrimPrefix(r.In.URL.Path, prefix)
			r.Out.URL.RawPath = ""
			r.SetXForwarded()
			r.Out.Host = upstream.Host
		},
		FlushInterval: -1,
	}
	return proxy
}

// withCORS lets browser apps served from this machine call every endpoint.
func withCORS(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		origin := r.Header.Get("Origin")
		if localOrigin(origin) {
			h := w.Header()
			h.Set("Access-Control-Allow-Origin", origin)
			h.Set("Access-Control-Allow-Credentials", "true")
			h.Add("Vary", "Origin")
			h.Set("Access-Control-Expose-Headers",
				"Grpc-Status, Grpc-Message, Grpc-Status-Details-Bin, Connect-Protocol-Version, WWW-Authenticate")
			if r.Method == http.MethodOptions && r.Header.Get("Access-Control-Request-Method") != "" {
				h.Set("Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS")
				h.Set("Access-Control-Allow-Headers", r.Header.Get("Access-Control-Request-Headers"))
				h.Set("Access-Control-Max-Age", corsMaxAgeSeconds)
				w.WriteHeader(http.StatusNoContent)
				return
			}
		}
		next.ServeHTTP(w, r)
	})
}

func localOrigin(origin string) bool {
	u, err := url.Parse(origin)
	if err != nil || u.Scheme != "http" {
		return false
	}
	host := u.Hostname()
	return host == "localhost" || host == "127.0.0.1"
}
