# Implementation Plan: Webhook Version Manager

**Branch**: `001-webhook-version-mgr` | **Date**: 2026-06-24 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-webhook-version-mgr/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

A shell-based project that manages the adnanh/webhook tool version — downloads
the latest binary from GitHub Releases (with SHA256 verification), provides
default status/date endpoints, Docker Compose support, systemd service
examples, and Makefile targets for all operations.

## Technical Context

**Language/Version**: Shell (bash) — Constitution Principle I mandates shell-first
**Primary Dependencies**: curl, sha256sum, jq (documented in manifest)
**Storage**: Filesystem (bin/, version.txt, hooks/, cache dir)
**Testing**: shellcheck for linting; manual verification via Makefile targets
**Target Platform**: Linux x86_64 (ARM deferred per spec Assumptions)
**Project Type**: CLI / shell ops tool
**Performance Goals**: Not applicable — single-operator, no throughput requirements
**Constraints**: POSIX-compatible environment; curl and common shell utilities
**Scale/Scope**: Single machine, single operator

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

**I. Shell-First Simplicity** — ✅ All implementation in shell scripts (Makefile
targets wrapping bash). Only external deps are `curl`, `sha256sum`, `jq` — all
standard Linux utilities. No violation.

**II. CLI-First Interface** — ✅ All functionality exposed via `make` targets
and shell scripts. Text in/out via stdin/stdout/stderr. JSON output from GitHub
API parsed with jq. Makefile targets for `status`, `date`, `start`, `stop`,
`update`, `docker-up`. No violation.

**III. Robust Operations** — ✅ Every script MUST use `set -euo pipefail`,
validate arguments, fail with clear error messages, clean up temps. Logging
to stdout with timestamp. This will be enforced during implementation. No
violation — but will be re-verified after Phase 1 design.

**Constitution gate: PASS** — No violations identified. No Complexity Tracking
section needed.

## Project Structure

### Documentation (this feature)

```text
specs/001-webhook-version-mgr/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
bin/                  # Webhook binary (gitignored)
├── webhook           # Current webhook executable
└── webhook.previous  # Previous version (backup before update)

hooks/                # Hook configuration files
├── status.json       # Health check endpoint hook
└── date.json         # Date/timestamp endpoint hook

docs/                 # Documentation
├── hooks.md          # Guide: how to add new hooks
└── systemd.md        # Guide: systemd service setup

systemd/              # Systemd service examples
└── webhook.service   # Example unit file

specs/                # Feature specifications
└── 001-webhook-version-mgr/

Makefile              # Targets: status, date, start, stop, update, docker-up
version.txt           # Current webhook version (e.g., 2.8.21)
Dockerfile            # Container build
docker-compose.yml    # Docker Compose service definition
```

**Structure Decision**: Single project layout (Option 1). Shell projects don't
need src/ — scripts live at root or in relevant directories. The `bin/`
directory stores the downloaded binary. `hooks/` stores JSON hook configs.
`docs/` holds documentation. `systemd/` holds example unit files.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

No constitution violations. Section omitted.
