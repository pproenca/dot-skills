---
name: dx-harness
description: Use this skill whenever the user mentions developer-experience friction, slow onboarding, repeated manual setup steps, missing bootstrap/reset/seed scripts, undiscoverable conventions, or asks to audit/fix/maintain a repository's dev harness. Triggers on phrases like "audit dx", "fix dev friction", "time to first commit", "set up the harness", "I keep doing X manually", "every time I reset the db I have to...", and on new-repo bootstrapping. Even if the user doesn't say "DX" — if they describe a repeated manual chore in their dev loop, this skill applies. The skill audits the repo, scores findings, scaffolds canonical fixes (bootstrap.sh, reset.sh, seed.sh, AGENTS.md, task-runner entries), then verifies the harness end-to-end in a scratch worktree against a 60-second time-to-first-commit target.
---

# DX Harness

Audits, scaffolds, and maintains the developer-experience harness of a repository. The harness is the meta-tooling that makes a dev loop fast: one-command bootstrap, one-command reset, one-command seed, discoverable conventions, agent-friendly entry points.

This skill exists because dev-experience attrition is real: harnesses rot, manual steps creep back in, conventions drift, and the cost is paid in micro-friction every day. The skill detects attrition systematically and applies canonical fixes.

## When to Apply

Trigger this skill when:

- A user describes a **repeated manual chore** ("every time I reset the db I have to re-register", "I always run these three commands before working")
- A user mentions **slow onboarding** or asks "how do I get this running"
- A new repo is being **bootstrapped** and needs a harness from day one
- A user explicitly asks to **audit DX** or **measure time-to-first-commit (TTFC)**
- A user asks to **fix** missing bootstrap/reset/seed scripts or AGENTS.md
- A periodic **maintenance pass** is needed (e.g., after a release, after onboarding a new engineer)

## Workflow Overview

```
┌────────────────────────────────────────────────────────────┐
│  1. DISCOVER     scripts/discover.sh → repo-fingerprint    │
│  2. AUDIT        scripts/audit.sh    → dx-audit.json       │
│  3. PRIORITIZE   scripts/prioritize.sh → ranked findings   │
│  4. SCAFFOLD     scripts/scaffold-*.sh → scratch dir       │
│  5. CONFIRM      show diff to user; user picks what to apply│
│  6. VERIFY       scripts/verify.sh → assertions + timing   │
│  7. TRACK        scripts/track-attrition.sh → audit log    │
└────────────────────────────────────────────────────────────┘
```

All scaffolded edits land in a scratch directory first (`${TMPDIR}/dx-harness-<timestamp>/`). The user reviews the diff and chooses what to copy back into the repo. No surprise writes to the working tree.

## Tool Requirements

Required: `bash`, `git`, `node`, `jq`.

Detected at runtime (the skill adapts — it never forces a migration):

| Toolchain | Detection signal |
|-----------|------------------|
| npm/pnpm/yarn/bun | `package.json`, `pnpm-lock.yaml`, `yarn.lock`, `bun.lockb` |
| cargo | `Cargo.toml` |
| go modules | `go.mod` |
| Python (uv/poetry/pip) | `pyproject.toml`, `uv.lock`, `poetry.lock`, `requirements.txt` |
| just | `Justfile` or `justfile` |
| make | `Makefile` |
| docker compose | `docker-compose.yml`, `compose.yaml` |
| database (postgres) | `docker-compose.yml` services, `DATABASE_URL` env reference |

## Risk Level

**Write.** The skill writes files but does not delete user data, force-push, or run destructive ops. Default mode stages everything in a scratch directory; the user explicitly approves each application. Verification runs in a separate git worktree so timing measurements never touch the working tree.

## Setup

On first invocation, the skill checks `config.json` and prompts via `AskUserQuestion` for any empty required fields. See [config.json](config.json) for fields and defaults.

Key defaults:
- `ttfc_target_seconds: 60` — the time-to-first-commit goal in seconds
- `apply_mode: "scratch"` — scaffolded edits go to scratch dir first; user copies in
- `audit_log_path: "${CLAUDE_PLUGIN_DATA}/dx-harness/audits.log"` — persistent attrition history

## Quick Reference

### Run a full audit + scaffold pass
```bash
bash scripts/discover.sh > /tmp/fingerprint.json
bash scripts/audit.sh /tmp/fingerprint.json > /tmp/audit.json
bash scripts/prioritize.sh /tmp/audit.json
```

### Scaffold one specific harness piece
```bash
bash scripts/scaffold-bootstrap.sh   /tmp/fingerprint.json
bash scripts/scaffold-reset.sh       /tmp/fingerprint.json
bash scripts/scaffold-seed.sh        /tmp/fingerprint.json
bash scripts/scaffold-agents-md.sh   /tmp/fingerprint.json
bash scripts/scaffold-justfile.sh    /tmp/fingerprint.json
```

### Verify the harness works end-to-end
```bash
bash scripts/verify.sh
# runs bootstrap in a scratch worktree, times it, asserts TTFC < target
```

### Track attrition over time
```bash
bash scripts/track-attrition.sh /tmp/audit.json
# appends to audits.log, prints diff vs previous run
```

## How to Use

The workflow scripts produce JSON between steps so they compose. The agent should read [references/workflow.md](references/workflow.md) for full step-by-step orchestration, including error handling and when to stop and ask the user.

For deeper context:

| File | Read When |
|------|-----------|
| [references/workflow.md](references/workflow.md) | Executing the workflow (always start here) |
| [references/audit-checklist.md](references/audit-checklist.md) | Understanding what `audit.sh` checks and why |
| [references/fix-recipes.md](references/fix-recipes.md) | Choosing which scaffold script applies for a finding |
| [references/attrition-patterns.md](references/attrition-patterns.md) | Reading git history for DX-rot signals |

## Gotchas

See [gotchas.md](gotchas.md) — accumulated failure points discovered over time. Always append new ones rather than rewriting.

## Related Skills

- `dev-skill:*` — for creating new agent-friendly skills (often the *output* of an AGENTS.md scaffolding pass references skills)
- `bug-review` — pairs naturally: bad DX often surfaces as repeat bug categories
