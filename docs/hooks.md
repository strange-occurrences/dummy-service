# Adding New Hooks

The webhook tool uses JSON hook configuration files stored in `hooks/`.

## Hook Format

Each hook file is a JSON array of hook rule objects:

```json
[
  {
    "id": "hook-name",
    "execute-command": "/path/to/command",
    "command-working-directory": "/working/dir",
    "pass-arguments-to-command": [
      {"source": "string", "name": "arg1"},
      {"source": "string", "name": "arg2"}
    ],
    "response-message": "Optional response body",
    "response-headers": [
      {"name": "Content-Type", "value": "application/json"}
    ]
  }
]
```

## Adding a Hook

1. Create `hooks/<name>.json` with the hook definition
2. Restart the webhook service:
   - Local: `make stop && make start`
   - Docker: `make docker-down && make docker-up`
   - Systemd: `sudo systemctl restart webhook`
3. Test the endpoint: `curl http://localhost:9000/<name>`

## Example: Custom Hook

```json
[
  {
    "id": "hello",
    "execute-command": "/bin/echo",
    "command-working-directory": ".",
    "pass-arguments-to-command": [
      {"source": "string", "name": "Hello, World!"}
    ],
    "response-headers": [
      {"name": "Content-Type", "value": "text/plain"}
    ]
  }
]
```

## Environment Variables

The webhook server supports:

- `WEBHOOK_PORT` — override the default port (9000)
- `HOOKS_DIR` — override the hooks directory (default: `hooks/`)
