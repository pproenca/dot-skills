---
title: Use WebP Format for Smaller File Sizes
impact: HIGH
impactDescription: 25-35% smaller than JPEG, 26% smaller than PNG
tags: image, webp, format, compression
---

## Use WebP Format for Smaller File Sizes

WebP provides superior compression compared to JPEG and PNG while maintaining quality. Both iOS and Android fully support WebP.

**Incorrect (unoptimized PNG/JPEG):**

```typescript
import { Image } from 'expo-image'

function ProductGallery({ images }) {
  return (
    <View>
      {images.map(img => (
        <Image
          key={img.id}
          source={{ uri: img.pngUrl }}  // 500KB PNG
          style={styles.productImage}
        />
      ))}
    </View>
  )
}
```

**Correct (WebP format):**

```typescript
import { Image } from 'expo-image'

function ProductGallery({ images }) {
  return (
    <View>
      {images.map(img => (
        <Image
          key={img.id}
          source={{ uri: img.webpUrl }}  // 175KB WebP (same quality)
          style={styles.productImage}
        />
      ))}
    </View>
  )
}
```

**Convert local assets to WebP:**

```bash
# Using cwebp (install via Homebrew: brew install webp)
cwebp -q 80 input.png -o output.webp

# Batch convert
for f in assets/images/*.png; do
  cwebp -q 80 "$f" -o "${f%.png}.webp"
done
```

**Request WebP from image CDN:**

```typescript
// Cloudinary - automatic format selection
`https://res.cloudinary.com/demo/image/upload/f_auto/${imageId}`

// Imgix
`https://example.imgix.net/image.jpg?fm=webp&q=80`

// Direct WebP URL
`${baseUrl}/images/${imageId}.webp`
```

**Format comparison:**
| Format | 1000x1000 Photo | Transparency |
|--------|-----------------|--------------|
| PNG | 2.5 MB | Yes |
| JPEG | 150 KB | No |
| WebP | 100 KB | Yes |

**Note:** For animated images, WebP also outperforms GIF with smaller file sizes and better quality.

Reference: [WebP Documentation](https://developers.google.com/speed/webp)
