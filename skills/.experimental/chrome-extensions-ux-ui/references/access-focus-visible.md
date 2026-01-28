---
title: Maintain Visible Focus Indicators
impact: CRITICAL
impactDescription: WCAG 2.4.7 requirement for keyboard users
tags: access, focus, indicator, keyboard, wcag
---

## Maintain Visible Focus Indicators

Never remove focus outlines without providing an alternative. Keyboard users must see which element is currently focused to navigate your extension.

**Incorrect (focus indicator removed):**

```css
/* styles.css - Common anti-pattern removes all focus */
*:focus {
  outline: none;
}

button:focus {
  outline: 0;
}

/* Keyboard user has no idea which button is focused */
```

**Correct (clear focus indicator preserved):**

```css
/* styles.css - Custom focus style that's visible */
*:focus {
  outline: 2px solid #4A90D9;
  outline-offset: 2px;
}

/* Use :focus-visible for mouse vs keyboard differentiation */
button:focus {
  outline: none;
}

button:focus-visible {
  outline: 2px solid #4A90D9;
  outline-offset: 2px;
  box-shadow: 0 0 0 4px rgba(74, 144, 217, 0.3);
}

/* High contrast mode support */
@media (forced-colors: active) {
  button:focus-visible {
    outline: 3px solid CanvasText;
  }
}
```

**Focus indicator requirements:**
- Minimum 3:1 contrast ratio against adjacent colors
- At least 2px thick outline or equivalent visual change
- Visible in both light and dark modes
- Not obscured by other elements

**Testing keyboard focus:**

```typescript
// Debug focus visibility during development
document.addEventListener('focusin', (event) => {
  console.log('Focused:', event.target)
  const styles = getComputedStyle(event.target)
  console.log('Outline:', styles.outline, 'Box-shadow:', styles.boxShadow)
})
```

Reference: [WCAG 2.4.7 Focus Visible](https://www.w3.org/WAI/WCAG21/Understanding/focus-visible.html)
