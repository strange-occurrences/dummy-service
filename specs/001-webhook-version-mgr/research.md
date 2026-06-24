# Research: Webhook Version Manager

## Technical Decisions

### Language Choice
- **Decision**: Bash shell scripts with Makefile orchestration
- **Rationale**: Constitution Principle I (Shell-First Simplicity) mandates shell
  as default. Project scope (download binary, run service, config files) is well
  within shell capability.
- **Alternatives**: Python (rejected — adds dependency overhead for simple ops)

### GitHub Release Fetch Strategy
- **Decision**: Use GitHub Releases API (`/repos/adnanh/webhook/releases/latest`)
  to discover the latest version tag and download URL
- **Rationale**: No authentication needed for public repos; returns structured
  JSON with all required metadata (tag, assets, download URLs)
- **Alternatives**: Scraping release page HTML (fragile, no structured data),
  git clone tags (unnecessary overhead)

### Binary Distribution Format
- **Decision**: Webhook distributes pre-compiled binaries as gzipped tarballs
  (`webhook-linux-amd64.tar.gz`) with a corresponding SHA256 checksum file
- **Rationale**: Standard GitHub release pattern; the checksum file contains the
  SHA256 hash of the tarball for integrity verification (confirmed by
  Clarification Q1)
- **Asset pattern**: `webhook-{os}-{arch}.tar.gz` + `webhook-{os}-{arch}.tar.gz.sha256`

### Checksum Verification
- **Decision**: Download the `.sha256` file alongside the tarball, verify with
  `sha256sum -c`, only then extract and install.
- **Rationale**: Standard `sha256sum` utility is available on all modern Linux
  systems. No additional dependencies.

### Rate Limit Caching
- **Decision**: Cache the GitHub API response locally with 1-hour TTL (confirmed
  by Clarification Q3). Cache stored at `.cache/latest-release.json`.
- **Rationale**: Unauthenticated GitHub API rate limit is 60 requests/hour.
  Cache prevents hitting limits during iterative development.

### Rollback Strategy
- **Decision**: Previous binary preserved as `bin/webhook.previous` before
  overwrite (confirmed by Clarification Q2). Manual restore via `cp`.
- **Rationale**: Lightweight, no infrastructure needed. Automatic health-check
  rollback would overcomplicate a simple shell project.

### Webhook Default Hooks
- **Decision**: Two default JSON hooks — `/status` returns `{"status": "ok"}`
  and `/date` returns the current ISO-8601 timestamp
- **Rationale**: The adnanh/webhook tool uses JSON hook files with `"id"`,
  `"execute-command"`, `"command-working-directory"`, and `"response-message"`
  fields. Status can be a simple `echo` command hook; date uses `date -Iseconds`.

### Webhook Hook Format
From adnanh/webhook documentation, a hook JSON file looks like:
```json
[
  {
    "id": "status",
    "execute-command": "/bin/bash",
    "command-working-directory": ".",
    "pass-arguments-to-command": [
      {"source": "string", "name": "-c"},
      {"source": "string", "name": "echo '{\"status\":\"ok\"}'"}
    ],
    "response-message": "OK",
    "response-headers": [{"name": "Content-Type", "value": "application/json"}]
  }
]
```

### Webhook Defaults
- Default port: 9000
- Default hooks directory: `./hooks`
- Binary download pattern: `webhook-linux-amd64.tar.gz`
