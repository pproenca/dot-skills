---
title: Understand Utility File Scope
impact: MEDIUM-HIGH
impactDescription: prevents build errors and missing class bugs
tags: comp, utility, scope, css-modules, organization
---

## Understand Utility File Scope

Custom utilities defined with `@utility` are only available in the file where they're defined. For shared utilities, create a dedicated file and import it.

**Incorrect (expecting global scope):**

```css
/* components/button.css */
@utility btn {
  @apply px-4 py-2 rounded font-medium;
}
```

```css
/* components/card.css */
.card-action {
  @apply btn; /* Error: btn not defined in this file */
}
```

**Correct (shared utilities file):**

```css
/* utilities.css */
@utility btn {
  @apply px-4 py-2 rounded font-medium;
}

@utility card-shadow {
  @apply shadow-md hover:shadow-lg transition-shadow;
}
```

```css
/* components/card.css */
@import "./utilities.css";

.card-action {
  @apply btn; /* Works: imported from utilities.css */
}
```

**Organization pattern:**

```text
styles/
├── main.css          # @import "tailwindcss" + @theme
├── utilities.css     # Shared @utility definitions
└── components/
    ├── button.css    # @import "../utilities.css"
    └── card.css      # @import "../utilities.css"
```

Reference: [Tailwind CSS Functions and Directives](https://tailwindcss.com/docs/functions-and-directives)
