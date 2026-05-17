---
title: Apply Window-Based Diversity Penalty in Rescore
impact: MEDIUM
impactDescription: preserves rank stability across sessions
tags: div, window, rescore, sliding, penalty
---

## Apply Window-Based Diversity Penalty in Rescore

Global re-rankers (MMR, DPP) reshuffle the entire top-K — which can cause significant rank-position changes that confuse repeat users ("where did that listing I clicked yesterday go?"). A window-based penalty applies diversity only to the *visible window* the user is scrolling through, leaving lower-ranked positions stable. The pattern: as you build the top-K, penalize an item's score by its similarity to items already placed within the last `w` positions; once a similar item exits the window, the penalty drops off.

**The window-penalty algorithm:**

```text
For position i from 1 to top_k:
    candidate_score(c) = base_score(c) - α × max{ sim(c, j) : j ∈ already_placed[i-w : i] }
    place item with highest candidate_score
    advance i
```

`α` controls the penalty strength; `w` controls how "local" the diversity is.

**Incorrect (global MMR reshuffles ranking — breaks repeat-visit memory):**

```python
# Re-ranks all top-50 with single global trade-off
final = mmr_rerank(candidates, query_vec, lambda_=0.5, top_k=50)
```

A listing that ranked #4 yesterday might rank #19 today purely from MMR diversity vs whoever else is in the top window — user thinks the marketplace is "unstable."

**Correct (window-based penalty — only adjacent positions interact):**

```python
import numpy as np

def window_diverse_rerank(candidates, query_vec, top_k=50, window=5, alpha=0.3):
    """
    Place items into positions 1..top_k in order. At each position,
    penalize candidates by similarity to items in the last `window` placed positions.
    """
    feats = np.array([c.embedding for c in candidates])
    feats = feats / np.linalg.norm(feats, axis=1, keepdims=True)
    base_scores = np.array([c.base_score for c in candidates])

    placed = []
    remaining = list(range(len(candidates)))

    for pos in range(top_k):
        if not remaining:
            break
        # Compute window-local penalty
        window_set = placed[-window:]
        if window_set:
            sim_to_window = feats[remaining] @ feats[window_set].T  # shape (R, W)
            penalty = sim_to_window.max(axis=1)
        else:
            penalty = np.zeros(len(remaining))

        adjusted = base_scores[remaining] - alpha * penalty
        winner_local = int(np.argmax(adjusted))
        winner_global = remaining[winner_local]
        placed.append(winner_global)
        remaining.pop(winner_local)

    return [candidates[i] for i in placed]
```

**Why this preserves rank stability better than MMR:** Items far from the current placement window don't influence each other — so adding/removing a single item in the candidate set causes only local reshuffles, not global. Users perceive consistent rankings session-over-session.

**Parameter calibration:**

| Surface | window | alpha |
|---------|--------|-------|
| Desktop top-10 visible | 5 | 0.3 |
| Mobile vertical scroll | 3 | 0.4 |
| Map view (visual grid) | 4 | 0.5 |
| Infinite scroll, long page | 7 | 0.2 |

**Combine with hard caps:** Window penalty for soft within-window diversity; hard per-host cap (`div-max-per-host`) for structural diversity. They address different problems: window-penalty stops near-duplicates from clumping; max-per-host stops a single host from dominating regardless of similarity.

**When to NOT diversify at all:** Specific intent queries ("Hotel Marriott Lisbon"), filter-narrow queries (already 4 results — diversity is moot), repeat queries from the same user (stability > diversity).

Reference: [Carbonell & Goldstein — The Use of MMR (SIGIR 1998)](https://www.cs.cmu.edu/~jgc/publication/The_Use_MMR_Diversity_Based_LTMIR_1998.pdf) · [Castells, Hurley, Vargas — Novelty and Diversity in Recommender Systems (book chapter)](https://link.springer.com/chapter/10.1007/978-1-0716-2197-4_17)
