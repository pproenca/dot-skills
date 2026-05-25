---
title: Vary spacing to show what is grouped
tags: space, grouping, forms
---

## Vary spacing to show what is grouped

Using one uniform gap between every element makes a label, its input, and the next field all look equally related, so a form reads as an undifferentiated list. Tighten space within a group and widen it between groups so the structure is visible without drawing a single border.

```css
/* Tight inside a field group, loose between groups */
.field { display: grid; gap: 6px; }    /* label ↔ input: closely related */
.field + .field { margin-top: 24px; }   /* field ↔ field: clearly separated */
```

Reference: [Refactoring UI — Grouping and proximity](https://www.refactoringui.com/)
