---
title: Migrate tailwind.config.js to CSS @theme
impact: CRITICAL
impactDescription: eliminates JS config dependency, enables CSS-native design tokens
tags: config, theme, design-tokens, css-variables
---

## Migrate tailwind.config.js to CSS @theme

Tailwind CSS v4 replaces the JavaScript configuration file with a CSS-native `@theme` directive. Moving your design tokens into CSS eliminates the JS build dependency, enables standard CSS tooling to understand your tokens, and makes them available as CSS custom properties throughout your project without any extra configuration.

**Incorrect (what's wrong):**

```js
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      colors: {
        brand: '#3b82f6',
        surface: '#f8fafc',
      },
      fontFamily: {
        display: ['Inter', 'sans-serif'],
      },
      spacing: {
        18: '4.5rem',
      },
    },
  },
};
```

**Correct (what's right):**

```css
@import "tailwindcss";

@theme {
  --color-brand: #3b82f6;
  --color-surface: #f8fafc;
  --font-display: "Inter", sans-serif;
  --spacing-18: 4.5rem;
}
```

If you have a large or complex config that cannot be migrated all at once, use the escape hatch to reference a legacy config file:

```css
@config "../../tailwind.config.js";
```
