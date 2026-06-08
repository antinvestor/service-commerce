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

package tests

import (
	"context"
	"testing"

	"github.com/pitabwire/frame"
	"github.com/pitabwire/frame/config"
	"github.com/pitabwire/frame/datastore"
	"github.com/pitabwire/frame/datastore/pool"
	"github.com/pitabwire/frame/frametests"
	"github.com/pitabwire/frame/frametests/definition"
	"github.com/pitabwire/frame/frametests/deps/testpostgres"
	"github.com/pitabwire/frame/security"
	"github.com/pitabwire/util"
	"github.com/stretchr/testify/require"

	aconfig "github.com/antinvestor/service-commerce/apps/procurement/config"
	"github.com/antinvestor/service-commerce/apps/procurement/service/repository"
)

const PostgresqlDBImage = "postgres:latest"

const (
	DefaultRandomStringLength = 8
)

type ProcurementBaseTestSuite struct {
	frametests.FrameBaseTestSuite
}

func initResources(_ context.Context) []definition.TestResource {
	pg := testpostgres.NewWithOpts("service_procurement", definition.WithUserName("ant"))
	return []definition.TestResource{pg}
}

func (bs *ProcurementBaseTestSuite) SetupSuite() {
	bs.InitResourceFunc = initResources
	bs.FrameBaseTestSuite.SetupSuite()
}

func (bs *ProcurementBaseTestSuite) CreateService(
	t *testing.T,
	depOpts *definition.DependencyOption,
) (context.Context, *frame.Service) {
	t.Setenv("OTEL_TRACES_EXPORTER", "none")

	cfg, err := config.FromEnv[aconfig.ProcurementConfig]()
	require.NoError(t, err)

	cfg.LogLevel = "debug"
	cfg.RunServiceSecurely = false
	cfg.ServerPort = ""
	cfg.DatabaseMigrate = true
	cfg.DatabaseTraceQueries = true
	cfg.DatabaseMaxOpenConnections = 2
	cfg.DatabaseMaxIdleConnections = 0

	res := depOpts.ByIsDatabase(t.Context())
	testDS, cleanup, err0 := res.GetRandomisedDS(t.Context(), depOpts.Prefix())
	require.NoError(t, err0)

	t.Cleanup(func() {
		cleanup(t.Context())
	})

	cfg.DatabasePrimaryURL = []string{testDS.String()}
	cfg.DatabaseReplicaURL = []string{}

	ctx, svc := frame.NewServiceWithContext(t.Context(), frame.WithName("procurement tests"),
		frame.WithConfig(&cfg),
		frame.WithDatastore(pool.WithTraceConfig(&cfg)),
		frametests.WithNoopDriver())

	svc.Init(ctx)

	err = repository.Migrate(ctx, svc.DatastoreManager(), "../migrations/0001")
	require.NoError(t, err)
	svc.DatastoreManager().RemovePool(ctx, datastore.DefaultMigrationPoolName)

	err = svc.Run(ctx, "")
	require.NoError(t, err)

	t.Cleanup(func() {
		bgCtx := context.Background()
		svc.Stop(bgCtx)
		svc.DatastoreManager().Close(bgCtx)
	})

	return ctx, svc
}

func (bs *ProcurementBaseTestSuite) TearDownSuite() {
	bs.FrameBaseTestSuite.TearDownSuite()
}

// WithTestDependancies creates subtests with each known DependencyOption.
func (bs *ProcurementBaseTestSuite) WithTestDependancies(
	t *testing.T,
	testFn func(t *testing.T, dep *definition.DependencyOption),
) {
	options := []*definition.DependencyOption{
		definition.NewDependancyOption(
			"default",
			util.RandomAlphaNumericString(DefaultRandomStringLength),
			bs.Resources(),
		),
	}

	frametests.WithTestDependencies(t, options, testFn)
}

// WithAuthClaims adds authentication claims to a context for testing.
func (bs *ProcurementBaseTestSuite) WithAuthClaims(
	ctx context.Context,
	tenantID, partitionID, profileID string,
) context.Context {
	claims := &security.AuthenticationClaims{
		TenantID:    tenantID,
		PartitionID: partitionID,
		AccessID:    util.IDString(),
		ContactID:   profileID,
		SessionID:   util.IDString(),
		DeviceID:    "test-device",
	}
	claims.Subject = profileID
	return claims.ClaimsToContext(ctx)
}
