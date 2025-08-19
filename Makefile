.PHONY: all shellcheck shellcheck-fix help validate-yaml validate-docker security-check

# Default target
.DEFAULT_GOAL := help

# Shell scripts to check
SHELL_SCRIPTS := $(shell find . -type f -name "*.sh")

# YAML files to check
YAML_FILES := $(shell find . -type f \( -name "*.yml" -o -name "*.yaml" \))

all: shellcheck validate-yaml validate-docker security-check ## Run all validation checks

help: ## Show this help message
	@echo 'Traefik Deployment Tools'
	@echo '======================'
	@echo ''
	@echo 'Available commands:'
	@echo ''
	@awk '/^[a-zA-Z\-_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "  %-20s %s\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)
	@echo ''
	@echo 'Examples:'
	@echo '  make all            # Run all validation checks'
	@echo '  make shellcheck     # Run ShellCheck on all shell scripts'
	@echo '  make shellcheck-fix # Show suggested fixes for shell scripts'
	@echo '  make validate-yaml  # Validate all YAML files'
	@echo '  make validate-docker # Validate Docker Compose configuration'
	@echo '  make security-check # Run security checks for secrets'
	@echo '  make help          # Show this help message'
	@echo ''
	@echo 'Dependencies:'
	@echo '  - shellcheck: brew install shellcheck'
	@echo '  - yamllint: brew install yamllint'
	@echo '  - docker-compose: brew install docker-compose'
	@echo '  - gitleaks: brew install gitleaks'

shellcheck: ## Run ShellCheck on all shell scripts
	@echo "Running ShellCheck on shell scripts..."
	@if command -v shellcheck >/dev/null 2>&1; then \
		if shellcheck $(SHELL_SCRIPTS); then \
			echo "✓ ShellCheck passed successfully - no issues found"; \
		else \
			TIMESTAMP=$$(TZ='America/Los_Angeles' date '+%Y-%m-%d %I:%M:%S %p %Z') && \
			if [ -n "$${NTFY_API_KEY}" ]; then \
				curl -H "Title: Traefik ShellCheck Failed" \
				     -H "Authorization: Bearer $${NTFY_API_KEY}" \
				     -d "ShellCheck found issues in shell scripts at $${TIMESTAMP}" \
				     https://ntfy.sntxrr.dev/traefik-deploy; \
			fi; \
			exit 1; \
		fi \
	else \
		echo "Error: shellcheck is not installed. Please install it first."; \
		echo "On macOS: brew install shellcheck"; \
		echo "On Ubuntu/Debian: sudo apt-get install shellcheck"; \
		exit 1; \
	fi

shellcheck-fix: ## Run ShellCheck with --format=diff to show suggested fixes
	@echo "Running ShellCheck with diff format..."
	@if command -v shellcheck >/dev/null 2>&1; then \
		shellcheck --format=diff $(SHELL_SCRIPTS); \
	else \
		echo "Error: shellcheck is not installed. Please install it first."; \
		echo "On macOS: brew install shellcheck"; \
		echo "On Ubuntu/Debian: sudo apt-get install shellcheck"; \
		exit 1; \
	fi

validate-yaml: ## Validate all YAML files
	@echo "Validating YAML files..."
	@if command -v yamllint >/dev/null 2>&1; then \
		if yamllint $(YAML_FILES); then \
			echo "✓ YAML validation passed successfully"; \
		else \
			TIMESTAMP=$$(TZ='America/Los_Angeles' date '+%Y-%m-%d %I:%M:%S %p %Z') && \
			if [ -n "$${NTFY_API_KEY}" ]; then \
				curl -H "Title: Traefik YAML Validation Failed" \
				     -H "Authorization: Bearer $${NTFY_API_KEY}" \
				     -d "YAML validation found issues at $${TIMESTAMP}" \
				     https://ntfy.sntxrr.dev/traefik-deploy; \
			fi; \
			exit 1; \
		fi \
	else \
		echo "Error: yamllint is not installed. Please install it first."; \
		echo "On macOS: brew install yamllint"; \
		echo "On Ubuntu/Debian: sudo apt-get install yamllint"; \
		exit 1; \
	fi

validate-docker: ## Validate Docker Compose configuration
	@echo "Validating Docker Compose configuration..."
	@if command -v docker-compose >/dev/null 2>&1; then \
		TEMP_DIR="$$(mktemp -d)" && \
		echo "Creating temporary directory at $${TEMP_DIR}" && \
		echo "TRAEFIK_DASHBOARD_CREDENTIALS=dummy:password" > "$${TEMP_DIR}/.env" && \
		echo "TRAEFIK_DASHBOARD_USER=dummy" >> "$${TEMP_DIR}/.env" && \
		echo "TRAEFIK_DASHBOARD_PASSWORD=password" >> "$${TEMP_DIR}/.env" && \
		echo "Using environment file: $${TEMP_DIR}/.env" && \
		cp docker-compose.yaml "$${TEMP_DIR}/" && \
		cp -r data "$${TEMP_DIR}/" && \
		if cd "$${TEMP_DIR}" && docker-compose --env-file .env config; then \
			cd - > /dev/null && rm -rf "$${TEMP_DIR}" && \
			echo "✓ Docker Compose validation passed successfully"; \
		else \
			cd - > /dev/null && rm -rf "$${TEMP_DIR}" && \
			TIMESTAMP=$$(TZ='America/Los_Angeles' date '+%Y-%m-%d %I:%M:%S %p %Z') && \
			if [ -n "$${NTFY_API_KEY}" ]; then \
				curl -H "Title: Traefik Docker Compose Validation Failed" \
				     -H "Authorization: Bearer $${NTFY_API_KEY}" \
				     -d "Docker Compose validation found issues at $${TIMESTAMP}" \
				     https://ntfy.sh/traefik-deploy; \
			fi; \
			exit 1; \
		fi \
	else \
		echo "Error: docker-compose is not installed. Please install it first."; \
		echo "On macOS: brew install docker-compose"; \
		echo "On Ubuntu/Debian: sudo apt-get install docker-compose"; \
		exit 1; \
	fi

security-check: ## Run security checks on configuration files
	@echo "Running security checks..."
	@if command -v gitleaks >/dev/null 2>&1; then \
		if gitleaks detect; then \
			echo "✓ Security check passed successfully - no secrets found"; \
		else \
			TIMESTAMP=$$(TZ='America/Los_Angeles' date '+%Y-%m-%d %I:%M:%S %p %Z') && \
			if [ -n "$${NTFY_API_KEY}" ]; then \
				curl -H "Title: Traefik Security Check Failed" \
				     -H "Authorization: Bearer $${NTFY_API_KEY}" \
				     -d "Security check found potential secrets at $${TIMESTAMP}" \
				     https://ntfy.sh/traefik-deploy; \
			fi; \
			exit 1; \
		fi \
	else \
		echo "Error: gitleaks is not installed. Please install it first."; \
		echo "On macOS: brew install gitleaks"; \
		echo "On Ubuntu/Debian: curl -sSfL https://raw.githubusercontent.com/gitleaks/gitleaks/master/install.sh | sh"; \
		exit 1; \
	fi 