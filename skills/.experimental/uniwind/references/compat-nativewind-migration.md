---
title: Follow NativeWind Migration Checklist
impact: LOW-MEDIUM
impactDescription: prevents 5-10 common migration errors
tags: compat, nativewind, migration, checklist
---

## Follow NativeWind Migration Checklist

Migrating from NativeWind to Uniwind requires several configuration changes. Follow this checklist to avoid issues.

**Incorrect (keeping NativeWind configuration):**

```javascript
// babel.config.js - WRONG: NativeWind preset
module.exports = {
  presets: ['nativewind/babel'],  // Remove this!
}
```

```javascript
// metro.config.js - WRONG: No Uniwind config
const { getDefaultConfig } = require('expo/metro-config')
module.exports = getDefaultConfig(__dirname)  // Missing withUniwindConfig!
```

**Correct (Uniwind configuration):**

```javascript
// babel.config.js - No NativeWind preset needed
module.exports = {
  presets: ['babel-preset-expo'],
}
```

```javascript
// metro.config.js - Uniwind configuration
const { getDefaultConfig } = require('expo/metro-config')
const { withUniwindConfig } = require('uniwind/metro')

const config = getDefaultConfig(__dirname)
module.exports = withUniwindConfig(config, {
  cssEntryFile: './src/global.css',
})
```

**Full migration checklist:**

1. Install: `bun add uniwind tailwindcss && bun remove nativewind`
2. Remove Babel preset from babel.config.js
3. Update Metro config with withUniwindConfig
4. Update CSS: `@import 'tailwindcss'; @import 'uniwind';`
5. Delete nativewind.d.ts
6. Remove ThemeProvider
7. Replace cssInterop with withUniwind
8. Delete tailwind.config.js

Reference: [Uniwind Migration Guide](https://docs.uniwind.dev/migration-from-nativewind)
