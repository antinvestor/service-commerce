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


-- Quantities are exact decimals: ten receipts of 0.1 must make exactly 1.
-- Existing double precision values are rounded to the six places kept.
ALTER TABLE supplier_items
    ALTER COLUMN min_order_quantity TYPE numeric(20,6) USING round(min_order_quantity::numeric, 6);
ALTER TABLE purchase_order_lines
    ALTER COLUMN ordered_quantity TYPE numeric(20,6) USING round(ordered_quantity::numeric, 6),
    ALTER COLUMN received_quantity TYPE numeric(20,6) USING round(received_quantity::numeric, 6);
ALTER TABLE goods_receipt_lines
    ALTER COLUMN received_quantity TYPE numeric(20,6) USING round(received_quantity::numeric, 6),
    ALTER COLUMN accepted_quantity TYPE numeric(20,6) USING round(accepted_quantity::numeric, 6),
    ALTER COLUMN rejected_quantity TYPE numeric(20,6) USING round(rejected_quantity::numeric, 6);

-- Everything recorded before supply kinds existed was a manufacturing
-- inventory item (SUPPLY_KIND_MATERIAL).
UPDATE supplier_items SET supply_kind = 1 WHERE supply_kind IS NULL OR supply_kind = 0;
UPDATE purchase_order_lines SET supply_kind = 1 WHERE supply_kind IS NULL OR supply_kind = 0;
UPDATE goods_receipt_lines SET supply_kind = 1 WHERE supply_kind IS NULL OR supply_kind = 0;

-- Earlier receipts never reached manufacturing inventory: mark them for
-- transfer (STOCK_DELIVERY_STATUS_PENDING_TRANSFER) rather than leave them
-- looking delivered.
UPDATE goods_receipt_lines SET delivery_status = 3 WHERE delivery_status IS NULL OR delivery_status = 0;

-- The delivery sweep reads pending lines least-tried and oldest first; with
-- nothing pending it is one index probe.
CREATE INDEX IF NOT EXISTS idx_goods_receipt_lines_pending_delivery
    ON goods_receipt_lines (delivery_attempts, created_at, id)
    WHERE delivery_status = 1;

-- Search pages run newest first within a property.
CREATE INDEX IF NOT EXISTS idx_purchase_orders_property_created
    ON purchase_orders (property_id, created_at DESC, id DESC);
CREATE INDEX IF NOT EXISTS idx_goods_receipts_property_created
    ON goods_receipts (property_id, created_at DESC, id DESC);
