---
title: Optimize Image Assets for Bundle Size
impact: HIGH
impactDescription: 50-90% reduction in asset size
tags: bundle, images, assets, optimization, compression
---

## Optimize Image Assets for Bundle Size

Unoptimized images dramatically increase bundle size. Compress images and use appropriate formats.

**Incorrect (unoptimized images bundled):**

```tsx
// Large uncompressed PNG bundled directly
import logo from './assets/logo.png'           // 500KB PNG
import background from './assets/bg.png'       // 2MB PNG
import heroImage from './assets/hero.jpg'      // 1.5MB JPEG

// Using require for large assets
<Image source={require('./assets/large-photo.png')} />
```

**Correct (optimized and appropriately sized):**

```tsx
// Optimized images with proper formats
import logo from './assets/logo.webp'          // 50KB WebP
import background from './assets/bg.webp'      // 200KB WebP

// Use @2x and @3x for resolution-specific assets
// assets/icon.png      - 24×24 (1x)
// assets/icon@2x.png   - 48×48 (2x)
// assets/icon@3x.png   - 72×72 (3x)
<Image source={require('./assets/icon.png')} />

// Load large images from CDN instead of bundling
<Image source={{ uri: 'https://cdn.example.com/hero.webp' }} />
```

**Use expo-optimize for automatic compression:**

```bash
# Install optimization tool
npm install -g sharp-cli

# Compress all images in assets folder
npx expo-optimize ./assets

# Or use sharp directly
sharp -i ./assets/hero.png -o ./assets/hero.webp --quality 80
```

**Configure asset optimization in app.json:**

```json
{
  "expo": {
    "assetBundlePatterns": [
      "assets/fonts/*",
      "assets/icons/*"
    ],
    "extra": {
      "eas": {
        "projectId": "xxx"
      }
    }
  }
}
```

**Image format guidelines:**
| Use Case | Format | Reason |
|----------|--------|--------|
| Photos | WebP | 30% smaller than JPEG |
| Icons | SVG or PNG | Crisp at any size |
| Logos | SVG | Scales perfectly |
| Animated | Lottie | Smaller than GIF |

**Alternative (use expo-image for remote images):**

```tsx
import { Image } from 'expo-image'

// Automatic caching, placeholders, and optimization
<Image
  source="https://cdn.example.com/photo.webp"
  placeholder={blurhash}
  contentFit="cover"
  transition={200}
/>
```

Reference: [Expo Image Documentation](https://docs.expo.dev/versions/latest/sdk/image/)
