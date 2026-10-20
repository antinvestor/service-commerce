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
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"time"

	commonv1 "buf.build/gen/go/antinvestor/common/protocolbuffers/go/common/v1"
	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connecthttp"

	commercev1 "github.com/antinvestor/service-commerce/gen/go/commerce/v1"
	"github.com/antinvestor/service-commerce/gen/go/commerce/v1/commercev1connect"
)

const (
	seedTimeout   = time.Minute
	seedOwner     = "owner@dev.local"
	seedShopSlug  = "corner"
	minDepositPct = 30
)

type seedVariant struct {
	sku, name string
	units     int64
	stock     int64
}

type seedProduct struct {
	name, description string
	variants          []seedVariant
}

//nolint:gochecknoglobals // fixed demo catalogue
var seedCatalogue = []seedProduct{
	{"Kenyan Tea", "Loose leaf black tea from Kericho.", []seedVariant{
		{"TEA-250", "250g", 450, 40}, {"TEA-500", "500g", 800, 20},
	}},
	{"Avocado Honey", "Raw honey from Machakos hives.", []seedVariant{
		{"HONEY-500", "500g jar", 650, 15},
	}},
	{"Roasted Coffee", "Medium roast arabica beans.", []seedVariant{
		{"COFFEE-250", "250g", 700, 25}, {"COFFEE-1K", "1kg", 2400, 6},
	}},
}

// seed creates the demo shop and catalogue through the running stack, as the
// dev owner. Running it again leaves an existing shop as it is.
func seed(cfg settings) error {
	ctx, cancel := context.WithTimeout(context.Background(), seedTimeout)
	defer cancel()

	token, err := devAccessToken(ctx, cfg.publicURL, seedOwner)
	if err != nil {
		return err
	}
	httpClient := &http.Client{Transport: bearer{token: token, next: http.DefaultTransport}}
	client := commercev1connect.NewCommerceServiceClient(
		connect.NewClient(connecthttp.NewTransport(httpClient, cfg.publicURL+"/commerce")))

	shops, err := client.ListShops(ctx, &commercev1.ListShopsRequest{})
	if err != nil {
		return fmt.Errorf("list shops (is commerce running?): %w", err)
	}
	for _, shop := range shops.GetShops() {
		if shop.GetSlug() == seedShopSlug {
			fmt.Printf("shop %q already exists: %s\n", //nolint:forbidigo // CLI output
				shop.GetName(), shop.GetStorefrontUrl())
			return nil
		}
	}

	created, err := client.CreateShop(ctx, &commercev1.CreateShopRequest{
		Name:             "Corner Shop",
		Slug:             seedShopSlug,
		Description:      "Tea, honey and coffee from Kenyan farms.",
		Currency:         "KES",
		PublicStorefront: true,
		PaymentPolicy:    &commercev1.PaymentPolicy{AllowInstalments: true, MinDepositPercent: minDepositPct},
	})
	if err != nil {
		return fmt.Errorf("create shop: %w", err)
	}
	shop := created.GetShop()
	for _, p := range seedCatalogue {
		product, createErr := client.CreateProduct(ctx, &commercev1.CreateProductRequest{
			ShopId: shop.GetId(), Name: p.name, Description: p.description,
		})
		if createErr != nil {
			return fmt.Errorf("create product %s: %w", p.name, createErr)
		}
		for _, v := range p.variants {
			if _, createErr = client.CreateProductVariant(ctx, &commercev1.CreateProductVariantRequest{
				ProductId:     product.GetProduct().GetId(),
				Sku:           v.sku,
				Name:          v.name,
				Price:         &commonv1.Money{CurrencyCode: "KES", Units: v.units},
				StockQuantity: v.stock,
			}); createErr != nil {
				return fmt.Errorf("create variant %s: %w", v.sku, createErr)
			}
		}
	}
	fmt.Printf("created %q with %d products\nstorefront: %s\n", //nolint:forbidigo // CLI output
		shop.GetName(), len(seedCatalogue), shop.GetStorefrontUrl())
	return nil
}

func devAccessToken(ctx context.Context, base, email string) (string, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet,
		base+"/dev/token?"+url.Values{"email": {email}, "name": {"Dev Owner"}}.Encode(), nil)
	if err != nil {
		return "", err
	}
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return "", fmt.Errorf("devstack is not reachable at %s: %w", base, err)
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("dev token: %s", resp.Status)
	}
	var body struct {
		AccessToken string `json:"access_token"`
	}
	if err = json.NewDecoder(resp.Body).Decode(&body); err != nil {
		return "", err
	}
	return body.AccessToken, nil
}

// bearer adds the access token to every request.
type bearer struct {
	token string
	next  http.RoundTripper
}

func (b bearer) RoundTrip(r *http.Request) (*http.Response, error) {
	r = r.Clone(r.Context())
	r.Header.Set("Authorization", tokenTypeBearer+" "+b.token)
	return b.next.RoundTrip(r)
}
