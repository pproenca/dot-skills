---
title: Measure McCabe Cyclomatic Complexity to Quantify Per-Function Branch Risk
impact: MEDIUM
impactDescription: predicts independent test paths in O(edges - nodes + 2)
tags: risk, cyclomatic, mccabe, complexity, radon
---

## Measure McCabe Cyclomatic Complexity to Quantify Per-Function Branch Risk

Cyclomatic complexity (McCabe, 1976) counts the number of linearly-independent paths through a function: every `if`, `for`, `while`, `case`, and `and/or` short-circuit adds one. The result is also a lower bound on the number of test cases needed for full branch coverage. It's the oldest and simplest complexity metric and the easiest to interpret: a function with CC ≤ 10 is easy to test; CC > 15 is hard; CC > 30 is almost certainly mis-structured. Use it as the *complexity* dimension in `mine-hotspots-churn-complexity` and as a per-file gate in code review.

**Incorrect (lines of code as a complexity proxy — completely insensitive to branching):**

```python
# A 200-line straight-line function is simple but scores "high" on LoC.
# A 50-line function with 12 nested ifs is complex but scores "low".
# LoC tells you nothing about test surface.
def loc(src: str) -> int:
    return len([l for l in src.splitlines() if l.strip()])
```

**Correct (count branches via radon / language-specific tools):**

```python
import radon.complexity as cc       # pip install radon
import pathlib

results = []
for p in pathlib.Path("src").rglob("*.py"):
    src = p.read_text(errors="ignore")
    try:
        blocks = cc.cc_visit(src)
    except SyntaxError:
        continue
    for b in blocks:                # one block per function/method
        results.append({
            "path": str(p),
            "function": b.name,
            "line": b.lineno,
            "cc": b.complexity,
            "rank": cc.cc_rank(b.complexity),  # 'A' (1-5) ... 'F' (>40)
        })

# Show the danger zone: CC > 15
danger = sorted([r for r in results if r["cc"] > 15], key=lambda r: -r["cc"])
for r in danger[:15]:
    print(f"  cc={r['cc']:>3} rank={r['rank']}  {r['path']}:{r['line']}  {r['function']}")
# cc= 38 rank=E  src/billing/proration.py:142  apply_proration
# cc= 31 rank=E  src/api/checkout.py:88        post
# cc= 22 rank=D  src/sitter/availability.py:204 compute_slots
```

**Interpret with McCabe's published thresholds:**

| CC range | Rank | Risk | Action |
|---|---|---|---|
| 1-5 | A | low | leave it alone |
| 6-10 | B | OK | OK if intentional |
| 11-20 | C | high | refactor candidate |
| 21-30 | D | very high | refactor or split |
| 31-40 | E | critical | rewrite the function |
| 41+ | F | unmaintainable | rewrite without question |

**Per-language tooling:**
- Python: `radon`, `mccabe`
- Java: `pmd`, `checkstyle`, `spotbugs`
- JS / TS: `eslint-plugin-complexity`, `ts-prune`
- Go: `gocyclo`
- C / C++: `lizard`, `pmccabe`
- Multi-language: `lizard` covers 20+ languages with one CLI

**CC alone is misleading.** A 30-branch `switch` over an enum is far easier to read than a 30-deep nested `if/else` tree. Use Cognitive Complexity (`risk-cognitive-complexity`) for a human-readability-aligned alternative; use CC for test-surface and McCabe-style refactoring decisions.

**Cap CC at the function boundary in CI** (e.g. fail builds where new code introduces CC > 15) — it's a forcing function that pushes engineers to decompose work. Beware grandfathering legacy violations; explicit allow-lists are clearer than implicit per-file overrides.

**Combine with `mine-hotspots-churn-complexity`** — CC × revisions is the canonical hotspot score. A high-CC function that nobody changes is acceptable risk; a high-CC function that changes weekly is a bug factory.

**When NOT to apply:**
- Pure data files / constants — CC is trivially 1 for any non-branching code; metric provides no signal
- Generated parser code — CC is artificially high but the function is correct by construction; exclude generated paths

Reference: [McCabe, A Complexity Measure (TSE 1976)](https://ieeexplore.ieee.org/document/1702388), [radon CC docs](https://radon.readthedocs.io/en/latest/intro.html#cyclomatic-complexity)
