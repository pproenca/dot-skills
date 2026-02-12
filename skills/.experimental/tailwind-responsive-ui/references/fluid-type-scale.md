---
title: Use a Responsive Type Scale
impact: MEDIUM
impactDescription: 50% smaller heading sizes on mobile vs desktop
tags: fluid, type-scale, custom-properties, theme, modular-scale
---

## Use a Responsive Type Scale

A single modular scale (e.g., 1.25 ratio) applied uniformly produces sizes that are either too similar on mobile — where 1rem, 1.25rem, and 1.563rem are nearly indistinguishable — or excessively large on desktop. Hand-crafted responsive type scales solve this by defining deliberately chosen sizes that compress on small screens and expand on large ones. In Tailwind v4, use the `@theme` directive with CSS custom properties that change at breakpoints to create a type scale your entire design system can reference.

**Incorrect (single mathematical scale across all viewports):**

```html
<!-- 1.25 modular scale: sizes are too close on mobile, h1 too large on desktop -->
<style>
  :root {
    --text-sm: 0.8rem;    /* 12.8px */
    --text-base: 1rem;    /* 16px */
    --text-lg: 1.25rem;   /* 20px — barely different from base */
    --text-xl: 1.563rem;  /* 25px */
    --text-2xl: 1.953rem; /* 31.25px */
    --text-hero: 3.052rem; /* 48.8px — too large on mobile */
  }
</style>
<div class="px-4 py-12">
  <h1 class="font-bold text-[length:var(--text-hero)]">Launch Day</h1>
  <h2 class="mt-4 font-semibold text-[length:var(--text-2xl)]">What's New</h2>
  <p class="mt-2 text-[length:var(--text-base)] text-gray-600">
    We've rebuilt the entire platform from the ground up.
  </p>
</div>
```

**Correct (responsive type scale with hand-picked sizes per breakpoint):**

```html
<!-- Type scale compresses on mobile, expands on desktop — each level stays distinct -->
<style>
  :root {
    --text-sm: 0.875rem;
    --text-base: 1rem;
    --text-lg: 1.125rem;
    --text-xl: 1.25rem;
    --text-2xl: 1.5rem;
    --text-hero: 2.25rem;
  }
  @media (min-width: 768px) {
    :root {
      --text-sm: 0.875rem;
      --text-base: 1rem;
      --text-lg: 1.25rem;
      --text-xl: 1.5rem;
      --text-2xl: 2rem;
      --text-hero: 3.5rem;
    }
  }
  @media (min-width: 1280px) {
    :root {
      --text-sm: 0.875rem;
      --text-base: 1.0625rem;
      --text-lg: 1.25rem;
      --text-xl: 1.75rem;
      --text-2xl: 2.5rem;
      --text-hero: 4.5rem;
    }
  }
</style>
<div class="px-4 py-12 md:px-8 lg:px-16">
  <h1 class="font-bold text-[length:var(--text-hero)]">Launch Day</h1>
  <h2 class="mt-4 font-semibold text-[length:var(--text-2xl)]">What's New</h2>
  <p class="mt-2 text-[length:var(--text-base)] text-gray-600">
    We've rebuilt the entire platform from the ground up.
  </p>
</div>
```

**Key principle:** Hand-craft your scale by choosing sizes where each level is visually distinct at every breakpoint. The hero jumps from 2.25rem to 4.5rem (2x), but base text barely changes (1rem to 1.0625rem). In Tailwind v4, define these custom properties inside `@theme` so they're available as first-class utilities like `text-hero`. This gives you a single source of truth that adapts across viewports without per-element breakpoint classes.
