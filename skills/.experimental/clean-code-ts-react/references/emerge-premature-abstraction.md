---
title: Resist Premature Abstraction
impact: MEDIUM
impactDescription: Avoid the wrong abstraction; let patterns emerge from concrete cases
tags: emerge, abstraction, rule-of-three, coupling
---

## Resist Premature Abstraction

The rule of three: duplicate twice before abstracting. The wrong abstraction couples unrelated concepts and forces them to evolve together. As Sandi Metz put it, "duplication is far cheaper than the wrong abstraction" — un-abstracting a bad abstraction costs more than living with copy-paste.

**Incorrect (abstracting on the second occurrence):**

```tsx
// After seeing <OrdersList> and <InvoicesList> both call fetch(),
// you extract useResource. Then:
//  - The next consumer needs cache invalidation -> add `invalidateOn` param.
//  - The next needs polling -> add `pollIntervalMs`.
//  - The next needs WebSocket updates -> add `subscribe`.
// useResource becomes 200 lines of optional params; every change risks
// breaking the four unrelated callers.
function useResource<T>(
  url: string,
  opts?: {
    invalidateOn?: string[];
    pollIntervalMs?: number;
    subscribe?: boolean;
    transform?: (raw: unknown) => T;
  }
): { data?: T; error?: Error; isLoading: boolean } {
  // ...sprawling implementation
}
```

**Correct (concrete first; abstract when the third caller proves the shape):**

```tsx
// Each list owns its small fetch logic. When five lists exist and a
// clear shared shape is visible, extract THAT specific shape — usually
// smaller than the speculative one (e.g., just a fetcher util).
function useOrders(): { orders: Order[]; isLoading: boolean } {
  const [orders, setOrders] = useState<Order[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  useEffect(() => {
    fetch('/api/orders')
      .then((r) => r.json())
      .then(setOrders)
      .finally(() => setIsLoading(false));
  }, []);
  return { orders, isLoading };
}
```

**When NOT to apply this pattern:**
- When a well-known, battle-tested abstraction already exists — use TanStack Query's `useQuery`; don't reinvent it.
- When duplication crosses team or service boundaries that will diverge — duplicating IS the right call, and the abstraction would create the wrong coupling.
- When the design space is clearly exhausted by the first 2-3 cases (e.g., three near-identical admin CRUD pages with a known fourth coming) — abstract earlier with eyes open.

**Why this matters:** A bad abstraction is harder to remove than duplication is to live with. Wait for the shape to reveal itself before naming it.

Reference: [Sandi Metz — The Wrong Abstraction](https://sandimetz.com/blog/2016/1/20/the-wrong-abstraction), [Rich Hickey — Simple Made Easy](https://www.infoq.com/presentations/Simple-Made-Easy/)
