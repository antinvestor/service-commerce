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

-- Storefront checkouts are counted per visitor address, contact and shop in
-- fixed windows, here rather than in each instance's memory, so every
-- instance enforces the same limit. The table carries no tenant: a visitor
-- is counted across every shop. Rows are cleared as new ones arrive.
CREATE TABLE IF NOT EXISTS storefront_limits (
    limit_key    varchar(128) NOT NULL,
    window_start timestamptz  NOT NULL,
    hits         integer      NOT NULL DEFAULT 0,
    PRIMARY KEY (limit_key, window_start)
);
CREATE INDEX IF NOT EXISTS idx_storefront_limits_window ON storefront_limits (window_start);

-- Orders placed from a public storefront by someone who did not sign in.
-- Before the column existed they were told apart by their idempotency key.
UPDATE orders SET guest = true WHERE idempotency_key LIKE 'storefront:%' AND NOT guest;

-- The units a shop's unpaid guest orders hold are summed on every guest
-- order; this keeps that to the few such orders open at a time.
CREATE INDEX IF NOT EXISTS idx_orders_guest_unpaid
    ON orders (shop_id)
    WHERE guest AND status = 4 AND amount_paid_nanos = 0 AND deleted_at IS NULL;

-- A fixed discount is an amount of money in the shop's currency, kept as
-- integers rather than the float it was entered as.
UPDATE discount_rules d
SET amount_currency = s.currency,
    amount_units    = trunc(round(d.value::numeric, 2)),
    amount_nanos    = ((round(d.value::numeric, 2) - trunc(round(d.value::numeric, 2))) * 1000000000)::integer
FROM shops s
WHERE d.shop_id = s.id AND d.discount_type = 2 AND COALESCE(d.amount_currency, '') = '' AND d.value >= 0;
