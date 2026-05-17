---
title: Use HITS To Distinguish Orchestrators (Hubs) From Implementations (Authorities)
impact: MEDIUM
impactDescription: separates orchestrators from implementations in O((V+E)·iter); orthogonal to PageRank
tags: rank, hits, kleinberg, hubs, authorities
---

## Use HITS To Distinguish Orchestrators (Hubs) From Implementations (Authorities)

PageRank gives one number per node — total importance. **HITS** (Hyperlink-Induced Topic Search; **Kleinberg, "Authoritative sources in a hyperlinked environment," JACM 1999**) gives **two**: a **hub score** (the node points to many high-authority things) and an **authority score** (the node is pointed to by many high-hub things). The two scores capture orthogonal roles:

- **High authority, low hub**: implementation files — leaf services, repositories, data accessors. *Many things call them; they call few.*
- **High hub, low authority**: orchestrators — controllers, request handlers, top-level entry points. *They call many things; few call them.*
- **High both**: middleware — services that compose other services. The architectural glue.
- **Low both**: peripheral utilities, dead code.

For codebase comprehension, this is the **shape of the architecture** in two numbers per file. The PageRank-top files are typically high authority *or* high hub but rarely both — knowing which is which tells the agent what kind of file it's reading.

**Incorrect (single importance score conflates the two roles):**

```python
import networkx as nx

pr = nx.pagerank(G)
top = sorted(pr.items(), key=lambda kv: -kv[1])[:20]
# Top contains both 'payment_controller.py' (orchestrator) and
# 'payment_charge_service.py' (implementation), but you can't tell which
# is which from one number.
```

**Correct (Step 1 — compute hub and authority scores):**

```python
import networkx as nx

def hub_authority(G: nx.DiGraph, max_iter: int = 100):
    """
    HITS computes hub h and authority a iteratively:
      a_v = sum over u with u→v of h_u
      h_u = sum over v with u→v of a_v
    Normalize after each step. Converges in 30-100 iterations on real graphs.
    Returns: (hubs, authorities) — both dict[node]→score.
    """
    hubs, authorities = nx.hits(G, max_iter=max_iter, normalized=True)
    return hubs, authorities

hubs, authorities = hub_authority(G_call)
```

**Correct (Step 2 — classify nodes by their hub-authority profile):**

```python
import numpy as np

def classify_by_role(hubs, authorities, hub_thresh=0.5, auth_thresh=0.5):
    """Classify each node into one of four roles based on percentile rank."""
    nodes = list(hubs)
    h_arr = np.array([hubs[n] for n in nodes])
    a_arr = np.array([authorities[n] for n in nodes])
    h_pct = (h_arr.argsort().argsort() / len(nodes))   # percentile rank
    a_pct = (a_arr.argsort().argsort() / len(nodes))

    roles = {}
    for i, n in enumerate(nodes):
        if h_pct[i] >= hub_thresh and a_pct[i] >= auth_thresh:
            roles[n] = "middleware"          # high both — glue / composer
        elif h_pct[i] >= hub_thresh:
            roles[n] = "orchestrator"        # high hub, low authority
        elif a_pct[i] >= auth_thresh:
            roles[n] = "implementation"      # low hub, high authority
        else:
            roles[n] = "peripheral"          # low both
    return roles

roles = classify_by_role(hubs, authorities, hub_thresh=0.9, auth_thresh=0.9)
for n, role in sorted(roles.items(), key=lambda kv: kv[1]):
    if role != "peripheral":
        print(f"  {role:15} {n}")
```

**Correct (Step 3 — print the architectural map by role):**

```python
def architectural_map(hubs, authorities, n_per_role: int = 10):
    """Show top-n per role. This IS the high-level architecture summary."""
    nodes = list(hubs)
    by_role = {"orchestrator": [], "implementation": [], "middleware": []}
    for n in nodes:
        h = hubs[n]
        a = authorities[n]
        role = (
            "middleware" if h > 0.01 and a > 0.01
            else "orchestrator" if h > 0.01
            else "implementation" if a > 0.01
            else "peripheral"
        )
        if role != "peripheral":
            by_role[role].append((n, h, a))
    for role, items in by_role.items():
        items.sort(key=lambda x: -(x[1] + x[2]))
        print(f"\n=== Top {role}s ===")
        for n, h, a in items[:n_per_role]:
            print(f"  hub={h:.4f}  auth={a:.4f}  {n}")
```

**Why HITS and PageRank are complementary:**

PageRank assumes you want a *single* notion of importance — a node's score is mass passed around the graph until convergence. HITS recognises that **importance is bipartite** in directed graphs: receivers and emitters can be ranked separately. This matters most in software because **the architectural role IS bipartite**: a controller is *defined* as an emitter (it dispatches to handlers), a repository is *defined* as a receiver (handlers call into it). HITS recovers this structure directly.

| Architecture pattern | What HITS reveals |
|---------------------|--------------------|
| MVC / 3-tier | Controllers = top hubs; Repositories = top authorities; Services = middleware |
| Plugin system | Plugin host = top hub; Plugins = top authorities |
| Event-driven | Publishers = high hubs; Handlers = high authorities |
| Layered (kernel / driver / app) | Apps = top hubs; Kernel = top authority; Drivers = middleware |
| Microservice mesh | API gateway = top hub; Data services = top authorities |

**Empirical baseline:** HITS is less applied to software clustering than PageRank — its main use has been in citation networks and the web. The applications that exist (Bavota et al. ICSM 2013 on Java OSS systems, Wettel-Lanza ICPC 2008 on visualisation) confirm the orchestrator-vs-implementation interpretation transfers cleanly.

**When NOT to use:**

- Undirected graphs (co-change, lexical) — HITS is direction-sensitive; on symmetric edges, hub = authority by construction.
- Tiny graphs — score variance is too high for percentile thresholds to be stable.
- You only want a single importance number — PageRank is simpler.

**Production:** NetworkX `nx.hits`, igraph `g.hub_score()` / `g.authority_score()`, graph-tool's `pagerank` and `hits` modules. Used by Google's original web-search alongside PageRank, and now by academic search engines (Google Scholar uses HITS-like signals for paper ranking).

Reference: [Authoritative Sources in a Hyperlinked Environment (Kleinberg, JACM 1999)](https://dl.acm.org/doi/10.1145/324133.324140)
