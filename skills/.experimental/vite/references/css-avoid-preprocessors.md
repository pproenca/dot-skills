---
title: Prefer CSS Over Preprocessors When Possible
impact: MEDIUM
impactDescription: reduces transform overhead
tags: css, sass, less, stylus, native
---

## Prefer CSS Over Preprocessors When Possible

Modern CSS supports nesting, variables, and other features that previously required Sass/Less. Native CSS is faster to process.

**Incorrect (preprocessor for basic features):**

```scss
// styles.scss
$primary: #007bff;
$spacing: 8px;

.button {
  color: $primary;
  padding: $spacing;

  &:hover {
    opacity: 0.8;
  }

  .icon {
    margin-right: $spacing;
  }
}
// Requires sass compilation
```

**Correct (native CSS with nesting):**

```css
/* styles.css */
:root {
  --primary: #007bff;
  --spacing: 8px;
}

.button {
  color: var(--primary);
  padding: var(--spacing);

  &:hover {
    opacity: 0.8;
  }

  .icon {
    margin-right: var(--spacing);
  }
}
/* Native CSS, no preprocessing needed */
```

**When to use preprocessors:**
- Team already uses Sass/Less
- Need advanced functions (color manipulation)
- Complex mixins
- Existing codebase

**When to use native CSS:**
- New projects
- Simple styling needs
- Maximum performance
- Smaller team

**Enable CSS nesting in PostCSS:**

```javascript
// postcss.config.js
export default {
  plugins: {
    'postcss-nesting': {}
  }
}
```

Reference: [Performance | Vite](https://vite.dev/guide/performance)
