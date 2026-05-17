---
title: {Imperative-verb title — Use X / Avoid Y / Choose X For Y}
impact: {CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW}
impactDescription: {quantified — "2-10× improvement", "200ms savings", "O(n²) to O(n)", "prevents stale closures", "reduces reflows by 80%"}
tags: {prefix}, {technique1}, {technique2}, {author-or-tool}
---

## {Title — same as frontmatter}

{1-3 sentences explaining WHY this matters for codebase comprehension —
what specifically goes wrong without this rule, and what cascade effect
that produces downstream. Lead with the consequence, not the theory.
Cite the paper or book the algorithm comes from inline so the reader
can verify.}

**Incorrect ({short label for what's broken about the bad pattern}):**

```python
# Production-realistic bad example — NOT a strawman.
# Use real-looking variable names (file_count, pair_count) not foo/bar.
# Annotate inline with what specifically goes wrong.
G = build_dependency_graph("./src")
clusters = naive_algorithm(G)  # ← misses 30-50% of real coupling
```

**Correct (Step 1 — {first stage, e.g. setup or core data structure}):**

```python
# Each "Correct" block must be <50 lines (validator limit).
# Use Step 1 / Step 2 / Step 3 to split long examples semantically.
def setup_inputs(repo):
    ...
```

**Correct (Step 2 — {second stage, e.g. the main algorithm}):**

```python
def main_algorithm(inputs):
    ...
```

{Optional sections — use what serves the rule:}

**Alternative ({when to use this variant}):**

```python
# Mention sibling techniques here. Cross-reference other rules by their
# slug, e.g. see `clust-leiden-not-louvain`.
```

**Why this matters (one paragraph if not already covered above):**

{Explain the underlying mathematical / information-theoretic / engineering
reason. The model generalizes from understood reasoning, not from rules.}

**Empirical baseline:** {cite a specific paper with quantified results, e.g.
"Beck-Diehl EMSE 2013 report a 15-30% MoJoFM improvement on six OSS systems
when this rule is applied." Reproducibility > rhetoric.}

**When NOT to use:**

- {Specific case 1 — quantified if possible (e.g. "graphs with fewer than 100 nodes")}
- {Specific case 2 — when the rule's assumption is violated}
- {Specific case 3 — when a different algorithm in this skill is the better choice}

**Production:** {Which real-world systems / tools / papers apply this.
Concrete names — "Sourcegraph", "Apache Tinkerpop", "Neo4j GDS" — not vague claims.}

Reference: [{Paper / book title}]({URL — peer-reviewed conference, journal, or canonical book})
