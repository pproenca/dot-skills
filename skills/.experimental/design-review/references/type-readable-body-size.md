---
title: Keep body text large and solid enough to read
tags: type, typography, readability
---

## Keep body text large and solid enough to read

Generated UI often sets body copy at 13–14px in a thin weight and a pale grey, which looks elegant in a static mockup but is a strain to actually read. Keep body text near 16px with a normal weight and enough contrast to be effortless.

```css
.card__body {
  font-size: 16px;
  font-weight: 400;
  color: hsl(215 25% 27%); /* dark enough to read comfortably on white */
}
```

Reference: [Refactoring UI — Typography](https://www.refactoringui.com/)
