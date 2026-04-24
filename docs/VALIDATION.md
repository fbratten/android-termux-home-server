# Validation Checklist

Use this checklist after cloning the repository to a non-rooted Android phone running Termux.

## Validation rule

Manual validation and automated validation both matter.

```text
docs/VALIDATION.md       → manual source of truth
scripts/validate_local.sh → local automated validation runner
```

A release candidate should pass both unless a failing item has been converted into a tracked follow-up issue.

## 1. Preflight

- [ ] Termux is installed from F-Droid or official GitHub release.
- [ ] Termux:API Android app is installed.
- [ ] Termux:Boot Android app is installed if boot startup is needed.
- [ ] Battery optimization is disabled or unrestricted for Termux.
- [ ] Battery optimization is disabled or unrestricted for Termux:Boot.
- [ ] Phone is connected to the intended LAN Wi-Fi.
- [ ] Router DHCP reservation is configured or planned.

## 2. Repository setup

```bash
git clone https://github.com/fbratten/android-termux-home-server.git
cd android-termux-home-server
bash scripts/install_or_rebuild.sh
```

Expected:

- [ ] Installer completes without fatal errors.
- [ ] `app/.action_token` is generated locally.
- [ ] `app/.venv/` is created locally.
- [ ] No secret token is committed to Git.

## 3. Service checks

```bash
sv status sshd
sv status phone-api
sv status status-collector
sv status phone-watchdog
```

Expected:

- [ ] `sshd` is running.
- [ ] `phone-api` is running.
- [ ] `status-collector` is running.
- [ ] `phone-watchdog` is running.

## 4. Local API checks

```bash
curl http://127.0.0.1:8080/health
curl http://127.0.0.1:8080/info
curl http://127.0.0.1:8080/status
curl http://127.0.0.1:8080/dashboard
```

Expected:

- [ ] `/health` returns JSON with `ok: true`.
- [ ] `/info` returns project name and version.
- [ ] `/status` returns live device status.
- [ ] `/dashboard` returns HTML.

## 5. Token-protected action checks

```bash
TOKEN="$(cat app/.action_token)"
curl "http://127.0.0.1:8080/actions?token=$TOKEN"
curl "http://127.0.0.1:8080/actions/heartbeat?token=$TOKEN"
curl "http://127.0.0.1:8080/actions/collect-status?token=$TOKEN"
curl "http://127.0.0.1:8080/actions/list-logs?token=$TOKEN"
```

Expected:

- [ ] `/actions` lists only whitelisted actions.
- [ ] `heartbeat` succeeds.
- [ ] `collect-status` updates `app/status.json`.
- [ ] `list-logs` returns known runtime files.

Negative check:

```bash
curl http://127.0.0.1:8080/actions
curl http://127.0.0.1:8080/actions/reboot?token=$TOKEN
```

Expected:

- [ ] Missing token is rejected.
- [ ] Non-whitelisted action is rejected.

## 6. Webhook checks

```bash
TOKEN="$(cat app/.action_token)"
curl -X POST "http://127.0.0.1:8080/webhook?token=$TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"source":"termux","event_type":"validation","message":"hello"}'

curl "http://127.0.0.1:8080/events?token=$TOKEN"
```

Expected:

- [ ] Webhook accepts JSON payload with valid token.
- [ ] `/events` returns the received validation event.
- [ ] Dashboard shows recent event after refresh.

## 7. Automated local validation runner

Run this after the installer and services are up:

```bash
bash scripts/validate_local.sh
```

Expected:

- [ ] Script exits with status code `0`.
- [ ] Commands are available: `curl`, `sv`, `python`.
- [ ] Required files and directories exist.
- [ ] Required services are running.
- [ ] Open endpoints respond.
- [ ] Token-protected action route accepts valid token.
- [ ] Missing-token action route is rejected.
- [ ] Non-whitelisted action is rejected.
- [ ] Webhook round-trip succeeds.
- [ ] `termux-battery-status` works.

## 8. LAN checks from another machine

Replace `PHONE_IP` with the phone LAN IP.

```bash
curl http://PHONE_IP:8080/health
curl http://PHONE_IP:8080/info
```

Expected:

- [ ] Another LAN device can reach `/health`.
- [ ] Another LAN device can reach `/info`.
- [ ] Router DHCP reservation keeps the phone IP stable.

## 9. Windows PowerShell client checks

On Windows, save the token locally:

```powershell
"PASTE_TOKEN_HERE" | Set-Content "$env:USERPROFILE\.android-termux-server-token"
```

Then run:

```powershell
.\clients\AndroidServerClient.ps1 -Mode Health -PhoneIp "PHONE_IP"
.\clients\AndroidServerClient.ps1 -Mode Status -PhoneIp "PHONE_IP"
.\clients\AndroidServerClient.ps1 -Mode Actions -PhoneIp "PHONE_IP"
.\clients\AndroidServerClient.ps1 -Mode RunAction -Action heartbeat -PhoneIp "PHONE_IP"
```

Expected:

- [ ] Health check succeeds.
- [ ] Status check succeeds.
- [ ] Actions list succeeds.
- [ ] Heartbeat action succeeds.

## 10. Diagnostics

```bash
bash scripts/diagnose.sh
```

Expected:

- [ ] Required files pass.
- [ ] Required services pass.
- [ ] Required endpoints pass.
- [ ] Missing event log before first webhook is treated as informational.

## 11. Safety checks before making public

- [ ] Confirm repo contains no `.action_token`.
- [ ] Confirm repo contains no `app/logs/`.
- [ ] Confirm repo contains no `app/status.json`.
- [ ] Confirm repo contains no `app/backups/`.
- [ ] Confirm README says LAN-only and no internet exposure.
- [ ] Confirm no arbitrary shell command endpoint exists.
