---
title: Use Fluid Typography with clamp()
impact: HIGH
impactDescription: eliminates abrupt font size jumps, reduces CSS
tags: resp, typography, clamp, fluid, css
---

## Use Fluid Typography with clamp()

Fixed font sizes at breakpoints create abrupt jumps. Fluid typography scales smoothly between minimum and maximum sizes, improving readability at every viewport width.

**Incorrect (stepped font sizes with jarring transitions):**

```css
h1 { font-size: 24px; }

@media (min-width: 768px) {
  h1 { font-size: 36px; } /* Sudden jump at 768px */
}

@media (min-width: 1024px) {
  h1 { font-size: 48px; } /* Another jump at 1024px */
}
/* Text size changes abruptly at breakpoints */
/* Users at 767px and 768px have very different experiences */
```

**Correct (smooth fluid scaling with clamp):**

```css
h1 {
  /* Min 24px, scales with viewport, max 48px */
  font-size: clamp(1.5rem, 4vw + 0.5rem, 3rem);
}

h2 {
  font-size: clamp(1.25rem, 3vw + 0.5rem, 2.25rem);
}

p {
  /* Body text: min 16px, max 20px */
  font-size: clamp(1rem, 1vw + 0.75rem, 1.25rem);
}

/* Spacing can also be fluid */
.section {
  padding: clamp(2rem, 5vw, 6rem);
}
/* Typography scales smoothly across all viewport widths */
/* No jarring size changes at breakpoints */
```

**Fluid typography formula:**
```text
clamp(min, preferred, max)
preferred = [viewport-unit] + [base-rem]
Example: clamp(1rem, 2vw + 0.5rem, 2rem)
```

**Guidelines:**
- Body text: 16px minimum, 20px maximum
- Headings: More aggressive scaling (h1 may double)
- Test at narrow widths to ensure readability

Reference: [CSS Tricks Fluid Type](https://css-tricks.com/simplified-fluid-typography/)
