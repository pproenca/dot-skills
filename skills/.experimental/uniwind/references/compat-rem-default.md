---
title: Account for Different rem Default Values
impact: LOW-MEDIUM
impactDescription: prevents 14% spacing difference after migration
tags: compat, rem, spacing, migration
---

## Account for Different rem Default Values

NativeWind uses 14px as rem default, Uniwind uses 16px. Adjust the polyfill if preserving existing spacing.

**Incorrect (ignoring rem difference):**

```javascript
// metro.config.js
module.exports = withUniwindConfig(config, {
  cssEntryFile: './src/global.css',
  // Using default 16px when app was designed for 14px
})
```

```tsx
// p-4 = 16px in Uniwind, but was 14px in NativeWind
// 14% larger spacing across the entire app!
<View className="p-4 gap-4">
  <Text className="text-base">Spacing is off</Text>
</View>
```

**Correct (matching NativeWind's rem for migration):**

```javascript
// metro.config.js
module.exports = withUniwindConfig(config, {
  cssEntryFile: './src/global.css',
  polyfills: {
    rem: 14,  // Match NativeWind's default
  },
})
```

```tsx
// Now p-4 = 14px, matching original design
<View className="p-4 gap-4">
  <Text className="text-base">Spacing matches original</Text>
</View>
```

**When to use each:**

| Scenario | rem Value |
|----------|-----------|
| Migrating existing NativeWind app | 14px |
| Design system uses 14px base | 14px |
| New Uniwind project | 16px (default) |
| Web app migration | 16px |

Reference: [Uniwind Migration Guide](https://docs.uniwind.dev/migration-from-nativewind)
