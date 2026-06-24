# Feature Specification: Webhook Version Manager

**Feature Branch**: `001-webhook-version-mgr`  
**Created**: 2026-06-24  
**Status**: Draft  
**Input**: User description: "Simple project serving purpose of maintaining compose version for the webhook https://github.com/adnanh/webhook/ tool, version.txt is responsible for current version of the tool."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Update Webhook Binary to Latest Version (Priority: P1)

An operator wants to update the local webhook binary to the latest release from
GitHub without manually downloading and extracting archives.

**Why this priority**: This is the core purpose of the project — maintaining
the webhook version. Without this, nothing else functions.

**Independent Test**: Run the update command and verify the binary at `bin/`
is executable and reports a version matching the latest GitHub release tag
recorded in `version.txt`.

**Acceptance Scenarios**:

1. **Given** no binary exists in `bin/`, **When** the operator runs the update
   command, **Then** the latest webhook binary is downloaded to `bin/webhook`
   and `version.txt` contains the matching version string.
2. **Given** an outdated binary exists in `bin/`, **When** the operator runs
   the update command, **Then** the binary is replaced with the latest version
   and `version.txt` is updated accordingly.
3. **Given** the binary is already at the latest version, **When** the operator
   runs the update command, **Then** the tool reports "already up to date" and
   makes no changes.

---

### User Story 2 - Run and Verify the Webhook Service (Priority: P2)

An operator wants to start the webhook service locally (or via Docker) and
verify it is operational using built-in health and timestamp endpoints.

**Why this priority**: Once the binary is installed, the operator needs to
confirm the webhook is running correctly before adding custom hooks or
deploying to production.

**Independent Test**: Start the service and run `make status` and `make date`
to confirm both endpoints return expected responses.

**Acceptance Scenarios**:

1. **Given** the webhook binary is installed, **When** the operator runs
   `make start`, **Then** the webhook server starts on the default port
   (9000) and is reachable.
2. **Given** the webhook is running, **When** the operator hits the `/status`
   endpoint, **Then** a health confirmation is returned (e.g., HTTP 200 with
   status OK).
3. **Given** the webhook is running, **When** the operator hits the `/date`
   endpoint, **Then** the current date/time is returned in a parseable format.
4. **Given** a Docker host with Docker and Docker Compose installed, **When**
   the operator runs `make docker-up`, **Then** the webhook builds and starts
   inside a container and all endpoints are reachable.

---

### User Story 3 - Set Up as a Systemd Service (Priority: P3)

An operator wants to run the webhook as a persistent system service using
systemd, with example configuration files they can adapt.

**Why this priority**: Production deployments typically require process
supervision. Systemd is the standard on modern Linux distributions.

**Independent Test**: Inspect the provided systemd unit file and confirm it
references the correct binary path, user, and hook configuration.

**Acceptance Scenarios**:

1. **Given** the project directory with systemd example files, **When** the
   operator reads the systemd unit file, **Then** it contains a working
   service definition for `webhook` with documented paths.
2. **Given** the operator follows the setup instructions, **When** they enable
   and start the systemd service, **Then** the webhook runs as a supervised
   daemon and restarts on failure.

---

### Edge Cases

- What happens when GitHub Releases API is unreachable (no network)?
  The update command should report the error and leave the existing binary and
  version.txt intact. If a cached release check is available and recent
  (<1 hour old), it MAY use the cached version.
- What happens when the downloaded binary fails checksum verification?
  The update command MUST abort installation, remove any partially downloaded
  files, and report the checksum mismatch error.
- What happens when port 9000 is already in use?
  The start command should fail with a clear message indicating the port
  conflict.
- What happens when running `make` targets without installing the binary first?
  Commands should check prerequisites and report missing dependencies.
- What happens when a new binary fails and the operator needs the previous
  version? The previous binary is preserved at `bin/webhook.previous` and can
  be restored manually by copying it back to `bin/webhook`.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The project MUST provide a command/script to fetch the latest
  webhook release from GitHub and install the binary to `bin/`. The binary
  MUST be verified against the published SHA256 checksum before installation.
  The previous binary MUST be saved as `bin/webhook.previous` before
  overwriting. Latest release info SHOULD be cached locally to avoid hitting
  GitHub API rate limits; cache TTL of 1 hour is the default.
- **FR-002**: The installed version MUST be recorded in `version.txt` at the
  project root.
- **FR-003**: The update command MUST detect when the binary is already at the
  latest version and skip the download.
- **FR-004**: The project MUST include a default hook configuration with at
  least two endpoints: `status` (health check) and `date` (current timestamp).
- **FR-005**: A Makefile MUST provide targets for `status` and `date` that
  call the respective webhook endpoints.
- **FR-006**: A Makefile MUST provide targets to start and stop the webhook
  service.
- **FR-007**: The project MUST include example systemd service files for
  running the webhook as a system daemon.
- **FR-008**: The project MUST include documentation explaining how to add new
  hook rules.
- **FR-009**: The project MUST include documentation explaining how to set up
  the webhook as a systemd service.
- **FR-010**: The project MUST include a Dockerfile for containerized
  deployment.
- **FR-011**: The project MUST include a `docker-compose.yml` to run the
  webhook via Docker Compose.
- **FR-012**: A Makefile MUST provide a `docker-up` target to start via Docker
  Compose.

### Key Entities *(include if feature involves data)*

- **Webhook Binary**: The compiled `webhook` executable stored in `bin/`.
  Represents the runtime of the adnanh/webhook tool.
- **version.txt**: A plain-text file at the project root tracking the current
  webhook version (e.g., `2.8.1`).
- **Hook Configuration**: JSON/YAML files defining webhook rules (endpoints,
  commands, triggers). Live under a `hooks/` directory.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Running the update target downloads and installs a working
  webhook binary in under 30 seconds on a typical broadband connection.
- **SC-002**: After starting the service, both `make status` and `make date`
  return HTTP 200 responses within 2 seconds.
- **SC-003**: An operator unfamiliar with the project can follow the hook
  documentation and add a new working hook in under 15 minutes.
- **SC-004**: The Docker Compose setup starts the webhook in a container and
  serves all endpoints on first run without additional configuration.

## Assumptions

- The target environment is Linux (x86_64). ARM support is out of scope for
  v1.
- Docker and Docker Compose are pre-installed on systems using the container
  workflow.
- The GitHub Releases API is publicly accessible (no authentication required).
- The webhook binary is distributed as a gzipped tarball on the GitHub
  releases page.
- The webhook tool uses JSON-based hook configuration files.
- The operator has basic familiarity with shell commands, Make, and HTTP
  endpoints.
- Port 9000 is the default webhook port; users may customize via environment
  variables if documented.

## Clarifications

### Session 2026-06-24

- Q: How should binary download integrity be verified? → A: SHA256 checksum
  verification against published checksum file from GitHub Releases.
- Q: What rollback mechanism should exist if the new binary fails at runtime?
  → A: Keep existing binary as `bin/webhook.previous` before overwrite for
  manual rollback.
- Q: How should GitHub API rate limiting be handled? → A: Cache the latest
  release check result locally and only re-fetch if the cache is older than
  1 hour.
