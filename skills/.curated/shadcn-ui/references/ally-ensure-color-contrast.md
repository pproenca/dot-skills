---
title: Ensure Color Contrast Meets WCAG Standards
impact: CRITICAL
impactDescription: enables readability for low vision users
tags: ally, contrast, wcag, colors, theming
---

## Ensure Color Contrast Meets WCAG Standards

When customizing shadcn/ui theme colors, ensure text meets WCAG AA contrast ratios (4.5:1 for normal text, 3:1 for large text). The default theme is compliant; custom themes may not be.

**Incorrect (insufficient contrast ratio):**

```css
:root {
  --primary: 200 80% 70%;
  --primary-foreground: 200 80% 90%;
  /* Light blue on lighter blue = ~1.5:1 ratio - fails WCAG */
}

.dark {
  --muted: 220 10% 20%;
  --muted-foreground: 220 10% 40%;
  /* Dark gray on slightly lighter gray = ~2:1 ratio - fails WCAG */
}
```

**Correct (WCAG AA compliant contrast):**

```css
:root {
  --primary: 222.2 47.4% 11.2%;
  --primary-foreground: 210 40% 98%;
  /* Dark blue on near-white = ~12:1 ratio - passes WCAG AAA */
}

.dark {
  --muted: 217.2 32.6% 17.5%;
  --muted-foreground: 215 20.2% 65.1%;
  /* Dark slate on light gray = ~6:1 ratio - passes WCAG AA */
}
```

**Testing contrast:**

```tsx
// Use browser DevTools or tools like WebAIM Contrast Checker
// shadcn/ui default colors are pre-tested for WCAG AA

// When adding custom colors, verify each combination:
// - foreground on background
// - primary-foreground on primary
// - destructive-foreground on destructive
// - muted-foreground on muted
```

**WCAG requirements:**
- Normal text (< 18pt): 4.5:1 minimum
- Large text (≥ 18pt or 14pt bold): 3:1 minimum
- UI components and graphics: 3:1 minimum

Reference: [WCAG Contrast Requirements](https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum.html)
