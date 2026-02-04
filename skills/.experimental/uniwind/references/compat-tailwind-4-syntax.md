---
title: Use Tailwind 4 CSS-First Configuration
impact: LOW-MEDIUM
impactDescription: enables proper theming and eliminates tailwind.config.js
tags: compat, tailwind-4, css, configuration
---

## Use Tailwind 4 CSS-First Configuration

Uniwind requires Tailwind 4 syntax. Configuration moves from JavaScript (tailwind.config.js) to CSS (@theme directive).

**Incorrect (Tailwind 3 JavaScript config):**

```javascript
// tailwind.config.js - DON'T USE THIS
module.exports = {
  theme: {
    extend: {
      colors: {
        primary: '#3b82f6',
        background: '#ffffff',
      },
    },
  },
}
```

**Correct (Tailwind 4 CSS config):**

```css
/* global.css */
@import 'tailwindcss';
@import 'uniwind';

@theme {
  --color-primary: #3b82f6;
  --color-background: #ffffff;
  --color-foreground: #0a0a0a;

  /* Custom spacing */
  --spacing-18: 4.5rem;

  /* Custom breakpoints */
  --breakpoint-tablet: 768px;
}
```

**Key differences:**

| Tailwind 3 | Tailwind 4 |
|------------|------------|
| `tailwind.config.js` | `@theme` in CSS |
| `theme.extend.colors` | `--color-*` variables |
| `theme.extend.spacing` | `--spacing-*` variables |
| `theme.screens` | `--breakpoint-*` variables |
| JavaScript module | Pure CSS |

Reference: [Tailwind CSS v4 Theme](https://tailwindcss.com/docs/theme)
