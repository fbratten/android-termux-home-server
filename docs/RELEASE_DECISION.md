# Release Decision

## Current decision

Public pre-release is approved with clear limitations.

The repository may be made public as an early MVP scaffold, provided that all public-facing documentation clearly states:

```text
Not fully tested on a real Android device yet.
Use as an experimental non-rooted Android + Termux LAN home-server starter kit.
```

## Reasoning

The repository contains a complete initial scaffold, governance layer, validation runner, contribution rules, agent instructions, and public release checklist. However, full real-device validation has not yet been completed.

This means public release is acceptable only as an explicit **pre-release / experimental MVP**, not as a proven production-ready tool.

## Public-release status

Status:

```text
PUBLIC PRE-RELEASE READY
```

Validation state:

```text
Not fully tested on real Android hardware yet.
```

Required public wording:

- Not fully tested
- LAN-only
- Non-rooted Android + Termux route
- No internet-facing deployment
- Experimental MVP / starter kit

## Public-release checklist before visibility switch

Before making the repository public, confirm:

- [ ] README states that the project is not fully tested.
- [ ] README states LAN-only / no internet-facing deployment.
- [ ] `docs/PUBLIC_RELEASE_CHECKLIST.md` exists.
- [ ] `scripts/validate_local.sh` is a full validation runner, not a placeholder.
- [ ] No `.action_token` is committed.
- [ ] No logs, backups, or runtime status files are committed.
- [ ] No secrets, SSH keys, API keys, or `.env` files are committed.
- [ ] Router/WAN exposure is explicitly discouraged.
- [ ] GitHub security settings are reviewed or marked pending.

## Still recommended after public release

After the repository is public:

- [ ] Run `docs/VALIDATION.md` on a real non-rooted Android device.
- [ ] Run `bash scripts/validate_local.sh` on the device.
- [ ] Confirm Termux:API battery status works.
- [ ] Confirm Termux:Boot startup works after reboot.
- [ ] Confirm dashboard loads from another LAN device.
- [ ] Confirm PowerShell client works from Windows if claimed.
- [ ] Convert any failure into a tracked issue.

## Explicit non-goals for public MVP

- No internet-facing deployment guide.
- No Docker route.
- No rooted Android route.
- No arbitrary command execution endpoint.
- No production-readiness claim.

## Public positioning

Recommended public positioning:

> Experimental MVP scaffold for turning an old non-rooted Android phone into a LAN-only Termux home-server node. Not fully tested yet; use as a starter kit and validate on your own device.
