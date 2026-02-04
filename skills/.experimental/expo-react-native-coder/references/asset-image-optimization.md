---
title: Use expo-image for Optimized Image Loading
impact: MEDIUM
impactDescription: better caching and performance than Image component
tags: asset, image, caching, performance
---

## Use expo-image for Optimized Image Loading

Use `expo-image` instead of React Native's `Image` for better caching, performance, and format support (including WebP and AVIF).

**Incorrect (basic Image component):**

```typescript
import { Image } from 'react-native';

<Image
  source={{ uri: 'https://example.com/photo.jpg' }}
  style={{ width: 200, height: 200 }}
/>
// No caching strategy, no placeholder, no loading state
```

**Correct (expo-image with caching):**

```bash
npx expo install expo-image
```

```typescript
import { Image } from 'expo-image';
import { StyleSheet, View } from 'react-native';

const blurhash = '|rF?hV%2WCj[ayj[a|j[az_NaeWBj@ayfRayfQfQM{M|azj[azf6fQfQfQIpWXofj[ayj[j[fQayWCoeoeaya}j[ayfQa{oLj?j[WVj[ayayj[fQoff7teleayj[ayj[ayofayayayj[fQj[ayayj[ayfjj[j[ayjuayj[';

export default function ProfileImage({ uri }: { uri: string }) {
  return (
    <Image
      source={uri}
      placeholder={{ blurhash }}
      contentFit="cover"
      transition={200}
      style={styles.image}
      cachePolicy="memory-disk"  // Cache in memory and disk
    />
  );
}

// For local images
function LocalImage() {
  return (
    <Image
      source={require('@/assets/images/logo.png')}
      style={styles.logo}
      contentFit="contain"
    />
  );
}

const styles = StyleSheet.create({
  image: { width: 100, height: 100, borderRadius: 50 },
  logo: { width: 200, height: 80 },
});
```

**Key features:**
- `placeholder`: Blurhash or low-res image while loading
- `transition`: Fade-in animation duration (ms)
- `contentFit`: `cover`, `contain`, `fill`, `none`, `scale-down`
- `cachePolicy`: `memory`, `disk`, `memory-disk`, `none`

Reference: [expo-image - Expo Documentation](https://docs.expo.dev/versions/latest/sdk/image/)
