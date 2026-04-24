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
```

---

## Agent-compatible contribution contract

All contributors MUST follow:

### 1. No assumption without classification

Before making changes:

```text
Type: core / optional / experimental
Impact: runtime / installer / docs / security
Risk: low / medium / high
```

---

### 2. No phase skipping

Current phase:

```text
Phase 1 → Validation (ACTIVE)
```

Rules:

❌ Do NOT add features
✅ Only fix, validate, clarify

---

### 3. No scope expansion without issue

Required flow:

```text
Open issue
→ describe change
→ classify scope
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
```

No validation → change is incomplete

---

## Agent execution pattern

Recommended flow:

```text
1. Clarify
2. Scope
3. Constrain
4. Implement (minimal)
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
```
