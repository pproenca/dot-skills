---
title: Use expo-image for Image Loading
impact: MEDIUM-HIGH
impactDescription: automatic caching, placeholder support
tags: asset, expo-image, caching, images
---

## Use expo-image for Image Loading

expo-image provides built-in disk and memory caching, BlurHash placeholders, and automatic downscaling. It outperforms the standard Image component in both performance and developer experience.

**Incorrect (React Native Image, no caching):**

```typescript
// components/Avatar.tsx
import { Image } from 'react-native';

export function Avatar({ user }: Props) {
  return (
    <Image
      source={{ uri: user.avatarUrl }}
      style={styles.avatar}
    />
    // No caching, reloads on every mount
    // Flickers when source changes
  );
}
```

**Correct (expo-image with caching and placeholder):**

```typescript
// components/Avatar.tsx
import { Image } from 'expo-image';

export function Avatar({ user }: Props) {
  return (
    <Image
      source={{ uri: user.avatarUrl }}
      placeholder={user.avatarBlurhash}
      contentFit="cover"
      transition={200}
      style={styles.avatar}
    />
    // Automatic disk/memory caching
    // BlurHash shows while loading
    // Smooth transition when loaded
  );
}
```

**Key props:**
- `placeholder` - BlurHash or ThumbHash while loading
- `transition` - Fade duration in ms
- `cachePolicy` - Control caching behavior
- `recyclingKey` - For FlashList view recycling

Reference: [expo-image](https://docs.expo.dev/versions/latest/sdk/image/)
