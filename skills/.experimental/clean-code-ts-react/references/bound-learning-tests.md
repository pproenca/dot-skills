---
title: Write Learning Tests for Third-Party Behavior
impact: MEDIUM-HIGH
impactDescription: alarms on silent library behavior changes during upgrades
tags: bound, testing, third-party, learning-tests
---

## Write Learning Tests for Third-Party Behavior

Before integrating an unfamiliar library, write small focused tests that exercise the parts you'll actually use. They serve double duty: they're the cheapest way to understand the library's contract, and they become regression alarms when a "minor" version bump quietly changes behavior. The cost is small; the cost of debugging a silent semantic change in production is large.

**Incorrect (read the docs, integrate 200 lines, hope):**

```ts
// 200 lines of TanStack Query integration sprinkled through 15 files.
// When v6 quietly changes `keepPreviousData` semantics in a minor version,
// pagination flickers in production and no test catches it.

function OrdersPage() {
  const { data, isPlaceholderData } = useQuery({
    queryKey: ['orders', page],
    queryFn: () => fetchOrders(page),
    placeholderData: keepPreviousData, // exact behavior?
  });
  // ...lots of feature code...
}
```

**Correct (a tiny test file documents and guards your assumptions):**

```ts
// useQuery.learning.test.ts — exercises the 5 patterns we actually use.
// Library upgrade either keeps these green or fails noisily in CI.
describe('TanStack Query: behaviors we depend on', () => {
  it('keepPreviousData returns prior page while new page loads', async () => { /* ... */ });
  it('staleTime: 0 refetches on every mount', async () => { /* ... */ });
  it('error state is reset when queryKey changes', async () => { /* ... */ });
  it('dependent queries wait for enabled', async () => { /* ... */ });
  it('optimistic update is rolled back on mutation error', async () => { /* ... */ });
});
```

**When NOT to apply this pattern:**
- Mature, stable APIs with no realistic version risk — `lodash.pick`, `date-fns.format`. The test would never fail.
- Single-use integrations you'll remove next sprint — a one-off CSV export library. Pay the cost where it pays back.
- When the library's own test suite already demonstrates the patterns you depend on — link to those instead of duplicating.

**Why this matters:** Tests pinned to library behavior turn invisible breaking changes into loud CI failures — the same "shift bugs left" principle as making illegal states unrepresentable.

Reference: [Clean Code, Chapter 8: Boundaries (Learning Tests)](https://www.oreilly.com/library/view/clean-code-a/9780136083238/), [Working Effectively with Legacy Code — Michael Feathers](https://www.oreilly.com/library/view/working-effectively-with/0131177052/)
