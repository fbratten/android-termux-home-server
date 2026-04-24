# Dry-Run Execution Plan

This document walks through the real-world validation sequence before running it on the Android device.

## Goal

Validate the MVP without expanding scope.

```text
Target route: non-rooted Android + Termux + LAN-only FastAPI node
Protocol: 5PP
Release gate: Issue #2
```

## 1. Clarify

Confirm target conditions:

- [ ] Android device is non-rooted.
- [ ] Termux is installed from F-Droid or official GitHub release.
- [ ] Termux:API app is installed.
- [ ] Termux:Boot app is installed if reboot startup is required.
- [ ] Device is on trusted LAN.
- [ ] No public port forwarding is planned.

## 2. Scope

Only validate the current MVP:

- SSH service
- FastAPI service
- Status collector
- Watchdog
- Token-protected action runner
- Webhook inbox
- Dashboard
- Local validation runner

Explicitly out of scope:

- Docker
- Root/chroot route
- Internet exposure
- Home Assistant full-server replacement
- New features

## 3. Plan

Execution order:

```text
1. Prepare Android / Termux
2. Clone repo
3. Run installer
4. Check services
5. Run manual smoke tests
6. Run scripts/validate_local.sh
7. Test LAN access
8. Test Windows client
9. Reboot and verify Termux:Boot behavior
10. Record failures as issues
```

## 4. Execute

### 4.1 Prepare Termux

```bash
pkg update && pkg upgrade -y
pkg install -y git curl
```

### 4.2 Clone repo

```bash
cd ~
git clone https://github.com/fbratten/android-termux-home-server.git
cd android-termux-home-server
```

### 4.3 Run installer

```bash
bash scripts/install_or_rebuild.sh
```

### 4.4 Verify services

```bash
sv status sshd
sv status phone-api
sv status status-collector
sv status phone-watchdog
```

### 4.5 Verify local API

```bash
curl http://127.0.0.1:8080/health
curl http://127.0.0.1:8080/info
curl http://127.0.0.1:8080/status
```

### 4.6 Run automated validation

```bash
bash scripts/validate_local.sh
```

### 4.7 Verify LAN access

From another machine on the same LAN:

```bash
curl http://PHONE_IP:8080/health
```

### 4.8 Verify Windows client

```powershell
.\clients\AndroidServerClient.ps1 -Mode Health -PhoneIp "PHONE_IP"
```

### 4.9 Verify reboot behavior

Reboot Android, wait for startup, then check:

```bash
sv status sshd
sv status phone-api
sv status status-collector
sv status phone-watchdog
```

## 5. Verify

Pass condition:

- [ ] `scripts/validate_local.sh` exits `0`.
- [ ] Manual checklist in `docs/VALIDATION.md` passes.
- [ ] Any failure has a follow-up issue.
- [ ] Repo remains private until pass condition is met.

## Failure recording format

For each failure, create an issue using:

```text
Title: Validation failure: <short description>

Context:
- Device:
- Android version:
- Termux source:
- Step:
- Expected:
- Actual:
- Logs:

5PP classification:
- Clarify:
- Scope:
- Plan:
- Execute:
- Verify:
```
