---
title: Register Custom Themes in Metro Config
impact: CRITICAL
impactDescription: unregistered themes are not compiled and won't work at runtime
tags: theme, custom-theme, metro, extra-themes
---

## Register Custom Themes in Metro Config

Custom themes beyond light/dark must be registered in Metro's `extraThemes` array. Unregistered themes won't be compiled.

**Incorrect (theme defined but not registered):**

```css
/* global.css */
@layer theme {
  :root {
    @variant ocean {
      --color-background: #0c4a6e;
      --color-foreground: #e0f2fe;
    }
  }
}
```

```javascript
// metro.config.js
module.exports = withUniwindConfig(config, {
  cssEntryFile: './src/global.css',
  // extraThemes missing - 'ocean' won't work!
})
```

**Correct (theme registered):**

```javascript
// metro.config.js
module.exports = withUniwindConfig(config, {
  cssEntryFile: './src/global.css',
  extraThemes: ['ocean', 'sunset', 'forest'],  // Register all custom themes
})
```

```typescript
// Now you can switch to custom themes
Uniwind.setTheme('ocean')
```

**After adding themes:**
1. Register in `extraThemes`
2. Define `@variant` block in CSS
3. Restart Metro with `--clear` flag

Reference: [Uniwind Custom Themes](https://docs.uniwind.dev/theming/custom-themes)
