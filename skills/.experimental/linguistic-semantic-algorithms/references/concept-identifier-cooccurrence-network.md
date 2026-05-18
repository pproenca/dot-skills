---
title: Build an Identifier Co-occurrence Graph to Reveal Conceptual Neighborhoods
impact: HIGH
impactDescription: reduces noise from utility tokens via PMI-weighted edges
tags: concept, cooccurrence, graph, networkx, conceptual-clustering
---

## Build an Identifier Co-occurrence Graph to Reveal Conceptual Neighborhoods

Two identifiers that frequently appear in the same function or file are conceptually adjacent in the domain — far more so than two identifiers that merely live in the same module directory. A weighted co-occurrence graph (nodes = identifier tokens, edge weight = number of functions in which both appear) lets you ask: "which concepts cluster around `subscription`?" and get back `{plan, invoice, charge, billingCycle, renewal}` — even when those terms live in completely different files. This is the trick that turns "I read the code" into "I read the relationships between concepts in the code".

**Incorrect (file-level co-occurrence — too coarse, dominated by `utils.py`):**

```python
import pathlib, itertools, collections

WORD = __import__("re").compile(r"\b[a-zA-Z_][a-zA-Z0-9_]{3,}\b")
edges = collections.Counter()
for p in pathlib.Path("src").rglob("*.py"):
    tokens = set(WORD.findall(p.read_text(errors="ignore")))
    for a, b in itertools.combinations(sorted(tokens), 2):
        edges[(a, b)] += 1

# Top edges are ("logging", "request"), ("logging", "response"),
# ("self", "value") — utility tokens that appear in every file.
# Real domain relationships drown.
```

**Correct (function-scoped co-occurrence with PMI weighting — domain neighborhoods emerge):**

```python
import ast, math, pathlib, itertools, collections
import networkx as nx

WORD = __import__("re").compile(r"[A-Z]?[a-z]+|[A-Z]+(?=[A-Z]|$)")

def function_tokens(src: str) -> list[set[str]]:
    bags = []
    for node in ast.walk(ast.parse(src)):
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
            text = ast.unparse(node)
            bags.append({w.lower() for w in WORD.findall(text) if len(w) > 3})
    return bags

pair_counts: collections.Counter = collections.Counter()
unigram_counts: collections.Counter = collections.Counter()
total_funcs = 0
for p in pathlib.Path("src").rglob("*.py"):
    for bag in function_tokens(p.read_text(errors="ignore")):
        total_funcs += 1
        unigram_counts.update(bag)
        for a, b in itertools.combinations(sorted(bag), 2):
            pair_counts[(a, b)] += 1

# PMI = log( P(a,b) / (P(a)·P(b)) ) — promotes pairs that co-occur
# more than chance, demotes pairs that are individually frequent.
def pmi(a: str, b: str, n_ab: int) -> float:
    p_ab = n_ab / total_funcs
    p_a = unigram_counts[a] / total_funcs
    p_b = unigram_counts[b] / total_funcs
    return math.log(p_ab / (p_a * p_b))

G = nx.Graph()
for (a, b), n_ab in pair_counts.items():
    if n_ab >= 5 and unigram_counts[a] >= 10 and unigram_counts[b] >= 10:
        w = pmi(a, b, n_ab)
        if w > 0:
            G.add_edge(a, b, weight=w)

# Neighborhood of "subscription": its strongest PMI partners
nbrs = sorted(G[("subscription")].items(), key=lambda kv: -kv[1]["weight"])[:10]
for term, attrs in nbrs:
    print(f"  {term:<20} pmi={attrs['weight']:.2f}")
# plan          pmi=4.81
# invoice       pmi=4.32
# renewal       pmi=4.10
# charge        pmi=3.88
# billingCycle  pmi=3.71
```

**Run Louvain on the resulting graph** (`nx.community.louvain_communities(G)`) — the communities are conceptual clusters that map almost directly to bounded contexts. This is the algorithmic backbone of `concept-bounded-context-detection`.

**Tune the function-bag size:** too-large functions (>200 lines) generate noisy edges; consider per-statement or per-class scoping for monolithic files.

**When NOT to apply:**
- Files where every function imports the same wide set of utilities — PMI alone won't filter
- Languages without per-function parsing support — use file-scoped co-occurrence with TF-IDF re-weighting instead

Reference: [Church & Hanks, Word Association Norms (1990)](https://aclanthology.org/J90-1003/), [Allamanis & Sutton, Mining Idioms from Source Code](https://miltos.allamanis.com/publications/2014idioms/)
