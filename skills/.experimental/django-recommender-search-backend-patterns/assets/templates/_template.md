---
title: {Action-Oriented Title — start with imperative verb (Use, Avoid, Cache, Set, Cap)}
impact: {CRITICAL | HIGH | MEDIUM-HIGH | MEDIUM | LOW-MEDIUM | LOW}
impactDescription: {quantified metric — "10-100× improvement", "200-800ms savings", "O(n) to O(1)", "prevents downstream stampede", "reduces N round-trips to 1"}
tags: {category-prefix}, {technique}, {tool-if-specific}, {related-concept}
---

## {Title}

{1-3 sentences explaining WHY this matters. What goes wrong without this pattern in a
Django backend serving recommendations + search? Frame the failure in concrete terms:
extra downstream load, blown SLO budget, cascading worker exhaustion, ML quota burn,
cache miss storm, OpenSearch shard pressure. The mechanism is what makes the rule
generalize to novel scenarios.}

**Incorrect ({problem label}):**

```python
{Production-realistic bad code — use names like fetch_recommendations, search_products,
PersonalizeClient, opensearch_client, not foo/bar.}
{Comments explain the *cost*: "# blocks event loop" or "# fires N requests".}

async def bad_example():
    items = ...  # 🚨 explanation of what's wrong
```

**Correct ({solution label}):**

```python
{Good code — minimal diff from incorrect when possible.}
{Comments explain the *benefit*.}

async def good_example():
    items = await with_circuit_breaker(
        lambda: personalize_client.get(...),
    )                                       # ← the fix
```

{Optional sections — include only when they add value:}

**Alternative ({context}):**

```python
{Alternative valid approach}
```

**Implementation ({name of pattern}):**

```python
{Reusable utility worth shipping with the rule}
```

**With {framework/tool}:**

```python
{Tool-specific variant — e.g., boto3, httpx, opensearch-py, redis.asyncio}
```

**When NOT to use this pattern:**
- {Specific exception with rationale}
- {Another specific exception}

**Warning ({context}):**
- {Gotcha that would burn a careful reader}

**Pair with [[other-rule-slug]]:** {how this rule combines with another}

Reference: [{Source Title}]({source URL — use authoritative sources only: official docs, AWS blog, RFC, primary maintainers})
