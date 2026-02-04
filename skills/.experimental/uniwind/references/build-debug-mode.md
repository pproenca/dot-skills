---
title: Enable Debug Mode During Development
impact: HIGH
impactDescription: identifies unsupported CSS properties before they cause runtime issues
tags: build, debug, development, errors
---

## Enable Debug Mode During Development

Debug mode logs warnings for unsupported CSS properties and invalid classNames. This catches issues at build time rather than runtime.

**Incorrect (no debug feedback):**

```javascript
// metro.config.js
module.exports = withUniwindConfig(config, {
  cssEntryFile: './src/global.css',
  // Web-specific CSS silently ignored, no feedback
})
```

**Correct (debug enabled in development):**

```javascript
// metro.config.js
module.exports = withUniwindConfig(config, {
  cssEntryFile: './src/global.css',
  debug: __DEV__,  // Only in development
})
```

**What debug mode catches:**

- Web-specific CSS properties (`float`, `cursor`, etc.)
- Invalid className syntax
- Missing theme variables
- Unsupported pseudo-classes (`hover:`, `visited:`)

**Disable in production:**

```javascript
debug: process.env.NODE_ENV !== 'production',
```

Reference: [Uniwind Metro Config](https://docs.uniwind.dev/api/metro-config)
