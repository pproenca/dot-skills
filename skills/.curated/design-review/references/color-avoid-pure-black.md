---
title: Use a near-black instead of pure black
tags: color, contrast, text
---

## Use a near-black instead of pure black

Pure `#000` text on a white background is harsher than real-world ink and makes an interface feel stark and high-strain. Use a very dark, slightly desaturated colour so text reads softer while keeping strong contrast.

**Incorrect (pure black on pure white):**

```css
body { color: #000000; background: #ffffff; }
```

**Correct (near-black, slightly cool):**

```css
body { color: hsl(222 47% 11%); background: #ffffff; } /* slate-900 */
```

Reference: [7 Practical Tips for Cheating at Design](https://medium.com/refactoring-ui/7-practical-tips-for-cheating-at-design-40c736799886)
