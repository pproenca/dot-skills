---
title: Use Gradients With Hues Within 30 Degrees of Each Other
impact: LOW
impactDescription: prevents clashing gradients by keeping hue distance within 30 degrees (e.g., from-blue-500 to-indigo-600)
tags: polish, gradients, color, hue, background
---

Gradients work best when the two colors are close on the color wheel (within ~30 degrees of hue). Wide hue jumps (e.g., red to green) look garish. If you need more contrast, shift lightness/saturation rather than hue.

**Incorrect (clashing hues — blue to orange):**
```html
<div class="bg-linear-to-r from-blue-500 to-orange-500 p-8">
  <h2 class="text-2xl font-bold text-white">Special Offer</h2>
</div>
```

**Correct (close hues — blue to indigo):**
```html
<div class="bg-linear-to-r from-blue-500 to-indigo-600 p-8">
  <h2 class="text-2xl font-bold text-white">Special Offer</h2>
</div>
```

**Alternative (monochromatic — same hue, different lightness):**
```html
<div class="bg-linear-to-r from-blue-400 to-blue-600 p-8">
  <h2 class="text-2xl font-bold text-white">Special Offer</h2>
</div>
```

Note: Tailwind v3 uses `bg-gradient-to-r` instead of `bg-linear-to-r`.

Reference: Refactoring UI — "Finishing Touches"
