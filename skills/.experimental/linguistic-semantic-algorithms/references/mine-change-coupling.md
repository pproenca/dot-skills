---
title: Compute Change Coupling from Git History to Find Hidden Architectural Couplings
impact: HIGH
impactDescription: directly affects refactor scope by exposing cross-layer coupling static analysis misses
tags: mine, change-coupling, git, temporal, architectural-debt
---

## Compute Change Coupling from Git History to Find Hidden Architectural Couplings

Two files that consistently change in the same commit are *coupled in fact*, regardless of what the import graph says. This is the single most counter-intuitive finding from repository mining: change-coupled files are usually NOT statically coupled — they share a domain concept that lives in different layers (e.g., a frontend form and the backend validator), and a change to one always requires a change to the other. Compute the conditional probability `P(B changes | A changes)` over the last 12 months of history. Pairs with P > 0.5 across many commits are strong architectural debt signals: either they should be unified, or the duplication should be made explicit and tested.

**Incorrect (rely on the static dependency graph alone — misses cross-layer coupling):**

```python
# Look at imports to find coupling. A frontend component
# and a backend validator never import each other but always
# change together. Static analysis cannot see this.
import ast, pathlib
imports = {p: [] for p in pathlib.Path("src").rglob("*.py")}
for p in imports:
    try: tree = ast.parse(p.read_text(errors="ignore"))
    except SyntaxError: continue
    for n in ast.walk(tree):
        if isinstance(n, ast.ImportFrom) and n.module:
            imports[p].append(n.module)
# All visible "coupling" is what compiles. Cross-stack coupling is invisible.
```

**Correct (mine git log for co-change frequency — conditional probability per pair):**

```python
import subprocess, collections, itertools, json
from pathlib import Path

# 1. Walk the last 12 months of commits, collect file sets per commit
def commits_with_files(since: str = "12 months ago") -> list[set[str]]:
    fmt = "--pretty=format:COMMIT"
    out = subprocess.check_output([
        "git", "log", f"--since={since}", "--name-only", fmt,
    ]).decode()
    sets = []
    current: set[str] = set()
    for line in out.splitlines():
        if line.startswith("COMMIT"):
            if current: sets.append(current)
            current = set()
        elif line.strip():
            current.add(line.strip())
    if current: sets.append(current)
    return sets

commits = commits_with_files()

# 2. Count single-file and pair-of-files occurrences
single: collections.Counter = collections.Counter()
pair: collections.Counter = collections.Counter()
for files in commits:
    if len(files) > 25: continue                       # skip megacommits (e.g. formatting)
    for f in files: single[f] += 1
    for a, b in itertools.combinations(sorted(files), 2):
        pair[(a, b)] += 1

# 3. Conditional probability P(B | A) and P(A | B); take the symmetric minimum
def coupling(a: str, b: str, n_ab: int) -> tuple[float, float]:
    return n_ab / single[a], n_ab / single[b]

results = []
for (a, b), n in pair.items():
    if n < 5 or single[a] < 10 or single[b] < 10: continue
    pa, pb = coupling(a, b, n)
    results.append((min(pa, pb), n, a, b))

# 4. Top-coupled pairs that have NO static import relation are gold
for score, n, a, b in sorted(results, reverse=True)[:15]:
    print(f"  {score:.2f}  (co-changed {n}× of {min(single[a], single[b])})  {a}  <->  {b}")
# 0.92  (co-changed 47× of 51)  src/api/checkout.py   <->  src/frontend/checkout-form.tsx
# 0.88  (co-changed 38× of 43)  src/billing/invoice.py <->  src/templates/invoice_email.html
# 0.86  (co-changed 31× of 36)  src/domain/sitter.py   <->  src/api/serializers/sitter.py
```

**Filter "megacommits".** A commit touching 100 files (rename, formatting pass, mass refactor) inflates every pair. The `len(files) > 25` filter is the simplest and most effective; tune for your repo's normal commit size.

**Drop file-rename history.** `git log --follow` per file is required if a high-coupling pair is actually the *same file* before and after a rename. Code Maat handles this automatically; rolling your own, run `git log --follow --name-only` and merge renamed paths under a canonical name.

**Combine with `graph-louvain-modules`:** if two files have high change-coupling but live in different Louvain communities, you have architectural drift. The structure says they're separate; history says they're one.

**This is Adam Tornhill's signature technique** ([Your Code as a Crime Scene](https://pragprog.com/titles/atcrime2/your-code-as-a-crime-scene-second-edition/)). The book is the canonical reference for this whole category — read it before doing serious repository mining.

**When NOT to apply:**
- Repos under ~3 months old — not enough commit history for stable coupling
- Trunk-based-development repos with squashed PRs only — the commit unit is too coarse; mine PRs instead of commits

Reference: [Tornhill, Your Code as a Crime Scene (2nd ed.)](https://pragprog.com/titles/atcrime2/your-code-as-a-crime-scene-second-edition/), [Code Maat — open-source mining tool](https://github.com/adamtornhill/code-maat), [Gall et al., Detection of Logical Coupling Based on Product Release History (ICSM 1998)](https://ieeexplore.ieee.org/document/738508)
