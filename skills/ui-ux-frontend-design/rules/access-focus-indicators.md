---
title: Provide Visible Focus Indicators
impact: CRITICAL
impactDescription: enables keyboard users to track position on page
tags: access, focus, keyboard, wcag, css
---

## Provide Visible Focus Indicators

Focus indicators show keyboard users which element is currently active. Removing or hiding focus styles makes navigation impossible for keyboard-only users.

**Incorrect (focus outline removed globally):**

```css
/* Reset that breaks accessibility */
*:focus {
  outline: none;
}

button:focus {
  outline: 0;
}
/* Keyboard users cannot see where they are on the page */
```

**Correct (enhanced visible focus styles):**

```css
/* Remove default only when providing custom focus */
button:focus {
  outline: none;
}

button:focus-visible {
  outline: 3px solid #005fcc;
  outline-offset: 2px;
  border-radius: 4px;
}

/* High contrast for dark backgrounds */
.dark-theme button:focus-visible {
  outline-color: #ffdd00;
}
/* Focus ring visible with sufficient contrast (3:1 minimum) */
```

**Focus indicator requirements (WCAG 2.2):**
- Minimum 2px thickness
- 3:1 contrast ratio against adjacent colors
- Encloses or is adjacent to the focused element
- Use `:focus-visible` to show focus only for keyboard navigation

Reference: [WCAG 2.2 Focus Appearance](https://www.w3.org/WAI/WCAG22/Understanding/focus-appearance.html)
