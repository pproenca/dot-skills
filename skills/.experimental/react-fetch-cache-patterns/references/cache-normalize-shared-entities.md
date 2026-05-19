---
title: Normalize Shared Entities Across Views
impact: CRITICAL
impactDescription: N-fold cache size reduction for shared entities
tags: cache, normalization, graph-cache, relay, entities
---

## Normalize Shared Entities Across Views

If a product appears in three carousels and a search result on the same page, a flat (query-keyed) cache stores it four times — and updates to "is in cart" propagate to only the one the user clicked. A normalized cache stores each entity once by ID; views hold references. Update once, all four views re-render with the new state.

This is what Relay, Apollo, RTK Query, and Normy do automatically. TanStack Query is flat by default — for high entity reuse, either layer Normy on top or denormalize-then-update via `setQueryData` after mutations.

**Incorrect (flat cache: same product cached four times):**

```tsx
// Each of these queries stores its own copy of overlapping product objects
useQuery({ queryKey: ['carousel', 'trending'], queryFn: fetchTrendingProducts });
useQuery({ queryKey: ['carousel', 'recently-viewed'], queryFn: fetchRecentProducts });
useQuery({ queryKey: ['carousel', 'recommended'], queryFn: fetchRecommendations });
useQuery({ queryKey: ['search', term], queryFn: () => searchProducts(term) });

// User mutates "add to favorites" on product #42 in trending
queryClient.setQueryData(['carousel', 'trending'], updateFavorite(/*...*/));
// → only the trending carousel re-renders; the same product in 'recently-viewed' stays stale
```

**Correct (normalize: store product once, queries hold IDs):**

```tsx
// Normalized store (Zustand/Jotai/custom) keyed by entity type + id
type Store = {
  products: Map<string, Product>;
  setProducts: (ps: Product[]) => void;
};

// Query stores only the IDs; rendering reads details from the store
const { data: ids } = useQuery({
  queryKey: ['carousel', 'trending'],
  queryFn: async () => {
    const products = await fetchTrendingProducts();
    productStore.setProducts(products); // dump entities into normalized store
    return products.map(p => p.id);       // query stores just the order
  },
});

function ProductCard({ id }: { id: string }) {
  const product = useProductStore(s => s.products.get(id)); // re-renders when THIS product changes
  return <Card product={product!} />;
}

// One mutation, all four views update:
function favoriteProduct(id: string) {
  productStore.setProducts([{ ...productStore.products.get(id)!, isFavorite: true }]);
}
```

**Alternative (Normy as a drop-in layer):**

```tsx
import { createQueryNormalizer } from '@normy/react-query';
// Normy reads response shapes, indexes by `id`, and surgically updates all queries
// that contain entities with that id. Zero per-query code.
```

**When NOT to normalize:** when entities are rarely shared between views (e.g. a settings page with unique data per route). The normalization tax isn't worth it.

Reference: [Normy — Automatic Normalization](https://github.com/klis87/normy)
