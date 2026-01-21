---
title: Meet WCAG Contrast Ratio Requirements
impact: MEDIUM
impactDescription: makes text readable for 8%+ of users with visual impairments
tags: color, contrast, wcag, accessibility, readability
---

## Meet WCAG Contrast Ratio Requirements

Low contrast text is unreadable for users with visual impairments and difficult for everyone in bright environments. WCAG requires minimum contrast ratios for accessibility compliance.

**Incorrect (insufficient contrast ratios):**

```css
/* Light gray on white: 2.5:1 ratio - FAILS */
.subtle-text {
  color: #999999;
  background: #ffffff;
}

/* Orange on white: 2.9:1 ratio - FAILS for small text */
.warning-text {
  color: #ff9900;
  background: #ffffff;
}

/* White on light blue: 3.8:1 ratio - FAILS AA */
.hero-title {
  color: #ffffff;
  background: #5fa8d3;
}
/* Users in sunlight or with low vision cannot read */
```

**Correct (WCAG compliant contrast):**

```css
/* Dark gray on white: 7:1 ratio - PASSES AAA */
.body-text {
  color: #4a4a4a;
  background: #ffffff;
}

/* Darker orange on white: 4.6:1 ratio - PASSES AA */
.warning-text {
  color: #b35900;
  background: #ffffff;
}

/* White on dark blue: 8.5:1 ratio - PASSES AAA */
.hero-title {
  color: #ffffff;
  background: #1a365d;
}
/* Readable in all lighting conditions */
```

**WCAG contrast requirements:**
| Element | AA Level | AAA Level |
|---------|----------|-----------|
| Normal text (<18px) | 4.5:1 | 7:1 |
| Large text (≥18px bold, ≥24px) | 3:1 | 4.5:1 |
| UI components & graphics | 3:1 | Not defined |

**Testing tools:** WebAIM Contrast Checker, Chrome DevTools, Stark

Reference: [WCAG Contrast Guidelines](https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum.html)
