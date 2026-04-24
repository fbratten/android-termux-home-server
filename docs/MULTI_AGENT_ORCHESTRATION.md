# Multi-Agent Orchestration

This document defines how multiple agents may work on this repository without conflict or scope drift.

## Current project phase

```text
Phase 1: On-device validation
```

Active rule:

```text
Validation only. No feature expansion.
```

## Mandatory protocol

All agents MUST follow 5PP:

```text
Clarify → Scope → Plan → Execute → Verify
```

Reference:

```text
https://fbratten.github.io/From-Blueprint-to-Application/demos/five-point-protocol/
```

## Agent roles

Use role separation to avoid collision.

### 1. Validation Agent

Purpose:

- Run or interpret `docs/VALIDATION.md`
- Run or interpret `scripts/validate_local.sh`
- Report failures as issues

Allowed files:

```text
docs/VALIDATION.md
scripts/validate_local.sh
.github/ISSUE_TEMPLATE/validation-failure.md
```

Not allowed:

- Add features
- Change runtime behavior unless fixing a validation failure

### 2. Runtime Agent

Purpose:

- Fix proven runtime failures in app code
- Keep changes minimal

Allowed files:

```text
app/main.py
app/collect_status.py
app/healthcheck.py
app/actions/
```

Rules:

- Must link change to validation failure
- Must update validation if behavior changes

### 3. Installer Agent

Purpose:

- Improve install/rebuild reliability
- Fix Termux setup failures

Allowed files:

```text
scripts/install_or_rebuild.sh
scripts/diagnose.sh
scripts/validate_local.sh
docs/ANDROID_SETUP.md
```

Rules:

- No new dependency without issue approval
- No root/Docker path

### 4. Documentation Agent

Purpose:

- Improve clarity
- Align docs with actual behavior
- Maintain source-of-truth consistency

Allowed files:

```text
README.md
docs/
AGENTS.md
CONTRIBUTING.md
```

Rules:

- May not document unsupported features
- Must preserve LAN-only/non-rooted boundaries

### 5. Release Gate Agent

Purpose:

- Check readiness for public release
- Maintain release decision status

Allowed files:

```text
docs/RELEASE_DECISION.md
docs/ROADMAP.md
issues / release notes
```

Rules:

- Repository stays private until validation passes
- Any failed validation item must become a tracked issue

## Collision rules

Agents must not work on the same file at the same time unless explicitly coordinated.

Preferred assignment pattern:

```text
One agent → one issue → one route → one minimal diff
```

If two agents need the same file:

```text
1. Stop
2. Declare file conflict
3. Pick one owner
4. Other agent waits or switches to docs/validation
```

## Required agent handoff format

Every agent must finish with:

```text
Role:
5PP phase completed:
Files changed:
Validation command:
Validation result:
Open risks:
Next exact step:
Related issue:
```

## Work queue pattern

Use issues as the work queue.

```text
Issue → assigned role → branch/commit → validation → handoff → close or follow-up
```

## Branch naming suggestion

```text
agent/<role>/<issue-number>-short-description
```

Examples:

```text
agent/validation/2-run-device-checks
agent/installer/3-fix-termux-api-check
agent/docs/4-clarify-battery-setup
```

## Prohibited multi-agent behavior

Agents must not:

- Race to edit the same file
- Expand scope without issue approval
- Mix root/Docker/WAN routes into MVP validation
- Bypass `CONTRIBUTING.md`
- Skip 5PP
- Claim validation passed without command output or stated reason

## Recommended orchestration modes

### Sequential mode

Best for current phase.

```text
Validation Agent
→ identifies failure
→ Runtime/Installer Agent fixes one issue
→ Validation Agent re-runs checks
→ Release Gate Agent updates status
```

### Parallel mode

Allowed only when file ownership does not overlap.

Example:

```text
Validation Agent → runs checklist
Documentation Agent → clarifies docs
Installer Agent → fixes installer issue
```

Parallel mode is not allowed for broad refactors.

## Release gate

Before public release:

```text
Validation Agent: pass
Installer Agent: pass
Documentation Agent: pass
Release Gate Agent: approve
```

If any role reports failure:

```text
Do not publish.
Create follow-up issue.
Keep repository private.
```
