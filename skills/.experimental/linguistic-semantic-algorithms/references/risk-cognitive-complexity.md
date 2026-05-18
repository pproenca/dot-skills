---
title: Use Cognitive Complexity When Readability Risk Matters More Than Test Surface
impact: MEDIUM
impactDescription: prevents the false-positive complexity flags that cyclomatic complexity produces
tags: risk, cognitive-complexity, sonarsource, readability, refactoring
---

## Use Cognitive Complexity When Readability Risk Matters More Than Test Surface

McCabe's cyclomatic complexity scores a switch with 20 branches the same as a function with 4 nested loops. They are not equivalent for the human reading the code: nesting amplifies cost; flat structures don't. Cognitive Complexity (Campbell, SonarSource 2018) fixes this by counting structural penalties (loops, conditionals) weighted by nesting depth: each level of nesting adds to the score for everything inside it. The output is a metric that tracks "how hard is this function to mentally execute?" — a better proxy for review effort and bug risk than CC.

**Incorrect (cyclomatic complexity for "is this function complex?" — misses nesting cost):**

```python
# Both functions have the same cyclomatic complexity (CC = 5).
# Cognitive complexity flags the second as much harder to read.
def flat_switch(kind):                          # CC=5, Cognitive=5
    if kind == "a": return handle_a()
    if kind == "b": return handle_b()
    if kind == "c": return handle_c()
    if kind == "d": return handle_d()
    return handle_default()

def nested_loops(items):                        # CC=5, Cognitive=11
    for group in items:                         # +1 (nesting=1)
        for item in group:                      # +2 (nesting=2: +1 base, +1 nesting)
            if item.valid:                      # +3 (nesting=3: +1 base, +2 nesting)
                for tag in item.tags:           # +4 (nesting=4)
                    if tag.flagged:             # +5
                        notify(item, tag)
```

**Correct (use Cognitive Complexity for readability gating):**

```python
# pip install complexipy   — fast Cognitive Complexity for Python
import complexipy, pathlib

results = []
for p in pathlib.Path("src").rglob("*.py"):
    try:
        analysis = complexipy.file_complexity(str(p))
    except Exception:
        continue
    for fn in analysis.functions:
        results.append({
            "path": str(p),
            "fn": fn.name,
            "line": fn.line_number,
            "cognitive": fn.complexity,
        })

# Sonar's default failure threshold: cognitive > 15
risky = sorted([r for r in results if r["cognitive"] > 15], key=lambda r: -r["cognitive"])
for r in risky[:15]:
    print(f"  cognitive={r['cognitive']:>3}  {r['path']}:{r['line']}  {r['fn']}")
# cognitive= 42  src/billing/proration.py:142  apply_proration
# cognitive= 27  src/sitter/availability.py:204 compute_slots
# cognitive= 19  src/api/checkout.py:88        post
```

**Interpreting Cognitive Complexity scores:**

| Cognitive | Action |
|---|---|
| 0-5 | trivially readable |
| 6-10 | requires focus, OK |
| 11-15 | refactor candidate |
| 16-30 | hard to maintain — split |
| 31+ | rewrite; nobody can hold this in their head |

**Cognitive vs Cyclomatic in CI gates.**
- Use **CC** for test surface — you must cover that many independent paths.
- Use **Cognitive** for review and maintenance — you must be able to understand it.

Best practice in production: fail builds on **both**, with cognitive having the lower threshold (15) and CC having the higher (20). This favors flat-but-branchy structures over nested-and-branchy ones.

**Per-language implementations:**
- Python: `complexipy`, `cognitive-complexity-py`
- JS / TS: `eslint-plugin-sonarjs` with `sonarjs/cognitive-complexity`
- Java: SonarQube native, `pmd-cognitive-complexity-rule`
- Multi-language: SonarQube Cloud (Sonar's own product)

**Combine with `risk-cyclomatic-mccabe`** as a two-dimensional risk view. A function high on cognitive but low on CC is *deeply nested with few branches* — a small refactor (extract method, early return) typically halves it. A function high on CC but low on cognitive is *flat with many branches* — usually fine if intentional.

**Combine with `mine-hotspots-churn-complexity`** by using Cognitive instead of CC in the formula. SonarSource's internal benchmarks report better bug-prediction correlation when cognitive replaces cyclomatic (no public number is available, so calibrate on your own labelled fix-history before relying on the gain).

**When NOT to apply:**
- Generated code — irrelevant, by definition not maintained by humans
- DSL or rule-engine files (e.g., long match-cases over enum values) — cognitive over-penalizes; tune the threshold for these paths

Reference: [Campbell, Cognitive Complexity — A new way of measuring understandability (SonarSource 2018)](https://www.sonarsource.com/resources/cognitive-complexity/), [complexipy — Python implementation](https://github.com/rohaquinlop/complexipy)
