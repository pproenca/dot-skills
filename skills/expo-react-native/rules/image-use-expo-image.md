---
title: Use expo-image Instead of React Native Image
impact: HIGH
impactDescription: built-in caching, memory optimization, faster loading
tags: image, expo-image, caching, performance
---

## Use expo-image Instead of React Native Image

expo-image provides built-in disk and memory caching, placeholder support, and uses performant native libraries (SDWebImage on iOS, Glide on Android) under the hood.

**Incorrect (React Native Image without caching):**

```typescript
import { Image, View } from 'react-native'

function UserAvatar({ user }) {
  return (
    <View>
      <Image
        source={{ uri: user.avatarUrl }}
        style={{ width: 48, height: 48, borderRadius: 24 }}
      />
    </View>
  )
}
// No disk caching - reloads on every mount
// No placeholder - shows nothing while loading
```

**Correct (expo-image with caching and placeholder):**

```typescript
import { Image } from 'expo-image'
import { View } from 'react-native'

const blurhash = 'LEHV6nWB2yk8pyo0adR*.7kCMdnj'

function UserAvatar({ user }) {
  return (
    <View>
      <Image
        source={{ uri: user.avatarUrl }}
        placeholder={{ blurhash }}
        contentFit="cover"
        transition={200}
        style={{ width: 48, height: 48, borderRadius: 24 }}
        cachePolicy="disk"
      />
    </View>
  )
}
```

**Installation:**

```bash
npx expo install expo-image
```

**Cache policies:**

```typescript
// Memory only - fastest, clears on app close
cachePolicy="memory"

// Disk - persists across sessions
cachePolicy="disk"

// Memory and disk - best of both
cachePolicy="memory-disk"

// No caching - always fetch
cachePolicy="none"
```

**Benefits over React Native Image:**
- Automatic disk and memory caching
- BlurHash/ThumbHash placeholders
- Automatic resizing to container size
- Better memory management
- Animated image support (GIF, WebP)

Reference: [expo-image Documentation](https://docs.expo.dev/versions/latest/sdk/image/)
