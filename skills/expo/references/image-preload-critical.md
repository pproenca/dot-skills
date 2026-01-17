---
title: Preload Critical Above-the-Fold Images
impact: MEDIUM-HIGH
impactDescription: eliminates loading delay for first visible images
tags: image, preload, prefetch, above-the-fold
---

## Preload Critical Above-the-Fold Images

Preload images that appear immediately when a screen loads. This ensures they're ready to display without network delay.

**Incorrect (images load on render):**

```typescript
import { Image } from 'expo-image'

function HomeScreen() {
  return (
    <View>
      <Image
        source={{ uri: 'https://cdn.example.com/hero-banner.webp' }}
        style={styles.heroBanner}
        // Network request starts when component mounts
      />
    </View>
  )
}
```

**Correct (preloaded during splash screen):**

```typescript
import { Image } from 'expo-image'
import * as SplashScreen from 'expo-splash-screen'

SplashScreen.preventAutoHideAsync()

const criticalImages = [
  'https://cdn.example.com/hero-banner.webp',
  'https://cdn.example.com/logo.webp',
]

async function preloadImages() {
  await Promise.all(
    criticalImages.map(uri => Image.prefetch(uri))
  )
}

export default function App() {
  const [ready, setReady] = useState(false)

  useEffect(() => {
    preloadImages().then(() => setReady(true))
  }, [])

  useEffect(() => {
    if (ready) {
      SplashScreen.hideAsync()
    }
  }, [ready])

  if (!ready) return null

  return <RootNavigator />
}
```

**Prefetch before navigation:**

```typescript
import { Image } from 'expo-image'
import { useRouter } from 'expo-router'

function ProductListItem({ product }) {
  const router = useRouter()

  const handlePress = async () => {
    // Start prefetching before navigation completes
    Image.prefetch(product.fullImageUrl)
    router.push(`/product/${product.id}`)
  }

  return (
    <Pressable onPress={handlePress}>
      <Image source={{ uri: product.thumbnailUrl }} />
      <Text>{product.name}</Text>
    </Pressable>
  )
}
```

**useImage hook for preloading with metadata:**

```typescript
import { useImage } from 'expo-image'

function ProductDetail({ productId }) {
  const imageSource = useImage(`https://cdn.example.com/products/${productId}.webp`)

  if (!imageSource) {
    return <LoadingSkeleton />
  }

  return (
    <Image
      source={imageSource}
      style={{ width: imageSource.width, height: imageSource.height }}
    />
  )
}
```

Reference: [expo-image Prefetching](https://docs.expo.dev/versions/latest/sdk/image/#prefetching)
