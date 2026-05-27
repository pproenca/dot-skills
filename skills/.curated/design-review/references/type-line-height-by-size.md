---
title: Set line-height relative to font size
tags: type, typography, leading
---

## Set line-height relative to font size

Applying one line-height (commonly 1.5) to everything leaves large headings too loose and small print too tight, because the optimal leading shrinks as type grows. Use a tighter ratio for display sizes and a looser one for body copy.

```css
h1 { font-size: 36px; line-height: 1.1; }  /* tight leading for display */
p  { font-size: 16px; line-height: 1.6; }  /* roomy leading for reading */
```

Reference: [Butterick — Line spacing](https://practicaltypography.com/line-spacing.html)
