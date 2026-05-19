---
title: {Action-Oriented Title — start with imperative verb (Use, Avoid, Cache, Defer, Batch)}
impact: {CRITICAL | HIGH | MEDIUM-HIGH | MEDIUM | LOW-MEDIUM | LOW}
impactDescription: {quantified metric — "2-10× improvement", "200-800ms savings", "O(n) to O(1)", "prevents stale closures", "reduces N requests to 1"}
tags: {category-prefix}, {technique}, {tool-if-specific}, {related-concept}
---

## {Title}

{1-3 sentences explaining WHY this matters. What goes wrong without this pattern, and what
the cascade effect is. This section is the highest-signal part of the rule — the model
generalizes from understood reasoning, not from rules. Don't just say "use X" — explain
the failure mode in concrete terms the model can internalize.

For data-fetching rules, frame the failure in terms of: extra round-trips, extra backend
load, extra bytes downloaded, layout shift, race conditions, retry storms, or memory leaks.
The mechanism is what makes the rule generalize to novel scenarios.}

**Incorrect ({problem label}):**

```tsx
{Production-realistic bad code — not a strawman.}
{Examples should use real names (CommentList, ProductCarousel) not foo/bar.}
{Comments explain the *cost*: "// 200 requests" or "// blocks main thread".}
function BadExample() {
  const { data } = useFetch('/api/things'); // 🚨 explanation of what's wrong
}
```

**Correct ({solution label}):**

```tsx
{Good code — minimal diff from incorrect when possible.}
{Comments explain the *benefit*.}
function GoodExample() {
  const { data } = useQuery({
    queryKey: ['things'],
    queryFn: fetchThings,
    staleTime: 30_000,                       // ← the fix
  });
}
```

{Optional sections — include only when they add value:}

**Alternative ({context}):**

```tsx
{Alternative valid approach}
```

**Implementation ({name of pattern}):**

```ts
{Reusable utility worth shipping with the rule}
```

**With {framework/tool}:**

```tsx
{Tool-specific variant — e.g., Next.js App Router, TanStack Router, SWR}
```

**When NOT to use this pattern:**
- {Specific exception with rationale}
- {Another specific exception}

**Warning ({context}):**
- {Gotcha that would burn a careful reader}

**Benefits:**
- {Concrete benefit 1}
- {Concrete benefit 2}

**Pair with [[other-rule-slug]]:** {how this rule combines with another}

Reference: [{Source Title}]({source URL — use authoritative sources only})
