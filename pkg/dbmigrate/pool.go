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

// Package dbmigrate finds the database pool a setup step or a starting
// service works on, and refuses one it cannot use.
package dbmigrate

import (
	"context"
	"errors"
	"fmt"

	"github.com/pitabwire/frame/v3"
	"github.com/pitabwire/frame/v3/datastore"
	"github.com/pitabwire/frame/v3/datastore/pool"
)

// ErrPoolNotInitialised is returned when no usable datastore pool exists:
// DATABASE_URL is unset, or the connection failed when the service started.
var ErrPoolNotInitialised = errors.New("datastore pool is not initialised")

// Pool prefers Frame's migration pool (opened in setup mode) and falls back
// to the default pool, matching Frame's setup-job contract.
func Pool(ctx context.Context, dbManager datastore.Manager) (pool.Pool, error) {
	if dbManager == nil {
		return nil, ErrPoolNotInitialised
	}
	if p := usable(ctx, dbManager.GetPool(ctx, datastore.DefaultMigrationPoolName)); p != nil {
		return p, nil
	}
	if p := usable(ctx, dbManager.GetPool(ctx, datastore.DefaultPoolName)); p != nil {
		return p, nil
	}
	return nil, ErrPoolNotInitialised
}

// Ready reports why svc cannot serve from its database: the first error
// recorded while it started (a failed connection among them), or a default
// pool with no primary connection. Frame keeps an empty pool when a
// connection fails, so repositories built on it would dereference nil.
func Ready(ctx context.Context, svc *frame.Service) error {
	if errs := svc.GetStartupErrors(); len(errs) > 0 {
		return fmt.Errorf("service start-up failed: %w", errors.Join(errs...))
	}
	if svc.DatastoreManager() == nil ||
		usable(ctx, svc.DatastoreManager().GetPool(ctx, datastore.DefaultPoolName)) == nil {
		return ErrPoolNotInitialised
	}
	return nil
}

// usable returns p when it holds a primary connection, else nil.
func usable(ctx context.Context, p pool.Pool) pool.Pool {
	if p == nil || p.DB(ctx, false) == nil {
		return nil
	}
	return p
}
