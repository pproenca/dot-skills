---
title: Meet WCAG contrast for body text
tags: color, contrast, accessibility
---

## Meet WCAG contrast for body text

Light-grey text on white reads as refined in a mockup but commonly falls below the 4.5:1 contrast minimum, leaving it unreadable for many users and in bright light. Verify body text against at least 4.5:1 (3:1 for large text) before settling on a grey.

**Incorrect (gray-400 on white — about 2.5:1, fails):**

```css
.helper-text { color: #9ca3af; background: #ffffff; }
```

**Correct (gray-500 on white — about 4.8:1, passes):**

```css
.helper-text { color: #6b7280; background: #ffffff; }
```

Reference: [WCAG 2.2 — Contrast (Minimum) 1.4.3](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html)
