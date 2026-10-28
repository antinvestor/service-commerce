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

package dbmigrate_test

import (
	"testing"

	"github.com/pitabwire/frame/v3"
	"github.com/pitabwire/frame/v3/datastore/pool"
	"github.com/stretchr/testify/require"

	"github.com/antinvestor/service-commerce/pkg/dbmigrate"
)

// A service whose database is unconfigured or unreachable is refused before
// anything is built on its empty pool, in setup and at runtime alike.
func TestReadyRefusesAServiceWithoutADatabase(t *testing.T) {
	t.Run("no DATABASE_URL", func(t *testing.T) {
		ctx, svc := frame.NewServiceWithContext(t.Context(), frame.WithName("ready-none"), frame.WithDatastore())
		t.Cleanup(func() { svc.Stop(ctx) })
		require.ErrorIs(t, dbmigrate.Ready(ctx, svc), dbmigrate.ErrPoolNotInitialised)
		_, err := dbmigrate.Pool(ctx, svc.DatastoreManager())
		require.ErrorIs(t, err, dbmigrate.ErrPoolNotInitialised)
	})

	t.Run("unreachable database", func(t *testing.T) {
		ctx, svc := frame.NewServiceWithContext(
			t.Context(),
			frame.WithName("ready-down"),
			frame.WithDatastore(
				pool.WithConnection("postgres://ant:secret@127.0.0.1:1/commerce?connect_timeout=1", false),
			),
		)
		t.Cleanup(func() { svc.Stop(ctx) })
		require.Error(t, dbmigrate.Ready(ctx, svc))
		_, err := dbmigrate.Pool(ctx, svc.DatastoreManager())
		require.ErrorIs(t, err, dbmigrate.ErrPoolNotInitialised)
	})
}
