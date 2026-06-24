# Makefile API Contract

The Makefile provides the primary user-facing interface for all operations.

## Targets

### `make update`
Fetch the latest webhook release from GitHub, verify SHA256 checksum, and
install to `bin/webhook`. Backs up current binary as `bin/webhook.previous`.

**Exit codes**:
- `0`: Binary updated successfully
- `1`: GitHub API unreachable or rate limited (cache available → uses cache)
- `2`: Checksum mismatch — abort, no files modified
- `3`: Missing dependency (curl, sha256sum, jq)

**Output**: Progress messages to stdout. Errors to stderr.

### `make start`
Start the webhook server with hooks from `hooks/` directory on port 9000.

**Exit codes**:
- `0`: Server started successfully (may daemonize)
- `1`: Port 9000 already in use
- `2`: Binary not found — run `make update` first
- `3`: No hook configs found in `hooks/`

### `make stop`
Stop the running webhook server.

**Exit codes**:
- `0`: Server stopped
- `1`: No running server found

### `make status`
Check the `/status` endpoint (HTTP GET http://localhost:9000/status).

**Exit codes**:
- `0`: Endpoint returns HTTP 200 with valid response
- `1`: Endpoint unreachable or non-200 response

### `make date`
Check the `/date` endpoint (HTTP GET http://localhost:9000/date).

**Exit codes**:
- `0`: Endpoint returns HTTP 200 with valid timestamp
- `1`: Endpoint unreachable or non-200 response

### `make docker-up`
Build Docker image and start service via Docker Compose.

**Exit codes**:
- `0`: Container started and serving
- `1`: Docker or Docker Compose not found
- `2`: Build or start failure

### `make docker-down`
Stop and remove Docker Compose services.

**Exit codes**:
- `0`: Services stopped
- `1`: No running services found
