---
title: Replace cssInterop with withUniwind
impact: LOW-MEDIUM
impactDescription: prevents runtime errors from incompatible API
tags: compat, cssinterop, with-uniwind, migration
---

## Replace cssInterop with withUniwind

NativeWind uses `cssInterop` for third-party components. Uniwind uses `withUniwind` with a different API.

**Incorrect (NativeWind's cssInterop):**

```tsx
import { cssInterop } from 'nativewind'  // Doesn't exist in Uniwind!
import { LinearGradient } from 'expo-linear-gradient'

cssInterop(LinearGradient, {
  className: 'style',
  contentContainerClassName: 'contentContainerStyle',
})

// Runtime error: cssInterop is not a function
```

**Correct (Uniwind's withUniwind):**

```tsx
import { withUniwind } from 'uniwind'
import { LinearGradient as BaseLinearGradient } from 'expo-linear-gradient'

export const LinearGradient = withUniwind(BaseLinearGradient)

// For custom prop mappings
export const LinearGradientWithProps = withUniwind(BaseLinearGradient, {
  contentContainerStyle: {
    fromClassName: 'contentContainerClassName',
  },
})
```

**Key API differences:**

| NativeWind `cssInterop` | Uniwind `withUniwind` |
|------------------------|---------------------|
| Mutates globally | Returns new component |
| Called once at setup | Define at module level |
| Maps className to style | className works by default |

Reference: [Uniwind withUniwind API](https://docs.uniwind.dev/api/with-uniwind)
