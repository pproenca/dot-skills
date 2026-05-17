---
title: Use The Reflexion Model To Compare Hypothesized vs Actual Architecture
impact: HIGH
impactDescription: reduces architecture recovery from months to days; reveals 80% of debt in 4-6 hours (Murphy-Notkin FSE 1995)
tags: arch, reflexion-model, murphy-notkin-sullivan, hypothesis-driven, mapping
---

## Use The Reflexion Model To Compare Hypothesized vs Actual Architecture

The **Reflexion Model** (Murphy, Notkin, Sullivan — "Software Reflexion Models: Bridging the Gap Between Source and High-Level Models," FSE 1995; expanded TSE 2001) is the architecture-recovery technique that *every* working software engineer should know about, and almost none do. The premise is delightful: you don't have to discover the architecture from scratch — you have a hypothesis (the architecture you *think* the codebase has, or the architecture in the wiki, or the architecture the founder once drew on a napkin), and you can **check it against reality** by mapping each file to a hypothesized box, computing the actual dependencies, and reporting on three categories:

1. **Convergences** — edges that exist in both the hypothesis AND the source code. The architecture is right here.
2. **Divergences** — edges in the source code NOT in the hypothesis. Surprise dependencies, often architectural debt.
3. **Absences** — edges in the hypothesis NOT in the source code. The architecture says these should connect; they don't.

This decomposes architecture recovery into a sequence of **small, validatable hypotheses** rather than a global clustering problem. For a coding agent: start with the folder structure or the README's mental model as the hypothesis, compute reflexion, report surprises. Iterate.

**Incorrect (full bottom-up clustering, ignoring any prior architectural knowledge):**

```python
import networkx.algorithms.community as nxc

G = build_dependency_graph("./src")
# Discard everything you know about the codebase. Run Leiden / Bunch /
# Limbo blind. Hope the algorithm finds the "right" decomposition.
# Result: a partition. Now you have to explain it to a human who has been
# describing the same system in entirely different terms for 5 years.
clusters = nxc.louvain_communities(G.to_undirected())
```

**Correct (Step 1 — declare the hypothesis as a mapping from files to high-level modules):**

```python
import re

# Hypothesis: the README says "we have payments, search, identity, billing,
# api-gateway, and shared utilities." Define a mapping function.
def hypothesis_mapping(file_path: str) -> str:
    """Map a source file to its hypothesized high-level module.
    Order matters — first match wins."""
    rules = [
        (r"^src/payments/",          "payments"),
        (r"^src/billing/",           "billing"),
        (r"^src/search/",            "search"),
        (r"^src/identity/|^src/auth/", "identity"),
        (r"^src/api/|^src/gateway/", "api-gateway"),
        (r"^src/shared/|^src/utils/", "shared"),
        (r".*",                       "unmapped"),
    ]
    for pattern, module in rules:
        if re.match(pattern, file_path):
            return module
    return "unmapped"

# Hypothesized high-level edges: what SHOULD connect to what.
# Drawn from the README or the architect's mental model.
HYPOTHESIZED_EDGES = {
    ("api-gateway", "payments"), ("api-gateway", "billing"),
    ("api-gateway", "search"),   ("api-gateway", "identity"),
    ("payments", "billing"), ("payments", "identity"), ("payments", "shared"),
    ("billing", "shared"),   ("search", "shared"),
    ("identity", "shared"),
}
```

**Correct (Step 2 — compute the reflexion summary):**

```python
import networkx as nx

def compute_reflexion(G: nx.DiGraph, mapping_fn, hypothesized_edges):
    """Lift the source-code graph to the hypothesis level and classify
    each lifted edge as Convergent / Divergent. Hypothesized edges with
    no source-code support become Absences."""
    actual_edges = set()
    for u, v in G.edges():
        m_u, m_v = mapping_fn(u), mapping_fn(v)
        if m_u != m_v:  # within-module edges aren't part of high-level architecture
            actual_edges.add((m_u, m_v))

    convergent = actual_edges & hypothesized_edges
    divergent  = actual_edges - hypothesized_edges
    absent     = hypothesized_edges - actual_edges
    return {"convergent": convergent, "divergent": divergent, "absent": absent}

reflexion = compute_reflexion(G, hypothesis_mapping, HYPOTHESIZED_EDGES)
print(f"Convergences: {len(reflexion['convergent'])}")
print(f"Divergences (surprise edges):   {sorted(reflexion['divergent'])}")
print(f"Absences (missing connections): {sorted(reflexion['absent'])}")
```

**Correct (Step 3 — for each divergence, drill into which files caused it):**

```python
def divergence_details(G, mapping_fn, divergent_edges):
    """For each (module_a, module_b) that wasn't hypothesized but exists in
    the code, list the specific (file_a, file_b) edges that caused it.
    These are the architectural surprises to investigate."""
    details = {}
    for u, v in G.edges():
        m_u, m_v = mapping_fn(u), mapping_fn(v)
        if (m_u, m_v) in divergent_edges:
            details.setdefault((m_u, m_v), []).append((u, v))
    return details

surprises = divergence_details(G, hypothesis_mapping, reflexion["divergent"])
# Example output:
#   ('payments', 'search'): [('src/payments/fraud.py', 'src/search/index.py'), ...]
# → "payments shouldn't import from search; fraud.py is doing it"
# → architectural debt or hypothesis incomplete; decide which.
```

**The reflexion iteration loop:**

1. Run reflexion with hypothesis H₀.
2. For each divergence, decide: *bug* (fix the code, e.g. extract a shared module) or *missing rule* (update H to H₁).
3. For each absence, decide: *missing feature* (add the connection) or *missing rule* (update H).
4. Re-run with H₁. Iterate until reflexion is "stable" — divergences and absences are intentional.

This is how architects *actually* keep documentation honest. It's the foundation of architecture-as-code tools (Structurizr, jQAssistant, ArchUnit) and dependency-cruiser-style enforcement.

**Why this beats clustering for many architecture-recovery tasks:**

Clustering recovers *a* partition — but is it *the right* partition? Only the human team knows. Reflexion makes the partition explicit, comparable, and iteratively refinable. It's also **incremental**: as the codebase evolves, you re-run reflexion in CI; new divergences are reported immediately. Clustering can't do that — its output varies with seed and slight graph changes.

**Empirical baseline:** Murphy-Notkin-Sullivan (FSE 1995) reported the reflexion technique uncovering ~80% of architectural debt in Microsoft Excel (250+ KLOC) in 4–6 hours of architect time, against months for full bottom-up recovery. Bowman, Holt, Brewster (ICSM 1999) replicated on Linux kernel and found reflexion + an initial layered hypothesis converged in ~10 iterations.

**When NOT to use:**

- You truly have no hypothesis — start with clustering, then *convert the clusters into a hypothesis* and switch to reflexion mode.
- The codebase is so small (< 20 files) that reflexion adds bureaucracy.
- The architecture is itself in flux — re-running reflexion daily, churning hypotheses, is exhausting.

**Production:** Structurizr CLI implements reflexion-style "architecture as code" checks; ArchUnit (Java) and dependency-cruiser (JavaScript) and rust-analyzer's module rules all implement reflexion in CI form. jQAssistant explicitly references the Murphy-Notkin model in its documentation.

Reference: [Software Reflexion Models: Bridging the Gap Between Source and High-Level Models (Murphy, Notkin, Sullivan, FSE 1995)](https://dl.acm.org/doi/10.1145/222124.222147)
