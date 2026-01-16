---
title: Establish Clear Visual Hierarchy
impact: HIGH
impactDescription: improves CTA click-through rates by 20-40%
tags: layout, hierarchy, typography, contrast, ux
---

## Establish Clear Visual Hierarchy

Visual hierarchy guides users through content in order of importance. Without it, users struggle to find key information and miss calls-to-action.

**Incorrect (flat hierarchy, nothing stands out):**

```css
.page-content h1 { font-size: 18px; color: #333; }
.page-content h2 { font-size: 16px; color: #333; }
.page-content p { font-size: 16px; color: #333; }
.page-content .cta-button {
  font-size: 14px;
  background: #eee;
  padding: 8px 12px;
}
/* Everything looks the same weight and importance */
/* User's eye has no focal point */
```

**Correct (clear hierarchy through size, weight, and contrast):**

```css
.page-content h1 {
  font-size: 48px;
  font-weight: 700;
  color: #1a1a2e;
  line-height: 1.1;
}

.page-content h2 {
  font-size: 32px;
  font-weight: 600;
  color: #1a1a2e;
}

.page-content p {
  font-size: 18px;
  font-weight: 400;
  color: #4a4a68;
  line-height: 1.6;
}

.page-content .cta-button {
  font-size: 18px;
  font-weight: 600;
  background: #0066ff;
  color: white;
  padding: 16px 32px;
  border-radius: 8px;
}
/* Clear progression: h1 > h2 > p */
/* CTA stands out with color contrast and size */
```

**Hierarchy tools (in order of impact):**
- Size: Larger elements draw attention first
- Color/Contrast: High contrast creates focal points
- Weight: Bold text stands out from regular
- Whitespace: Isolation increases importance
- Position: Top-left is scanned first (F-pattern)

Reference: [NNGroup Visual Hierarchy](https://www.nngroup.com/articles/visual-hierarchy-ux-definition/)
