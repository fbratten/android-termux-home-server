# Android Termux Home Server

![Status](https://img.shields.io/badge/status-public--pre--release-orange)
![Testing](https://img.shields.io/badge/testing-not%20fully%20tested-red)
![Platform](https://img.shields.io/badge/platform-Android%20%2B%20Termux-blue)
![Security](https://img.shields.io/badge/model-LAN--only-green)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

Experimental MVP scaffold for turning an old non-rooted Android phone into a lightweight LAN-only home server using Termux, FastAPI, SSH, scheduled status collection, a watchdog, token-protected actions, and a local webhook inbox.

> **Pre-release notice**  
> This project is **not fully tested on real Android hardware yet**. Treat it as an experimental starter kit. Validate it on your own device before relying on it.

## Current MVP

This project is intentionally small and realistic:

- Not fully tested yet
- No root required
- No Docker required
- LAN-only by default
- No internet-facing deployment guidance
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
bash scripts/validate_local.sh
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
| `docs/VALIDATION.md` | Manual validation checklist |
| `docs/PUBLIC_RELEASE_CHECKLIST.md` | Public release and GitHub UI/security checklist |
| `docs/ANDROID_SETUP.md` | Termux, Termux:API, Termux:Boot, battery, and background reliability notes |
| `docs/NETWORKING.md` | DHCP reservation, LAN-only safety, ports, and remote-access boundaries |
| `docs/RELEASE_DECISION.md` | Public pre-release decision note |
| `docs/ROADMAP.md` | Atomic project roadmap and future route boundaries |
| `CONTRIBUTING.md` | Contribution rules and workflow |
| `AGENTS.md` | Agent interoperability instructions |

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
scripts/         Install, rebuild, validation, and diagnostics scripts
clients/         Windows PowerShell client scripts
docs/            Project documentation
.github/         Issue/PR templates and triage workflows
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

Public pre-release ready, with limitation: **not fully tested on real Android hardware yet**. See `docs/RELEASE_DECISION.md`.
