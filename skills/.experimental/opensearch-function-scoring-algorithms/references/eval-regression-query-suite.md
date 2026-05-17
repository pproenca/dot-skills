---
title: Maintain a Regression Query Suite for Silent Quality Drops
impact: MEDIUM
impactDescription: prevents tail/edge-case degradation while average is flat
tags: eval, regression, query-suite, pre-deploy, edge-case
---

## Maintain a Regression Query Suite for Silent Quality Drops

Average NDCG can stay flat while specific query types degrade catastrophically — a refactor that drops top-3 results for the head query "lisbon" by one slot loses a fraction of a percent on the offline metric but tanks the marketplace's most-trafficked search. A regression query suite is a small named set (200-500) of queries covering head, torso, tail, multi-language, and known edge cases. On every PR, check that the top-K for each named query doesn't churn dramatically without justification. It catches silent regressions before they ship.

**Incorrect (only average NDCG check — silent regressions on specific queries slip through):**

```python
def pre_deploy_check(new_ranker):
    ndcg = mean_ndcg_at_k(new_ranker, judgment_set, k=10)
    if ndcg >= baseline_ndcg - 0.005:
        return True  # "close enough on average" — but might have moved a top query
    return False
```

The judgment set is biased toward what was sampled at annotation time. Real production query distribution has long-tail patterns the judgment set misses.

**Correct (named regression suite with per-query churn alarms):**

`regression_queries.yaml` — versioned in the repo. Sample entries (full suite has 200-500):

```yaml
- { query: "lisbon",                 category: head,              language: en, notes: "highest-traffic; top-3 must include landmarks" }
- { query: "apartamento lisboa",     category: head,              language: pt, notes: "Portuguese head" }
- { query: "modern loft alfama",     category: torso,             language: en, notes: "neighborhood + style" }
- { query: "Casa do João",           category: tail_navigational, language: pt, notes: "top-1 must be Casa do João" }
- { query: "8 people beach pet ok",  category: tail_long,         language: en, notes: "compound constraints; was 0-result in v22" }
- { query: "🏖️",                     category: edge_emoji,                       notes: "fall back to category labels" }
- { query: "    ",                   category: edge_whitespace,                  notes: "popular default, not error" }
- { query: "DROP TABLE listings;",   category: edge_injection,                   notes: "no error; zero or default" }
```

Pre-deploy check — for each named query, compare top-K from old vs new ranker; alert if churn exceeds threshold:

```python
def pre_deploy_regression_check(new_ranker, old_ranker, suite, k=10, churn_threshold=0.3):
    """Churn = fraction of items in new top-K that were NOT in old top-K."""
    regressions = []
    for q in suite:
        old_top = {item.id for item in old_ranker.search(q.query, k=k)}
        new_top = {item.id for item in new_ranker.search(q.query, k=k)}
        if not old_top:
            continue
        churn = len(new_top - old_top) / len(old_top)
        if churn > churn_threshold:
            regressions.append({"query": q.query, "category": q.category,
                                "churn": churn, "notes": q.notes})
    return regressions

regressions = pre_deploy_regression_check(new_ranker, prod_ranker, REGRESSION_SUITE)
if regressions:
    raise DeployBlock(f"{len(regressions)} regressions — investigate and justify")
```

**Categories every regression suite needs:**

| Category | Coverage | Sample size |
|----------|----------|-------------|
| `head` | Top 1% by volume — what most users actually search | 30-50 |
| `torso` | The middle 10% — typical exploratory queries | 50-100 |
| `tail_long` | Long compound queries with many constraints | 30-50 |
| `tail_navigational` | Specific listing/host name searches | 20-30 |
| `multi_language` | Each supported language; rotate seasonally | 20 per language |
| `edge_unicode` | Emoji, RTL scripts, mixed-script | 10-15 |
| `edge_malformed` | Empty, whitespace-only, SQL injection patterns | 10-15 |
| `regression_specific` | Queries that previously broke and got a fix | grows over time |

**Treat regression-specific entries as test fixtures:** Every time a production bug hits a specific query, add it to the regression suite. The suite becomes living institutional memory — "this query broke once, never let it break again."

**Justify-don't-block workflow for legitimate churn:**

```python
# Allow churn if the change is documented in the PR description
def churn_with_justification(regressions, pr_description):
    if "churn-approved:" in pr_description:
        approved = parse_approved_queries(pr_description)
        regressions = [r for r in regressions if r["query"] not in approved]
    return regressions
```

This stops the suite from becoming friction — meaningful churn is fine when intentional and documented.

**Run on every PR and at deploy time:**

```yaml
# .github/workflows/ranking-regression.yml
- name: Ranking regression check
  run: python scripts/check_regression.py --pr ${{ github.event.pull_request.number }}
  on: pull_request
```

**The deeper habit:** A regression suite is the *narrowest* possible measurement — it doesn't replace NDCG or A/B tests, but it catches the specific failure modes that average metrics smooth over. Treat it as a complement to `eval-ndcg-primary-metric`, not a substitute.

Reference: [Google SRE Workbook — Testing as Reliable Engineering](https://sre.google/workbook/canarying-releases/) · [Kohavi et al. — Trustworthy Online Controlled Experiments (Cambridge, 2020)](https://experimentguide.com/)
