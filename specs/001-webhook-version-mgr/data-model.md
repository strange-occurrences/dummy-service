# Data Model: Webhook Version Manager

## Entities

### WebhookBinary
The compiled webhook executable managed by this project.

| Field | Type | Description |
|-------|------|-------------|
| `path` | Path | `bin/webhook` — primary binary location |
| `previous_path` | Path | `bin/webhook.previous` — backup before update |
| `state` | Enum | `absent` / `current` / `outdated` / `corrupt` |

**Lifecycle**:
- `absent` → `current`: Fresh install (no prior binary)
- `current` → `outdated`: Newer version available on GitHub
- `outdated` → `current`: Update command succeeds
- `current` → `current` (with `.previous`): Update replaces in-place
- Any state → `corrupt`: Checksum mismatch, abort install

### VersionFile
Tracks the currently installed webhook version.

| Field | Type | Description |
|-------|------|-------------|
| `path` | Path | `version.txt` at project root |
| `content` | String | Semantic version string (e.g., `2.8.21`) |
| `encoding` | String | Plain text, single line, no trailing newline requirement |

**Validation Rules**:
- MUST match semver pattern: `\d+\.\d+\.\d+`
- MUST be kept in sync with `bin/webhook` binary version
- Source of truth for "is update needed?" comparison

### ReleaseCache
Local cache of the latest GitHub release metadata.

| Field | Type | Description |
|-------|------|-------------|
| `path` | Path | `.cache/latest-release.json` |
| `version` | String | Latest release tag (e.g., `2.8.21`) |
| `cached_at` | Timestamp | Unix epoch of when cache was fetched |
| `ttl` | Duration | 1 hour (3600 seconds) — configurable |

**Validation Rules**:
- Cache is stale if `now - cached_at > ttl`
- Stale cache triggers fresh API fetch
- Cache miss (file absent) triggers fresh fetch

### HookConfig
A webhook endpoint definition stored as a JSON file.

| Field | Type | Description |
|-------|------|-------------|
| `path` | Path | `hooks/{id}.json` |
| `id` | String | Endpoint identifier (e.g., `status`, `date`) |
| `format` | String | JSON array of hook rule objects (adnanh/webhook schema) |

**Default Hooks**:
| Hook ID | Endpoint | Behavior |
|---------|----------|----------|
| `status` | `/status` | Returns `{"status":"ok"}` with HTTP 200 |
| `date` | `/date` | Returns current ISO-8601 timestamp with HTTP 200 |

### Makefile
Defines available operations. Not a data entity, but defines the interface:

| Target | Operation | Depends On |
|--------|-----------|------------|
| `update` | Download & install latest webhook | curl, sha256sum, jq |
| `start` | Start webhook service locally | `bin/webhook`, `hooks/` |
| `stop` | Stop webhook service | PID file or process |
| `status` | Check `/status` endpoint | Running webhook |
| `date` | Check `/date` endpoint | Running webhook |
| `docker-up` | Build & start via Docker Compose | Docker, Docker Compose |
| `docker-down` | Stop Docker Compose services | Running docker-compose |
