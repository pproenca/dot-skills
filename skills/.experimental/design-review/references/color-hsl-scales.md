---
title: Define colour as HSL shade ramps
tags: color, palette, design-tokens
---

## Define colour as HSL shade ramps

Sprinkling one-off hex values through the CSS makes it hard to keep greys and accents consistent or to derive hover and disabled variants. Define each hue as a ramp of shades in HSL, where changing only the lightness produces predictable, related steps.

```css
:root {
  --brand-100: hsl(221 83% 93%);  /* tint for backgrounds */
  --brand-500: hsl(221 83% 53%);  /* base action colour */
  --brand-600: hsl(221 83% 45%);  /* hover: same hue, lower lightness */
}
```

Reference: [Refactoring UI — Defining a colour palette](https://www.refactoringui.com/)
