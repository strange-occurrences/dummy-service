# Quickstart: Webhook Version Manager

## Prerequisites

- Linux x86_64
- `curl`, `sha256sum`, `jq`
- `make`
- Docker & Docker Compose (optional, for containerized deployment)

## Quick Start

```bash
# 1. Install or update the webhook binary
make update

# 2. Start the webhook service
make start

# 3. Verify it's running
make status    # → HTTP 200 {"status":"ok"}
make date      # → HTTP 200 2026-06-24T12:00:00+00:00

# 4. Stop the service
make stop
```

## Docker

```bash
# Build and start via Docker Compose
make docker-up

# Verify endpoints
curl http://localhost:9000/status
curl http://localhost:9000/date

# Stop and clean up
make docker-down
```

## Systemd (Production)

See `docs/systemd.md` and the example unit file in `systemd/webhook.service`.

## Adding Hooks

See `docs/hooks.md` for the hook configuration guide.
