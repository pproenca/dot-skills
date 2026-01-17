---
title: Subset Custom Fonts to Used Characters
impact: MEDIUM-HIGH
impactDescription: 50-90% font file size reduction
tags: bundle, fonts, subsetting, assets
---

## Subset Custom Fonts to Used Characters

Custom fonts often include thousands of glyphs for multiple languages. Subset fonts to include only the characters your app actually uses.

**Incorrect (full font file):**

```typescript
// Using complete font file (400KB+)
import * as Font from 'expo-font'

await Font.loadAsync({
  'Inter-Bold': require('./assets/fonts/Inter-Bold.ttf'),  // 300KB
  'Inter-Regular': require('./assets/fonts/Inter-Regular.ttf'),  // 290KB
})
```

**Correct (subsetted fonts):**

```bash
# Subset font using fonttools (Python)
pip install fonttools brotli

# Subset to Latin characters only
pyftsubset Inter-Bold.ttf \
  --unicodes="U+0000-00FF,U+0131,U+0152-0153,U+02BB-02BC,U+02C6,U+02DA,U+02DC,U+2000-206F" \
  --output-file="Inter-Bold-subset.ttf"
```

```typescript
// Using subsetted font file (40KB)
import * as Font from 'expo-font'

await Font.loadAsync({
  'Inter-Bold': require('./assets/fonts/Inter-Bold-subset.ttf'),  // 40KB
  'Inter-Regular': require('./assets/fonts/Inter-Regular-subset.ttf'),  // 38KB
})
```

**Alternative (use Google Fonts with expo-google-fonts):**

```typescript
import { useFonts, Inter_700Bold } from '@expo-google-fonts/inter'

// Google Fonts are already optimized and cached
const [fontsLoaded] = useFonts({
  Inter_700Bold,
})
```

**Common Unicode ranges:**
| Range | Description |
|-------|-------------|
| U+0000-00FF | Latin Basic + Supplement |
| U+0100-017F | Latin Extended-A |
| U+0400-04FF | Cyrillic |
| U+0600-06FF | Arabic |

Reference: [fonttools Documentation](https://fonttools.readthedocs.io/)
