---
title: Use Interleaved Evaluation for Low-Traffic Ranking Comparisons
impact: MEDIUM-HIGH
impactDescription: 10-100x more statistical power than A/B at low traffic
tags: bias, interleaving, team-draft, tdi, evaluation
---

## Use Interleaved Evaluation for Low-Traffic Ranking Comparisons

Classic A/B test at 1% traffic on a low-volume query (10 queries/day) needs months to reach statistical significance. Interleaving — show users a *merged* ranking from both rankers, attribute clicks to whichever ranker contributed each item — is 10-100× higher statistical efficiency per impression because every user contributes to both arms simultaneously. Team-Draft Interleaving (Radlinski et al., CIKM 2008) is the canonical implementation and what Airbnb uses for ranking experimentation on low-traffic verticals.

**Incorrect (classic A/B on low-traffic vertical — months to statistical power):**

```python
# 1% traffic on a vertical that gets 50 queries/day = 0.5 queries/day in treatment
# Need ~1000 conversions to detect 5% effect → months of waiting
ab_test.launch(treatment=ranker_v2, control=ranker_v1, traffic_pct=1)
```

**Correct (Team-Draft Interleaving — every query contributes to both arms):**

```python
import random

def team_draft_interleave(ranking_a, ranking_b, k=10):
    """
    Build a merged top-K ranking where each slot is drawn from one of the two rankers,
    alternating who picks first (the "team captain" coin flip).
    """
    merged = []
    used = set()
    pool_a = list(ranking_a)
    pool_b = list(ranking_b)
    a_picks = []
    b_picks = []
    a_first = random.random() < 0.5  # coin flip for first pick

    while len(merged) < k and (pool_a or pool_b):
        if (len(a_picks) <= len(b_picks)) if a_first else (len(a_picks) < len(b_picks)):
            picker = "A"; pool = pool_a; picks = a_picks
        else:
            picker = "B"; pool = pool_b; picks = b_picks
        # Pop next unused from the picker's pool
        while pool and pool[0].id in used:
            pool.pop(0)
        if not pool:
            continue
        item = pool.pop(0)
        merged.append((item, picker))
        used.add(item.id)
        picks.append(item.id)

    return merged  # [(item, attributed_to), ...]


# Online: serve merged ranking, log which "team" each clicked item belongs to
ranking_a = ranker_v1.rank(query, candidates)
ranking_b = ranker_v2.rank(query, candidates)
merged = team_draft_interleave(ranking_a, ranking_b, k=10)
serve_to_user(merged)

# After clicks logged: tally credit per ranker
def credit_clicks(impression_log):
    a_wins = b_wins = 0
    for impression in impression_log:
        a_clicks = sum(1 for click in impression.clicks if click.attribution == "A")
        b_clicks = sum(1 for click in impression.clicks if click.attribution == "B")
        if a_clicks > b_clicks: a_wins += 1
        elif b_clicks > a_clicks: b_wins += 1
        # Ties (including zero clicks) don't count
    return a_wins, b_wins

# Binomial test for significance — much higher power than A/B
```

**Why interleaving is so much more efficient:**

```text
A/B test: each impression contributes to ONE arm (Var = pq/N per arm)
Interleaving: each impression contributes to comparison directly (paired observation)
              variance is dominated by within-impression noise, not between-user noise

Result: ~10-100x sample-size efficiency
```

**Trade-offs:**

| Aspect | A/B test | Interleaving |
|--------|----------|--------------|
| Sample efficiency | Baseline | 10-100× better |
| Measures absolute metrics (CTR, conversion) | Yes | No (only relative preference) |
| Long-term user habit effects | Yes | No (each session sees mixed) |
| Implementation complexity | Low | Medium (attribution logic) |
| Risk | One arm fully exposed | Mixed exposure |

**Use interleaving when:** comparing two rankers head-to-head, low-traffic vertical, need fast iteration. Use A/B when: measuring absolute lift on long-term metrics, learning effects (habit formation), business KPIs.

**Combine with counterfactual evaluation:** Counterfactual triage offline → interleaving live for fast preference signal → A/B confirmation on top variant. That's the full Airbnb playbook.

Reference: [Radlinski, Kurup, Joachims — Team-Draft Interleaving (CIKM 2008)](https://www.cs.cornell.edu/people/tj/publications/radlinski_etal_08a.pdf) · [Chapelle et al. — Large-scale validation and analysis of interleaved search evaluation (TIST 2012)](https://research.yahoo.com/publications/6020/large-scale-validation-analysis-interleaved-search-evaluation) · [Airbnb — Interleaving + Counterfactual (KDD 2025)](https://airbnb.tech/infrastructure/academic-publications-airbnb-tech-2025-year-in-review/)
