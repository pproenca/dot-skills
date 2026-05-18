---
title: Rank Files by Bug-Fix Density to Find Defect Magnets
impact: MEDIUM-HIGH
impactDescription: identifies files where 50%+ of commits are bug fixes
tags: mine, bug-fix, defect-prediction, commit-classification, fix-density
---

## Rank Files by Bug-Fix Density to Find Defect Magnets

A "defect magnet" is a file where most of the recent commits are bug fixes, not features. The signal is direct: classify each commit as bug-fix vs non-bug-fix using commit-message regex (`fix`, `bug`, ticket prefixes), then compute per-file fix density = bug-fix-commits / total-commits over the last year. Files above 50% are defect magnets — they're the ones the team keeps patching. They almost always also score high on `mine-hotspots-churn-complexity`, but density adds the extra signal that the *content* of the changes is reactive. They're rewrite candidates, not refactor candidates.

**Incorrect (count all commits as equal — misses the reactive vs proactive distinction):**

```python
# All commits look the same: feature work and emergency fixes
# both increment the counter. A file with 30 commits that are
# all features looks identical to a file with 30 commits that
# are all firefighting.
import subprocess, pathlib, collections

counts = collections.Counter()
for p in pathlib.Path("src").rglob("*.py"):
    out = subprocess.check_output([
        "git", "log", "--since=12 months ago", "--oneline", "--follow", "--", str(p),
    ]).decode()
    counts[str(p)] = len([l for l in out.splitlines() if l.strip()])
# Pure activity ranking — no signal about *why* the files changed so much.
```

**Correct (classify commits, compute per-file fix density, surface defect magnets):**

```python
import subprocess, re, collections, pathlib

# Bug-fix message classifier. Tune per repo's conventions.
FIX_RE = re.compile(
    r"\b(fix(es|ed|ing)?|bug|hotfix|patch|defect|regression|broken|crash|err"
    r"|incident|inc-\d+|prod\b)\b",
    re.I,
)
TICKET_RE = re.compile(r"\b(?:bug|issue|incident|sev[0-9])[-/]?\d+\b", re.I)

def is_fix(msg: str) -> bool:
    return bool(FIX_RE.search(msg) or TICKET_RE.search(msg))

# 1. Per-file commit log with messages
def per_file_commits(path: str) -> list[str]:
    out = subprocess.check_output([
        "git", "log", "--since=12 months ago", "--follow",
        "--pretty=format:%s %b", "--", path,
    ]).decode(errors="ignore")
    return [line for line in out.split("\n") if line.strip()]

# 2. Score every file
results = []
for p in pathlib.Path("src").rglob("*.py"):
    msgs = per_file_commits(str(p))
    if len(msgs) < 5: continue                  # ignore low-activity files
    fixes = sum(1 for m in msgs if is_fix(m))
    density = fixes / len(msgs)
    results.append({
        "path": str(p),
        "n_commits": len(msgs),
        "n_fixes": fixes,
        "fix_density": density,
        "score": fixes * density,               # absolute fix count × density
    })

# 3. Defect magnets: density > 0.5 AND fixes >= 5
magnets = [r for r in results if r["fix_density"] > 0.50 and r["n_fixes"] >= 5]
magnets.sort(key=lambda r: -r["score"])
for r in magnets[:15]:
    print(f"  fix_density={r['fix_density']:.0%}  fixes={r['n_fixes']:>2}/{r['n_commits']:>2}  {r['path']}")
# fix_density=78%  fixes=14/18  src/integrations/legacy_sync.py
# fix_density=71%  fixes=10/14  src/payments/reconciliation.py
# fix_density=65%  fixes=11/17  src/billing/proration.py
```

**Tune the FIX_RE regex per team conventions.** If your team uses Conventional Commits (`fix:`, `feat:`, etc.) the classifier becomes trivial and far more reliable. If commit messages are unstructured, calibrate by manually labeling 100 commits and adjusting the regex until precision > 0.85.

**Train a classifier for better precision.** A small fastText / logistic-regression model on labeled commit messages (200 examples is enough) outperforms regex by 10-20% in F1 — especially on noisy messages like "wip" or "address review feedback". Worth doing if you'll run this monthly.

**Combine with `mine-change-coupling`:** when a defect magnet has high coupling to a clean file, the clean file is hiding the defect that the magnet keeps absorbing. Rewriting only the magnet rarely fixes the underlying problem; investigate the coupled partner too.

**Combine with `mine-hotspots-churn-complexity`:** a file in the top decile of BOTH hotspots and fix density is a rewrite candidate. Refactoring won't help — the design is wrong.

**When NOT to apply:**
- Repos with rebase-and-squash workflow where fix commits get rolled into feature commits — fix density is artificially low; mine *original* PR commits instead
- Recently-rewritten files — they will look like defect magnets transiently while bugs in the rewrite stabilize; require ≥ 9-month window

Reference: [Mockus & Votta, Identifying reasons for software changes using historic databases (ICSM 2000)](https://ieeexplore.ieee.org/document/883024), [Tornhill, Software Design X-Rays (Chapter 4)](https://pragprog.com/titles/atevol/software-design-x-rays/)
