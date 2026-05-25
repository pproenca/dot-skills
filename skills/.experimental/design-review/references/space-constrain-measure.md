---
title: Cap and centre the page container width
tags: space, layout, responsive
---

## Cap and centre the page container width

Block elements stretch to fill their container by default, so on wide monitors a layout spans edge to edge and loses any sense of composition. Cap the container width and centre it; a full-bleed section should be a deliberate choice, not the default for everything.

```css
.page-shell {
  max-width: 1120px;
  margin-inline: auto;
  padding-inline: 24px;
}
```

Reference: [Refactoring UI — Layout and spacing](https://www.refactoringui.com/)
