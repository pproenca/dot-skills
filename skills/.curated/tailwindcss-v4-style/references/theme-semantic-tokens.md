---
title: Use Semantic Design Token Names
impact: MEDIUM
impactDescription: improves maintainability, enables theme switching
tags: theme, tokens, naming, semantic, design-system
---

## Use Semantic Design Token Names

Name design tokens by their purpose, not their visual appearance. This enables theme switching and makes the design system more maintainable.

**Incorrect (visual naming):**

```css
@theme {
  --color-blue-500: oklch(0.623 0.214 259.1);
  --color-gray-100: oklch(0.967 0 0);
  --color-gray-900: oklch(0.21 0 0);
}
```

```html
<button class="bg-blue-500 text-gray-100">
  <!-- What if brand color changes to green? -->
</button>
```

**Correct (semantic naming):**

```css
@theme {
  /* Semantic tokens reference visual tokens */
  --color-primary: oklch(0.623 0.214 259.1);
  --color-surface: oklch(0.967 0 0);
  --color-text: oklch(0.21 0 0);

  /* Or map directly */
  --color-button-bg: var(--color-primary);
  --color-button-text: oklch(1 0 0);
}
```

```html
<button class="bg-primary text-button-text">
  <!-- Purpose is clear, easy to change -->
</button>
```

**Token hierarchy:**

```css
@theme {
  /* Primitive tokens */
  --color-brand-500: oklch(0.623 0.214 259.1);

  /* Semantic tokens */
  --color-primary: var(--color-brand-500);
  --color-interactive: var(--color-primary);

  /* Component tokens (optional) */
  --color-button-default: var(--color-interactive);
}
```

Reference: [Tailwind CSS Theme Variables](https://tailwindcss.com/docs/theme)
