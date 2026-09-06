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

	"github.com/pitabwire/frame/v2/data"
	"gorm.io/gorm"
)

// DefaultPageSize is used when a caller does not supply a limit.
const DefaultPageSize = 50

// MaxPageSize caps a caller-supplied limit.
const MaxPageSize = 500

// ErrInvalidCursor is returned when a page cursor cannot be decoded.
var ErrInvalidCursor = errors.New("invalid page cursor")

// PageKey identifies the last row of a page for keyset pagination. Rows are
// ordered by (created_at DESC, id DESC); the key carries both so ties on
// created_at are stable.
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

// EncodePageKey serialises a key into an opaque cursor string.
func EncodePageKey(k *PageKey) string {
	if k == nil {
		return ""
	}
	raw := k.CreatedAt.UTC().Format(time.RFC3339Nano) + "|" + k.ID
	return base64.RawURLEncoding.EncodeToString([]byte(raw))
}

// DecodePageKey parses a cursor produced by EncodePageKey. An empty cursor
// yields a nil key.
func DecodePageKey(cursor string) (*PageKey, error) {
	if cursor == "" {
		return nil, nil //nolint:nilnil // empty cursor means "first page"
	}
	raw, err := base64.RawURLEncoding.DecodeString(cursor)
	if err != nil {
		return nil, fmt.Errorf("%w: %w", ErrInvalidCursor, err)
	}
	const cursorParts = 2 // "created_at|id"
	parts := strings.SplitN(string(raw), "|", cursorParts)
	if len(parts) != cursorParts || parts[1] == "" {
		return nil, ErrInvalidCursor
	}
	ts, err := time.Parse(time.RFC3339Nano, parts[0])
	if err != nil {
		return nil, fmt.Errorf("%w: %w", ErrInvalidCursor, err)
	}
	return &PageKey{CreatedAt: ts, ID: parts[1]}, nil
}

// applyKeyset orders the query newest-first and, when a key is present,
// restricts it to rows strictly after that key. Callers should request
// limit+1 rows and use trimPage to detect whether a next page exists.
func applyKeyset(query *gorm.DB, page Page) *gorm.DB {
	query = query.Order("created_at DESC, id DESC").Limit(page.NormalisedLimit() + 1)
	if page.After != nil {
		query = query.Where("(created_at, id) < (?, ?)", page.After.CreatedAt, page.After.ID)
	}
	return query
}

// trimPage drops the sentinel row fetched by applyKeyset and returns the key of
// the last row on the page when more rows exist.
func trimPage[T data.BaseModelI](items []T, page Page, keyOf func(T) PageKey) ([]T, *PageKey) {
	limit := page.NormalisedLimit()
	if len(items) <= limit {
		return items, nil
	}
	items = items[:limit]
	key := keyOf(items[limit-1])
	return items, &key
}

// baseKey builds a PageKey from an embedded BaseModel.
func baseKey(m data.BaseModel) PageKey {
	return PageKey{CreatedAt: m.CreatedAt, ID: m.ID}
}
