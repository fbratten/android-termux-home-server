# Networking and LAN Safety

This project is designed as a local LAN utility node. Do not expose it directly to the public internet.

## 1. Stable phone IP

Reserve a fixed DHCP lease in your router.

Typical flow:

```text
Router admin UI
→ Connected devices / LAN clients
→ Find Android phone
→ Copy MAC address
→ Add DHCP reservation
→ Assign stable IP, for example 192.168.1.50
```

Then use that stable IP in the dashboard URL:

```text
http://192.168.1.50:8080/dashboard
```

And in the PowerShell client:

```powershell
.\clients\AndroidServerClient.ps1 -Mode Health -PhoneIp "192.168.1.50"
```

## 2. Ports

| Port | Purpose | Scope |
|---:|---|---|
| `8022` | Termux SSH | LAN-only |
| `8080` | FastAPI dashboard/API | LAN-only |

## 3. Router guidance

Recommended:

- Keep router firewall enabled.
- Do not create public port forwards to the phone.
- Do not expose port `8080` to WAN.
- Do not expose port `8022` to WAN.
- Use a DHCP reservation instead of hardcoding static IP on the phone.

## 4. Remote access alternatives

If remote access is needed later, prefer a private overlay network or VPN route rather than raw port forwarding.

Possible later routes:

- Tailscale
- WireGuard
- SSH through an existing trusted jump host

These are intentionally out of scope for the MVP.

## 5. Token model

The shared token protects action and webhook endpoints from casual LAN access.

Protected endpoints include:

```text
/actions
/actions/{name}
/webhook
/events
```

Unprotected endpoints include:

```text
/health
/info
/status
/dashboard
```

This is acceptable for a local MVP, but not sufficient for public internet exposure.

## 6. Negative safety checks

Before making the repository public or deploying on a real LAN, confirm:

- [ ] No `.action_token` is committed.
- [ ] No logs are committed.
- [ ] No backups are committed.
- [ ] Router has no WAN port forward to the phone.
- [ ] The action whitelist contains only safe scripts.
- [ ] No arbitrary command execution route exists.
