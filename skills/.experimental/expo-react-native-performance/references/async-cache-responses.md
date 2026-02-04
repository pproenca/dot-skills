---
title: Cache API Responses Locally
impact: MEDIUM
impactDescription: eliminates redundant network requests
tags: async, caching, tanstack-query, swr
---

## Cache API Responses Locally

Repeated API calls for the same data waste bandwidth and slow down the app. Use a caching library to store and reuse responses.

**Incorrect (fetch on every mount):**

```typescript
// screens/ProductDetails.tsx
export function ProductDetails({ productId }: Props) {
  const [product, setProduct] = useState<Product | null>(null);

  useEffect(() => {
    fetchProduct(productId).then(setProduct);
  }, [productId]);

  // User navigates away and back: fetches again
  return product ? <ProductView product={product} /> : <Loading />;
}
// Same product fetched every time user visits this screen
```

**Correct (cached with TanStack Query):**

```typescript
// screens/ProductDetails.tsx
import { useQuery } from '@tanstack/react-query';

export function ProductDetails({ productId }: Props) {
  const { data: product, isLoading } = useQuery({
    queryKey: ['product', productId],
    queryFn: () => fetchProduct(productId),
    staleTime: 5 * 60 * 1000,  // Consider fresh for 5 minutes
  });

  // Instant display on return visit, background refetch if stale
  return product ? <ProductView product={product} /> : <Loading />;
}
// Cached response shown immediately, refetches in background
```

**Benefits of caching libraries:**
- Automatic deduplication of in-flight requests
- Background refetching when data is stale
- Optimistic updates for mutations
- Request retry on failure

Reference: [TanStack Query](https://tanstack.com/query/latest)
