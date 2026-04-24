# Issue Labels and Agent Roles

This repository uses issue labels as the routing layer for human and agent contributors.

## Purpose

Labels help agents identify:

```text
Which role should act
Which files are likely affected
Which validation path is required
Whether scope expansion is allowed
```

## Role labels

| Label | Agent role | Primary responsibility |
|---|---|---|
| `role:validation` | Validation Agent | Run/interpret validation and report failures |
| `role:runtime` | Runtime Agent | Fix proven runtime failures in app code |
| `role:installer` | Installer Agent | Fix install, rebuild, service, and Termux setup issues |
| `role:docs` | Documentation Agent | Clarify documentation and keep docs aligned |
| `role:release-gate` | Release Gate Agent | Maintain release state and public/private decision |

## Work-type labels

| Label | Meaning |
|---|---|
| `validation` | Validation work or validation failure |
| `release-gate` | Blocks or informs release decision |
| `hardening` | Reliability, safety, or operational strengthening |
| `documentation` | Documentation-only change |
| `bug` | Confirmed defect |
| `needs-triage` | Requires classification before action |

## Agent routing rules

### Validation issue

Use:

```text
role:validation
validation
```

Agent should:

```text
Run docs/VALIDATION.md and/or scripts/validate_local.sh
Report exact failing step
Create follow-up issue if needed
```

### Runtime failure

Use:

```text
role:runtime
bug
validation
```

Agent should:

```text
Fix only the proven failing behavior
Update validation if behavior changes
Avoid unrelated refactors
```

### Installer failure

Use:

```text
role:installer
bug
validation
```

Agent should:

```text
Fix Termux install/rebuild/service behavior
Keep non-rooted route intact
Avoid new dependency unless approved
```

### Documentation clarification

Use:

```text
role:docs
documentation
```

Agent should:

```text
Clarify only
Do not describe unsupported features
Preserve LAN-only/non-rooted boundaries
```

### Release decision

Use:

```text
role:release-gate
release-gate
```

Agent should:

```text
Check validation status
Update docs/RELEASE_DECISION.md
Keep repo private until validation passes
```

## Required 5PP issue triage block

Every issue intended for agent work should include:

```text
5PP classification:
- Clarify:
- Scope:
- Plan:
- Execute:
- Verify:

Suggested role:
Suggested labels:
Validation impact:
```

## Collision prevention

If an issue has more than one role label:

```text
1. Validation Agent acts first unless issue is documentation-only.
2. Runtime/Installer Agent acts only after failure is confirmed.
3. Release Gate Agent acts last.
```

## Current phase lock

Current phase:

```text
Phase 1: On-device validation
```

Allowed labels during this phase:

```text
role:validation
role:runtime
role:installer
role:docs
role:release-gate
validation
bug
documentation
hardening
release-gate
needs-triage
```

Avoid labels implying feature expansion until validation is complete.
