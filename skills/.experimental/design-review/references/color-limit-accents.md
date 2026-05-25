---
title: Limit the palette to one accent plus neutrals
tags: color, palette, restraint
---

## Limit the palette to one accent plus neutrals

Giving each section its own bright colour produces a chaotic, toy-like interface where no hue carries meaning. Build on a neutral grey scale plus a single accent for primary actions, and add further colours only when they signal something (success, warning, danger).

```css
:root {
  --neutral-200: hsl(220 13% 91%);
  --accent-500: hsl(221 83% 53%);  /* the one brand action colour */
  --danger-600: hsl(0 72% 45%);    /* introduced only for destructive state */
}
```

Reference: [Refactoring UI — Working with colour](https://www.refactoringui.com/)
