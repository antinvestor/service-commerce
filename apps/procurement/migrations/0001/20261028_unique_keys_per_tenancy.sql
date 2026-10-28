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

-- Purchase order numbers and idempotency keys are unique within the tenant
-- and partition row-level security scopes every lookup to, not across every
-- tenant. A global index let one tenant's key block another's create.
DROP INDEX IF EXISTS idx_purchase_orders_order_number;
DROP INDEX IF EXISTS idx_purchase_orders_idempotency_key;
DROP INDEX IF EXISTS idx_goods_receipts_idempotency_key;
CREATE UNIQUE INDEX IF NOT EXISTS idx_purchase_orders_tenancy_order_number
    ON purchase_orders (tenant_id, partition_id, order_number);
CREATE UNIQUE INDEX IF NOT EXISTS idx_purchase_orders_tenancy_idempotency_key
    ON purchase_orders (tenant_id, partition_id, idempotency_key);
CREATE UNIQUE INDEX IF NOT EXISTS idx_goods_receipts_tenancy_idempotency_key
    ON goods_receipts (tenant_id, partition_id, idempotency_key);
