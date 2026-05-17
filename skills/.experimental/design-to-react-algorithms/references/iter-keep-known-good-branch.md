---
title: Maintain a Known-Good Baseline Branch
impact: HIGH
impactDescription: enables instant rollback in 1 command vs hand-reconstructing the last-known-good state; cuts triage time by ~10x
tags: iter, baseline, rollback, branching-strategy
---

## Maintain a Known-Good Baseline Branch

Keep a `baseline` branch that contains only conversion states that have passed the full snapshot gate. When `main` regresses, you can `git diff baseline..main` to see exactly which converter change caused it, and instantly `git checkout baseline -- src/generated/` to roll back the generated tree without losing hand-written work. Without this branch, "known good" is a tribal memory and every regression triage starts from scratch.

**Incorrect (single branch, no rollback target):**

```bash
# Every conversion run overwrites main.
git checkout main
yarn convert-sketch app.sketch
yarn test:visual    # fails
# Now what? The previous good state is gone. Re-run the converter
# with old code? Pick through git log to find the last green commit?
```

**Correct (baseline branch as the ratchet):**

```bash
# baseline branch only advances when the snapshot gate is green.
git checkout main
yarn convert-sketch app.sketch
yarn test:visual

if [[ $? -eq 0 ]]; then
  # Green: advance the baseline branch.
  git tag "baseline-$(date +%Y%m%d-%H%M%S)"
  git branch -f baseline HEAD
else
  # Red: diff against baseline to find the regression locus.
  git diff baseline..HEAD -- src/generated/ | less
  # And if the converter itself broke, roll back just the generated tree:
  git checkout baseline -- src/generated/
fi
```

**Three-way regression triage:** when a regression appears, you have three sources of truth:
1. `baseline` — last known-good React tree
2. `HEAD` — current (broken) React tree
3. `app.sketch` — current design source

Compare baseline↔HEAD to find the offending code change; compare baseline-snapshot↔HEAD-snapshot to find the offending pixel region. The two together localize the bug to one converter rule.

Reference: [Pro Git — Branching Strategies](https://git-scm.com/book/en/v2/Git-Branching-Branching-Workflows)
