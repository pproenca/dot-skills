---
title: Resize Images to Display Size
impact: HIGH
impactDescription: 50-90% memory reduction for oversized images
tags: image, resize, memory, contentFit
---

## Resize Images to Display Size

Loading a 4000x3000 image into a 100x100 avatar wastes memory and slows rendering. Resize images server-side or use expo-image's automatic resizing.

**Incorrect (full-resolution image for small display):**

```typescript
import { Image } from 'expo-image'

function UserAvatar({ user }) {
  return (
    <Image
      source={{ uri: user.profilePhotoUrl }}  // 4032x3024 original
      style={{ width: 48, height: 48 }}
      // 35MB in memory for a tiny avatar
    />
  )
}
```

**Correct (request resized image):**

```typescript
import { Image } from 'expo-image'
import { PixelRatio } from 'react-native'

function UserAvatar({ user }) {
  // Request image at actual pixel size needed
  const size = 48 * PixelRatio.get()  // 144px on 3x device
  const resizedUrl = `${user.profilePhotoUrl}?w=${size}&h=${size}&fit=cover`

  return (
    <Image
      source={{ uri: resizedUrl }}
      style={{ width: 48, height: 48 }}
      contentFit="cover"
    />
  )
}
```

**For local images, use ImageManipulator:**

```typescript
import * as ImageManipulator from 'expo-image-manipulator'

async function resizeImage(uri, targetWidth, targetHeight) {
  const result = await ImageManipulator.manipulateAsync(
    uri,
    [{ resize: { width: targetWidth, height: targetHeight } }],
    { compress: 0.8, format: ImageManipulator.SaveFormat.JPEG }
  )
  return result.uri
}
```

**Image CDN URL patterns:**

```typescript
// Cloudinary
`https://res.cloudinary.com/demo/image/upload/w_100,h_100,c_fill/${imageId}`

// Imgix
`https://example.imgix.net/image.jpg?w=100&h=100&fit=crop`

// AWS CloudFront + Lambda@Edge
`${baseUrl}?width=100&height=100`
```

**Note:** Always account for pixel density with `PixelRatio.get()` to avoid blurry images on high-DPI screens.

Reference: [expo-image-manipulator Documentation](https://docs.expo.dev/versions/latest/sdk/imagemanipulator/)
