---
title: Use @custom-variant for Custom Variant Definitions
impact: MEDIUM-HIGH
impactDescription: enables reusable custom variants without JavaScript plugins
tags: comp, custom-variant, variants, selectors, themes
---

## Use @custom-variant for Custom Variant Definitions

Use the `@custom-variant` directive to define custom variants directly in CSS, replacing the need for JavaScript plugins. Custom variants work with all utility classes just like built-in variants.

**Incorrect (JavaScript plugin for custom variant):**

```javascript
// tailwind.config.js — v3 approach
const plugin = require("tailwindcss/plugin");

module.exports = {
  plugins: [
    plugin(function ({ addVariant }) {
      addVariant("theme-midnight", "&:where([data-theme='midnight'] *)");
      addVariant("sidebar-open", "&:where([data-sidebar='open'] *)");
    }),
  ],
};
```

**Correct (CSS-first with @custom-variant):**

```css
/* styles.css */
@import "tailwindcss";

@custom-variant theme-midnight (&:where([data-theme="midnight"] *));
@custom-variant sidebar-open (&:where([data-sidebar="open"] *));
```

```html
<div data-theme="midnight">
  <p class="text-gray-900 theme-midnight:text-white">
    Adapts to midnight theme
  </p>
</div>

<nav class="w-16 sidebar-open:w-64 transition-all">
  Expands when sidebar is open
</nav>
```

**Multi-rule custom variants:**

```css
@custom-variant theme-dark {
  &:where([data-theme="dark"] *) {
    @slot;
  }
}

/* For group-like patterns */
@custom-variant pointer-fine (@media (pointer: fine));
```

**Note:** Use `@variant` (without "custom") to apply existing variants within CSS blocks, and `@custom-variant` to define new variants.

Reference: [Tailwind CSS Functions and Directives](https://tailwindcss.com/docs/functions-and-directives)
