---
title: Remove Built-in Plugins
impact: HIGH
impactDescription: eliminates duplicate code, reduces dependencies
tags: bundle, plugins, container-queries, built-in, optimization
---

## Remove Built-in Plugins

Tailwind CSS v4 includes features that previously required separate plugins. Remove these plugins to avoid duplicate code and reduce bundle size.

**Incorrect (unnecessary plugins):**

```json
{
  "devDependencies": {
    "tailwindcss": "^4.0.0",
    "@tailwindcss/container-queries": "^0.1.0",
    "@tailwindcss/aspect-ratio": "^0.4.0"
  }
}
```

```css
/* Duplicate functionality */
@import "@tailwindcss/container-queries";
```

**Correct (use built-in features):**

```json
{
  "devDependencies": {
    "tailwindcss": "^4.0.0"
  }
}
```

```html
<!-- Container queries are built-in -->
<div class="@container">
  <div class="@sm:grid-cols-3 @lg:grid-cols-4">Content</div>
</div>

<!-- Aspect ratio is built-in -->
<div class="aspect-video">Video</div>
```

**Built-in features in v4:**
- Container queries (`@container`, `@sm:`, `@lg:`)
- Aspect ratio utilities
- Logical properties
- 3D transforms

Reference: [Tailwind CSS v4.0 Release](https://tailwindcss.com/blog/tailwindcss-v4)
