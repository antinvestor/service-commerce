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
	"fmt"

	manufacturingv1 "buf.build/gen/go/antinvestor/manufacturing/protocolbuffers/go/v1"
	"connectrpc.com/connect"
)

// ManufacturingClient is the slice of the manufacturing API suggestions use.
type ManufacturingClient interface {
	GetProductionPlan(
		context.Context,
		*connect.Request[manufacturingv1.GetProductionPlanRequest],
	) (*connect.Response[manufacturingv1.GetProductionPlanResponse], error)
	GetPlanMaterialRequirements(
		context.Context,
		*connect.Request[manufacturingv1.GetPlanMaterialRequirementsRequest],
	) (*connect.Response[manufacturingv1.GetPlanMaterialRequirementsResponse], error)
}

// NewManufacturingMaterialSource reads plan shortages from manufacturing. A
// nil client yields a nil source (suggestions unavailable).
func NewManufacturingMaterialSource(cli ManufacturingClient) MaterialSource {
	if cli == nil {
		return nil
	}
	return &manufacturingMaterialSource{cli: cli}
}

type manufacturingMaterialSource struct {
	cli ManufacturingClient
}

func (m *manufacturingMaterialSource) PlanShortages(
	ctx context.Context,
	propertyID, planID string,
) ([]Shortage, error) {
	plan, err := m.cli.GetProductionPlan(ctx, connect.NewRequest(
		manufacturingv1.GetProductionPlanRequest_builder{Id: planID}.Build(),
	))
	if err != nil {
		return nil, fmt.Errorf("get production plan: %w", err)
	}
	if plan.Msg.GetProductionPlan().GetPropertyId() != propertyID {
		return nil, ErrPlanNotInProperty
	}
	resp, err := m.cli.GetPlanMaterialRequirements(ctx, connect.NewRequest(
		manufacturingv1.GetPlanMaterialRequirementsRequest_builder{PlanId: planID}.Build(),
	))
	if err != nil {
		return nil, fmt.Errorf("get plan material requirements: %w", err)
	}
	shortages := make([]Shortage, 0, len(resp.Msg.GetRequirements()))
	for _, r := range resp.Msg.GetRequirements() {
		if r.GetShortageQuantity() <= 0 {
			continue
		}
		shortages = append(shortages, Shortage{
			InventoryItemID: r.GetInventoryItemId(),
			ItemName:        r.GetItemName(),
			Quantity:        r.GetShortageQuantity(),
			Unit:            r.GetUnit(),
		})
	}
	return shortages, nil
}
