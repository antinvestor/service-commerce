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

package config

import (
	"github.com/pitabwire/frame/v3/config"
)

type ProcurementConfig struct {
	config.ConfigurationDefault

	// ManufacturingServiceURI is where production plan shortages are read
	// for purchase order suggestions. Empty disables suggestions.
	ManufacturingServiceURI                   string `env:"MANUFACTURING_SERVICE_URI"                      envDefault:""`
	ManufacturingServiceWorkloadAPITargetPath string `env:"MANUFACTURING_SERVICE_WORKLOAD_API_TARGET_PATH" envDefault:"/ns/manufacturing/sa/service-manufacturing"`

	// CommerceServiceURI is where received resale stock is pushed (product
	// variants). Empty leaves those receipt lines pending.
	CommerceServiceURI                   string `env:"COMMERCE_SERVICE_URI"                      envDefault:""`
	CommerceServiceWorkloadAPITargetPath string `env:"COMMERCE_SERVICE_WORKLOAD_API_TARGET_PATH" envDefault:"/ns/commerce/sa/service-commerce"`

	// Trustage runs the scheduled stock delivery retry; the setup job
	// registers the workflow, which calls back into ProcurementServiceURI.
	TrustageServiceURI                   string `env:"TRUSTAGE_SERVICE_URI"                      envDefault:""`
	TrustageServiceWorkloadAPITargetPath string `env:"TRUSTAGE_SERVICE_WORKLOAD_API_TARGET_PATH" envDefault:"/ns/trustage/sa/service-trustage"`
	ProcurementServiceURI                string `env:"PROCUREMENT_SERVICE_URI"                   envDefault:""`
}
