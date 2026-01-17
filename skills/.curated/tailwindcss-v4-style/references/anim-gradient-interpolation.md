---
title: Use OKLCH Gradient Interpolation
impact: LOW-MEDIUM
impactDescription: 20-40% more vivid gradient midpoints
tags: anim, gradients, oklch, interpolation, colors
---

## Use OKLCH Gradient Interpolation

Use the `/oklch` modifier for gradient interpolation to produce more vivid colors and avoid muddy midpoints that occur with sRGB interpolation.

**Incorrect (default sRGB interpolation):**

```html
<div class="bg-linear-to-r from-blue-500 to-green-500">
  <!-- sRGB interpolation produces grayish/muddy midpoint -->
</div>
```

**Correct (OKLCH interpolation):**

```html
<div class="bg-linear-to-r/oklch from-blue-500 to-green-500">
  <!-- OKLCH produces vibrant cyan midpoint -->
</div>
```

**Interpolation comparison:**

```html
<!-- sRGB: Colors can look desaturated in the middle -->
<div class="h-10 bg-linear-to-r/srgb from-red-500 to-blue-500"></div>

<!-- OKLCH: Maintains vibrance throughout -->
<div class="h-10 bg-linear-to-r/oklch from-red-500 to-blue-500"></div>

<!-- Longer hue path for rainbow effect -->
<div class="h-10 bg-linear-to-r/[in_oklch_longer_hue] from-red-500 to-red-500"></div>
```

**When to use OKLCH:**
- Gradients between complementary colors
- Brand gradients requiring specific midpoints
- Any gradient where sRGB looks "muddy"

Reference: [Tailwind CSS v4.0 Release](https://tailwindcss.com/blog/tailwindcss-v4)
