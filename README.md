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

## Authors

- Fredrik Bratten
- Nelly, co-worker agent

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

For a Mermaid diagram and request-flow breakdown, see `docs/ARCHITECTURE.md`.

## Quick start

Install Termux from F-Droid or the official GitHub release, then clone this repo to the phone:

```bash
git clone https://github.com/fbratten/android-termux-home-server.git
cd android-termux-home-server
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

## Documentation

| Document | Purpose |
|---|---|
| `docs/PROJECT.md` | Project map, endpoints, services, and safety model |
| `docs/ARCHITECTURE.md` | Mermaid architecture diagram and request flows |
| `docs/VALIDATION.md` | Manual validation checklist before public release |
| `docs/ANDROID_SETUP.md` | Termux, Termux:API, Termux:Boot, battery, and background reliability notes |
| `docs/NETWORKING.md` | DHCP reservation, LAN-only safety, ports, and remote-access boundaries |
| `docs/RELEASE_DECISION.md` | Current release gate and public/private decision note |
| `docs/ROADMAP.md` | Atomic project roadmap and future route boundaries |
| `CONTRIBUTING.md` | Pre-public contribution rules and workflow |

## Security model

This is a LAN-oriented utility node, not an internet-facing server.

- Keep it behind your router/firewall.
- Do not expose port `8080` directly to the internet.
- Do not expose port `8022` directly to the internet.
- Do not commit `.action_token`.
- Only predefined scripts in the action whitelist can run.
- Runtime logs, status files, backups, and virtual environments are ignored by Git.

## Repository layout

```text
app/             FastAPI app and Python service scripts
app/actions/     Whitelisted shell actions used by the FastAPI action runner
scripts/         Install, rebuild, and diagnostics scripts
clients/         Windows PowerShell client scripts
docs/            Project documentation
```

## Important runtime files

These are generated on the Android device and should not be committed:

```text
app/.action_token
app/.venv/
app/logs/
app/status.json
app/collector.log
app/backups/
```

## Release state

Private until validated on a real Android device. See `docs/RELEASE_DECISION.md`.
