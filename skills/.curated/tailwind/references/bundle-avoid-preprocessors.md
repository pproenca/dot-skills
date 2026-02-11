---
title: Avoid Sass/Less Preprocessors
impact: HIGH
impactDescription: prevents compatibility issues, enables native features
tags: bundle, preprocessors, sass, less, css, compatibility
---

## Avoid Sass/Less Preprocessors

Tailwind CSS v4 is incompatible with Sass, Less, and Stylus preprocessors. Modern CSS and Tailwind's built-in features replace the need for these tools.

**Incorrect (preprocessor syntax):**

```scss
// styles.scss
@import "tailwindcss"; // May fail with preprocessor

.navigation {
  $spacing: 1rem;
  padding: $spacing;

  &__item {
    color: $brand-color;

    &:hover {
      color: darken($brand-color, 10%);
    }
  }
}
```

**Correct (native CSS with Tailwind):**

```css
/* styles.css */
@import "tailwindcss";

.navigation {
  padding: var(--spacing-4);

  &__item {
    color: var(--color-brand);

    &:hover {
      color: oklch(from var(--color-brand) calc(l - 0.1) c h);
    }
  }
}
```

**Native CSS alternatives:**
- CSS nesting (built into v4)
- CSS custom properties (replace Sass variables)
- `@theme` directive (replace Sass maps)
- `calc()` and modern CSS functions
- `oklch(from ...)` relative color syntax (replace Sass `darken`/`lighten`)

Reference: [Tailwind CSS Upgrade Guide](https://tailwindcss.com/docs/upgrade-guide)
