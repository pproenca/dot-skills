---
title: Avoid Unnecessary Polyfills
impact: HIGH
impactDescription: 10-50KB bundle size reduction
tags: bundle, polyfills, hermes, native-apis
---

## Avoid Unnecessary Polyfills

Hermes supports most modern JavaScript features natively. Many polyfills are no longer needed and add unnecessary bundle weight.

**Incorrect (including unneeded polyfills):**

```tsx
// Unnecessary - Hermes supports these natively
import 'core-js/stable'
import 'regenerator-runtime/runtime'

// Polyfilling already-supported features
import { Buffer } from 'buffer'  // Often not needed
import 'react-native-url-polyfill/auto'  // Check if actually needed
```

```json
// package.json - unnecessary dependencies
{
  "dependencies": {
    "core-js": "^3.0.0",
    "regenerator-runtime": "^0.13.0",
    "react-native-get-random-values": "^1.0.0"
  }
}
```

**Correct (use native Hermes features):**

```tsx
// Hermes supports these natively (Expo SDK 48+):
// - Async/await
// - Array methods (map, filter, find, includes, flat, flatMap)
// - Object methods (entries, values, keys, fromEntries)
// - String methods (includes, startsWith, endsWith, padStart)
// - Promise, Symbol, WeakMap, WeakSet
// - Optional chaining (?.)
// - Nullish coalescing (??)

// Use native crypto when available
import * as Crypto from 'expo-crypto'
const uuid = Crypto.randomUUID()  // Native, no polyfill

// Use native URL
const url = new URL('https://api.example.com/users')
url.searchParams.set('page', '1')
```

**Check what you actually need:**

```tsx
// Only polyfill if you see runtime errors
// Test in production build first

// If you need Buffer (rare)
import { Buffer } from 'buffer'
global.Buffer = Buffer

// If you need TextEncoder/TextDecoder (some crypto libs)
import 'text-encoding-polyfill'
```

**Hermes feature support by SDK version:**
- SDK 48+: Most ES2020 features
- SDK 49+: Intl APIs (DateTimeFormat, NumberFormat)
- SDK 50+: Additional Intl locales

Reference: [Hermes Language Features](https://hermesengine.dev/docs/language-features)
