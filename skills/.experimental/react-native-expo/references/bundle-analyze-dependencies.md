---
title: Analyze Bundle Size Before Adding Dependencies
impact: CRITICAL
impactDescription: prevents 100KB+ additions per dependency
tags: bundle, dependencies, analysis, metro, expo-atlas
---

## Analyze Bundle Size Before Adding Dependencies

A single dependency can add hundreds of kilobytes to your bundle. Analyze impact before installing.

**Incorrect (installing without analysis):**

```bash
# Installing without knowing the cost
npm install moment              # +300KB
npm install lodash              # +70KB
npm install react-native-paper  # +150KB (+ dependencies)
```

**Correct (analyze before installing):**

```bash
# Check bundle cost on bundlephobia.com first
# moment: 300KB minified, 72KB gzipped
# date-fns: 85KB but tree-shakeable to ~5KB per function

# Use package-phobia for React Native specific
npx package-phobia react-native-paper

# After installing, verify actual impact
npx react-native-bundle-visualizer
```

**Using Expo Atlas for analysis:**

```bash
# Generate bundle analysis
npx expo export --dump-assetmap

# View bundle contents
npx expo-atlas
```

**Check alternatives before installing:**

```tsx
// Instead of moment.js (300KB)
// Use date-fns (tree-shakeable) or dayjs (2KB)
import dayjs from 'dayjs'

// Instead of lodash (70KB)
// Use native methods or lodash-es with bundler
const unique = [...new Set(array)]
const grouped = Object.groupBy(items, item => item.category)

// Instead of uuid (15KB)
// Use expo-crypto
import * as Crypto from 'expo-crypto'
const uuid = Crypto.randomUUID()
```

**Questions to ask before adding a dependency:**
1. What's the minified + gzipped size?
2. Is it tree-shakeable?
3. Can I use a native API instead?
4. Is there a smaller alternative?
5. Will I use more than 10% of its features?

Reference: [Expo Atlas Documentation](https://docs.expo.dev/guides/analyzing-bundles/)
