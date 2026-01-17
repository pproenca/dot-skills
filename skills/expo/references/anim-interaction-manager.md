---
title: Defer Heavy Work During Animations with InteractionManager
impact: MEDIUM
impactDescription: maintains 60fps by deferring 100-500ms of JS work
tags: anim, interactionmanager, defer, scheduling
---

## Defer Heavy Work During Animations with InteractionManager

Use `InteractionManager.runAfterInteractions` to schedule CPU-intensive work after animations and transitions complete. This ensures smooth 60fps animations.

**Incorrect (heavy work during navigation transition):**

```typescript
function ProductDetailScreen({ route }) {
  const { productId } = route.params
  const [relatedProducts, setRelatedProducts] = useState([])
  const [reviews, setReviews] = useState([])

  useEffect(() => {
    // Starts immediately, competes with navigation animation
    fetchRelatedProducts(productId).then(setRelatedProducts)
    fetchReviews(productId).then(setReviews)
    processAnalytics(productId)
  }, [productId])

  return <ProductDetailContent />
}
// Navigation transition stutters
```

**Correct (defers work until after transition):**

```typescript
import { InteractionManager } from 'react-native'

function ProductDetailScreen({ route }) {
  const { productId } = route.params
  const [relatedProducts, setRelatedProducts] = useState([])
  const [reviews, setReviews] = useState([])

  useEffect(() => {
    // Wait for navigation animation to complete
    const task = InteractionManager.runAfterInteractions(() => {
      fetchRelatedProducts(productId).then(setRelatedProducts)
      fetchReviews(productId).then(setReviews)
      processAnalytics(productId)
    })

    return () => task.cancel()
  }, [productId])

  return <ProductDetailContent />
}
// Smooth navigation, then data loads
```

**With loading states:**

```typescript
function ProductDetailScreen({ route }) {
  const { productId } = route.params
  const [isReady, setIsReady] = useState(false)
  const [data, setData] = useState(null)

  useEffect(() => {
    const task = InteractionManager.runAfterInteractions(async () => {
      const result = await fetchProductDetails(productId)
      setData(result)
      setIsReady(true)
    })

    return () => task.cancel()
  }, [productId])

  if (!isReady) {
    return <ProductDetailSkeleton />  // Show skeleton during animation
  }

  return <ProductDetailContent data={data} />
}
```

**Create custom interaction handles for long animations:**

```typescript
import { InteractionManager } from 'react-native'

function ComplexAnimation() {
  const startAnimation = () => {
    const handle = InteractionManager.createInteractionHandle()

    // Run your animation
    Animated.timing(value, { ... }).start(() => {
      // Clear handle when animation completes
      InteractionManager.clearInteractionHandle(handle)
    })
  }
}
```

Reference: [InteractionManager Documentation](https://reactnative.dev/docs/interactionmanager)
