---
title: Bound Prefetch Bandwidth by Priority Tier
impact: MEDIUM-HIGH
impactDescription: prevents prefetch from competing with critical fetches
tags: prefetch, priority, bandwidth, budget, save-data
---

## Bound Prefetch Bandwidth by Priority Tier

Prefetching the next 50 things "in case the user needs them" is great until those 50 prefetches drown out the *actual* user-initiated fetch happening at the same moment. Tier prefetches by priority: critical user-initiated fetches go first, navigational prefetches (likely-next) second, predictive prefetches (might-be-next) last. Use `fetch`'s `priority` hint, and gate aggressive prefetching on connection quality.

The `Network Information API` and `fetch` priority hints let the browser shed lower-priority work when the network is busy or slow.

**Incorrect (prefetch competes for the same slots as the user's actual fetch):**

```tsx
function ProductGrid({ products }: { products: Product[] }) {
  // Prefetch detail for all 50 visible products
  useEffect(() => {
    products.forEach(p => {
      queryClient.prefetchQuery({
        queryKey: ['product', p.id],
        queryFn: () => fetchProduct(p.id),
      });
    });
    // 50 parallel prefetches drown out the user clicking "Add to Cart"
  }, [products]);
}
```

**Correct (priority hints + connection-aware + bounded concurrency):**

```ts
type Priority = 'high' | 'low' | 'auto';

export async function fetchWithPriority(
  url: string,
  priority: Priority = 'auto'
): Promise<Response> {
  // Skip low-priority prefetches on slow or save-data connections
  // @ts-expect-error — Network Information API
  const conn = navigator.connection;
  if (priority === 'low' && (conn?.saveData || conn?.effectiveType === '2g')) {
    throw new Error('skipped-prefetch-on-slow-connection');
  }
  return fetch(url, { priority }); // fetch() supports priority hints in Chrome/Edge
}
```

**Tier prefetches with a budget:**

```tsx
const prefetchLimit = pLimit(2); // at most 2 concurrent prefetches

function ProductCard({ product }: { product: Product }) {
  useEffect(() => {
    prefetchLimit(() =>
      queryClient.prefetchQuery({
        queryKey: ['product', product.id],
        queryFn: ({ signal }) => fetchWithPriority(`/api/products/${product.id}`, 'low')
          .then(r => r.json()),
        staleTime: 60_000,
      })
    );
  }, [product.id]);
}
```

**Three tiers:**

| Tier | What | Priority | Bandwidth share |
|------|------|----------|-----------------|
| Critical | User clicked / navigated | `high` | Unbounded |
| Likely-next | Hover, viewport sentinel | `auto` | 4-6 concurrent |
| Predictive | Idle-time guesses | `low` | 1-2 concurrent, gated by `connection` |

**Respect `Save-Data`:** when the user has enabled data-saver mode, the browser sends `Save-Data: on` and `navigator.connection.saveData === true`. Skip predictive prefetch entirely; show smaller images; fetch only on direct interaction.

**Cancellation interplay:** when the user clicks something that needs an in-flight prefetch slot, cancel the lowest-priority outstanding prefetches first. AbortController + a priority-tagged queue makes this clean.

Reference: [WICG — Priority Hints](https://wicg.github.io/priority-hints/) | [MDN — Network Information API](https://developer.mozilla.org/en-US/docs/Web/API/Network_Information_API)
