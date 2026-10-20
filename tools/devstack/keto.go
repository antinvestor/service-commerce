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

package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"

	"github.com/antinvestor/service-commerce/apps/default/service/authz"
)

const ketoTimeout = 5 * time.Second

// ketoProvisioner grants a signed-in person what identity grants staff in a
// real deployment: membership of the dev partition and the owner role on it.
type ketoProvisioner struct {
	writeURL    string
	tenancyPath string
	client      *http.Client
}

type ketoTuple struct {
	Namespace string `json:"namespace"`
	Object    string `json:"object"`
	Relation  string `json:"relation"`
	SubjectID string `json:"subject_id"`
}

func (k *ketoProvisioner) provision(who identity) error {
	for _, t := range []ketoTuple{
		{Namespace: authz.NamespaceTenancyAccess, Object: k.tenancyPath, Relation: authz.RoleMember},
		{Namespace: authz.NamespaceCommerce, Object: k.tenancyPath, Relation: authz.RoleOwner},
	} {
		t.SubjectID = who.ProfileID
		if err := k.write(t); err != nil {
			return err
		}
	}
	return nil
}

func (k *ketoProvisioner) write(t ketoTuple) error {
	body, err := json.Marshal(t)
	if err != nil {
		return err
	}
	ctx, cancel := context.WithTimeout(context.Background(), ketoTimeout)
	defer cancel()
	req, err := http.NewRequestWithContext(ctx, http.MethodPut,
		k.writeURL+"/admin/relation-tuples", bytes.NewReader(body))
	if err != nil {
		return err
	}
	req.Header.Set("Content-Type", "application/json")
	resp, err := k.client.Do(req)
	if err != nil {
		return fmt.Errorf("keto: %w", err)
	}
	defer resp.Body.Close()
	if resp.StatusCode >= http.StatusBadRequest {
		msg, _ := io.ReadAll(io.LimitReader(resp.Body, 1<<10)) //nolint:mnd // 1 KiB of error text
		return fmt.Errorf("keto %s %s#%s: %s: %s", t.Namespace, t.Object, t.Relation, resp.Status, msg)
	}
	return nil
}
