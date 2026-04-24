# Android Setup Notes

This document captures the Android-specific setup checks that matter most for a non-rooted Termux home server.

## 1. Install source

Install Termux and companion apps from trusted current sources:

- Termux
- Termux:API
- Termux:Boot, optional but recommended for startup after reboot

Avoid the old Play Store Termux package because it is commonly outdated.

## 2. Required Termux packages

The installer installs these packages:

```bash
pkg install -y openssh python nano curl termux-services termux-api
```

Purpose:

| Package | Purpose |
|---|---|
| `openssh` | SSH access on port `8022` |
| `python` | FastAPI app and helper scripts |
| `curl` | Local endpoint verification |
| `termux-services` | `runit` service supervision |
| `termux-api` | Access to Android-side API commands such as battery status |

## 3. Storage permission

Run once if file access outside the Termux home directory is needed:

```bash
termux-setup-storage
```

This project primarily runs inside the Termux home directory, so storage permission is useful but not always mandatory for the MVP.

## 4. Battery and background settings

Android may stop background processes to save power. For a reliable always-on server:

- Set Termux battery usage to unrestricted.
- Set Termux:Boot battery usage to unrestricted.
- Disable aggressive battery saver modes for this device.
- Keep the phone ventilated while charging.
- Avoid placing the phone in direct sun or enclosed wall boxes.

Recommended Android path, wording may vary by device/vendor:

```text
Settings → Apps → Termux → Battery → Unrestricted
Settings → Apps → Termux:Boot → Battery → Unrestricted
```

## 5. Wake lock

The boot script runs:

```bash
termux-wake-lock
```

Manual test:

```bash
termux-wake-lock
```

Release manually if needed:

```bash
termux-wake-unlock
```

## 6. Boot startup

The installer creates:

```text
~/.termux/boot/start-services
```

Expected content starts these services:

```bash
sv up sshd
sv up phone-api
sv up status-collector
sv up phone-watchdog
```

After installing Termux:Boot, open the Termux:Boot app once if required by Android so it can register startup behavior.

## 7. Service verification

```bash
sv status sshd
sv status phone-api
sv status status-collector
sv status phone-watchdog
```

Expected: each service should show `run:`.

## 8. Termux:API verification

```bash
termux-battery-status
```

Expected: JSON describing battery percentage, status, health, and temperature.

If this fails:

- Confirm the Termux:API Android app is installed.
- Confirm `pkg install termux-api` was run inside Termux.
- Reopen Termux and try again.

## 9. Charging safety

For long-running use:

- Prefer a lower-wattage charger.
- Avoid heat buildup.
- Periodically inspect the phone for battery swelling.
- Do not run the device under a pillow, in a sealed case, or in a hot window.

## 10. MVP non-goals

This route intentionally avoids:

- Rooting the device
- Custom ROM requirements
- Docker
- Public internet exposure
- Arbitrary remote shell command endpoints
