# Roadmap

This roadmap keeps the project atomic: validate the non-rooted Termux MVP first, then expand only after the base route is proven.

## Phase 0 — Repo scaffold

Status: complete.

- [x] Initial FastAPI app
- [x] Status collector
- [x] Watchdog
- [x] Whitelisted actions
- [x] Webhook inbox
- [x] PowerShell clients
- [x] Installer/rebuild script
- [x] Diagnostics script
- [x] Validation, setup, networking, architecture, and release decision docs

## Phase 1 — On-device validation

Status: active.

Tracked by Issue #2.

Goal:

- Prove that the current MVP works on a real non-rooted Android phone.

Exit criteria:

- `docs/VALIDATION.md` completed.
- Any failed item converted into a follow-up issue.
- Release decision revisited after validation.

## Phase 2 — Reliability hardening

Status: pending validation.

Possible work:

- Improve installer idempotency.
- Add clearer error output for missing Termux:API.
- Add service restart troubleshooting.
- Add optional log retention policy.
- Add backup restore test procedure.

## Phase 3 — Usability improvements

Status: pending validation.

Possible work:

- Improve dashboard layout.
- Add dashboard auto-refresh with safe polling interval.
- Add endpoint for summarized event counts.
- Add simple device identity/config panel.
- Add screenshots after real-device validation.

## Phase 4 — Optional integrations

Status: future.

Possible routes:

- Home Assistant webhook integration.
- Windows scheduled task sender.
- Obsidian/home-lab event notes.
- Tailscale/WireGuard private remote access guide.

## Explicitly out of scope for this roadmap

- Rooted Android route
- Docker route
- Public internet exposure
- Arbitrary remote command execution
- Full Home Assistant server replacement
