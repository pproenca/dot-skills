---
title: Lazy Load Off-Screen Images
impact: MEDIUM-HIGH
impactDescription: reduces initial memory footprint and network requests
tags: image, lazy-loading, offscreen, virtualization
---

## Lazy Load Off-Screen Images

Only load images when they're about to become visible. For lists, FlashList handles this automatically. For grids and custom layouts, implement manual lazy loading.

**Incorrect (all images load immediately):**

```typescript
import { Image } from 'expo-image'
import { ScrollView } from 'react-native'

function PhotoGallery({ photos }) {
  return (
    <ScrollView>
      {photos.map(photo => (
        <Image
          key={photo.id}
          source={{ uri: photo.url }}
          style={styles.photo}
        />  // All 100 images start loading immediately
      ))}
    </ScrollView>
  )
}
// Network saturated, high memory usage
```

**Correct (images load when visible):**

```typescript
import { Image } from 'expo-image'
import { FlashList } from '@shopify/flash-list'

function PhotoGallery({ photos }) {
  return (
    <FlashList
      data={photos}
      renderItem={({ item }) => (
        <Image
          source={{ uri: item.url }}
          style={styles.photo}
          contentFit="cover"
        />
      )}
      estimatedItemSize={200}
      numColumns={3}
    />
  )
}
// FlashList only renders visible items + buffer
```

**Manual lazy loading with visibility detection:**

```typescript
import { Image } from 'expo-image'
import { View, useWindowDimensions } from 'react-native'
import { useRef, useState, useCallback } from 'react'

function LazyImage({ source, style }) {
  const [isVisible, setIsVisible] = useState(false)
  const { height: screenHeight } = useWindowDimensions()

  const handleLayout = useCallback((event) => {
    const { y } = event.nativeEvent.layout
    // Load if within 2 screens of viewport
    if (y < screenHeight * 2) {
      setIsVisible(true)
    }
  }, [screenHeight])

  return (
    <View style={style} onLayout={handleLayout}>
      {isVisible ? (
        <Image source={source} style={style} />
      ) : (
        <View style={[style, styles.placeholder]} />
      )}
    </View>
  )
}
```

**expo-image recyclingKey for list image recycling:**

```typescript
<FlashList
  data={products}
  renderItem={({ item }) => (
    <Image
      source={{ uri: item.imageUrl }}
      recyclingKey={item.id}  // Helps with image recycling in lists
      style={styles.productImage}
    />
  )}
  estimatedItemSize={120}
/>
```

Reference: [expo-image recyclingKey](https://docs.expo.dev/versions/latest/sdk/image/#recyclingkey)
