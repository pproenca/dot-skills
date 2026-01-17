---
title: Use Semantic Color Names in Design Tokens
impact: MEDIUM
impactDescription: enables consistent theming and easier maintenance
tags: color, design-tokens, semantic, css-variables, theming
---

## Use Semantic Color Names in Design Tokens

Hardcoded color values scattered through CSS are impossible to maintain and theme. Semantic color tokens describe purpose, not appearance, enabling consistent updates and dark mode support.

**Incorrect (literal color names and raw values):**

```css
.header { background: #1a365d; }
.error { color: #dc2626; }
.success { color: #16a34a; }
.button { background: blue; }
.sidebar { background: #f3f4f6; }

/* Renaming "blue" requires find-replace across codebase */
/* No clear relationship between colors */
```

**Correct (semantic design tokens):**

```css
:root {
  /* Primitive tokens (raw values) */
  --blue-600: #2563eb;
  --blue-700: #1d4ed8;
  --red-600: #dc2626;
  --green-600: #16a34a;
  --gray-100: #f3f4f6;
  --gray-900: #111827;

  /* Semantic tokens (purpose-based) */
  --color-bg-primary: var(--gray-100);
  --color-bg-inverse: var(--gray-900);
  --color-text-primary: var(--gray-900);
  --color-text-inverse: white;

  --color-interactive: var(--blue-600);
  --color-interactive-hover: var(--blue-700);

  --color-feedback-error: var(--red-600);
  --color-feedback-success: var(--green-600);
}

.header { background: var(--color-bg-inverse); }
.error { color: var(--color-feedback-error); }
.success { color: var(--color-feedback-success); }
.button { background: var(--color-interactive); }
.button:hover { background: var(--color-interactive-hover); }
.sidebar { background: var(--color-bg-primary); }
/* Change brand color in one place, updates everywhere */
```

**Token naming hierarchy:**
1. Primitive: `--blue-600` (raw values)
2. Semantic: `--color-interactive` (purpose)
3. Component: `--button-bg` (optional, specific)

Reference: [Design Tokens Community Group](https://www.w3.org/community/design-tokens/)
