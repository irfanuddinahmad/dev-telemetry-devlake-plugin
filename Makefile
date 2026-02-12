.PHONY: build lint fmt clean install help

# Build configuration
PLUGIN_NAME = developer_telemetry
BUILD_DIR = bin
PLUGINS_DIR = plugins/developer_telemetry
GO = go
GOFLAGS = -v
LDFLAGS = -s -w

# DevLake directory (override with DEVLAKE_DIR environment variable)
DEVLAKE_DIR ?= ../incubator-devlake/backend

all: fmt build

build:
	@echo "⚠️  WARNING: Building from this standalone repository will fail!"
	@echo "The plugin requires DevLake's internal packages that aren't available here."
	@echo ""
	@echo "Options:"
	@echo "  1. Use the pre-built binary from GitHub Releases"
	@echo "  2. Build from within the DevLake monorepo"
	@echo ""
	@echo "To build from DevLake monorepo:"
	@echo "  cd /path/to/devlake/backend"
	@echo "  cp -r $(PWD)/$(PLUGINS_DIR) plugins/"
	@echo "  DEVLAKE_PLUGINS=$(PLUGIN_NAME) scripts/build-plugins.sh"
	@echo ""
	@read -p "Continue anyway? [y/N] " answer; \
	if [ "$$answer" != "y" ] && [ "$$answer" != "Y" ]; then \
		echo "Build cancelled."; \
		exit 1; \
	fi
	@echo "Building Developer Telemetry plugin..."
	@mkdir -p $(BUILD_DIR)
	cd $(PLUGINS_DIR) && $(GO) build $(GOFLAGS) -buildmode=plugin -ldflags="$(LDFLAGS)" -o ../../$(BUILD_DIR)/$(PLUGIN_NAME).so .
	@echo "Build complete: $(BUILD_DIR)/$(PLUGIN_NAME).so"

lint:
	@echo "Running linter..."
	@which golangci-lint > /dev/null || (echo "golangci-lint not installed. Run: brew install golangci-lint" && exit 1)
	golangci-lint run ./...

fmt:
	@echo "Formatting code..."
	$(GO) fmt ./...
	gofmt -s -w .

clean:
	@echo "Cleaning build artifacts..."
	rm -rf $(BUILD_DIR)
	find . -name "*.so" -delete

install: build
	@echo "Installing plugin to DevLake..."
	@if [ ! -d "$(DEVLAKE_DIR)" ]; then \
		echo "Error: DevLake directory not found at $(DEVLAKE_DIR)"; \
		echo "Set DEVLAKE_DIR environment variable to your DevLake backend directory"; \
		exit 1; \
	fi
	mkdir -p $(DEVLAKE_DIR)/bin/plugins/$(PLUGIN_NAME)
	cp $(BUILD_DIR)/$(PLUGIN_NAME).so $(DEVLAKE_DIR)/bin/plugins/$(PLUGIN_NAME)/
	@echo "Plugin installed to $(DEVLAKE_DIR)/bin/plugins/$(PLUGIN_NAME)/"

dev: fmt build install
	@echo "Development build complete!"

verify: fmt lint build
	@echo "All verification checks passed!"

help:
	@echo "Developer Telemetry DevLake Plugin - Makefile targets:"
	@echo "  make build           - Build the plugin (will warn about dependencies)"
	@echo "  make lint            - Run linter"
	@echo "  make fmt             - Format code"
	@echo "  make clean           - Clean build artifacts"
	@echo "  make install         - Install plugin to DevLake"
	@echo "  make dev             - Format, build, and install (development workflow)"
	@echo "  make verify          - Run all checks (fmt, lint, build)"
	@echo "  make help            - Show this help message"
	@echo ""
	@echo "Environment Variables:"
	@echo "  DEVLAKE_DIR          - Path to DevLake backend directory (default: ../incubator-devlake/backend)"
