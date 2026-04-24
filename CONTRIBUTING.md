# Contributing (Pre-Publication)

This repository is currently **private** and in **pre-publication validation**.

Contributions are welcome in a controlled manner while we validate the MVP on a real Android device.

## Current phase

- Phase: **On-device validation** (see `docs/ROADMAP.md`)
- Gate: **Issue #2 — validation must pass before public release**

## Contribution rules (pre-public)

1. **Do not break the MVP path**
   - Keep changes compatible with:
     - Non-rooted Android
     - Termux-only environment
     - LAN-only model

2. **No scope expansion without issue**
   - Open an issue before adding:
     - New services
     - New endpoints
     - New dependencies

3. **No security regressions**
   - Do NOT:
     - Commit `.action_token`
     - Add arbitrary command execution
     - Introduce WAN exposure guidance

4. **Prefer atomic changes**
   - Small, reviewable commits
   - One concern per change

5. **Follow existing structure**

```text
app/        → runtime code
actions/    → whitelisted scripts
scripts/    → install/diagnostics
clients/    → external clients
docs/       → documentation
```

## Contribution workflow

1. Open an issue describing the change
2. Link it to the roadmap phase if relevant
3. Keep PR focused and minimal
4. Validate locally where possible
5. Update documentation if behavior changes

## Validation impact

If your change affects behavior:

- Update `docs/VALIDATION.md`
- Or add a new validation step

## Examples of good contributions now

- Improve installer robustness
- Fix Termux-specific edge cases
- Improve diagnostics output
- Clarify documentation
- Add missing validation steps

## Examples of changes to defer

- Public internet deployment guides
- Dockerization
- Root-based optimizations
- Full UI frameworks

## Attribution

Contributors during this phase will be added to `AUTHORS.md` once the project moves to public release.

## Summary

```text
Stability > features
Validation > expansion
Safety > convenience
```
