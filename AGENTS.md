# AGENTS.md

Canonical operating instructions for AI / coding agents working on this repository.

## Project mission

Build and validate a practical, non-rooted Android + Termux LAN-only home server starter kit.

## Current phase

```text
Phase 1: On-device validation
```

Active rule:

```text
Validation only. No feature expansion.
```

## Mandatory protocol: 5PP

All agent work MUST follow the Five-Point Protocol.

Reference:

```text
https://fbratten.github.io/From-Blueprint-to-Application/demos/five-point-protocol/
```

Operational form:

```text
1. Clarify
2. Scope
3. Plan
4. Execute
5. Verify
```

No phase skipping.

## Required read order

Before making changes, agents MUST read:

```text
README.md
CONTRIBUTING.md
docs/ROADMAP.md
docs/VALIDATION.md
docs/RELEASE_DECISION.md
AGENTS.md
```

## Allowed work in current phase

Allowed:

- Fix validation failures
- Improve diagnostics
- Clarify documentation
- Add missing validation coverage
- Fix Termux-specific setup issues

Not allowed:

- New product features
- Rooted Android route
- Docker route
- Public internet deployment route
- Arbitrary command execution endpoint
- Large refactors

## Route boundaries

The active implementation route is:

```text
Non-rooted Android
→ Termux
→ LAN-only FastAPI node
→ token-protected actions/webhooks
```

Do not merge this route with:

- Docker
- chroot/root Linux
- custom ROM requirements
- WAN exposure

## File ownership map

```text
app/                 Runtime app and Python service scripts
app/actions/         Whitelisted action scripts only
scripts/             Install, validation, and diagnostics scripts
clients/             External clients, currently PowerShell
docs/                Source-of-truth documentation
.github/             Repo workflow templates
```

## Validation requirements

Before completion, agents MUST report:

```text
Validation run: passed / failed / not run
Command used: <command>
Reason if not run: <reason>
```

Preferred command:

```bash
bash scripts/validate_local.sh
```

If behavior changes, update at least one of:

```text
docs/VALIDATION.md
scripts/validate_local.sh
docs/DRY_RUN_EXECUTION.md
```

## Assumption classification

All uncertain claims must be classified as:

```text
confirmed
assumed
needs validation
blocked
```

No silent assumptions.

## Commit / PR expectations

Every change should be:

```text
small
atomic
reversible
validated
```

PRs must explain:

```text
Clarify: what changed
Scope: which route/files are affected
Plan: dependency/checkpoint logic
Execute: files changed
Verify: validation result
```

## Failure handoff format

If work is incomplete, leave:

```text
Current state:
Next exact command:
Known failure:
Related file:
Related issue:
Validation status:
```

## Security invariants

Never commit:

```text
app/.action_token
app/.venv/
app/logs/
app/status.json
app/backups/
```

Never add:

```text
WAN exposure guidance
arbitrary shell command endpoint
root requirement
Docker requirement
```

## Final response rule for agents

Before finalizing, state:

```text
Files changed:
Validation status:
Remaining risks:
Next recommended step:
```
