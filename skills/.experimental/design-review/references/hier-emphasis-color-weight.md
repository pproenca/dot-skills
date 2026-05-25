---
title: Use colour and weight to set emphasis, not size alone
tags: hier, emphasis, typography
---

## Use colour and weight to set emphasis, not size alone

To make text secondary, the default move is to shrink it — which quickly drives it below a readable size. Reach for font weight and text colour first; reserve size changes for genuine levels of the hierarchy so secondary text stays legible.

**Incorrect (de-emphasizes by shrinking until it is hard to read):**

```css
.invoice-meta { font-size: 11px; } /* secondary info, now too small to read */
```

**Correct (de-emphasizes with colour and weight, keeps a readable size):**

```css
.invoice-meta {
  font-size: 14px;
  font-weight: 400;
  color: hsl(215 16% 47%); /* slate-500 — quieter but still legible */
}
```

Reference: [7 Practical Tips for Cheating at Design](https://medium.com/refactoring-ui/7-practical-tips-for-cheating-at-design-40c736799886)
