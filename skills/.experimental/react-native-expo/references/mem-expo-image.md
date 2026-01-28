---
title: Use expo-image for Efficient Image Caching
impact: MEDIUM
impactDescription: reduces memory usage and network requests
tags: mem, images, expo-image, caching, performance
---

## Use expo-image for Efficient Image Caching

expo-image provides automatic caching, memory management, and placeholder support superior to React Native's Image component.

**Incorrect (React Native Image with poor caching):**

```tsx
import { Image } from 'react-native'

function ProductCard({ product }) {
  return (
    <View>
      {/* No built-in caching, re-fetches on remount */}
      <Image
        source={{ uri: product.imageUrl }}
        style={{ width: 200, height: 200 }}
      />
      {/* Flickers when source changes */}
      {/* No placeholder during load */}
    </View>
  )
}
```

**Correct (expo-image with caching):**

```tsx
import { Image } from 'expo-image'

function ProductCard({ product }) {
  return (
    <View>
      <Image
        source={product.imageUrl}
        style={{ width: 200, height: 200 }}
        contentFit="cover"
        // Smooth transition prevents flicker
        transition={200}
        // Placeholder while loading
        placeholder={product.blurhash}
        // Cache policy
        cachePolicy="memory-disk"
      />
    </View>
  )
}
```

**Configure cache policies:**

```tsx
import { Image } from 'expo-image'

// Memory + disk cache (default, best for most cases)
<Image source={url} cachePolicy="memory-disk" />

// Memory only (for sensitive images)
<Image source={url} cachePolicy="memory" />

// Disk only (for large images accessed infrequently)
<Image source={url} cachePolicy="disk" />

// No caching (rarely needed)
<Image source={url} cachePolicy="none" />
```

**Use placeholders for better UX:**

```tsx
// BlurHash placeholder (most common)
<Image
  source="https://example.com/photo.jpg"
  placeholder="LKO2?U%2Tw=w]~RBVZRi};RPxuwH"
  contentFit="cover"
  transition={200}
/>

// ThumbHash placeholder (smaller, supports transparency)
<Image
  source="https://example.com/photo.png"
  placeholder={{ thumbhash: 'HBkSHYSIeHiPiHh8eJd4eTN0EEQG' }}
  contentFit="cover"
  transition={200}
/>

// Color placeholder (simplest)
<Image
  source="https://example.com/photo.jpg"
  placeholder="#e0e0e0"
  contentFit="cover"
  transition={200}
/>
```

**Prefetch images:**

```tsx
import { Image } from 'expo-image'

// Prefetch single image
await Image.prefetch('https://example.com/hero.jpg')

// Prefetch multiple images
await Promise.all([
  Image.prefetch('https://example.com/product1.jpg'),
  Image.prefetch('https://example.com/product2.jpg'),
  Image.prefetch('https://example.com/product3.jpg'),
])

// Prefetch on component mount
useEffect(() => {
  products.forEach(p => Image.prefetch(p.imageUrl))
}, [products])
```

**Clear cache when needed:**

```tsx
import { Image } from 'expo-image'

// Clear all cached images
await Image.clearDiskCache()
await Image.clearMemoryCache()

// Useful for:
// - User logout (clear sensitive images)
// - Low memory warnings
// - Manual cache refresh
```

**Memory optimization:**

```tsx
// Force resize to reduce memory
<Image
  source={largeImageUrl}
  style={{ width: 100, height: 100 }}
  // Image is resized before storing in memory
  contentFit="cover"
/>

// Priority for lists
<Image
  source={url}
  priority={isVisible ? 'high' : 'low'}
/>
```

Reference: [Expo Image Documentation](https://docs.expo.dev/versions/latest/sdk/image/)
