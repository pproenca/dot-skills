---
title: Animate Only GPU-Accelerated Properties
impact: LOW-MEDIUM
impactDescription: maintains 60fps, eliminates jank on complex animations
tags: anim, gpu, transform, opacity, performance
---

## Animate Only GPU-Accelerated Properties

Animating layout properties like `width`, `height`, or `top` triggers expensive reflows. GPU-accelerated properties (`transform`, `opacity`) animate on a separate compositor layer without affecting layout.

**Incorrect (animating layout-triggering properties):**

```css
.sidebar {
  transition: width 0.3s ease;
}
.sidebar.collapsed {
  width: 60px; /* Triggers layout recalculation */
}

.modal {
  transition: top 0.3s ease;
}
.modal.open {
  top: 50%; /* Triggers reflow on every frame */
}

.card:hover {
  margin-top: -10px; /* Shifts all siblings, expensive */
}
/* Each frame: layout → paint → composite */
/* Results in dropped frames and jank */
```

**Correct (GPU-accelerated transforms):**

```css
.sidebar {
  transition: transform 0.3s ease;
  will-change: transform;
}
.sidebar.collapsed {
  transform: translateX(-200px); /* GPU compositor handles this */
}

.modal {
  transition: transform 0.3s ease, opacity 0.3s ease;
}
.modal.open {
  transform: translate(-50%, -50%); /* No layout recalculation */
  opacity: 1;
}

.card {
  transition: transform 0.2s ease;
}
.card:hover {
  transform: translateY(-10px); /* Only this element moves */
}
/* Each frame: composite only */
/* Smooth 60fps animation */
```

**GPU-accelerated properties:**
- `transform` (translate, scale, rotate, skew)
- `opacity`
- `filter` (blur, brightness, etc.)

**Properties that trigger layout (avoid animating):**
- `width`, `height`, `padding`, `margin`
- `top`, `right`, `bottom`, `left`
- `font-size`, `line-height`

Reference: [CSS Triggers](https://csstriggers.com/)
