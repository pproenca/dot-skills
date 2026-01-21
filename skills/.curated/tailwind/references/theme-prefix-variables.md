---
title: Use Prefix for Variable Namespacing
impact: MEDIUM
impactDescription: prevents CSS variable conflicts in large codebases
tags: theme, prefix, variables, namespacing, conflicts
---

## Use Prefix for Variable Namespacing

When integrating Tailwind into existing projects or component libraries, use a prefix to prevent CSS variable conflicts.

**Incorrect (potential conflicts):**

```css
@import "tailwindcss";

@theme {
  --color-primary: oklch(0.623 0.214 259.1);
  /* May conflict with existing --color-primary in project */
}
```

**Correct (prefixed variables):**

```css
@import "tailwindcss" prefix(tw);

@theme {
  /* Define without prefix */
  --color-primary: oklch(0.623 0.214 259.1);
  --font-display: "Satoshi", sans-serif;
}
```

```css
/* Generated CSS variables are prefixed */
:root {
  --tw-color-primary: oklch(0.623 0.214 259.1);
  --tw-font-display: "Satoshi", sans-serif;
}
```

```html
<!-- Utility classes are also prefixed -->
<div class="tw:bg-primary tw:font-display">
  Content
</div>
```

**When to use prefixes:**
- Migrating existing projects with CSS variables
- Building embeddable widgets
- Creating component libraries
- Multi-framework applications

Reference: [Tailwind CSS Upgrade Guide](https://tailwindcss.com/docs/upgrade-guide)
