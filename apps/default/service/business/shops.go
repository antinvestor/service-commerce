package business

import (
	"context"
	"errors"
	"strings"

	commercev1 "buf.build/gen/go/antinvestor/commerce/protocolbuffers/go/commerce/v1"
	"connectrpc.com/connect"
	"github.com/pitabwire/frame"
	"github.com/pitabwire/frame/data"

	"github.com/antinvestor/service-commerce/apps/default/service/models"
	"github.com/antinvestor/service-commerce/apps/default/service/repository"
)

type ShopBusiness interface {
	CreateShop(ctx context.Context, req *commercev1.CreateShopRequest) (*commercev1.Shop, error)
	GetShop(ctx context.Context, id string) (*commercev1.Shop, error)
	UpdateShop(ctx context.Context, req *commercev1.UpdateShopRequest) (*commercev1.Shop, error)
}

func NewShopBusiness(_ context.Context, shopRepo repository.ShopRepository) ShopBusiness {
	return &shopBusiness{shopRepo: shopRepo}
}

type shopBusiness struct {
	shopRepo repository.ShopRepository
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

	shop := &models.Shop{
		Name:        name,
		Slug:        slug,
		Description: req.GetDescription(),
		Status:      int32(commercev1.ShopStatus_SHOP_STATUS_ACTIVE),
		MediaIDs:    models.StringArray(req.GetMediaIds()),
		Properties:  data.JSONMap{},
	}

	if createErr := sb.shopRepo.Create(ctx, shop); createErr != nil {
		return nil, data.ErrorConvertToAPI(createErr)
	}

	return shop.ToAPI(), nil
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

	fields := req.GetUpdateMask().GetPaths()
	if len(fields) == 0 {
		// Update all provided fields
		fields = []string{"name", "description", "media_ids", "status", "extra"}
	}

	updateColumns := make([]string, 0, len(fields))
	for _, field := range fields {
		switch field {
		case "name":
			if req.GetName() != "" {
				shop.Name = req.GetName()
				updateColumns = append(updateColumns, "name")
			}
		case "description":
			shop.Description = req.GetDescription()
			updateColumns = append(updateColumns, "description")
		case "media_ids":
			shop.MediaIDs = models.StringArray(req.GetMediaIds())
			updateColumns = append(updateColumns, "media_ids")
		case "status":
			if req.GetStatus() != commercev1.ShopStatus_SHOP_STATUS_UNSPECIFIED {
				shop.Status = int32(req.GetStatus())
				updateColumns = append(updateColumns, "status")
			}
		case "extra":
			if req.GetExtra() != nil {
				props := data.JSONMap{}
				shop.Properties = props.FromProtoStruct(req.GetExtra())
				updateColumns = append(updateColumns, "properties")
			}
		}
	}

	if len(updateColumns) > 0 {
		_, updateErr := sb.shopRepo.Update(ctx, shop, updateColumns...)
		if updateErr != nil {
			return nil, data.ErrorConvertToAPI(updateErr)
		}
	}

	return shop.ToAPI(), nil
}
