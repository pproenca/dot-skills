---
title: Limit body line length for readability
tags: type, typography, readability
---

## Limit body line length for readability

A paragraph that stretches the full width of a wide container forces the eye to track long distances and lose its place returning to the next line. Cap the measure at roughly 45–75 characters (Butterick allows up to ~90) so reading stays comfortable. Note `ch` is the width of the `0` glyph, so in a proportional font the rendered line runs a little longer than the `ch` count.

```css
.prose p {
  max-width: 66ch; /* a comfortable 65–75 character measure */
}
```

Reference: [Butterick — Line length](https://practicaltypography.com/line-length.html)
