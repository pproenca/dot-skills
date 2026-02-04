---
title: Configure rem Base Value for Design System Consistency
impact: HIGH
impactDescription: mismatched rem values cause incorrect spacing across entire app
tags: build, rem, polyfill, spacing
---

## Configure rem Base Value for Design System Consistency

Uniwind defaults to 16px for rem calculations. If your design system uses a different base, configure the polyfill to match.

**Incorrect (assuming NativeWind's 14px default):**

```javascript
// metro.config.js
module.exports = withUniwindConfig(config, {
  cssEntryFile: './src/global.css',
  // Using default 16px, but design uses 14px base
})
```

```tsx
// p-4 = 16px (1rem × 16), but design expects 14px
<View className="p-4" />
```

**Correct (matching design system):**

```javascript
// metro.config.js
module.exports = withUniwindConfig(config, {
  cssEntryFile: './src/global.css',
  polyfills: {
    rem: 14,  // Match your design system's base
  },
})
```

**When to change rem:**

- Migrating from NativeWind (uses 14px default)
- Design system specifies different base font size
- Web app migration with existing rem-based spacing

**Keep default 16px when:**
- Starting fresh with Uniwind
- Using Tailwind's standard spacing scale
- No existing design system constraints

Reference: [Uniwind Metro Config](https://docs.uniwind.dev/api/metro-config)
