# Android Termux Home Server

## Purpose

A non-rooted Android phone running Termux as a lightweight LAN-only home server.

## Current capabilities

- SSH access on port 8022
- FastAPI web server on port 8080
- Local dashboard
- Health/status endpoints
- Scheduled status collection
- Watchdog restart check
- Token-protected action runner
- Local webhook inbox
- Event dashboard
- Backup/export action
- Rebuild script support

## Main files

| File | Purpose |
|---|---|
| `app/main.py` | FastAPI application |
| `app/collect_status.py` | Collects battery/storage/network status |
| `app/healthcheck.py` | Checks API health and restarts service |
| `app/config.json` | Node configuration |
| `app/requirements.txt` | Python dependencies |
| `app/VERSION` | Project version |
| `app/.action_token` | Shared local action token, generated on device and ignored by Git |
| `app/status.json` | Latest collected status, ignored by Git |
| `app/logs/events.jsonl` | Webhook event log, ignored by Git |

## Actions

| Action | Purpose |
|---|---|
| `heartbeat` | Write heartbeat log |
| `collect-status` | Update status file |
| `list-logs` | Show log files |
| `trim-logs` | Keep logs small |
| `backup` | Create backup archive |
| `diagnose` | Run local diagnostics |

## Services

| Service | Purpose |
|---|---|
| `sshd` | Remote shell access |
| `phone-api` | FastAPI app |
| `status-collector` | Scheduled collector loop |
| `phone-watchdog` | API watchdog loop |

## Endpoints

| Endpoint | Protected | Purpose |
|---|---:|---|
| `/` | No | Root info |
| `/health` | No | Basic health check |
| `/status` | No | Live status |
| `/dashboard` | No | Local dashboard |
| `/collected-status` | No | Last collected status |
| `/info` | No | Project metadata |
| `/actions` | Yes | List allowed actions |
| `/actions/{name}` | Yes | Run whitelisted action |
| `/webhook` | Yes | Receive event |
| `/events` | Yes | Read recent events |

## Verify on Android

```bash
sv status sshd
sv status phone-api
sv status status-collector
sv status phone-watchdog

curl http://127.0.0.1:8080/health
curl http://127.0.0.1:8080/info
curl http://127.0.0.1:8080/dashboard
```

## Windows client examples

```powershell
.\clients\AndroidServerClient.ps1 -Mode Health -PhoneIp "192.168.1.50"
.\clients\AndroidServerClient.ps1 -Mode Status -PhoneIp "192.168.1.50"
.\clients\AndroidServerClient.ps1 -Mode RunAction -Action collect-status -PhoneIp "192.168.1.50"
```

## Safety model

- LAN-only by default
- No root required
- No Docker required
- No arbitrary command execution
- Only whitelisted scripts can run
- Action and webhook endpoints require token
