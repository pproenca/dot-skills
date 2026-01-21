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

.card {
  @apply bg-white rounded-lg;

  &:hover {
    @apply shadow-lg;
  }

  $padding: 1rem;
  padding: $padding;
}
```

**Correct (native CSS with Tailwind):**

```css
/* styles.css */
@import "tailwindcss";

@utility card {
  @apply bg-white rounded-lg;

  &:hover {
    @apply shadow-lg;
  }

  padding: var(--spacing-4);
}
```

**Native CSS alternatives:**
- CSS nesting (built into v4)
- CSS custom properties (replace Sass variables)
- `@theme` directive (replace Sass maps)
- `calc()` and modern CSS functions

Reference: [Tailwind CSS Upgrade Guide](https://tailwindcss.com/docs/upgrade-guide)
