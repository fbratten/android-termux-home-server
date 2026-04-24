## 5PP Checklist

- [ ] Clarify: change classified
- [ ] Scope: route confirmed
- [ ] Plan: dependencies/checkpoints listed
- [ ] Execute: minimal diff
- [ ] Verify: validation run or reason stated

## Validation

- [ ] Ran: `bash scripts/validate_local.sh`
- [ ] Result: pass / fail / not run
- [ ] Updated docs/VALIDATION.md if behavior changed

## Safety

- [ ] No `.action_token`
- [ ] No logs/runtime files
- [ ] No root/Docker/WAN drift
- [ ] No arbitrary command execution

## Summary

What changed:

Why:

Risk level: low / medium / high
