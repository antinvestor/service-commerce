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
	"strings"

	"connectrpc.com/connect"
	"github.com/pitabwire/frame/v2"
	"github.com/pitabwire/frame/v2/data"
	"github.com/pitabwire/frame/v2/security"
	"github.com/pitabwire/util"

	commercev1 "github.com/antinvestor/service-commerce/gen/go/commerce/v1"

	"github.com/antinvestor/service-commerce/apps/default/service/authz"
	"github.com/antinvestor/service-commerce/apps/default/service/models"
	"github.com/antinvestor/service-commerce/apps/default/service/repository"
)

// ShopPage is one page of shops plus the cursor for the next page.
type ShopPage struct {
	Shops    []*commercev1.Shop
	NextPage string
}

type ShopBusiness interface {
	// CreateShop creates the shop, makes the authenticated caller its owner,
	// and bridges the partition's staff roles onto the shop so employees
	// managed through the identity service can work in it. If the grants
	// cannot be written the shop is removed again and the error returned.
	CreateShop(ctx context.Context, req *commercev1.CreateShopRequest) (*commercev1.Shop, error)
	GetShop(ctx context.Context, id string) (*commercev1.Shop, error)
	UpdateShop(ctx context.Context, req *commercev1.UpdateShopRequest) (*commercev1.Shop, error)
	ListShops(ctx context.Context, req *commercev1.ListShopsRequest) (*ShopPage, error)
}

func NewShopBusiness(_ context.Context, shopRepo repository.ShopRepository, authzMw authz.Middleware) ShopBusiness {
	return &shopBusiness{shopRepo: shopRepo, authz: authzMw}
}

type shopBusiness struct {
	shopRepo repository.ShopRepository
	authz    authz.Middleware
}

func (sb *shopBusiness) CreateShop(ctx context.Context, req *commercev1.CreateShopRequest) (*commercev1.Shop, error) {
	name := strings.TrimSpace(req.GetName())
	if name == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("shop name is required"))
	}

	slug := strings.TrimSpace(req.GetSlug())
	if slug == "" {
		slug = strings.ToLower(strings.ReplaceAll(name, " ", "-"))
	}

	// Check slug uniqueness
	existing, err := sb.shopRepo.GetBySlug(ctx, slug)
	if err == nil && existing != nil {
		return nil, connect.NewError(connect.CodeAlreadyExists, errors.New("shop with this slug already exists"))
	}
	if err != nil && !frame.ErrorIsNotFound(err) {
		return nil, err
	}

	currency := strings.ToUpper(strings.TrimSpace(req.GetCurrency()))
	if currency == "" {
		currency = defaultShopCurrency
	}
	if len(currency) != currencyCodeLength {
		return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("currency must be an ISO 4217 code"))
	}

	shop := &models.Shop{
		Name:              name,
		Slug:              slug,
		Description:       req.GetDescription(),
		Status:            int32(commercev1.ShopStatus_SHOP_STATUS_ACTIVE),
		Currency:          currency,
		ContactID:         req.GetContactId(),
		CheckoutReturnURL: strings.TrimSpace(req.GetCheckoutReturnUrl()),
		MediaIDs:          models.StringArray(req.GetMediaIds()),
		Properties:        data.JSONMap{},
	}

	if createErr := sb.shopRepo.Create(ctx, shop); createErr != nil {
		return nil, data.ErrorConvertToAPI(createErr)
	}

	if ownerErr := sb.grantAccess(ctx, shop); ownerErr != nil {
		if delErr := sb.shopRepo.Delete(ctx, shop.GetID()); delErr != nil {
			util.Log(ctx).WithError(delErr).WithField("shop_id", shop.GetID()).
				Error("could not roll back shop after ownership grant failure")
		}
		return nil, connect.NewError(connect.CodeInternal,
			fmt.Errorf("grant shop ownership: %w", ownerErr))
	}

	return shop.ToAPI(), nil
}

// Shop defaults.
const (
	defaultShopCurrency = "KES"
	currencyCodeLength  = 3
)

// grantAccess writes the owner tuple for the calling subject and bridges the
// partition's roles onto the shop. Without an authenticated subject (internal
// callers, tests) there is nothing to grant.
func (sb *shopBusiness) grantAccess(ctx context.Context, shop *models.Shop) error {
	if sb.authz == nil {
		return nil
	}
	claims := security.ClaimsFromContext(ctx)
	if claims == nil {
		return nil
	}
	// An unreadable or empty subject means an internal caller; nothing to grant.
	profileID, _ := claims.GetSubject()
	if profileID == "" {
		return nil
	}
	if err := sb.authz.AddShopMember(ctx, shop.GetID(), profileID, authz.RoleOwner); err != nil {
		return err
	}
	tenantID, partitionID := claims.GetTenantID(), claims.GetPartitionID()
	if tenantID == "" || partitionID == "" {
		return nil
	}
	return sb.authz.BridgeShopRoles(ctx, shop.GetID(), tenantID+"/"+partitionID)
}

func (sb *shopBusiness) ListShops(ctx context.Context, req *commercev1.ListShopsRequest) (*ShopPage, error) {
	page, err := pageFromSearch(req.GetSearch())
	if err != nil {
		return nil, err
	}
	shops, next, err := sb.shopRepo.List(ctx, page)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	result := &ShopPage{Shops: make([]*commercev1.Shop, 0, len(shops)), NextPage: nextCursor(next)}
	for _, shop := range shops {
		result.Shops = append(result.Shops, shop.ToAPI())
	}
	return result, nil
}

func (sb *shopBusiness) GetShop(ctx context.Context, id string) (*commercev1.Shop, error) {
	shop, err := sb.shopRepo.GetByID(ctx, id)
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}
	return shop.ToAPI(), nil
}

func (sb *shopBusiness) UpdateShop(ctx context.Context, req *commercev1.UpdateShopRequest) (*commercev1.Shop, error) {
	shop, err := sb.shopRepo.GetByID(ctx, req.GetId())
	if err != nil {
		return nil, data.ErrorConvertToAPI(err)
	}

	updateColumns := applyShopFields(shop, req)
	if len(updateColumns) > 0 {
		if _, updateErr := sb.shopRepo.Update(ctx, shop, updateColumns...); updateErr != nil {
			return nil, data.ErrorConvertToAPI(updateErr)
		}
	}

	return shop.ToAPI(), nil
}

// applyShopFields copies requested fields onto the shop and returns the
// columns to persist. Without a mask only fields carrying a value are applied,
// so a partial request cannot blank description or media.
func applyShopFields(shop *models.Shop, req *commercev1.UpdateShopRequest) []string {
	fields := req.GetUpdateMask().GetPaths()
	explicitMask := len(fields) > 0
	if !explicitMask {
		fields = []string{
			fieldName, fieldDescription, fieldMediaIDs, fieldStatus, "extra",
			fieldCurrency, fieldContactID, fieldCheckoutReturnURL,
		}
	}

	updateColumns := make([]string, 0, len(fields))
	for _, field := range fields {
		if column, ok := applyShopField(shop, req, field, explicitMask); ok {
			updateColumns = append(updateColumns, column)
		}
	}
	return updateColumns
}

func applyShopField(
	shop *models.Shop,
	req *commercev1.UpdateShopRequest,
	field string,
	explicitMask bool,
) (string, bool) {
	switch field {
	case fieldName:
		if name := strings.TrimSpace(req.GetName()); name != "" {
			shop.Name = name
			return fieldName, true
		}
	case fieldDescription:
		if explicitMask || req.GetDescription() != "" {
			shop.Description = req.GetDescription()
			return fieldDescription, true
		}
	case fieldMediaIDs:
		if explicitMask || len(req.GetMediaIds()) > 0 {
			shop.MediaIDs = models.StringArray(req.GetMediaIds())
			return fieldMediaIDs, true
		}
	case fieldStatus:
		if req.GetStatus() != commercev1.ShopStatus_SHOP_STATUS_UNSPECIFIED {
			shop.Status = int32(req.GetStatus())
			return fieldStatus, true
		}
	case "extra":
		if req.GetExtra() != nil {
			props := data.JSONMap{}
			shop.Properties = props.FromProtoStruct(req.GetExtra())
			return "properties", true
		}
	case fieldCurrency, fieldContactID, fieldCheckoutReturnURL:
		return applyShopSettingField(shop, req, field, explicitMask)
	}
	return "", false
}

// applyShopSettingField handles the commercial settings: currency, seller
// contact, and the checkout return page.
func applyShopSettingField(
	shop *models.Shop,
	req *commercev1.UpdateShopRequest,
	field string,
	explicitMask bool,
) (string, bool) {
	switch field {
	case fieldCurrency:
		if c := strings.ToUpper(strings.TrimSpace(req.GetCurrency())); len(c) == currencyCodeLength {
			shop.Currency = c
			return fieldCurrency, true
		}
	case fieldContactID:
		if explicitMask || req.GetContactId() != "" {
			shop.ContactID = req.GetContactId()
			return fieldContactID, true
		}
	case fieldCheckoutReturnURL:
		if explicitMask || req.GetCheckoutReturnUrl() != "" {
			shop.CheckoutReturnURL = strings.TrimSpace(req.GetCheckoutReturnUrl())
			return fieldCheckoutReturnURL, true
		}
	}
	return "", false
}
