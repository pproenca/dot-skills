---
title: Prefetch Data Before Navigation
impact: MEDIUM-HIGH
impactDescription: eliminates loading state on destination screen
tags: nav, prefetch, data-fetching, ux
---

## Prefetch Data Before Navigation

Start fetching data for the next screen before navigation completes. This eliminates the loading spinner on the destination screen.

**Incorrect (fetch on screen mount):**

```typescript
// ProductListScreen.tsx
function ProductListItem({ product }) {
  const router = useRouter()

  return (
    <Pressable onPress={() => router.push(`/product/${product.id}`)}>
      <Text>{product.name}</Text>
    </Pressable>
  )
}

// ProductDetailScreen.tsx
function ProductDetailScreen() {
  const { id } = useLocalSearchParams()
  const [product, setProduct] = useState(null)

  useEffect(() => {
    fetchProduct(id).then(setProduct)  // Fetch starts after navigation
  }, [id])

  if (!product) return <LoadingSpinner />  // User sees loading state

  return <ProductDetail product={product} />
}
```

**Correct (prefetch before navigation):**

```typescript
import { useQueryClient } from '@tanstack/react-query'

// ProductListScreen.tsx
function ProductListItem({ product }) {
  const router = useRouter()
  const queryClient = useQueryClient()

  const handlePress = () => {
    // Start prefetching immediately
    queryClient.prefetchQuery({
      queryKey: ['product', product.id],
      queryFn: () => fetchProduct(product.id),
    })
    router.push(`/product/${product.id}`)
  }

  return (
    <Pressable onPress={handlePress}>
      <Text>{product.name}</Text>
    </Pressable>
  )
}

// ProductDetailScreen.tsx
function ProductDetailScreen() {
  const { id } = useLocalSearchParams()
  const { data: product } = useQuery({
    queryKey: ['product', id],
    queryFn: () => fetchProduct(id),
  })

  // Data often ready immediately due to prefetch
  if (!product) return <LoadingSpinner />

  return <ProductDetail product={product} />
}
```

**Prefetch on hover/focus (web-like pattern):**

```typescript
function ProductListItem({ product }) {
  const router = useRouter()
  const queryClient = useQueryClient()

  const prefetchProduct = useCallback(() => {
    queryClient.prefetchQuery({
      queryKey: ['product', product.id],
      queryFn: () => fetchProduct(product.id),
      staleTime: 30000,  // Consider fresh for 30 seconds
    })
  }, [product.id, queryClient])

  return (
    <Pressable
      onPressIn={prefetchProduct}  // Start prefetch on touch down
      onPress={() => router.push(`/product/${product.id}`)}
    >
      <Text>{product.name}</Text>
    </Pressable>
  )
}
```

Reference: [TanStack Query Prefetching](https://tanstack.com/query/latest/docs/framework/react/guides/prefetching)
