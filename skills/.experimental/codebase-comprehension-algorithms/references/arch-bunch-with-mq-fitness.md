---
title: Use Bunch's Modularization Quality As A Software-Specific Fitness Function
impact: HIGH
impactDescription: improves MoJoFM by 5-15% over Q-maximization on standard SAR benchmarks (Mitchell-Mancoridis TSE 2006)
tags: arch, bunch, mq, modularization-quality, mancoridis, search-based
---

## Use Bunch's Modularization Quality As A Software-Specific Fitness Function

Generic community detection (Louvain, Leiden, Infomap) maximises *modularity Q*, a metric defined for general graphs. **Modularization Quality (MQ)** is the software-specific cousin from **Mancoridis et al. (ICSM 1998, "Using Automatic Clustering to Produce High-Level System Organizations of Source Code")** — it's tailored to the way software dependencies actually distribute. MQ rewards **intra-cluster cohesion** (edges that stay inside clusters) and penalises **inter-cluster coupling** (edges that cross clusters), normalised so a single huge cluster doesn't trivially win. Bunch's contribution wasn't MQ alone — it was *using MQ as a fitness function* for **hill-climbing or genetic-algorithm search** over the partition space, which is what lets it match expert decompositions on real codebases.

The relevant insight: software dependency graphs have features (omnipresent utilities, hierarchical layering, naming-prefix coherence) that MQ captures and Q misses. Mitchell & Mancoridis (TSE 2006) showed MQ beats Q by 5–15 MoJoFM points on the standard benchmark systems (TOBEY, Linux kernel, Mozilla).

**Incorrect (Q-maximizing community detection on a software graph):**

```python
import networkx.algorithms.community as nxc
import networkx as nx

G = build_dependency_graph("./src")
# Louvain / Leiden maximise modularity Q, which is defined for general graphs
# under a degree-preserving null model. That null model isn't great for
# software, which has scale-free degree distributions and hierarchical layers.
# The result is *a* valid partition, but not the one a senior engineer would draw.
comms = nxc.louvain_communities(G.to_undirected())
```

**Correct (Step 1 — implement MQ for an arbitrary partition):**

```python
def modularization_quality(G, partition):
    """
    TurboMQ (Mitchell-Mancoridis TSE 2006) — the cluster-factor sum:
      MQ = Σᵢ CF(i)
      where CF(i) = μᵢ / (μᵢ + 0.5·(εᵢ_out + εᵢ_in))  for cluster i
        μᵢ  = number of intra-cluster edges in i
        εᵢ_out, εᵢ_in = edges leaving i / entering i
    MQ is bounded in [0, |C|]: 0 = all edges cross clusters, |C| = perfect
    cohesion. Normalize by |C| for a [0,1] score across decompositions of
    different size.
    """
    node_to_cluster = {n: i for i, c in enumerate(partition) for n in c}
    intra = [0] * len(partition)
    inter_out = [0] * len(partition)
    inter_in = [0] * len(partition)
    for u, v in G.edges():
        cu, cv = node_to_cluster[u], node_to_cluster[v]
        if cu == cv:
            intra[cu] += 1
        else:
            inter_out[cu] += 1
            inter_in[cv] += 1

    mq = 0.0
    for i in range(len(partition)):
        denom = intra[i] + 0.5 * (inter_out[i] + inter_in[i])
        mq += (intra[i] / denom) if denom > 0 else 0
    return mq

# MQ alone doesn't tell you a partition — you need to search.
```

**Correct (Step 2 — hill-climbing search over partitions, the Bunch way):**

```python
import random

def bunch_hillclimb(G, max_iters: int = 1000, seed: int = 42):
    """
    Simple Bunch-style local search:
    1) Start with each node in its own cluster.
    2) Repeatedly try moving a random node to a random other cluster (or to
       its own new cluster) and accept if MQ improves.
    3) Stop when no improvement for N consecutive tries (Bunch uses ~50).
    The full Bunch tool uses simulated annealing and steady-state genetic
    algorithms — this is the simplest variant that already beats Q-only methods.
    """
    rng = random.Random(seed)
    nodes = list(G.nodes())
    clusters = [{n} for n in nodes]
    best_mq = modularization_quality(G, clusters)

    stale = 0
    for _ in range(max_iters):
        if stale > len(nodes):
            break
        node = rng.choice(nodes)
        src = next(i for i, c in enumerate(clusters) if node in c)
        # candidate destinations: other clusters + a new singleton cluster
        dest = rng.randrange(len(clusters) + 1)
        if dest >= len(clusters):
            clusters.append(set())
        if dest == src:
            stale += 1
            continue
        clusters[src].discard(node)
        clusters[dest].add(node)
        new_mq = modularization_quality(G, [c for c in clusters if c])
        if new_mq > best_mq:
            best_mq = new_mq
            stale = 0
        else:
            clusters[dest].discard(node)
            clusters[src].add(node)
            stale += 1
        clusters = [c for c in clusters if c]
    return clusters, best_mq

partition, mq = bunch_hillclimb(G)
print(f"Bunch hill-climb: {len(partition)} clusters, MQ = {mq:.4f}")
```

**Correct (Step 3 — compare MQ vs Q vs ground truth):**

```python
import networkx.algorithms.community as nxc

louvain = nxc.louvain_communities(G.to_undirected(), seed=42)
louvain_Q = nxc.modularity(G.to_undirected(), louvain)
louvain_MQ = modularization_quality(G, louvain)

bunch, bunch_MQ = bunch_hillclimb(G)
bunch_Q = nxc.modularity(G.to_undirected(), bunch)

print(f"Louvain: {len(louvain):>2} clusters,  Q={louvain_Q:.3f}  MQ={louvain_MQ:.3f}")
print(f"Bunch  : {len(bunch):>2} clusters,  Q={bunch_Q:.3f}  MQ={bunch_MQ:.3f}")
# Typical: Bunch wins on MQ, Louvain wins on Q. Compare both against
# expert-labelled ground truth via MoJoFM to decide which matters more
# for your codebase. Mitchell-Mancoridis 2006 reports MQ wins on MoJoFM
# by 5-15 points on standard SAR benchmarks.
```

**Why MQ matters and why the genetic-algorithm variant matters even more:**

MQ's per-cluster *cluster factor* — μᵢ / (μᵢ + 0.5·boundary) — is essentially a **micro-modularity** for that one cluster, summed across the partition. The 0.5 weight balances cohesion against coupling; the formula self-penalises tiny clusters (low μᵢ kills the score) and giant clusters (huge boundary kills the score). This implicitly enforces "reasonable cluster size" without any explicit prior — a property modularity Q lacks (Q exhibits the resolution limit; see `valid-be-aware-of-resolution-limit`).

The genetic-algorithm variant (NSGA-II — Praditwong, Harman, Yao, TSE 2011, "Software Module Clustering as a Multi-Objective Search Problem") treats MQ and *number of clusters* as competing objectives, producing a Pareto front of solutions. Useful when the agent should *report alternatives* rather than impose one.

**When NOT to use:**

- Very small codebases (< 50 files) — MQ's normalization assumptions break down with few clusters.
- Co-change graphs (already weighted by frequency) — MQ assumes binary edges; needs adaptation.
- When you want a hierarchical decomposition — Bunch produces flat partitions. Use SBM hierarchical or Walktrap dendrogram instead.

**Production:** The Bunch tool itself is open-source from Drexel University (Mitchell-Mancoridis lab) — bunch.cs.drexel.edu. Used in several SAR research replications. NSGA-II implementations (DEAP, pymoo) make the multi-objective variant easy to reproduce.

Reference: [On the Automatic Modularization of Software Systems Using the Bunch Tool (Mitchell & Mancoridis, IEEE TSE 2006)](https://ieeexplore.ieee.org/document/1610591)
