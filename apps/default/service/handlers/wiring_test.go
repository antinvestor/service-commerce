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

package handlers_test

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"

	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connecthttp"
	"github.com/stretchr/testify/require"

	commercev1 "github.com/antinvestor/service-commerce/gen/go/commerce/v1"
	"github.com/antinvestor/service-commerce/gen/go/commerce/v1/commercev1connect"
)

// shopOnly answers GetShop and leaves every other RPC unimplemented.
type shopOnly struct {
	commercev1connect.UnimplementedCommerceServiceHandler
}

func (shopOnly) GetShop(_ context.Context, req *commercev1.GetShopRequest) (*commercev1.GetShopResponse, error) {
	if req.GetId() == "missing" {
		return nil, connect.NewError(connect.CodeNotFound, "shop not found")
	}
	return &commercev1.GetShopResponse{Shop: &commercev1.Shop{Id: req.GetId(), Name: "Duka"}}, nil
}

// The services mount a connect.Server on a mux next to plain HTTP routes
// (the payment return page); a generated client must reach the RPCs and the
// plain route must still answer.
func TestConnectServerMountsBesidePlainRoutes(t *testing.T) {
	t.Parallel()
	server := connect.NewServer()
	commercev1connect.RegisterCommerceServiceHandler(server, shopOnly{})
	mux := http.NewServeMux()
	mux.HandleFunc("/payments/return", func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusTeapot)
	})
	connecthttp.Mount(mux, server)
	srv := httptest.NewServer(mux)
	t.Cleanup(srv.Close)

	client := commercev1connect.NewCommerceServiceClient(
		connect.NewClient(connecthttp.NewTransport(srv.Client(), srv.URL)))
	ctx := t.Context()

	got, err := client.GetShop(ctx, &commercev1.GetShopRequest{Id: "shop-1"})
	require.NoError(t, err)
	require.Equal(t, "Duka", got.GetShop().GetName())

	_, err = client.GetShop(ctx, &commercev1.GetShopRequest{Id: "missing"})
	require.Equal(t, connect.CodeNotFound, connect.CodeOf(err))

	_, err = client.ListShops(ctx, &commercev1.ListShopsRequest{})
	require.Equal(t, connect.CodeUnimplemented, connect.CodeOf(err))

	resp, err := srv.Client().Get(srv.URL + "/payments/return")
	require.NoError(t, err)
	require.NoError(t, resp.Body.Close())
	require.Equal(t, http.StatusTeapot, resp.StatusCode)
}
