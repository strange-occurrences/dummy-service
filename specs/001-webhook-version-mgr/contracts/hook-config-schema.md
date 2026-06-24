# Hook Configuration Contract

Hook files live in `hooks/` directory and follow the adnanh/webhook JSON
schema. Each file is a JSON array of hook rule objects.

## Schema

```json
[
  {
    "id": "<endpoint-path>",
    "execute-command": "<command-to-run>",
    "command-working-directory": "<cwd>",
    "pass-arguments-to-command": [
      {"source": "string", "name": "<arg>"}
    ],
    "response-message": "<body-text>",
    "response-headers": [
      {"name": "<header-name>", "value": "<header-value>"}
    ]
  }
]
```

## Default Hooks

### `hooks/status.json`
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
    "response-headers": [
      {"name": "Content-Type", "value": "application/json"}
    ]
  }
]
```

### `hooks/date.json`
```json
[
  {
    "id": "date",
    "execute-command": "/bin/bash",
    "command-working-directory": ".",
    "pass-arguments-to-command": [
      {"source": "string", "name": "-c"},
      {"source": "string", "name": "date -Iseconds"}
    ],
    "response-headers": [
      {"name": "Content-Type", "value": "text/plain"}
    ]
  }
]
```

## Adding New Hooks

Create a new `hooks/<name>.json` file following the schema above. See
`docs/hooks.md` for detailed guidance.
