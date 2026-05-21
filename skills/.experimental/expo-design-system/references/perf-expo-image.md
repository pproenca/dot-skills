---
title: Load Remote Images With expo-image and Caching
impact: MEDIUM
impactDescription: prevents redundant network fetches and decode jank
tags: perf, images, expo-image, caching
---

## Load Remote Images With expo-image and Caching

React Native's `Image` re-fetches and re-decodes a remote source on each mount and decodes large originals on the UI thread, so scrolling a patient list with avatars janks. `expo-image` caches decoded frames to memory and disk and decodes off the main thread, so revisiting the list is instant.

**Incorrect (RN Image without a cache policy):**

```typescript
import { Image } from 'react-native'

<Image source={{ uri: patient.avatarUrl }} style={{ width: 48, height: 48 }} />
// Re-fetches and re-decodes on every mount; large originals decode on the UI thread.
```

**Correct (expo-image with caching and a placeholder):**

```typescript
import { Image } from 'expo-image'

<Image
  source={patient.avatarUrl}
  style={{ width: 48, height: 48, borderRadius: 24 }}
  cachePolicy="memory-disk"
  transition={150}
  placeholder={require('./assets/avatar-blur.png')}
/>
// Decoded frames are cached on memory and disk, so revisiting the list avoids refetching.
```

Reference: [expo-image](https://docs.expo.dev/versions/latest/sdk/image/)
