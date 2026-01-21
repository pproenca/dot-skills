---
title: Use Mobile-First Responsive Design
impact: MEDIUM
impactDescription: 10-30% smaller CSS output
tags: resp, mobile-first, breakpoints, responsive, design
---

## Use Mobile-First Responsive Design

Write base styles for mobile, then add complexity with breakpoint prefixes. This produces smaller CSS and follows progressive enhancement principles.

**Incorrect (desktop-first, override down):**

```html
<div class="grid-cols-4 lg:grid-cols-4 md:grid-cols-2 sm:grid-cols-1">
  <!-- Redundant: lg same as base -->
  <!-- More CSS needed to override -->
</div>
```

**Correct (mobile-first, enhance up):**

```html
<div class="grid-cols-1 md:grid-cols-2 lg:grid-cols-4">
  <!-- Base: 1 column (mobile) -->
  <!-- md+: 2 columns (tablet) -->
  <!-- lg+: 4 columns (desktop) -->
</div>
```

**Why mobile-first works better:**
1. Base styles apply to all screen sizes
2. Breakpoints add complexity progressively
3. Smaller CSS output (fewer overrides)
4. Better performance on mobile devices

**Breakpoint reference:**

| Prefix | Min-width | Target |
|--------|-----------|--------|
| (none) | 0px | Mobile |
| `sm:` | 640px | Large phones |
| `md:` | 768px | Tablets |
| `lg:` | 1024px | Laptops |
| `xl:` | 1280px | Desktops |
| `2xl:` | 1536px | Large screens |

Reference: [Tailwind CSS Responsive Design](https://tailwindcss.com/docs/responsive-design)
