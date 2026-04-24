# Release Decision

## Current decision

Keep the repository private until the MVP has been validated on a real Android device.

## Reasoning

The repository now contains a complete initial scaffold, but the installer, Termux service behavior, Android background behavior, and PowerShell clients should be tested on-device before public release.

## Public-release gate

Before making the repository public, complete `docs/VALIDATION.md` and confirm:

- [ ] Fresh clone works on the target Android phone.
- [ ] `scripts/install_or_rebuild.sh` completes successfully.
- [ ] `phone-api`, `status-collector`, `phone-watchdog`, and `sshd` run correctly.
- [ ] Termux:API battery status works.
- [ ] Termux:Boot startup works after reboot.
- [ ] Dashboard loads from another LAN device.
- [ ] Webhook inbox works.
- [ ] PowerShell client works from Windows.
- [ ] No `.action_token` is committed.
- [ ] No logs, backups, or runtime status files are committed.
- [ ] Router has no WAN port forwarding to the phone.

## Explicit non-goals for public MVP

- No internet-facing deployment guide.
- No Docker route.
- No rooted Android route.
- No arbitrary command execution endpoint.

## Future public positioning

If validated successfully, this can be positioned as:

> A practical, non-rooted Android + Termux home-server starter kit for turning an old phone into a LAN-only automation node.
