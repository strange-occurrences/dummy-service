---

description: "Task list for Webhook Version Manager feature"
---

# Tasks: Webhook Version Manager

**Input**: Design documents from `/specs/001-webhook-version-mgr/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Tests are OPTIONAL - only include them if explicitly requested in the feature specification.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Shell project**: Files at root or in purpose-named directories (bin/, hooks/, docs/, systemd/)
- All shell scripts use `set -euo pipefail` and pass shellcheck

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and directory structure

- [x] T001 Create project directory structure: `bin/`, `hooks/`, `docs/`, `systemd/`, `.cache/`
- [x] T002 [P] Create `.gitignore` — ignore `bin/`, `.cache/`, and os-specific files
- [x] T003 [P] Create `version.txt` with initial version placeholder (`0.0.0`)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Makefile, dependency management, and hook configurations that MUST exist before any user story can be exercised

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T004 Create `Makefile` with all target stubs: `update`, `start`, `stop`, `status`, `date`, `docker-up`, `docker-down`
- [x] T005 [P] Create `hooks/status.json` — default health-check hook returning `{"status":"ok"}` at `/status`
- [x] T006 [P] Create `hooks/date.json` — default timestamp hook returning ISO-8601 date at `/date`
- [x] T007 Add prerequisite check logic to Makefile: verify `curl`, `sha256sum`, `jq` availability before real targets

**Checkpoint**: Foundation ready - Makefile exists with all targets, hooks configured, deps verified.

---

## Phase 3: User Story 1 - Update Webhook Binary to Latest Version (Priority: P1) 🎯 MVP

**Goal**: Operator can run `make update` to download and install the latest webhook binary from GitHub Releases.

**Independent Test**: Run `make update` with no existing binary — verify `bin/webhook` is executable and `version.txt` matches the latest GitHub release tag. Run it again — verify it reports "already up to date".

### Implementation for User Story 1

- [x] T008 [US1] Implement `make update` target: call `scripts/update-webhook.sh`
- [x] T009 [P] [US1] Create `scripts/update-webhook.sh` — fetch latest release from GitHub API (`/repos/adnanh/webhook/releases/latest`), parse JSON with `jq`, compare with current version from `version.txt`
- [x] T010 [P] [US1] Implement SHA256 checksum verification in `scripts/update-webhook.sh`: download `.sha256` file, verify tarball with `sha256sum -c`, abort on mismatch
- [x] T011 [US1] Implement rollback backup in `scripts/update-webhook.sh`: save existing `bin/webhook` → `bin/webhook.previous` before overwriting
- [x] T012 [P] [US1] Implement release cache in `scripts/update-webhook.sh`: store latest release data in `.cache/latest-release.json` with 1h TTL, use cache on API failure
- [x] T013 [US1] Implement idempotency in `scripts/update-webhook.sh`: detect `version.txt` matches latest, print "Already up to date (v{version})" and exit 0

**Checkpoint**: At this point, User Story 1 should be fully functional — `make update` installs or updates the binary correctly with checksum verification and rollback.

---

## Phase 4: User Story 2 - Run and Verify the Webhook Service (Priority: P2)

**Goal**: Operator can start the webhook service locally (or via Docker) and verify it via `make status` and `make date`.

**Independent Test**: Run `make start`, then run `make status` (returns HTTP 200) and `make date` (returns timestamp). Run `make docker-up` and verify same endpoints via Docker.

### Implementation for User Story 2

- [x] T014 [US2] Implement `make start` target: launch `bin/webhook -hooks hooks/ -port 9000` with process management
- [x] T015 [US2] Implement `make stop` target: kill webhook process by PID or process name
- [x] T016 [P] [US2] Implement `make status` target: `curl -s -o /dev/null -w "%{http_code}" http://localhost:9000/status` — verify HTTP 200
- [x] T017 [P] [US2] Implement `make date` target: `curl -s http://localhost:9000/date` — verify non-empty timestamp response
- [x] T018 [P] [US2] Create `Dockerfile` for containerized webhook: copy binary and hooks, expose port 9000
- [x] T019 [P] [US2] Create `docker-compose.yml`: service definition for webhook with hooks volume mount
- [x] T020 [US2] Implement `make docker-up` and `make docker-down` targets: wrap `docker compose up/down`

**Checkpoint**: At this point, User Stories 1 AND 2 should both work — binary installed, service starts, endpoints respond, Docker workflow functional.

---

## Phase 5: User Story 3 - Set Up as a Systemd Service (Priority: P3)

**Goal**: Operator has example systemd unit file and documentation to set up webhook as a system service.

**Independent Test**: Inspect `systemd/webhook.service` — verify it contains correct binary path, user, working directory, and hook configuration path. Follow docs to enable the service.

### Implementation for User Story 3

- [x] T021 [US3] Create `systemd/webhook.service` — example systemd unit file with: `ExecStart` pointing to `bin/webhook`, `WorkingDirectory` to project root, `User` placeholder, restart policy, and standard paths
- [x] T022 [P] [US3] Create `docs/hooks.md` — guide explaining hook JSON schema, how to add new hooks, test endpoints, and common patterns
- [x] T023 [P] [US3] Create `docs/systemd.md` — guide explaining how to install the service, enable on boot, start/stop/status, view logs, and customize paths

**Checkpoint**: All user stories should now be independently functional.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Quality assurance, linting, and final verification

- [x] T024 Run `shellcheck` on all shell scripts (`scripts/update-webhook.sh`, Makefile) and fix any violations
- [ ] T025 End-to-end verification: run `make update`, `make start`, `make status`, `make date`, `make stop` in sequence and confirm all pass (requires network + webhook binary)
- [ ] T026 [P] Verify Docker workflow: `make docker-up`, `make status`, `make date`, `make docker-down` (requires Docker)
- [x] T027 [P] Verify docs are accurate: read `docs/hooks.md` and `docs/systemd.md` against actual project layout

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Story 1 (Phase 3)**: Depends on Foundational — Makefile must exist
- **User Story 2 (Phase 4)**: Depends on Foundational + US1 binary installation — Makefile and hooks must exist
- **User Story 3 (Phase 5)**: Depends on Foundational — project structure must exist but is otherwise independent
- **Polish (Phase 6)**: Depends on all user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational — No dependencies on other stories
- **User Story 2 (P2)**: Depends on US1 (needs binary installed) — hooks independent of US1 logic
- **User Story 3 (P3)**: Independent of US1 and US2 — only needs project structure from Foundational

### Within Each User Story

- Type order: Infrastructure before implementation
- Models before services
- Core implementation before verification

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational hooks (T005, T006) can run in parallel
- US1: T009, T010, T012 can run in parallel (different files, different concerns)
- US2: T016, T017, T018, T019 can run in parallel (curl targets, Docker files)
- US3: T022, T023 can run in parallel (different docs)
- Polish: T024 and T025 are sequential (lint then verify); T026, T027 parallel

---

## Parallel Example: User Story 1

```bash
# Launch all independent US1 tasks together:
Task: "Create scripts/update-webhook.sh — fetch logic"
Task: "Implement SHA256 checksum verification in update-webhook.sh"
Task: "Implement release cache in update-webhook.sh"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Run `make update`, confirm binary installed and version.txt matches
5. MVP achieved — binary management works

### Incremental Delivery

1. Phase 1 + Phase 2 → Foundation ready
2. Add User Story 1 → Test independently → MVP
3. Add User Story 2 → Test independently → Service operational
4. Add User Story 3 → Test independently → Production-ready
5. Each story adds value without breaking previous stories

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence
