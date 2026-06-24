# shellcheck shell=bash
SHELL := /bin/bash
WEBHOOK_PORT ?= 9000
WEBHOOK_BIN := bin/webhook
HOOKS_DIR := hooks

.PHONY: update start stop status date docker-up docker-down check-deps

check-deps:
	@command -v curl >/dev/null 2>&1 || { echo "ERROR: curl is required but not installed"; exit 1; }
	@command -v sha256sum >/dev/null 2>&1 || { echo "ERROR: sha256sum is required but not installed"; exit 1; }
	@command -v jq >/dev/null 2>&1 || { echo "ERROR: jq is required but not installed"; exit 1; }

update: check-deps
	@scripts/update-webhook.sh

start:
	@if [ ! -f "$(WEBHOOK_BIN)" ]; then echo "ERROR: $(WEBHOOK_BIN) not found. Run 'make update' first"; exit 2; fi
	@if lsof -i :$(WEBHOOK_PORT) >/dev/null 2>&1; then echo "ERROR: Port $(WEBHOOK_PORT) is already in use"; exit 1; fi
	@nohup "$(WEBHOOK_BIN)" -hooks "$(HOOKS_DIR)" -port "$(WEBHOOK_PORT)" > .cache/webhook.log 2>&1 &
	@echo "webhook started on port $(WEBHOOK_PORT) (PID: $$!)"

stop:
	@pkill -f "$(WEBHOOK_BIN) -hooks $(HOOKS_DIR)" 2>/dev/null && echo "webhook stopped" || echo "No running webhook found"

status:
	@status=$$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$(WEBHOOK_PORT)/status 2>/dev/null); \
	if [ "$$status" = "200" ]; then \
		echo "HTTP 200 OK"; \
		curl -s http://localhost:$(WEBHOOK_PORT)/status; \
	else \
		echo "ERROR: /status returned HTTP $$status (expected 200)"; \
		exit 1; \
	fi

date:
	@response=$$(curl -s http://localhost:$(WEBHOOK_PORT)/date 2>/dev/null); \
	if [ -n "$$response" ]; then \
		echo "$$response"; \
	else \
		echo "ERROR: /date returned empty response"; \
		exit 1; \
	fi

docker-up:
	@docker compose up --build -d

docker-down:
	@docker compose down
