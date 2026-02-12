---
title: Use Semantic Color Names, Not Palette Names
impact: CRITICAL
impactDescription: enables theme changes without codebase-wide find-and-replace
tags: token, color, naming, semantic, theme
---

## Use Semantic Color Names, Not Palette Names

Name color tokens by their purpose (`--color-primary`, `--color-danger`, `--color-surface`), not their visual value (`--color-blue-500`, `--color-red-600`). When the brand evolves from blue to purple, a single token update propagates everywhere. Palette names scattered across hundreds of templates turn a one-line rebrand into a multi-week migration.

**Incorrect (palette names hardcoded across views):**

```erb
<%# app/views/layouts/application.html.erb %>
<nav class="bg-blue-600 text-white">
  <%= link_to "Home", root_path, class: "hover:bg-blue-700" %>
</nav>

<%# app/views/shared/_alert.html.erb %>
<div class="bg-red-100 border-red-500 text-red-900 p-4 rounded">
  <%= message %>
</div>

<%# app/views/orders/_status.html.erb %>
<span class="bg-green-100 text-green-800 px-2 py-1 rounded-full text-sm">
  Completed
</span>

<%# Brand changes from blue to purple? Find-replace bg-blue-600
   across 200+ files. Miss one? Visual inconsistency. %>
```

**Correct (semantic names in @theme, used everywhere):**

```css
/* app/assets/stylesheets/application.css */
@import "tailwindcss";

@theme {
  /* Brand */
  --color-primary: oklch(0.55 0.2 240);
  --color-primary-hover: oklch(0.48 0.2 240);
  --color-primary-subtle: oklch(0.95 0.03 240);

  /* Feedback */
  --color-danger: oklch(0.55 0.22 25);
  --color-danger-subtle: oklch(0.95 0.03 25);
  --color-success: oklch(0.55 0.18 145);
  --color-success-subtle: oklch(0.95 0.03 145);
  --color-warning: oklch(0.75 0.15 85);
  --color-warning-subtle: oklch(0.97 0.04 85);

  /* Surfaces */
  --color-surface: oklch(0.99 0 0);
  --color-surface-raised: oklch(0.97 0 0);
  --color-surface-overlay: oklch(0.95 0 0);

  /* Text */
  --color-text: oklch(0.15 0 0);
  --color-text-muted: oklch(0.45 0 0);
  --color-text-on-primary: oklch(0.99 0 0);
}
```

```erb
<%# Now views use semantic names %>
<nav class="bg-primary text-text-on-primary">
  <%= link_to "Home", root_path, class: "hover:bg-primary-hover" %>
</nav>

<div class="bg-danger-subtle border-danger text-danger p-4 rounded">
  <%= message %>
</div>

<span class="bg-success-subtle text-success px-2 py-1 rounded-full text-sm">
  Completed
</span>

<%# Rebrand from blue to purple? One change: %>
<%# --color-primary: oklch(0.55 0.2 300); %>
```

**Exception:** Tailwind's built-in gray scales (`gray-50` through `gray-950`) are acceptable for one-off structural use. Grays rarely change semantically, and wrapping every gray shade in a token adds noise without value. However, if your app uses grays for specific purposes (borders, dividers, disabled states), consider semantic aliases like `--color-border` and `--color-disabled`.

Reference: [Tailwind CSS v4 Theme Configuration](https://tailwindcss.com/docs/theme)
