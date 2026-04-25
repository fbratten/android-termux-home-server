# Public Release Checklist

Use this checklist before changing the repository from private to public.

## Release rule

This repository may be made public as an **experimental public pre-release** if the public-facing documentation clearly states that the project is **not fully tested**.

Required public wording:

```text
Not fully tested on real Android hardware yet.
Experimental MVP / starter kit.
LAN-only. No internet-facing deployment guidance.
```

## 1. Public pre-release gate

Before switching public:

- [ ] README states that the project is not fully tested.
- [ ] README states LAN-only / no internet-facing deployment.
- [ ] README badge/status reflects public pre-release or experimental state.
- [ ] `docs/RELEASE_DECISION.md` says public pre-release is approved with limitations.
- [ ] `docs/PUBLIC_RELEASE_CHECKLIST.md` exists.
- [ ] `scripts/validate_local.sh` is a full validation runner, not a placeholder.
- [ ] No `.action_token` is committed.
- [ ] No logs, backups, or runtime status files are committed.
- [ ] No secrets, SSH keys, API keys, or `.env` files are committed.
- [ ] Router/WAN exposure is explicitly discouraged.
- [ ] GitHub security settings are reviewed or marked pending.

## 2. Recommended validation after public release

The repository can be public before full validation only if it remains clearly marked as not fully tested.

Still recommended:

- [ ] Issue #2 is completed or all failed validation steps have follow-up issues.
- [ ] `docs/VALIDATION.md` has been executed on a real non-rooted Android device.
- [ ] `bash scripts/validate_local.sh` exits with status code `0`.
- [ ] `bash scripts/diagnose.sh` passes or only reports accepted informational warnings.
- [ ] Termux:API works.
- [ ] Termux:Boot behavior has been checked after reboot.
- [ ] Dashboard works from another LAN device.
- [ ] Windows PowerShell client works, if used for the release claim.

## 3. Repository content safety

Confirm the repository does NOT contain:

- [ ] `app/.action_token`
- [ ] `*.token`
- [ ] `.env` or `.env.*`
- [ ] `app/.venv/`
- [ ] `app/logs/`
- [ ] `app/status.json`
- [ ] `app/collector.log`
- [ ] `app/backups/`
- [ ] `*.tar.gz`
- [ ] Real LAN IPs, private hostnames, or personal network details in docs/examples
- [ ] API keys, passwords, SSH keys, or access tokens

Suggested local scan:

```bash
git status --short
git ls-files | grep -E '(\.action_token|\.env|\.venv|logs/|status\.json|collector\.log|backups/|\.tar\.gz|id_rsa|id_ed25519|token|secret|password)'
```

Expected result: no sensitive tracked files.

## 4. Documentation readiness

- [ ] README clearly states LAN-only model.
- [ ] README clearly states no internet-facing deployment.
- [ ] README clearly states not fully tested.
- [ ] README links to validation, Android setup, networking, release decision, roadmap, and contribution docs.
- [ ] `docs/RELEASE_DECISION.md` is updated for public pre-release.
- [ ] `docs/ROADMAP.md` reflects actual current phase.
- [ ] `CONTRIBUTING.md` requires 5PP.
- [ ] `AGENTS.md` is present and current.
- [ ] `docs/MULTI_AGENT_ORCHESTRATION.md` is present and current.

## 5. Runtime safety review

Confirm the code does NOT include:

- [ ] Arbitrary shell command execution endpoint
- [ ] WAN exposure instructions
- [ ] Root requirement
- [ ] Docker requirement
- [ ] Hardcoded secret
- [ ] Hardcoded private IP specific to the maintainer

Confirm the action runner is still whitelist-only:

- [ ] Allowed actions are explicitly listed in `app/main.py`.
- [ ] Unknown actions are rejected.
- [ ] Token is required for `/actions`, `/webhook`, and `/events`.

## 6. GitHub UI repository settings

Before switching public, review GitHub UI settings.

### General

Go to:

```text
Repository → Settings → General
```

Check:

- [ ] Repository description is set.
- [ ] Website URL is blank or points to a safe project/showcase page.
- [ ] Features are intentional:
  - [ ] Issues enabled
  - [ ] Projects optional
  - [ ] Wiki disabled unless intentionally used
  - [ ] Discussions optional
- [ ] Default branch is `main`.
- [ ] Allow squash merge is enabled if preferred.
- [ ] Delete head branches after merge is enabled if available/preferred.

Suggested description:

```text
Experimental starter kit for turning an old non-rooted Android phone into a lightweight Termux-based LAN home server. Not fully tested yet.
```

Suggested topics:

```text
android
termux
home-server
homelab
fastapi
automation
lan
python
powershell
experimental
```

## 7. GitHub security settings

Go to:

```text
Repository → Settings → Code security and analysis
```

Enable where available:

- [ ] Dependency graph
- [ ] Dependabot alerts
- [ ] Dependabot security updates
- [ ] Secret scanning, if available for the repo/account
- [ ] Push protection, if available
- [ ] Private vulnerability reporting, if available after public release

Notes:

- Availability depends on repository visibility, account plan, and GitHub feature access.
- If a feature is unavailable, record that in `docs/RELEASE_DECISION.md`.

## 8. Branch protection / rulesets

Go to:

```text
Repository → Settings → Branches
```

Recommended for `main` after public release:

- [ ] Require pull request before merging.
- [ ] Require status checks if validation workflows are added.
- [ ] Require conversation resolution before merge.
- [ ] Restrict force pushes.
- [ ] Restrict deletions.

Minimum for early public MVP:

- [ ] No direct unreviewed changes to `main` once contributors are expected.

## 9. Actions permissions

Go to:

```text
Repository → Settings → Actions → General
```

Check:

- [ ] Actions are enabled intentionally.
- [ ] Workflow permissions are least-privilege where practical.
- [ ] `GITHUB_TOKEN` permissions are not broader than needed.
- [ ] Third-party actions are pinned or reviewed before trust-sensitive use.

Current workflows:

```text
.github/workflows/labeler.yml
.github/workflows/issue-triage.yml
```

Both are for labeling/triage, not deployment.

## 10. Labels and issue templates

- [ ] Labels exist or are created automatically when first applied.
- [ ] Role labels are documented in `docs/ISSUE_LABELS.md`.
- [ ] Issue templates are present.
- [ ] PR template is present.
- [ ] Agent task template is present.
- [ ] Validation failure template is present.

## 11. Visibility switch

Only after pre-release gates pass:

```text
Repository → Settings → General → Danger Zone → Change repository visibility → Public
```

After switching public:

- [ ] Re-check README rendering.
- [ ] Re-check badges.
- [ ] Re-check issues/templates.
- [ ] Re-check workflows.
- [ ] Re-check security settings that only appear for public repositories.
- [ ] Create a release note or tag if appropriate.

## 12. Post-public monitoring

First 24–72 hours:

- [ ] Watch issues.
- [ ] Watch Dependabot/security alerts.
- [ ] Watch workflow failures.
- [ ] Keep scope tight: validation/fixes only unless roadmap phase changes.

## Final go/no-go

```text
GO for public pre-release:
- README says not fully tested
- Secrets absent
- LAN-only/no internet exposure clear
- GitHub security settings reviewed or pending status recorded
- Release decision says public pre-release approved

NO-GO:
- Runtime token/log/status artifacts present
- Public exposure ambiguity exists
- Release decision still says private
- README implies production-ready status
```
