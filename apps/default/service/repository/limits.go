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
	"fmt"
	"strings"
	"time"

	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/pitabwire/util"
)

// limitSweep is how many finished windows one hit clears away, so the
// table stays small without a scheduled job.
const limitSweep = 50

// LimitRepository counts attempts per key in fixed windows, shared by every
// instance through the database. Its table (storefront_limits, created by
// migration) has no tenant columns: a visitor's address is counted across
// every shop.
type LimitRepository interface {
	// Hit counts one attempt against each key in the window starting at
	// windowStart and returns every key's count in it, this one included.
	// Windows that started before expiredBefore are cleared as it goes.
	Hit(ctx context.Context, keys []string, windowStart, expiredBefore time.Time) (map[string]int64, error)
}

type limitRepository struct {
	pool pool.Pool
}

// NewLimitRepository counts attempts in dbPool.
func NewLimitRepository(dbPool pool.Pool) LimitRepository {
	return &limitRepository{pool: dbPool}
}

func (r *limitRepository) Hit(
	ctx context.Context,
	keys []string,
	windowStart, expiredBefore time.Time,
) (map[string]int64, error) {
	unique := make([]string, 0, len(keys))
	seen := make(map[string]bool, len(keys))
	for _, k := range keys {
		if k != "" && !seen[k] {
			seen[k] = true
			unique = append(unique, k)
		}
	}
	counts := make(map[string]int64, len(unique))
	if len(unique) == 0 {
		return counts, nil
	}

	values := make([]string, 0, len(unique))
	args := make([]any, 0, 2*len(unique)) //nolint:mnd // two placeholders per key
	for _, k := range unique {
		values = append(values, "(?, ?, 1)")
		args = append(args, k, windowStart)
	}
	var rows []struct {
		LimitKey string
		Hits     int64
	}
	db := r.pool.DB(ctx, false)
	err := db.Raw(`INSERT INTO storefront_limits (limit_key, window_start, hits) VALUES `+
		strings.Join(values, ", ")+`
		ON CONFLICT (limit_key, window_start) DO UPDATE SET hits = storefront_limits.hits + 1
		RETURNING limit_key, hits`, args...).Scan(&rows).Error
	if err != nil {
		return nil, fmt.Errorf("count attempts: %w", err)
	}
	for _, row := range rows {
		counts[row.LimitKey] = row.Hits
	}

	if sweepErr := db.Exec(`DELETE FROM storefront_limits WHERE ctid IN (
		SELECT ctid FROM storefront_limits WHERE window_start < ? LIMIT ?)`,
		expiredBefore, limitSweep).Error; sweepErr != nil {
		util.Log(ctx).WithError(sweepErr).Warn("could not clear finished attempt windows")
	}
	return counts, nil
}
