---
title: Configure Metro Plugin with Required Options
impact: CRITICAL
impactDescription: missing configuration causes zero styles to apply
tags: build, metro, configuration, setup
---

## Configure Metro Plugin with Required Options

The Metro plugin is required for Uniwind to function. Without proper configuration, no styles will be processed at build time.

**Incorrect (missing Uniwind configuration):**

```javascript
// metro.config.js
const { getDefaultConfig } = require('expo/metro-config')

module.exports = getDefaultConfig(__dirname)
// No Uniwind integration - styles won't work
```

**Correct (properly configured):**

```javascript
// metro.config.js
const { getDefaultConfig } = require('expo/metro-config')
const { withUniwindConfig } = require('uniwind/metro')

const config = getDefaultConfig(__dirname)

module.exports = withUniwindConfig(config, {
  cssEntryFile: './src/global.css',
  dtsFile: './src/uniwind-types.d.ts',
})
```

**Key configuration options:**

- `cssEntryFile` (required): Path to your CSS entry file
- `dtsFile` (optional): Path for generated TypeScript definitions
- `extraThemes` (optional): Array of custom theme names
- `debug` (optional): Enable debug mode for development

Reference: [Uniwind Metro Config](https://docs.uniwind.dev/api/metro-config)
