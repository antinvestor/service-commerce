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

package repository

import (
	"context"
	"errors"
	"fmt"

	"github.com/pitabwire/frame/v3/datastore/pool"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"

	"github.com/antinvestor/service-commerce/apps/default/service/models"
)

type stockReceiptRepository struct {
	pool pool.Pool
}

// NewStockReceiptRepository builds the repository on the primary.
func NewStockReceiptRepository(dbPool pool.Pool) StockReceiptRepository {
	return &stockReceiptRepository{pool: dbPool}
}

func (r *stockReceiptRepository) Receive(
	ctx context.Context,
	variant *models.ProductVariant,
	receipt *models.StockReceipt,
) (int64, *models.StockReceipt, bool, error) {
	if variant == nil || receipt == nil || receipt.Quantity <= 0 || receipt.Reference == "" {
		return 0, nil, false, errors.New("receive stock: variant, positive quantity and reference are required")
	}
	receipt.VariantID = variant.GetID()
	receipt.CopyPartitionInfo(&variant.BaseModel)

	var (
		stock    int64
		existing *models.StockReceipt
	)
	err := r.pool.DB(ctx, false).Transaction(func(tx *gorm.DB) error {
		// Two deliveries of one reference serialise on the variant row; the
		// unique index backs this up should they name different variants.
		if err := tx.Model(&models.ProductVariant{}).Clauses(clause.Locking{Strength: "UPDATE"}).
			Where("id = ?", variant.GetID()).Select("stock_quantity").Scan(&stock).Error; err != nil {
			return fmt.Errorf("lock variant: %w", err)
		}
		var err error
		existing, err = findStockReceipt(tx, receipt)
		if err != nil || existing != nil {
			return err
		}
		inserted, err := insertStockReceipt(tx, receipt)
		if err != nil {
			return err
		}
		if !inserted {
			existing, err = findStockReceipt(tx, receipt)
			if err == nil && existing == nil {
				err = errors.New("record stock receipt: conflicting reference not found")
			}
			return err
		}
		stock += receipt.Quantity // the variant row is locked
		return nil
	})
	if err != nil {
		return 0, nil, false, err
	}
	if existing != nil {
		return stock, existing, true, nil
	}
	return stock, receipt, false, nil
}

// insertStockReceipt records receipt and raises its variant's stock; false
// when the reference was taken meanwhile.
func insertStockReceipt(tx *gorm.DB, receipt *models.StockReceipt) (bool, error) {
	res := tx.Clauses(clause.OnConflict{DoNothing: true}).Create(receipt)
	if res.Error != nil {
		return false, fmt.Errorf("record stock receipt: %w", res.Error)
	}
	if res.RowsAffected == 0 {
		return false, nil
	}
	if err := tx.Model(&models.ProductVariant{}).Where("id = ?", receipt.VariantID).
		UpdateColumn("stock_quantity", gorm.Expr("stock_quantity + ?", receipt.Quantity)).Error; err != nil {
		return false, fmt.Errorf("raise variant stock: %w", err)
	}
	return true, nil
}

func findStockReceipt(tx *gorm.DB, receipt *models.StockReceipt) (*models.StockReceipt, error) {
	var found []*models.StockReceipt
	if err := tx.Where("tenant_id = ? AND partition_id = ? AND reference = ?",
		receipt.TenantID, receipt.PartitionID, receipt.Reference).Limit(1).Find(&found).Error; err != nil {
		return nil, fmt.Errorf("find stock receipt: %w", err)
	}
	if len(found) == 0 {
		return nil, nil //nolint:nilnil // not received yet
	}
	return found[0], nil
}
