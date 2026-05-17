---
title: Treat Logical Coupling As The Architectural Signal Static Analysis Misses
impact: HIGH
impactDescription: 30-50% of strongest software coupling is invisible to static analysis (Gall ICSM 1998)
tags: evol, logical-coupling, gall, hidden-coupling, architecture
---

## Treat Logical Coupling As The Architectural Signal Static Analysis Misses

**Gall, Hajek, Jazayeri** ("Detection of logical coupling based on product release history," ICSM 1998) introduced **Logical Coupling**: two source artefacts are *logically coupled* if they consistently change together, even when no static dependency exists between them. The finding was startling at the time: across telecom-product releases, **30–50% of the strongest coupling** measured by co-change had no corresponding edge in the static call/import graph. The coupling was *hidden* — through shared protocols, shared numeric constants, runtime configuration, event buses, distributed transactions, or just convention ("when we add a new auth method, we also have to update three unrelated files").

For codebase comprehension, this is the most important finding from 30 years of mining-software-repositories research: **the architecture you can see is not the architecture you have**. Files that change together belong together regardless of what the import graph says. Logical coupling has consistently been shown to be a stronger predictor of bug propagation (Hassan-Holt ICSE 2004), refactoring opportunities (D'Ambros, Lanza, Robbes ICSE 2009), and feature ownership (Bird et al. FSE 2009) than static dependencies alone.

**Incorrect (rely on static dependency graph alone — miss hidden coupling):**

```python
import networkx.algorithms.community as nxc

G = build_import_graph("./src")
# Static graph misses:
#   - Files connected via DI containers / Spring annotations
#   - Files sharing event bus topic strings (publisher + N subscribers)
#   - Files coordinated by config keys / feature flags
#   - Files sharing implicit constants across packages
#   - Database schema files coordinated with model files
# Co-change captures ALL of these. Static graph captures none.
clusters = nxc.louvain_communities(G.to_undirected())
```

**Correct (Step 1 — compute logical coupling using support and confidence):**

```python
def logical_coupling(pair, file_count, pair_count, total_commits,
                     min_support_count: int = 5,
                     min_confidence: float = 0.5):
    """
    Logical Coupling (Gall et al. 1998 + Zimmermann ROSE refinement):
      Coupling(A, B) exists if:
        1. support_count(A ∧ B) ≥ min_support_count  (avoid noise)
        2. confidence(A → B) ≥ min_confidence
           confidence(B → A) ≥ min_confidence
           (bidirectional — both files predict each other)
      Confidence threshold of 0.5 means "when A changes, B changes 50%+ of the time"
    """
    a, b = pair
    if pair_count[pair] < min_support_count:
        return None
    conf_ab = pair_count[pair] / file_count[a]
    conf_ba = pair_count[pair] / file_count[b]
    if conf_ab < min_confidence or conf_ba < min_confidence:
        return None
    return {
        "support_count": pair_count[pair],
        "confidence_ab": conf_ab,
        "confidence_ba": conf_ba,
        "mean_confidence": (conf_ab + conf_ba) / 2,
    }
```

**Correct (Step 2 — compare static dependency to logical coupling, find hidden edges):**

```python
import networkx as nx

def hidden_coupling(pair_count, file_count, total_commits, G_static: nx.Graph,
                    min_support_count: int = 5, min_confidence: float = 0.5):
    """
    Hidden coupling = logically coupled BUT no static edge.
    These are the architectural surprises.
    """
    static_edges = set()
    for u, v in G_static.edges():
        static_edges.add(tuple(sorted([u, v])))

    hidden = []
    for pair, count in pair_count.items():
        if pair in static_edges:
            continue
        lc = logical_coupling(pair, file_count, pair_count, total_commits,
                              min_support_count, min_confidence)
        if lc:
            hidden.append((pair, lc))
    return sorted(hidden, key=lambda x: -x[1]["mean_confidence"])

surprises = hidden_coupling(pair_count, file_count, total_commits, G_static)
print(f"Found {len(surprises)} hidden coupling pairs:")
for (a, b), lc in surprises[:20]:
    print(f"  conf={lc['mean_confidence']:.2f} sup={lc['support_count']:>3}  "
          f"{a}  ~~  {b}  (no static edge)")
# Each hidden coupling is an architectural surprise worth investigating —
# it's either real hidden coupling (event bus, shared config) or a code smell.
```

**Correct (Step 3 — combine static and logical into one architectural picture):**

```python
def combined_coupling_graph(G_static: nx.Graph, pair_count, file_count, total_commits,
                            alpha: float = 0.5):
    """
    Build a unified coupling graph where edge weight =
       alpha · static_normalized + (1-alpha) · logical_normalized
    alpha = 0.5 balances both; lower to favour history, higher to favour structure.
    """
    G = nx.Graph()
    # Static edges
    for u, v in G_static.edges():
        G.add_edge(u, v, static=1.0, logical=0.0)
    # Logical coupling
    for pair, count in pair_count.items():
        lc = logical_coupling(pair, file_count, pair_count, total_commits)
        if lc:
            u, v = pair
            if G.has_edge(u, v):
                G[u][v]["logical"] = lc["mean_confidence"]
            else:
                G.add_edge(u, v, static=0.0, logical=lc["mean_confidence"])
    # Combined weight
    for u, v, d in G.edges(data=True):
        d["weight"] = alpha * d["static"] + (1 - alpha) * d["logical"]
    return G
```

**Why logical coupling beats static dependency in many real cases:**

Static analysis sees only **what the language allows you to express**. Logical coupling sees **what developers actually intend to keep in sync**. Examples where the divergence is large:

| Coupling type | Visible to static? | Visible to logical? |
|---------------|--------------------|--------------------:|
| Direct import / call | Yes | Yes |
| DI / Spring autowiring | Partial | Yes |
| Event bus topic strings | No | Yes |
| Shared config keys / feature flags | No | Yes |
| Distributed transaction coordination | No | Yes |
| Implicit constants ("user_role_id = 42") | No | Yes |
| Protocol-level coordination (DB schema ↔ model) | No | Yes |
| Test fixtures coordinated with prod files | Partial | Yes |
| Generated code regeneration | No | Yes |

**Empirical baseline:** Gall et al. (ICSM 1998) on the Lucent-style telecom platform: 30–40% of coupling was hidden. D'Ambros-Lanza-Robbes (ICSE 2009, "Visualizing co-change information with the evolution radar") replicated on five OSS systems with 25–55% hidden rates. Hassan-Holt (ICSE 2004) showed that combining static + logical predicts change-propagation correctly 70% more often than static alone.

**Where this matters most for codebase comprehension:**

- **Event-driven architectures**: handlers are coupled via topic strings, invisible to static analysis
- **Microservices monorepos**: services coordinated via shared schema/proto definitions
- **Plugin systems**: extensions register with a runtime registry
- **Configuration-driven code**: behaviour depends on YAML/JSON
- **Multi-language codebases**: cross-language coupling (Python service + TypeScript frontend) is fully invisible to per-language static analysis

**When NOT to weight logical coupling heavily:**

- Insufficient history (< 100 feature commits) — logical signal is noise.
- Codebase recently went through a giant refactor — old logical coupling reflects old architecture.
- You explicitly want the *static* picture for compile-time analysis.

**Production:** GitLens "files changed together" shows logical coupling. Software Improvement Group's BetterCodeHub uses logical coupling as one of its architectural quality metrics. Microsoft's CodeFlow recommendation engine uses logical coupling. Open-source: `cochange` and `gittutorial` tools.

Reference: [Detection of logical coupling based on product release history (Gall, Hajek, Jazayeri, ICSM 1998)](https://ieeexplore.ieee.org/document/738508)
