---
title: Use Betweenness Centrality To Find Cross-Domain Bottlenecks
impact: MEDIUM
impactDescription: O(V·E) — finds files that connect clusters; surprise edges often signal architectural debt
tags: rank, betweenness, freeman, bottleneck, bridge
---

## Use Betweenness Centrality To Find Cross-Domain Bottlenecks

PageRank tells you what's important *within* the dependency flow. **Betweenness centrality** (Freeman, "A set of measures of centrality based on betweenness," Sociometry 1977) tells you what sits *between* groups — the **bridges and bottlenecks**. Formally: betweenness(v) is the fraction of shortest paths in the graph that pass through v. A node with high betweenness is on the cross-roads of many paths; remove it and many node pairs lose their shortest connection.

For software, high-betweenness files are typically one of three things:

1. **Architectural pivots** — files like an API gateway, an event dispatcher, or a service registry that legitimately route between subsystems
2. **Code smells / God classes** — files that have accreted unrelated responsibilities until they sit in the middle of every dependency path (often refactoring candidates)
3. **Boundaries between recovered clusters** — the file *between* the payment cluster and the user cluster, where domain leakage happens

For agent-driven analysis, the top-10 betweenness files combined with the cluster assignments tell you **where the architectural boundaries actually live** — and whether they're respected.

**Incorrect (only inspect cluster centroids — miss the inter-cluster bottlenecks):**

```python
# Cluster the codebase, inspect cluster centroids. Each cluster is reported
# as a self-contained domain. But who knits them together? You don't know.
# The architectural pivots — the files where the agent should investigate
# coupling — are exactly the high-betweenness ones at cluster boundaries.
```

**Correct (Step 1 — compute betweenness with sampling for large graphs):**

```python
import networkx as nx

def betweenness_with_sampling(G, k: int = None, normalized: bool = True):
    """
    Exact betweenness is O(V·E) (Brandes 2001). For graphs > 5000 nodes,
    pass k = ~200-500 for an approximate version (sample k source nodes,
    accumulate betweenness contributions from each). Error decreases as
    1/sqrt(k); k = 200 is usually accurate to ~5%.
    """
    return nx.betweenness_centrality(G, k=k, normalized=normalized, seed=42)

# Use undirected for "any path" semantics; directed if you only count
# forward flows.
bc = betweenness_with_sampling(G.to_undirected(), k=200)
top = sorted(bc.items(), key=lambda kv: -kv[1])[:20]
for n, score in top:
    print(f"  bw = {score:.4f}  {n}")
```

**Correct (Step 2 — cross-reference top-betweenness with cluster assignments):**

```python
def cluster_boundary_files(bc_scores, cluster_assignment, n_top: int = 30):
    """
    For each top-betweenness file: report which cluster it belongs to AND
    which clusters its neighbours belong to. A file whose neighbours span
    many clusters is a *true* architectural bridge.
    """
    boundary_files = []
    for n, score in sorted(bc_scores.items(), key=lambda kv: -kv[1])[:n_top]:
        own_cluster = cluster_assignment.get(n, "unassigned")
        neighbor_clusters = {cluster_assignment.get(nb, "unassigned")
                             for nb in G.neighbors(n)}
        cross_count = len(neighbor_clusters - {own_cluster})
        boundary_files.append({
            "file": n,
            "betweenness": score,
            "own_cluster": own_cluster,
            "neighbor_clusters": neighbor_clusters,
            "cross_cluster_links": cross_count,
        })
    return boundary_files

boundaries = cluster_boundary_files(bc, cluster_assignment)
for b in boundaries:
    if b["cross_cluster_links"] >= 3:
        print(f"  bridge: {b['file']} (own: {b['own_cluster']}, "
              f"spans {b['cross_cluster_links']} other clusters)")
```

**Correct (Step 3 — classify each bridge as pivot, smell, or boundary):**

```python
def classify_bridge(file, neighbor_clusters, own_cluster, G):
    """
    Three categories:
    - pivot: a small focused file that legitimately routes (API gateway pattern)
              — typically <500 LOC, well-named (router/dispatcher/gateway)
    - smell: a large file that has accreted many unrelated callers
              — typically >2000 LOC, generic name
    - boundary: a file specific to one cluster that handles cross-cluster cases
                — moderate size, name aligned with own_cluster
    """
    loc = lines_of_code(file)
    has_routing_name = any(kw in file.lower()
                           for kw in ["router", "dispatcher", "gateway",
                                      "registry", "bus", "broker"])
    if loc < 500 and has_routing_name:
        return "pivot (legitimate routing)"
    elif loc > 2000:
        return "smell (god-class candidate)"
    else:
        return "boundary (cross-cluster handler in " + own_cluster + ")"
```

**Why betweenness specifically:**

| Centrality | What it measures | Best for |
|------------|------------------|----------|
| Degree | Local popularity | Quick popularity rank |
| Closeness | Average distance to all | "How quickly can this reach everything?" |
| PageRank | Transitive importance | "What's in the architectural spine?" |
| HITS | Hub vs authority | "What's a controller vs leaf?" |
| **Betweenness** | **On shortest paths** | **"Where are the bridges and bottlenecks?"** |

Betweenness is the unique answer to "if I removed this file, would large parts of the codebase become disconnected from each other?" That's exactly the question you ask when investigating *architectural debt* (because high-betweenness files are change-amplifiers).

**Empirical baseline:** Sarkar, Kak, Rama (TSE 2009, "Discovery of Architectural Layers and Measurement of Layering Violations in Source Code") used betweenness explicitly to find layering violators — files whose betweenness is "wrong" given their layer. Wang et al. (ICSE 2018) showed top-betweenness files in OSS projects predict bug fixes 30–50% better than random — betweenness is a proxy for change risk.

**When NOT to use:**

- Very large graphs without sampling — exact betweenness is O(V·E), which is hours on a 50K-node graph. Use k-sampling.
- Disconnected graphs (multiple components) — betweenness within each component is meaningful; comparing across components isn't.
- Co-change graphs — betweenness on undirected co-change measures something different (commit-co-occurrence bridge) — interpret carefully.

**Production:** NetworkX `nx.betweenness_centrality`, igraph `g.betweenness()`, graph-tool, Neo4j GDS. Used by network-science researchers, road-network analysis (bottleneck identification), and increasingly by software-analysis tools.

Reference: [A Faster Algorithm for Betweenness Centrality (Brandes, J. Mathematical Sociology 2001)](https://www.tandfonline.com/doi/abs/10.1080/0022250X.2001.9990249)
