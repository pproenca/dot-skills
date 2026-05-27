---
title: Give layouts more whitespace than feels necessary
tags: space, whitespace, layout
---

## Give layouts more whitespace than feels necessary

The default instinct is to fit more in by tightening space, which makes interfaces feel cramped and cheap. Start with generous padding and gaps, then remove space only where the layout feels too sparse — emptier almost always reads as more considered.

```css
/* Generous breathing room around and within the card */
.feature-card {
  padding: 32px;
  display: grid;
  gap: 16px;
}
```

Reference: [Refactoring UI — Whitespace](https://www.refactoringui.com/)
