# Systemd Service Setup

## Prerequisites

- Linux with systemd
- Webhook binary installed via `make update`
- Hook configurations in `hooks/`

## Installation

1. Copy the example service file:

```bash
sudo cp systemd/webhook.service /etc/systemd/system/webhook.service
```

2. Edit the service file to match your paths:

```bash
sudo nano /etc/systemd/system/webhook.service
```

Update these fields:
- `User` — the user to run the service as
- `WorkingDirectory` — the project directory path
- `ExecStart` — the full path to `bin/webhook`
- `-port` — the port to listen on (default: 9000)

3. Reload systemd and enable the service:

```bash
sudo systemctl daemon-reload
sudo systemctl enable webhook
sudo systemctl start webhook
```

## Management

```bash
# Status
sudo systemctl status webhook

# Stop
sudo systemctl stop webhook

# Restart
sudo systemctl restart webhook

# View logs
sudo journalctl -u webhook -f

# Disable on boot
sudo systemctl disable webhook
```

## Customization

To change the port, update the `ExecStart` line and ensure the port is
accessible via any firewall rules:

```ini
ExecStart=/opt/webhook/bin/webhook -hooks /opt/webhook/hooks -port 9443
```

## Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| Service fails to start | Binary not found | Verify path in `ExecStart` |
| Port conflict | Another service on the same port | Change `-port` value |
| Hooks not responding | Wrong hooks directory | Check `-hooks` path |
| Permission denied | User can't access binary | Check file ownership and permissions |
