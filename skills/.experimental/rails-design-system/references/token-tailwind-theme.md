---
title: Define Tokens in Tailwind @theme, Not Custom CSS
impact: CRITICAL
impactDescription: single source of truth for all design values
tags: token, tailwind, css, theme, configuration
---

## Define Tokens in Tailwind @theme, Not Custom CSS

Tailwind v4's `@theme` directive is the canonical place to declare design tokens. Values defined in `@theme` are available as both utility classes and CSS custom properties automatically. This eliminates the dual-maintenance problem where tokens drift between a `:root` block and the Tailwind config, causing visual inconsistencies that compound over time.

**Incorrect (tokens split between CSS and Tailwind):**

```css
/* app/assets/stylesheets/application.css */

/* Tokens defined in :root... */
:root {
  --color-primary: #2563eb;
  --color-danger: #dc2626;
  --radius-default: 0.5rem;
}

/* ...AND duplicated in a Tailwind config or plugin */
/* Now two sources of truth that inevitably diverge */
```

```erb
<%# Some files use the CSS variable... %>
<div style="color: var(--color-primary);">Hello</div>

<%# ...while others use a hardcoded Tailwind class that may not match %>
<div class="text-blue-600">Hello</div>
```

**Correct (tokens defined once in @theme):**

```css
/* app/assets/stylesheets/application.css */
@import "tailwindcss";

@theme {
  --color-primary: oklch(0.55 0.2 240);
  --color-primary-hover: oklch(0.48 0.2 240);
  --color-danger: oklch(0.55 0.22 25);
  --color-surface: oklch(0.99 0 0);
  --color-surface-raised: oklch(0.97 0 0);
  --radius-default: 0.5rem;
  --radius-full: 9999px;
}
```

```erb
<%# Utility classes generated automatically from @theme %>
<button class="bg-primary hover:bg-primary-hover text-white rounded-default px-4 py-2">
  Save
</button>

<%# CSS variable also available when needed (e.g., inline styles for emails) %>
<div style="background: var(--color-surface-raised);">
  Dynamic content
</div>
```

**What @theme gives you:**

| Token declaration | Generated utility | CSS variable |
|---|---|---|
| `--color-primary: ...` | `bg-primary`, `text-primary`, `border-primary` | `var(--color-primary)` |
| `--radius-default: ...` | `rounded-default` | `var(--radius-default)` |
| `--text-heading: ...` | `text-heading` | `var(--text-heading)` |

Reference: [Tailwind CSS v4 Theme Configuration](https://tailwindcss.com/docs/theme)
