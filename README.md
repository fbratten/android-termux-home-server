# Android Termux Home Server

Turn an old non-rooted Android phone into a lightweight LAN-only home server using Termux, FastAPI, SSH, scheduled status collection, a watchdog, token-protected actions, and a local webhook inbox.

## Current MVP

This project is intentionally small and realistic:

- No root required
- No Docker required
- LAN-only by default
- FastAPI dashboard on port `8080`
- SSH access through Termux on port `8022`
- Whitelisted action runner
- Shared-token protection for actions and webhooks
- Scheduled status collector
- Watchdog process for API recovery
- Backup/export action
- PowerShell client scripts for Windows operators

## Architecture

```text
Android phone
└── Termux
    ├── sshd
    ├── FastAPI app
    │   ├── /dashboard
    │   ├── /health
    │   ├── /status
    │   ├── /actions/{name}
    │   ├── /webhook
    │   └── /events
    ├── status collector
    ├── watchdog
    └── whitelisted shell actions
```

## Quick start

Install Termux from F-Droid or the official GitHub release, then copy this repo to the phone and run:

```bash
bash scripts/install_or_rebuild.sh
```

Then verify:

```bash
sv status sshd
sv status phone-api
sv status status-collector
sv status phone-watchdog
curl http://127.0.0.1:8080/health
```

Open from another device on the same LAN:

```text
http://PHONE_IP:8080/dashboard
```

## Security model

This is a LAN-oriented utility node, not an internet-facing server.

- Keep it behind your router/firewall.
- Do not expose port `8080` directly to the internet.
- Do not commit `.action_token`.
- Only predefined scripts in the action whitelist can run.
- Runtime logs, status files, backups, and virtual environments are ignored by Git.

## Repository layout

```text
app/        FastAPI app and Python service scripts
actions/    Whitelisted shell actions
scripts/    Install, rebuild, and diagnostics scripts
clients/    Windows PowerShell client scripts
docs/       Project documentation
```

## Status

MVP scaffold. Intended for iterative hardening and practical home-lab use.
