--- Copyright 2023-2026 Ant Investor Ltd
---
--- Licensed under the Apache License, Version 2.0 (the "License");
--- you may not use this file except in compliance with the License.
--- You may obtain a copy of the License at
---
---      http://www.apache.org/licenses/LICENSE-2.0
---
--- Unless required by applicable law or agreed to in writing, software
--- distributed under the License is distributed on an "AS IS" BASIS,
--- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--- See the License for the specific language governing permissions and
--- limitations under the License.


-- A stock receipt reference (one procurement goods receipt line) raises a
-- variant's stock once: a repeated delivery finds it and adds nothing.
CREATE UNIQUE INDEX IF NOT EXISTS idx_stock_receipts_tenancy_reference
    ON stock_receipts (tenant_id, partition_id, reference);
