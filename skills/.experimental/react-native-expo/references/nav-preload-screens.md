---
title: Preload Screens Before Navigation
impact: MEDIUM
impactDescription: eliminates navigation delay for heavy screens
tags: nav, preload, prefetch, navigation, ux
---

## Preload Screens Before Navigation

Preload heavy screens and their data before navigation to eliminate perceived load time.

**Incorrect (load on navigation):**

```tsx
function HomeScreen() {
  return (
    <TouchableOpacity onPress={() => router.push('/product/123')}>
      <Text>View Product</Text>
    </TouchableOpacity>
  )
}

// ProductScreen loads all data after navigation
function ProductScreen() {
  const { id } = useLocalSearchParams()
  const { data, isLoading } = useQuery(['product', id], fetchProduct)

  if (isLoading) return <Spinner />  // User sees loading state
  return <ProductDetails product={data} />
}
```

**Correct (preload on hover/press-in):**

```tsx
import { useQueryClient } from '@tanstack/react-query'

function HomeScreen() {
  const queryClient = useQueryClient()

  const prefetchProduct = useCallback((productId) => {
    // Prefetch data before navigation
    queryClient.prefetchQuery(['product', productId], () =>
      fetchProduct(productId)
    )
  }, [queryClient])

  return (
    <TouchableOpacity
      onPressIn={() => prefetchProduct('123')}  // Start on press
      onPress={() => router.push('/product/123')}
    >
      <Text>View Product</Text>
    </TouchableOpacity>
  )
}

// ProductScreen data is already cached
function ProductScreen() {
  const { id } = useLocalSearchParams()
  const { data } = useQuery(['product', id], fetchProduct)

  // Data available immediately from cache
  return <ProductDetails product={data} />
}
```

**Preload on list item visibility:**

```tsx
function ProductList({ products }) {
  const queryClient = useQueryClient()

  const onViewableItemsChanged = useCallback(({ viewableItems }) => {
    // Prefetch products that are now visible
    viewableItems.forEach(({ item }) => {
      queryClient.prefetchQuery(
        ['product', item.id],
        () => fetchProduct(item.id),
        { staleTime: 60000 }  // Don't refetch for 1 minute
      )
    })
  }, [queryClient])

  return (
    <FlatList
      data={products}
      renderItem={renderItem}
      onViewableItemsChanged={onViewableItemsChanged}
      viewabilityConfig={{ itemVisiblePercentThreshold: 50 }}
    />
  )
}
```

**Preload images:**

```tsx
import { Image } from 'expo-image'

// Prefetch images for next screen
async function prefetchProductImages(productId) {
  const product = await fetchProduct(productId)

  // Prefetch all product images
  await Promise.all(
    product.images.map(url => Image.prefetch(url))
  )
}

function ProductCard({ product, onPress }) {
  const prefetch = useCallback(() => {
    prefetchProductImages(product.id)
  }, [product.id])

  return (
    <TouchableOpacity
      onPressIn={prefetch}
      onPress={onPress}
    >
      <Image source={product.thumbnail} />
      <Text>{product.name}</Text>
    </TouchableOpacity>
  )
}
```

**Benefits:**
- Zero perceived loading time
- Smoother navigation transitions
- Better UX for predictable navigation paths

Reference: [TanStack Query Prefetching](https://tanstack.com/query/latest/docs/react/guides/prefetching)
