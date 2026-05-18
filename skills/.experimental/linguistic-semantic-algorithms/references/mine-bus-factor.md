---
title: Compute Per-File Bus Factor from Authorship Concentration
impact: MEDIUM-HIGH
impactDescription: prevents key-person dependencies from surprising the team mid-incident
tags: mine, bus-factor, authorship, knowledge-risk, git-blame
---

## Compute Per-File Bus Factor from Authorship Concentration

The "bus factor" of a file is the number of authors whose departure would leave nobody on the team who still knows how it works. It's traditionally estimated by intuition, badly. The algorithmic answer is to compute per-author share of lines authored over the last N months — if a single author owns >75% of a file's lines, the bus factor of that file is 1. Aggregated to the directory or module level, this produces a heat map of "if you lost author X, here's what stops working". Run this once a quarter. Pair high-bus-factor files with high-churn files — those are the files to pair-program on *now*.

**Incorrect (eyeball `git shortlog` per file — slow, inconsistent, ranks by commit count not LoC):**

```bash
# Manually: for each file, who has the most commits?
# Commit count is a poor proxy — one commit can add 500 lines,
# another fixes a typo. Equating them misrepresents knowledge.
for f in $(find src -name "*.py"); do
    echo "=== $f ==="
    git shortlog -sn -- "$f" | head -3
done
# Inconsistent, hard to aggregate, hours for a single repo.
```

**Correct (line-attribution via git blame + Gini coefficient on authorship):**

```python
import subprocess, collections, pathlib
from typing import Iterable

def blame_authors(path: str) -> collections.Counter:
    """Lines authored per email for this file at HEAD."""
    out = subprocess.check_output(
        ["git", "blame", "-w", "--line-porcelain", path],
        stderr=subprocess.DEVNULL,
    ).decode(errors="ignore")
    counts: collections.Counter = collections.Counter()
    for line in out.splitlines():
        if line.startswith("author-mail "):
            counts[line.split(" ", 1)[1].strip("<>")] += 1
    return counts

def gini(values: Iterable[int]) -> float:
    """Inequality measure — 0 = perfect spread, 1 = single author."""
    sorted_vals = sorted(values)
    n = len(sorted_vals)
    if n == 0 or sum(sorted_vals) == 0: return 0.0
    cum = 0.0
    for i, v in enumerate(sorted_vals, 1):
        cum += i * v
    return (2 * cum) / (n * sum(sorted_vals)) - (n + 1) / n

risk = []
for p in pathlib.Path("src").rglob("*.py"):
    authors = blame_authors(str(p))
    if not authors: continue
    total = sum(authors.values())
    top_share = authors.most_common(1)[0][1] / total
    g = gini(authors.values())
    risk.append({
        "path": str(p),
        "lines": total,
        "n_authors": len(authors),
        "top_share": top_share,
        "gini": g,
        "bus_factor": 1 if top_share > 0.75 else (2 if top_share > 0.50 else 3),
    })

# Rank by lines-at-risk if the top author leaves
risk.sort(key=lambda r: -(r["top_share"] * r["lines"]))
for r in risk[:15]:
    print(f"  bf={r['bus_factor']}  top={r['top_share']:.0%}  lines={r['lines']:>4}  {r['path']}")
# bf=1  top=92%  lines=1240  src/payments/reconciliation.py
# bf=1  top=88%  lines=820   src/billing/invoice_generator.py
# bf=1  top=85%  lines=710   src/integrations/stripe/client.py
```

**Filter authors who have left the company.** A 92%-share by someone who left 2 years ago means bus factor 0, not 1. Cross-reference against your HR feed or maintain a `.former-employees` list.

**Aggregate to module level too.** A directory where every file has bus-factor 1 to a *different* person has aggregate bus-factor 1 too — losing any of those people loses parts of the module. Compute Gini of authorship across the module.

**Combine with `mine-hotspots-churn-complexity`:** a file that is bus-factor-1 AND a hotspot is the codebase's single highest risk. Pair-program on it this quarter, regardless of whether anyone is "available". Code Maat's `knowledge-loss` analysis automates this combination.

**This is industry-standard at large companies.** Microsoft Research has published several papers using these exact metrics ([Bird et al.](https://www.microsoft.com/en-us/research/publication/dont-touch-my-code-examining-the-effects-of-ownership-on-software-quality/)) — high author concentration correlates with defect rate in their data.

**When NOT to apply:**
- Repos following strict code-review with broad reviewer pools — blame may not reflect knowledge ownership; weight by reviewer history too
- Recently-restructured repos — git blame can attribute lines to a refactor commit and obscure real authorship; use `git log --follow --patch -S<line>` for spot checks

Reference: [Bird et al., Don't Touch My Code (FSE 2011)](https://www.microsoft.com/en-us/research/publication/dont-touch-my-code-examining-the-effects-of-ownership-on-software-quality/), [Avelino et al., A Novel Approach for Estimating Truck Factors (ICPC 2016)](https://homepages.dcc.ufmg.br/~mtov/pub/2016_icpc_truckfactor.pdf)
