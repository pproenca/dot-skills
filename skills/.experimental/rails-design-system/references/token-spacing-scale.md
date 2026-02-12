---
title: Use Tailwind's Built-in Spacing Scale, Don't Reinvent
impact: HIGH
impactDescription: prevents spacing token bloat
tags: token, spacing, tailwind, layout
---

## Use Tailwind's Built-in Spacing Scale, Don't Reinvent

Tailwind ships with a comprehensive spacing scale (0, 0.5, 1, 1.5, 2, 2.5, 3, 4, 5, 6, 8, 10, 12, 16, 20, 24...) that covers virtually all general-purpose spacing needs. Redefining this scale with custom tokens adds maintenance burden and creates confusion about which system to use. Only add custom spacing tokens for app-specific fixed dimensions like sidebar widths or header heights.

**Incorrect (duplicating Tailwind's spacing scale):**

```css
/* app/assets/stylesheets/application.css */
@theme {
  /* Pointless duplication of what Tailwind already provides */
  --spacing-xs: 0.25rem;   /* same as spacing-1 */
  --spacing-sm: 0.5rem;    /* same as spacing-2 */
  --spacing-md: 1rem;      /* same as spacing-4 */
  --spacing-lg: 1.5rem;    /* same as spacing-6 */
  --spacing-xl: 2rem;      /* same as spacing-8 */
  --spacing-2xl: 3rem;     /* same as spacing-12 */
}
```

```erb
<%# Now developers don't know whether to use p-4 or p-md %>
<div class="p-md gap-lg">
  <h2 class="mb-sm">Title</h2>
</div>
```

**Correct (Tailwind's scale for spacing, custom tokens for fixed dimensions):**

```css
/* app/assets/stylesheets/application.css */
@import "tailwindcss";

@theme {
  /* Only app-specific layout dimensions */
  --width-sidebar: 16rem;
  --height-header: 4rem;
  --height-footer: 3rem;
  --width-content-max: 72rem;
}
```

```erb
<%# Use Tailwind's built-in spacing for padding, margin, gap %>
<div class="p-4 gap-6">
  <h2 class="mb-2">Title</h2>
  <p class="mt-4 text-text-muted">Description</p>
</div>

<%# Use custom tokens for fixed layout dimensions %>
<aside class="w-sidebar h-screen fixed">
  <%= render "shared/navigation" %>
</aside>

<main class="ml-sidebar max-w-content-max mx-auto py-8 px-6">
  <%= yield %>
</main>

<header class="h-header flex items-center px-6 border-b">
  <%= render "shared/header" %>
</header>
```

**When to add a custom spacing token:**

| Situation | Approach |
|---|---|
| Padding, margin, gap between elements | Use `p-4`, `mt-6`, `gap-8` directly |
| Fixed sidebar width used in multiple places | Add `--width-sidebar: 16rem` |
| Header height referenced by both header and main content offset | Add `--height-header: 4rem` |
| Card internal padding | Use `p-6` directly, not a token |
| Consistent section spacing | Use `py-12` or `py-16` directly |

Reference: [Tailwind CSS Spacing](https://tailwindcss.com/docs/padding)
