<!--
  Sync Impact Report
  ==================
  Version change: N/A → 1.0.0 (initial creation)
  Modified principles: (none — first constitution)
  Added sections:
    - Core Principles: I. Shell-First Simplicity, II. CLI-First Interface, III. Robust Operations
    - Operational Requirements
    - Development Workflow
    - Governance (amendment procedure, versioning policy, compliance review)
  Removed sections: none
  Templates requiring updates:
    - .specify/templates/plan-template.md — ✅ no changes needed (Constitution Check section already generic)
    - .specify/templates/spec-template.md — ✅ no changes needed
    - .specify/templates/tasks-template.md — ⚠ pending: add shell-specific lint task category example
  Deferred TODOs: none
-->

# Dummy Service Constitution

## Core Principles

### I. Shell-First Simplicity

Shell is the default implementation language. Before reaching for Python, Go, or
another language, demonstrate that shell is genuinely insufficient. Prefer POSIX
sh over bash; prefer bash over external tools. Every dependency MUST be
justified and documented in a single manifest.

Rationale: Shell scripts are the most transparent, debuggable, and portable
option for operations tasks. Each additional dependency increases the surface
area for breakage in diverse runtime environments.

### II. CLI-First Interface

All functionality MUST be invocable via CLI. Text in (stdin/args) → text out
(stdout), errors → stderr. Support machine-parseable output (JSON where
feasible) alongside human-readable formats.

Rationale: Text-based I/O enables composability, ad-hoc debugging, and
automation without coupling to a specific language runtime or framework.

### III. Robust Operations

Every script MUST:
- Use `set -euo pipefail` (or equivalent in non-sh shells).
- Validate all required arguments early with clear failure messages.
- Fail fast on unexpected input — do not silently ignore errors.
- Clean up temporary resources (files, processes) on exit via traps.
- Log every meaningful action to stdout with timestamp + severity level.
- Include context in error messages: what failed, why, and the relevant input.

Rationale: Shell scripts silently continue past errors by default. Defensive
flags and structured logging prevent catastrophic chain failures and enable
forensic debugging in production.

## Operational Requirements

- **Runtime**: Scripts MUST target a POSIX-compatible environment. Bash-specific
  features are acceptable only when POSIX-sh equivalence would be excessively
  painful; call this out in the script header.
- **Idempotency**: All scripts MUST be safe to re-run. Running the same script
  twice with the same inputs MUST produce the same outcome. Use guard checks
  before destructive operations.
- **Dry-Run**: Destructive operations (delete, overwrite, mutate external state)
  MUST support a `--dry-run` flag that shows what would happen without
  executing the change.
- **Common Tools**: Required external tools MUST be listed at the top of each
  script with a brief note on why each is needed.

## Development Workflow

- Follow the speckit workflow: analyze → specify → plan → implement.
- Every spec MUST include a Constitution Check gate referencing the relevant
  principles.
- All scripts MUST pass `shellcheck` before merge. Lint configuration lives
  at the project root.
- Dry-run scripts on representative inputs before requesting review.
- Tests are OPTIONAL but encouraged for non-trivial logic. When tests exist,
  they MUST be written before implementation (test-first).

## Governance

**Supremacy**: This constitution supersedes all other development practices,
conventions, and guidelines. Any conflicting guidance must be resolved in favor
of this document.

**Amendment Procedure**:
1. Propose the change with documented rationale.
2. Update this file with the new text and bump the version per the rules below.
3. If backward-incompatible, include a migration plan for existing scripts and
   CI pipelines.
4. The amended constitution takes effect on the `LAST_AMENDED_DATE`.

**Versioning Policy**:
- MAJOR: Backward-incompatible principle removal, redefinition, or governance
  restructuring.
- MINOR: New principle or section added; materially expanded guidance.
- PATCH: Clarifications, wording refinements, typo fixes.

**Compliance Review**:
- Every spec plan and task list MUST include a Constitution Check section
  referencing applicable principles.
- Reviewers MUST verify compliance before approving.
- Complexity must be justified: any violation of principles (e.g., adding a
  non-shell dependency) requires explicit rationale in the plan.

**Version**: 1.0.0 | **Ratified**: 2026-06-24 | **Last Amended**: 2026-06-24
