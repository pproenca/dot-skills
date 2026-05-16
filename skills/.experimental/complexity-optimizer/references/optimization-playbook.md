# Optimization Playbook

## Common Transformations

### Nested lookup loops

Symptom: for each item in A, scan all of B to find a match.

Preferred fix: build a map from B once, then perform O(1) lookups.

Complexity: O(a*b) to O(a+b).

Correctness checks:

- Are duplicate keys possible?
- Does the original code pick first match, last match, or all matches?
- Is ordering observable?
- Is key normalization required?

### Repeated membership checks

Symptom: `items.includes(x)`, `x in list`, `array.indexOf(x)`, or equivalent inside a loop.

Preferred fix: convert the membership collection to a set once.

Complexity: O(n*m) to O(n+m).

Correctness checks:

- Does equality change after conversion? JavaScript object identity and Python hashability matter.
- Are values normalized the same way?

### Sorting inside loops

Symptom: sorting the same or growing collection repeatedly.

Preferred fix: sort once outside the loop, maintain a heap, or use binary insertion/search.

Complexity: often O(n^2 log n) to O(n log n), or O(n log k) with a heap.

Correctness checks:

- Is each intermediate sorted state externally observed?
- Does the comparator depend on loop-local state?

### Pairwise comparisons

Symptom: compare every pair to find overlaps, nearest values, conflicts, or ranges.

Preferred fixes:

- Sort + two pointers for pair/range matching.
- Sweep line for interval overlaps.
- Spatial/hash bucketing for local-neighborhood checks.
- Union-find for connectivity.

Complexity: commonly O(n^2) to O(n log n) or O(n alpha(n)).

### Recomputing derived data in render paths

Symptom: filters, sorts, grouping, or expensive transforms run during every render.

Preferred fixes:

- Memoize derived values with correct dependencies.
- Move derivation to selectors, loaders, or server-side preparation.
- Virtualize long lists.
- Stabilize callbacks and object props only when child renders are measurably affected.

Correctness checks:

- Dependency arrays must include every semantic input.
- Memoization must not hide mutations of mutable input objects.

### N+1 database or API calls

Symptom: a query or request inside a loop.

Preferred fixes:

- Bulk fetch by IDs and join in memory.
- Use joins, includes/preloads, dataloaders, or batched API endpoints.
- Preserve filtering, authorization, tenancy, ordering, pagination, and error behavior.

Correctness checks:

- Do not fetch records the previous per-item logic would not authorize.
- Preserve missing-record behavior.
- Preserve rate-limit and retry semantics.

## What Not To Do

- Do not replace clear linear code with complex structures when input sizes are tiny or the path is cold.
- Do not cache without invalidation.
- Do not use JSON serialization as a general-purpose key unless the key format is stable and collision-safe for the domain.
- Do not change public ordering unless tests and callers prove it is irrelevant.
- Do not trade O(n) for O(n log n) unless it removes a larger bottleneck or enables batching.
