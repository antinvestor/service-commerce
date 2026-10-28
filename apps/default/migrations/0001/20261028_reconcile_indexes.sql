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

-- The reconcile run first asks whether there is anything to do. These keep
-- that question, and the lists that follow it, on the few orders still open
-- for payment rather than every order ever placed.

-- Unpaid (status 4) and part-paid (payment status 6) orders, oldest look
-- first.
CREATE INDEX IF NOT EXISTS idx_orders_open_for_payment
    ON orders (COALESCE(next_reconcile_at, created_at))
    WHERE deleted_at IS NULL AND payment_review = '' AND (status = 4 OR payment_status = 6);

-- Cancelled orders still watched for a late payment.
CREATE INDEX IF NOT EXISTS idx_orders_cancelled_at
    ON orders (cancelled_at)
    WHERE deleted_at IS NULL AND status = 2;

-- Refunds not yet confirmed or failed.
CREATE INDEX IF NOT EXISTS idx_order_refunds_open
    ON order_refunds (modified_at)
    WHERE deleted_at IS NULL AND status IN (1, 2);
