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
	"encoding/base64"
	"errors"
	"fmt"
	"strings"
	"time"

	"github.com/pitabwire/frame/v3/data"
	"gorm.io/gorm"
)

// DefaultPageSize is used when a caller does not supply a limit.
const DefaultPageSize = 50

// MaxPageSize caps a caller-supplied limit.
const MaxPageSize = 200

// ErrInvalidCursor is returned when a page cursor cannot be decoded.
var ErrInvalidCursor = errors.New("invalid page cursor")

// PageKey is the last row of a page: rows run newest first by
// (created_at, id), and the key carries both so ties stay stable.
type PageKey struct {
	CreatedAt time.Time
	ID        string
}

// Page bounds a list query. A nil After starts from the newest row.
type Page struct {
	Limit int
	After *PageKey
}

// NormalisedLimit clamps the requested limit into [1, MaxPageSize].
func (p Page) NormalisedLimit() int {
	switch {
	case p.Limit <= 0:
		return DefaultPageSize
	case p.Limit > MaxPageSize:
		return MaxPageSize
	default:
		return p.Limit
	}
}

// EncodePageKey serialises a key into an opaque cursor; nil gives "".
func EncodePageKey(k *PageKey) string {
	if k == nil {
		return ""
	}
	raw := k.CreatedAt.UTC().Format(time.RFC3339Nano) + "|" + k.ID
	return base64.RawURLEncoding.EncodeToString([]byte(raw))
}

// DecodePageKey parses a cursor from EncodePageKey; "" is the first page.
func DecodePageKey(cursor string) (*PageKey, error) {
	if cursor == "" {
		return nil, nil //nolint:nilnil // empty cursor means "first page"
	}
	raw, err := base64.RawURLEncoding.DecodeString(cursor)
	if err != nil {
		return nil, fmt.Errorf("%w: %w", ErrInvalidCursor, err)
	}
	created, id, ok := strings.Cut(string(raw), "|")
	if !ok || id == "" {
		return nil, ErrInvalidCursor
	}
	ts, err := time.Parse(time.RFC3339Nano, created)
	if err != nil {
		return nil, fmt.Errorf("%w: %w", ErrInvalidCursor, err)
	}
	return &PageKey{CreatedAt: ts, ID: id}, nil
}

// applyKeyset orders newest first and starts after the page key. It fetches
// one row more than the page so trimPage can tell whether another follows.
func applyKeyset(query *gorm.DB, page Page) *gorm.DB {
	query = query.Order("created_at DESC, id DESC").Limit(page.NormalisedLimit() + 1)
	if page.After != nil {
		query = query.Where("(created_at < ? OR (created_at = ? AND id < ?))",
			page.After.CreatedAt, page.After.CreatedAt, page.After.ID)
	}
	return query
}

// findPage runs query as one keyset page.
func findPage[T any](query *gorm.DB, page Page, base func(T) *data.BaseModel) ([]T, *PageKey, error) {
	var rows []T
	if err := applyKeyset(query, page).Find(&rows).Error; err != nil {
		return nil, nil, err
	}
	out, next := trimPage(rows, page, base)
	return out, next, nil
}

// trimPage drops the look-ahead row and returns the key of the page's last
// row when another page follows.
func trimPage[T any](items []T, page Page, base func(T) *data.BaseModel) ([]T, *PageKey) {
	limit := page.NormalisedLimit()
	if len(items) <= limit {
		return items, nil
	}
	items = items[:limit]
	last := base(items[limit-1])
	return items, &PageKey{CreatedAt: last.CreatedAt, ID: last.ID}
}
