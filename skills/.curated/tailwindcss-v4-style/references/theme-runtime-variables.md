---
title: Leverage Runtime CSS Variables
impact: MEDIUM
impactDescription: enables dynamic theming without JavaScript
tags: theme, variables, runtime, dynamic, css
---

## Leverage Runtime CSS Variables

Tailwind CSS v4 exposes all theme values as CSS variables, enabling runtime customization without rebuilding CSS.

**Incorrect (hardcoded theme values):**

```typescript
// Changing theme requires rebuild
const theme = {
  primary: "#0066ff",
  secondary: "#6b7280",
};

function applyTheme(theme) {
  // Can't change Tailwind classes at runtime
}
```

**Correct (runtime CSS variable override):**

```css
@theme {
  --color-primary: oklch(0.623 0.214 259.1);
  --color-secondary: oklch(0.551 0.027 264.4);
}
```

```typescript
// Change theme at runtime without rebuild
function applyTheme(theme: { primary: string; secondary: string }) {
  document.documentElement.style.setProperty("--color-primary", theme.primary);
  document.documentElement.style.setProperty("--color-secondary", theme.secondary);
}

// Usage
applyTheme({
  primary: "oklch(0.7 0.15 150)",  // Green theme
  secondary: "oklch(0.6 0.1 160)",
});
```

**Use cases:**
- User-customizable themes
- White-label applications
- A/B testing color schemes
- Accessibility contrast modes

Reference: [Tailwind CSS Theme Variables](https://tailwindcss.com/docs/theme)
