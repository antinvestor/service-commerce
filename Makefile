# Service-specific configuration
SERVICE_NAME := commerce
APP_DIRS     := apps/default

# Bootstrap: download shared Makefile.common if missing
ifeq (,$(wildcard .tmp/Makefile.common))
  $(shell mkdir -p .tmp && curl -sSfL https://raw.githubusercontent.com/antinvestor/common/main/Makefile.common -o .tmp/Makefile.common)
endif

include .tmp/Makefile.common

# Dart proto modules — each gets its own buf.gen.dart.<module>.yaml.
DART_MODULES := commerce property

.PHONY: proto-generate-dart
proto-generate-dart: $(BIN)/buf ## Regenerate the per-module dart SDKs
	@if [ ! -d "$(PROTO_DIR)" ]; then exit 0; fi
	@for m in $(DART_MODULES); do rm -rf sdk/dart/$$m/lib/src/v1; done
	@for m in $(DART_MODULES); do \
		echo "==> dart $$m"; \
		(cd $(PROTO_DIR) && buf generate --template buf.gen.dart.$$m.yaml $$m); \
	done

proto-generate: proto-generate-dart

.PHONY: proto-generate-go
proto-generate-go: $(BIN)/buf ## Regenerate the local Go code for the commerce API (gen/go/commerce)
	@cd $(PROTO_DIR) && buf generate --template buf.gen.local-go.yaml commerce

# ── Local stack (tools/devstack) ────────────────────────────────────────────
DEV_DIR     := .tmp/devstack
DEV_COMPOSE := docker compose -f tools/devstack/compose.yaml
DEV_ENV     := set -a; . tools/devstack/commerce.env; set +a;

$(DEV_DIR)/namespaces.ts: opl/commerce/service_commerce.opl.ts opl/commerce/commerce_resources.opl.ts
	@mkdir -p $(DEV_DIR)
	@cat opl/commerce/service_commerce.opl.ts > $@
	@sed -n '/^class commerce_shop/,$$p' opl/commerce/commerce_resources.opl.ts >> $@

.PHONY: dev-deps
dev-deps: $(DEV_DIR)/namespaces.ts ## Start local Postgres and Keto
	$(DEV_COMPOSE) up -d --wait postgres keto

.PHONY: dev-migrate
dev-migrate: ## Migrate the local commerce database
	$(DEV_ENV) FRAME_SETUP_TASKS=migrate DO_SETUP=true go run ./apps/default/cmd

.PHONY: dev-stack
dev-stack: ## Run devstack on :8090 (sign-in, checkout simulator, profiles, /commerce gateway) and the built console on :5173
	DEVSTACK_CONSOLE_DIR=$(if $(wildcard $(DEV_DIR)/console/index.html),$(DEV_DIR)/console,) go run ./tools/devstack

.PHONY: dev-console
dev-console: ## Build the console for the local stack (served by dev-stack on :5173)
	tools/devstack/console.sh

.PHONY: dev-commerce
dev-commerce: ## Run commerce against the local stack on :8081
	$(DEV_ENV) go run ./apps/default/cmd

.PHONY: dev-seed
dev-seed: ## Create a demo shop with products in the local stack
	go run ./tools/devstack seed

.PHONY: dev-down
dev-down: ## Stop local Postgres and Keto (data kept; add -v to the compose call to wipe)
	$(DEV_COMPOSE) down
