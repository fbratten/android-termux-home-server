# Architecture

## MVP Architecture

```mermaid
flowchart TD
    User[LAN User / Operator]
    Windows[Windows PowerShell Client]
    Router[Home Router / LAN]
    Phone[Old Android Phone]
    Termux[Termux]
    SSH[sshd :8022]
    API[FastAPI :8080]
    Dashboard[/dashboard]
    Health[/health, /info, /status]
    Actions[Token-protected Action Runner]
    Webhook[Token-protected Webhook Inbox]
    Collector[status-collector service]
    Watchdog[phone-watchdog service]
    Files[Runtime Files]
    Scripts[Whitelisted Shell Scripts]

    User --> Router
    Windows --> Router
    Router --> Phone
    Phone --> Termux
    Termux --> SSH
    Termux --> API
    API --> Dashboard
    API --> Health
    API --> Actions
    API --> Webhook
    Actions --> Scripts
    Collector --> Files
    Webhook --> Files
    Watchdog --> API
    API --> Files
```

## Runtime Components

| Component | Purpose |
|---|---|
| Android phone | Physical always-on node, battery-backed and LAN-connected |
| Termux | Non-rooted Linux-like userland on Android |
| `sshd` | Remote shell access on port `8022` |
| `phone-api` | FastAPI app on port `8080` |
| `status-collector` | Periodically writes device status to `app/status.json` |
| `phone-watchdog` | Checks `/health` and restarts `phone-api` if unhealthy |
| `app/actions/` | Whitelisted scripts callable through token-protected API routes |
| `app/logs/` | Runtime logs and webhook event storage |

## Request Flow

### Dashboard

```text
LAN browser
→ http://PHONE_IP:8080/dashboard
→ FastAPI
→ live status + recent events
```

### Action Runner

```text
PowerShell client / browser
→ /actions/{name}?token=TOKEN
→ token check
→ whitelist check
→ shell script execution
→ JSON response
```

### Webhook Inbox

```text
LAN client
→ POST /webhook?token=TOKEN
→ token check
→ append event to app/logs/events.jsonl
→ dashboard displays recent events
```

## Security Boundaries

| Boundary | Decision |
|---|---|
| Root access | Not required |
| Docker | Not used |
| Internet exposure | Out of scope |
| WAN port forwarding | Explicitly discouraged |
| Arbitrary command execution | Not implemented |
| Actions | Whitelist-only |
| Secrets | Local `.action_token`, ignored by Git |

## Operational Assumptions

- The phone stays on the trusted LAN.
- The router does not forward ports `8022` or `8080` to the internet.
- The phone has a stable DHCP reservation.
- Android battery optimization is relaxed for Termux and Termux:Boot.
- The operator validates the setup with `docs/VALIDATION.md` before any public release.
