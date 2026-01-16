---
title: Use BlurHash or ThumbHash Placeholders
impact: MEDIUM-HIGH
impactDescription: eliminates layout shift, improves perceived loading speed
tags: image, placeholder, blurhash, thumbhash
---

## Use BlurHash or ThumbHash Placeholders

Show a compact placeholder while images load to prevent layout shift and improve perceived performance. BlurHash encodes an image preview in ~20-30 characters.

**Incorrect (no placeholder, content jumps):**

```typescript
import { Image } from 'expo-image'

function ProductCard({ product }) {
  return (
    <View>
      <Image
        source={{ uri: product.imageUrl }}
        style={{ width: 200, height: 200 }}
        // Blank space, then sudden image appearance
      />
      <Text>{product.name}</Text>
    </View>
  )
}
```

**Correct (BlurHash placeholder):**

```typescript
import { Image } from 'expo-image'

function ProductCard({ product }) {
  return (
    <View>
      <Image
        source={{ uri: product.imageUrl }}
        placeholder={{ blurhash: product.blurhash }}
        contentFit="cover"
        transition={300}
        style={{ width: 200, height: 200 }}
      />
      <Text>{product.name}</Text>
    </View>
  )
}
```

**Generate BlurHash on backend:**

```typescript
// Node.js with sharp and blurhash
import { encode } from 'blurhash'
import sharp from 'sharp'

async function generateBlurhash(imagePath) {
  const { data, info } = await sharp(imagePath)
    .raw()
    .ensureAlpha()
    .resize(32, 32, { fit: 'inside' })
    .toBuffer({ resolveWithObject: true })

  return encode(
    new Uint8ClampedArray(data),
    info.width,
    info.height,
    4,  // x components
    3   // y components
  )
}
// Returns: "LEHV6nWB2yk8pyo0adR*.7kCMdnj"
```

**ThumbHash alternative (preserves aspect ratio):**

```typescript
import { Image } from 'expo-image'

function ProductCard({ product }) {
  return (
    <Image
      source={{ uri: product.imageUrl }}
      placeholder={{ thumbhash: product.thumbhash }}
      style={{ width: 200, height: 200 }}
    />
  )
}
```

**Include hash in API response:**

```json
{
  "id": "prod_123",
  "name": "Running Shoes",
  "imageUrl": "https://cdn.example.com/shoes.webp",
  "blurhash": "LEHV6nWB2yk8pyo0adR*.7kCMdnj"
}
```

Reference: [BlurHash](https://blurha.sh/) | [ThumbHash](https://evanw.github.io/thumbhash/)
