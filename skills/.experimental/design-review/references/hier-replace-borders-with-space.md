---
title: Replace borders with spacing and background
tags: hier, borders, spacing
---

## Replace borders with spacing and background

Reaching for a border to separate every element produces a boxy, busy interface where the lines themselves add visual noise. Separate regions with whitespace or a subtle background-shade difference first, and use a border only when two elements must sit flush.

**Incorrect (a box around every row competes for attention):**

```css
.settings-row { border: 1px solid #e5e7eb; padding: 16px; }
```

**Correct (whitespace plus a single hairline divider does the separating):**

```css
.settings-row { padding: 20px 16px; }
.settings-row + .settings-row { border-top: 1px solid hsl(220 13% 91%); }
```

Reference: [7 Practical Tips for Cheating at Design](https://medium.com/refactoring-ui/7-practical-tips-for-cheating-at-design-40c736799886)
