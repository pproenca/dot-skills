---
title: Support Dark Mode with Color Scheme
impact: MEDIUM
impactDescription: reduces eye strain and battery usage for 80%+ of users
tags: color, dark-mode, prefers-color-scheme, css, ux
---

## Support Dark Mode with Color Scheme

Over 80% of users prefer dark mode, especially at night. Proper dark mode implementation reduces eye strain and saves battery on OLED screens. Use CSS custom properties for maintainable theming.

**Incorrect (hardcoded colors, no dark mode):**

```css
body {
  background: #ffffff;
  color: #333333;
}

.card {
  background: #f5f5f5;
  border: 1px solid #e0e0e0;
}

.button {
  background: #0066ff;
  color: #ffffff;
}
/* No dark mode support */
/* Users in dark environments experience eye strain */
```

**Correct (CSS custom properties with dark mode):**

```css
:root {
  --color-bg-primary: #ffffff;
  --color-bg-secondary: #f5f5f5;
  --color-text-primary: #1a1a2e;
  --color-text-secondary: #4a4a68;
  --color-border: #e0e0e0;
  --color-accent: #0066ff;
}

@media (prefers-color-scheme: dark) {
  :root {
    --color-bg-primary: #1a1a2e;
    --color-bg-secondary: #2d2d44;
    --color-text-primary: #ffffff;
    --color-text-secondary: #a0a0b8;
    --color-border: #3d3d5c;
    --color-accent: #4d94ff;
  }
}

body {
  background: var(--color-bg-primary);
  color: var(--color-text-primary);
}

.card {
  background: var(--color-bg-secondary);
  border: 1px solid var(--color-border);
}
/* Automatically responds to system preference */
```

**Dark mode considerations:**
- Avoid pure black (#000); use dark gray (#1a1a2e)
- Reduce contrast slightly (white text on black is harsh)
- Desaturate bright colors to avoid vibration
- Test that contrast ratios still meet WCAG in dark mode

Reference: [web.dev Dark Mode](https://web.dev/articles/prefers-color-scheme)
