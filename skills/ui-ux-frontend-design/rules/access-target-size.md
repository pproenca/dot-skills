---
title: Ensure Minimum Touch Target Size
impact: CRITICAL
impactDescription: enables users with motor impairments to tap controls accurately
tags: access, touch, target-size, mobile, wcag
---

## Ensure Minimum Touch Target Size

Small tap targets cause frustration and errors for users with motor impairments, tremors, or large fingers. WCAG 2.2 requires minimum 24×24px targets.

**Incorrect (tiny touch targets):**

```css
.icon-button {
  width: 16px;
  height: 16px;
  padding: 0;
}

.nav-link {
  padding: 4px 8px;
  font-size: 12px;
}
/* Touch targets too small for reliable tapping */
/* Users with motor impairments will miss frequently */
```

**Correct (adequately sized touch targets):**

```css
.icon-button {
  min-width: 44px;
  min-height: 44px;
  padding: 12px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.nav-link {
  padding: 12px 16px;
  min-height: 44px;
  display: inline-flex;
  align-items: center;
}
/* 44×44px meets WCAG AAA and iOS/Android guidelines */
```

**Target size requirements:**
- WCAG 2.2 AA: Minimum 24×24 CSS pixels
- WCAG 2.2 AAA: Minimum 44×44 CSS pixels (recommended)
- Spacing: At least 8px between adjacent targets
- Exception: Inline text links can be smaller if paragraph text

Reference: [WCAG 2.2 Target Size](https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html)
