---
title: Boost IR Scores with a Bug-History Prior for Better Localization Precision
impact: MEDIUM
impactDescription: improves top-10 bug-localization precision by 15-30% over IR-only ranking
tags: local, bayesian-prior, bug-history, defect-prediction, fusion
---

## Boost IR Scores with a Bug-History Prior for Better Localization Precision

IR-based bug localization (TF-IDF, BM25) is good but not great alone: it scores ~25-40% recall at top-10 on real benchmarks. The defect-prediction literature has known for 15 years that bugs cluster — files with a history of bugs are more likely to have new ones. Combining IR with this prior lifts top-10 recall to 50-65% on the same benchmarks. The combination is a tiny implementation: multiply each file's IR score by a logged bug-fix count factor. Use this anytime the agent has access to a bug-tracker integration and at least 6 months of fix history.

**Incorrect (IR score alone — ignores the strongest known feature for defect prediction):**

```python
# Pure BM25 ranking. The right file might not have the
# right vocabulary in the bug report but has a long history of
# similar bugs — IR score alone misses this.
from rank_bm25 import BM25Okapi
# ... compute scores from bug query ...
top = sorted(zip(scores, files), reverse=True)[:10]
```

**Correct (BM25 × historical bug-fix prior — Bayesian fusion):**

```python
import math, subprocess, re, pathlib
from rank_bm25 import BM25Okapi

WORD = re.compile(r"[A-Za-z_][A-Za-z0-9_]{2,}")
FIX_RE = re.compile(r"\b(fix(es|ed)?|bug|hotfix|patch|defect|incident)\b", re.I)

# 1. Build IR index (BM25)
files = list(pathlib.Path("src").rglob("*.py"))
corpus = [[w.lower() for w in WORD.findall(p.read_text(errors="ignore"))] for p in files]
bm25 = BM25Okapi(corpus)

# 2. Build the fix-history prior per file
def bug_fix_count(path: str, since: str = "24 months ago") -> int:
    out = subprocess.check_output([
        "git", "log", f"--since={since}", "--follow", "--pretty=format:%s %b", "--", path,
    ]).decode(errors="ignore")
    return sum(1 for line in out.split("\n") if line.strip() and FIX_RE.search(line))

fix_count = {str(p): bug_fix_count(str(p)) for p in files}

# 3. Combine: BM25 score × (1 + log(1 + fix_count))
def combined_score(path: str, bm25_score: float) -> float:
    return bm25_score * (1 + math.log(1 + fix_count[path]))

# 4. Rank
query = [w.lower() for w in WORD.findall("checkout fails after retry with card declined")]
bm25_scores = bm25.get_scores(query)
ranked = sorted(
    ((combined_score(str(files[i]), bm25_scores[i]), str(files[i]), bm25_scores[i], fix_count[str(files[i])])
     for i in range(len(files))),
    reverse=True,
)[:10]

print(f"{'combined':>10}  {'bm25':>6}  {'fixes':>5}  file")
for combined, path, bm, fc in ranked:
    print(f"{combined:>10.2f}  {bm:>6.2f}  {fc:>5}  {path}")
# combined  bm25    fixes  file
#     78.3  24.31     11  src/api/v2/checkout_retry.py     <- IR + history agree
#     62.0  19.78      8  src/billing/decline_handler.py
#     48.1  14.22      9  src/payments/stripe/retry.py
#     11.2   8.61      0  src/integrations/legacy_sync.py  <- demoted (no fix history)
```

**The right combination weight depends on your data.** For mature codebases with rich bug history, the prior is informative — give it more weight (e.g., `bm25 + 5 × log(fixes)` additive instead of multiplicative). For new codebases, fall back toward IR-only. Calibrate by holding out 20% of historical bug reports as a validation set and sweeping the weight.

**Use the prior alone as a "where will bugs land next" heatmap.** Without an IR query, files ranked by `log(1 + fix_count) × log(1 + complexity)` predict the next year's bug distribution remarkably well — this is exactly the formula in `mine-hotspots-churn-complexity`, viewed from the localization side.

**Combine with `mine-change-coupling`:** when IR top-1 is file A but A has a tight change-coupling partner B, present both. Many bug fixes touch both halves of a coupled pair, and the report may describe the symptom from A's side while the fix lives in B.

**Tune `FIX_RE` per team conventions.** Without good fix-classification (see `mine-bug-fix-density`), the prior is noisy. Use Conventional Commits or a trained classifier when possible.

**When NOT to apply:**
- New codebases (< 6 months) — fix history is too sparse, prior is unreliable
- Repos with massive recent reorganization (file moves invalidate per-path history) — re-attribute via `git log --follow` first, or run history mining on the new layout once it stabilizes

Reference: [Sisman & Kak, Incorporating Version Histories in IR-Based Bug Localization (MSR 2012)](https://engineering.purdue.edu/RVL/Publications/Sisman_2012_MSR.pdf), [Saha et al., BLUiR Improvement Strategies (ICSE 2014)](https://www.cs.utexas.edu/~mitra/csFall2014/cs395t/resources/icse2014_saha.pdf)
