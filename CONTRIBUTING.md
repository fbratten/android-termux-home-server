# Contributing (Pre-Publication + Agent-Friendly)

This repository is currently **private** and in **validation phase**.

This document applies to:
- Human contributors
- AI / agent contributors (LLMs, copilots, automation)

---

## Core principles

```text
Stability > features
Validation > expansion
Safety > convenience
Atomic > complex
5PP > ad-hoc execution
```

---

## Mandatory protocol: 5PP

All project work MUST follow the **Five-Point Protocol (5PP)**.

Reference:

```text
https://fbratten.github.io/From-Blueprint-to-Application/demos/five-point-protocol/
```

Operational form for this repository:

```text
1. Clarify
   → Extract and classify the requested change.

2. Scope
   → Separate independent routes and reject incompatible merges.

3. Plan
   → Build the dependency path and identify checkpoints.

4. Execute
   → Make the smallest safe implementation.

5. Verify
   → Validate constraints, risks, and completeness.
```

A contribution that skips 5PP is incomplete.

---

## Agent-compatible contribution contract

All contributors MUST follow:

### 1. No assumption without classification

Before making changes:

```text
Type: core / optional / experimental
Impact: runtime / installer / docs / security
Risk: low / medium / high
5PP phase: Clarify / Scope / Plan / Execute / Verify
```

---

### 2. No phase skipping

Current project phase:

```text
Phase 1 → Validation (ACTIVE)
```

Rules:

❌ Do NOT add features
✅ Only fix, validate, clarify

5PP rule:

```text
No Execute without Clarify + Scope + Plan.
No final output without Verify.
```

---

### 3. No scope expansion without issue

Required flow:

```text
Open issue
→ describe change
→ classify scope
→ map to 5PP phase
→ wait for approval
```

---

### 4. Hard safety rules (non-negotiable)

DO NOT:

- Commit `.action_token`
- Add arbitrary command execution
- Add WAN exposure guidance
- Require root access
- Introduce Docker as requirement

---

### 5. Atomic changes only

Each change must:

```text
Solve one problem
Touch minimal files
Be reversible
Be explainable
Pass verification
```

---

### 6. Structure compliance

Respect repo layout:

```text
app/        → runtime
app/actions → execution layer
scripts/    → install/diagnostics
clients/    → external clients
docs/       → source of truth
```

---

### 7. Validation coupling (critical)

If behavior changes:

```text
Update docs/VALIDATION.md
OR
Add validation step
OR
Update scripts/validate_local.sh
```

No validation → change is incomplete

---

## Agent execution pattern

Required flow:

```text
1. Clarify
2. Scope
3. Plan
4. Execute (minimal)
5. Verify against validation
```

---

## Good contributions (now)

- Fix installer edge cases
- Improve diagnostics
- Improve documentation clarity
- Extend validation steps
- Fix Termux-specific issues

---

## Defer these

- UI frameworks
- Internet exposure
- Dockerization
- Root optimizations
- Large refactors

---

## Attribution

Contributors in this phase:

→ Added to AUTHORS.md after validation completes

---

## Summary

```text
Do not expand the system
→ prove the system first

Do not improvise execution
→ follow 5PP
```
