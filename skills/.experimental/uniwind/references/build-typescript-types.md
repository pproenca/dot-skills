---
title: Configure TypeScript Definition File Location
impact: CRITICAL
impactDescription: enables autocomplete for all utilities and theme tokens
tags: build, typescript, types, autocomplete
---

## Configure TypeScript Definition File Location

Uniwind generates TypeScript definitions during build. Proper placement enables autocomplete for all utilities, platform variants, and custom CSS classes.

**Incorrect (types in root, not included in tsconfig):**

```javascript
// metro.config.js
module.exports = withUniwindConfig(config, {
  cssEntryFile: './src/global.css',
  dtsFile: './uniwind-types.d.ts',  // Root level, may not be included
})
```

**Correct (types in src for automatic inclusion):**

```javascript
// metro.config.js
module.exports = withUniwindConfig(config, {
  cssEntryFile: './src/global.css',
  dtsFile: './src/uniwind-types.d.ts',  // Auto-included by TypeScript
})
```

**Alternative (explicit tsconfig inclusion):**

```json
// tsconfig.json
{
  "compilerOptions": {
    "types": ["./uniwind-types.d.ts"]
  }
}
```

**Benefits of proper type generation:**
- Autocomplete for all Tailwind utilities
- Type checking for platform variants (`ios:`, `android:`)
- IntelliSense for custom CSS classes
- Theme token suggestions

Reference: [Uniwind Metro Config](https://docs.uniwind.dev/api/metro-config)
