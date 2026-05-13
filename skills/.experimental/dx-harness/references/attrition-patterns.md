# Attrition Patterns

DX rot leaves fingerprints in git history. This document lists the patterns `scripts/audit.sh` scans for, and what each pattern usually means.

These patterns are heuristic — they surface candidates, not verdicts. The skill always presents the matched commits to the user before treating them as findings.

## Pattern Catalog

### "again" / "every time" / "always"

**Grep:** `git log --all --oneline -i -E "(again|every time|always need|i always)"`

**What it usually means:** a manual chore the dev has done multiple times and is annoyed about. The commit message itself is often the venting.

**Mapped fix recipe:** depends on what the commit touched. The audit reads the commit's files and matches:
- DB schema / migration → `scaffold-seed` or `scaffold-reset`
- env / dotfiles → `scaffold-bootstrap`
- README → `scaffold-agents-md`

---

### "manual" / "by hand"

**Grep:** `git log --all --oneline -i -E "(manual(ly)?|by hand|hand-run)"`

**What it usually means:** a step that should be in a script but isn't.

**Mapped fix recipe:** open the commit, see what was being done manually, route to the matching scaffold recipe.

---

### "re-seed" / "reset db" / "wipe db"

**Grep:** `git log --all --oneline -i -E "(re-seed|reseed|reset.{0,5}db|wipe.{0,5}db|drop.{0,5}db)"`

**What it usually means:** dev had to interact with the database directly to recover state. Strong signal `seed.sh` / `reset.sh` are missing or broken.

**Mapped fix recipe:** `scaffold-reset` + `scaffold-seed`.

---

### "register again" / "re-login" / "test user"

**Grep:** `git log --all --oneline -i -E "(register again|re-?login|re-?register|test user|create.{0,10}account|signup)"`

**What it usually means:** the user's specific example — every reset wipes the user account so they have to re-register. The fix is a seeded test user.

**Mapped fix recipe:** `scaffold-seed` (with explicit credentialed test user).

---

### "wip: setup" / "fix: bootstrap" / "fix: getting started"

**Grep:** `git log --all --oneline -i -E "(wip.{0,5}setup|fix.{0,5}bootstrap|getting.{0,5}started|onboard)"`

**What it usually means:** repeated fixes to the setup process. Even if each fix is small, frequency means the harness is fragile.

**Mapped fix recipe:** `scaffold-bootstrap` (regenerate with idempotency + offline-friendly defaults).

---

### "flaky" / "retry" / "intermittent"

**Grep:** `git log --all --oneline -i -E "(flaky|retry|intermittent|sometimes fails)"`

**What it usually means:** tests or harness steps that aren't deterministic. This isn't a DX harness fix exactly — it's a code-fix — but it's worth surfacing because flaky tests destroy trust in the dev loop.

**Mapped fix recipe:** `manual` (the skill doesn't fix flakes; it just notes them).

---

### "TODO" / "HACK" near the dev loop

**Grep over files (not commits):** `grep -rE "(TODO|HACK|FIXME).*(bootstrap|setup|seed|reset|test)" {scripts,Justfile,Makefile,package.json,docs/} 2>/dev/null`

**What it usually means:** known harness debt left in comments. Counts toward attrition score.

**Mapped fix recipe:** depends on TODO content.

---

## Time-Window Scope

The audit defaults to scanning the **last 200 commits or 90 days, whichever is smaller**. Wider scans are noisy; narrower miss patterns. The user can override via:

```bash
DX_HARNESS_HISTORY_DAYS=180 bash scripts/audit.sh ...
DX_HARNESS_HISTORY_COMMITS=500 bash scripts/audit.sh ...
```

## What's NOT in the catalog

Patterns we considered but excluded:

- **"sorry, my bad"** — too generic; doesn't isolate DX.
- **"oops"** — same.
- **"final final v2"** — file/versioning hygiene issue, not DX harness.
- **"build failed"** — that's a CI issue; the audit's `ci-status` check covers it separately.

The catalog stays focused on signals that map cleanly to harness-level fixes. Patterns that surface generic frustration but don't have a clean fix recipe go in [gotchas.md](../gotchas.md) instead, where the user can capture them with context.

## Trend Analysis

`scripts/track-attrition.sh` reads the audit log and tracks attrition over time:

- **Recurrence count**: same pattern appearing in N consecutive audits → severity bump
- **TTFC drift**: TTFC trending up over recent audits → P1 even if still under target
- **Score-of-scores**: total normalized score over time → headline "is the dev loop getting better or worse"

The trend output is short — three lines max — because trend-fatigue is itself an attrition pattern.
