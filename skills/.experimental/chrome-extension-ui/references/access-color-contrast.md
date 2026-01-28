---
title: Ensure Sufficient Color Contrast
impact: CRITICAL
impactDescription: WCAG AA requires 4.5:1 for normal text
tags: access, color, contrast, wcag, readability
---

## Ensure Sufficient Color Contrast

Maintain minimum contrast ratios between text and background colors. Low contrast text is unreadable for users with visual impairments and difficult for everyone in bright conditions.

**Incorrect (insufficient contrast):**

```css
/* styles.css - Light gray on white fails WCAG */
.popup-container {
  background: #ffffff;
}

.hint-text {
  color: #aaaaaa;  /* 2.3:1 contrast - FAILS */
}

.disabled-text {
  color: #cccccc;  /* 1.6:1 contrast - FAILS */
}

.link {
  color: #6699ff;  /* 2.9:1 contrast - FAILS for normal text */
}
```

**Correct (WCAG AA compliant contrast):**

```css
/* styles.css - All text meets 4.5:1 minimum */
.popup-container {
  background: #ffffff;
}

.hint-text {
  color: #767676;  /* 4.5:1 contrast - PASSES */
}

.disabled-text {
  color: #767676;  /* 4.5:1 contrast - PASSES */
  opacity: 0.7;    /* Visual distinction through opacity */
}

.link {
  color: #0066cc;  /* 5.9:1 contrast - PASSES */
}

/* Large text (18px+ or 14px+ bold) only needs 3:1 */
.heading {
  font-size: 18px;
  color: #595959;  /* 7:1 contrast - exceeds requirement */
}
```

**Contrast requirements summary:**

| Element Type | Minimum Ratio |
|--------------|---------------|
| Normal text (< 18px) | 4.5:1 |
| Large text (≥ 18px or ≥ 14px bold) | 3:1 |
| UI components & graphics | 3:1 |
| Disabled elements | No requirement (but consider usability) |

**Testing contrast in your extension:**

```typescript
// Add to development build - logs contrast issues
function checkContrast(element) {
  const styles = getComputedStyle(element)
  const textColor = styles.color
  const bgColor = styles.backgroundColor
  // Use a library like 'color-contrast-checker' for calculation
  console.log(`${element.className}: ${textColor} on ${bgColor}`)
}
```

Reference: [WCAG 1.4.3 Contrast](https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum.html)
