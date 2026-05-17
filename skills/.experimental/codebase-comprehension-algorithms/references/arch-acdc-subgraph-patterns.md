---
title: Use ACDC's Subgraph Patterns To Recover Subsystem And Skeleton Structure
impact: HIGH
impactDescription: recovers MoJoFM 75+ vs 40-55% for statistical methods on standard SAR benchmarks
tags: arch, acdc, subsystem-pattern, skeleton-pattern, tzerpos, comprehension-driven
---

## Use ACDC's Subgraph Patterns To Recover Subsystem And Skeleton Structure

**ACDC** (Algorithm for Comprehension-Driven Clustering, **Tzerpos & Holt, WCRE 2000**) takes a fundamentally different approach from modularity-based methods: it scans the dependency graph for **specific subgraph patterns** that experienced software architects use to identify subsystems. The two main patterns are:

1. **Subsystem pattern**: a "central" module + a collection of files that fan out from it (a controller + its handlers, a service + its repositories). Detected as a *median node + its successor/predecessor neighbourhood*.
2. **Skeleton pattern**: a chain of mutually dependent modules forming the architectural backbone (the request-handling pipeline, the data-transformation chain). Detected via *biconnected component analysis*.

ACDC also applies an **omnipresent filter** (see `graph-filter-omnipresent-utilities-before-clustering`) and a **size-constraint heuristic** (clusters of "reasonable" size — typically 5–25 files), making it directly tunable to architect expectations. The result: ACDC's decompositions match expert ground truth on Mozilla, Linux, and Apache better than any pure-graph method when "match expert" is the metric.

It's the most explicitly comprehension-oriented algorithm — designed not for mathematical optimality, but for producing the decomposition a human architect would draw.

**Incorrect (modularity-based clustering ignores software-specific patterns):**

```python
import networkx.algorithms.community as nxc

G = build_call_graph("./src")
# Louvain / Leiden don't know what a "subsystem" looks like. They find dense
# blobs. A real subsystem (controller + 12 handlers) might score badly on
# modularity because the controller has high inter-cluster fan-out (to other
# subsystems' controllers) — so Louvain splits it.
comms = nxc.louvain_communities(G.to_undirected())
```

**Correct (Step 1 — detect subsystem patterns: median nodes and their neighbourhoods):**

```python
import networkx as nx

def find_subsystem_patterns(G, min_size: int = 5, max_size: int = 25):
    """
    A median node is a node whose neighbourhood (in + out) forms a cohesive
    cluster of `min_size`-`max_size` nodes that are weakly connected to the
    rest of the graph. ACDC §3.2 defines this precisely.
    """
    candidates = []
    for n in G.nodes():
        # Median criterion: |N(n)| is in [min_size, max_size]
        neighbourhood = set(G.predecessors(n)) | set(G.successors(n)) | {n}
        if not (min_size <= len(neighbourhood) <= max_size):
            continue
        # Cohesion: how many edges stay inside vs leave?
        inside = G.subgraph(neighbourhood).number_of_edges()
        boundary = sum(1 for u in neighbourhood
                       for v in (set(G.successors(u)) | set(G.predecessors(u))) - neighbourhood)
        if inside > boundary:  # more internal than external
            candidates.append({"median": n, "members": neighbourhood,
                               "cohesion_ratio": inside / max(boundary, 1)})
    # Resolve overlap: pick by descending cohesion; remove members of higher-
    # cohesion patterns from later ones.
    candidates.sort(key=lambda c: -c["cohesion_ratio"])
    assigned = set()
    patterns = []
    for c in candidates:
        if c["members"] & assigned:
            c["members"] -= assigned
            if len(c["members"]) < min_size:
                continue
        patterns.append(c)
        assigned |= c["members"]
    return patterns
```

**Correct (Step 2 — detect skeleton patterns: biconnected backbone):**

```python
def find_skeleton_pattern(G, undirected_view=None):
    """
    The skeleton is the set of biconnected components in the undirected
    version of the graph — articulation-point analysis. ACDC §3.3 treats
    biconnected components above a size threshold as architectural skeleton.
    Use Tarjan's biconnected-components algorithm: O(V+E).
    """
    UG = undirected_view or G.to_undirected()
    bccs = list(nx.biconnected_components(UG))
    skeleton = [list(bcc) for bcc in bccs if len(bcc) >= 5]
    return skeleton
```

**Correct (Step 3 — combine into ACDC's final clustering):**

```python
def acdc_cluster(G, min_size: int = 5, max_size: int = 25, omnipresent_z: float = 2.5):
    """
    Full ACDC pipeline:
      1. Filter omnipresent files (see graph-filter-omnipresent-utilities)
      2. Find subsystem patterns (median node + neighbourhood)
      3. Find skeleton patterns (biconnected components)
      4. Place remaining unassigned files into a leftover "tail" cluster
         or attach them to nearest existing cluster.
    """
    G_filtered, omnipresent = filter_omnipresent(G, z_threshold=omnipresent_z)

    subsystems = find_subsystem_patterns(G_filtered, min_size, max_size)
    skeleton = find_skeleton_pattern(G_filtered)

    clusters = []
    for s in subsystems:
        clusters.append({"type": "subsystem", "median": s["median"], "members": s["members"]})
    for skel in skeleton:
        clusters.append({"type": "skeleton", "members": set(skel)})

    # Unassigned nodes
    assigned = set().union(*[c["members"] for c in clusters])
    leftover = set(G_filtered.nodes()) - assigned
    if leftover:
        clusters.append({"type": "tail", "members": leftover})
    return clusters, omnipresent
```

**Why patterns capture architecture better than statistics:**

A modularity-based algorithm averages over all edges. ACDC asks specific structural questions: *"is this a controller surrounded by its delegates?"* (subsystem pattern), *"is this a chain of bottlenecks the system flows through?"* (skeleton pattern). Both questions are about *named* architectural roles that match how architects describe systems. The downside: it's less mathematically pure than modularity, and the heuristics (`min_size`, `max_size`) need tuning per codebase.

**Empirical baseline:** Tzerpos & Holt (WCRE 2000) showed ACDC matches expert decompositions of Linux kernel, X11, Tcl/Tk, and Mosaic with **MoJoFM > 75** on each — significantly better than the Bunch tool of the time (~60–70) and far better than naive Q-maximization (~40–55). Anquetil & Lethbridge (1999, "Experiments with clustering as a software remodularization method") replicated the results on industrial code.

**When NOT to use:**

- Codebases without clear architectural roles (data pipelines, scripts) — patterns don't match anything.
- Functional codebases (Haskell, OCaml) — function-level granularity doesn't have "subsystems" in the same sense.
- When you want statistical guarantees / a fitness score — ACDC produces a partition with no defended optimality.

**Production:** The original ACDC tool is available from York University (Bil Holt's lab). Implementations exist as research replications; not yet packaged for industry use. Hindle's *Tool* dataset includes ACDC-baseline decompositions for ~10 systems.

Reference: [ACDC: An Algorithm for Comprehension-Driven Clustering (Tzerpos & Holt, WCRE 2000)](https://www.cs.yorku.ca/~bil/papers/wcre00.pdf)
