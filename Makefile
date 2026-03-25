# Service-specific configuration
SERVICE_NAME := commerce
APP_DIRS     := apps/default

# Bootstrap: download shared Makefile.common if missing
ifeq (,$(wildcard .tmp/Makefile.common))
  $(shell mkdir -p .tmp && curl -sSfL https://raw.githubusercontent.com/antinvestor/common/main/Makefile.common -o .tmp/Makefile.common)
endif

include .tmp/Makefile.common
