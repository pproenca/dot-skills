---
title: Use light-dark() Function for Adaptive Colors
impact: HIGH
impactDescription: automatically switches colors based on active theme
tags: theme, light-dark, adaptive, css-function
---

## Use light-dark() Function for Adaptive Colors

The CSS `light-dark()` function automatically selects values based on the active color scheme, reducing theme boilerplate.

**Incorrect (duplicating values in each variant):**

```css
@layer theme {
  :root {
    @variant light {
      --color-surface: #ffffff;
      --color-border: #e5e7eb;
    }

    @variant dark {
      --color-surface: #1f2937;
      --color-border: #374151;
    }
  }
}
```

**Correct (using light-dark function):**

```css
@theme {
  --color-surface: light-dark(#ffffff, #1f2937);
  --color-border: light-dark(#e5e7eb, #374151);
  --color-shadow: light-dark(
    rgba(0, 0, 0, 0.1),
    rgba(0, 0, 0, 0.5)
  );
}
```

**When to use light-dark():**
- Simple two-theme setups (light/dark only)
- Reducing CSS duplication
- Inline adaptive values

**When to use @variant blocks:**
- More than two themes
- Complex theme-specific logic
- Different variable sets per theme

Reference: [Uniwind CSS Parser](https://docs.uniwind.dev/api/css)
