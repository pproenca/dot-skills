---
title: Animate Transform Properties Instead of Layout Properties
impact: HIGH
impactDescription: 60fps vs 15-30fps with layout thrashing
tags: anim, transform, layout, performance, reflow
---

## Animate Transform Properties Instead of Layout Properties

Transform properties (x, y, scale, rotate) are GPU-accelerated and bypass the browser's layout engine. Animating layout properties (width, height, top, left) triggers expensive reflows on every frame, causing jank.

**Incorrect (layout-triggering properties):**

```tsx
import { motion } from "framer-motion";

function ExpandingCard() {
  return (
    <motion.div
      className="card"
      initial={{ width: 200, height: 100 }}
      animate={{ width: 400, height: 200 }}  // Triggers layout recalculation every frame
      transition={{ duration: 0.5 }}
    >
      <p>Content here</p>
    </motion.div>
  );
}

function SlidingPanel() {
  return (
    <motion.div
      className="panel"
      initial={{ left: -300 }}
      animate={{ left: 0 }}  // Causes reflow, not GPU-accelerated
      transition={{ duration: 0.3 }}
    >
      <nav>Menu items</nav>
    </motion.div>
  );
}
```

**Correct (GPU-accelerated transforms):**

```tsx
import { motion } from "framer-motion";

function ExpandingCard() {
  return (
    <motion.div
      className="card"
      initial={{ scale: 0.5 }}
      animate={{ scale: 1 }}  // GPU-accelerated, no layout recalculation
      transition={{ duration: 0.5 }}
    >
      <p>Content here</p>
    </motion.div>
  );
}

function SlidingPanel() {
  return (
    <motion.div
      className="panel"
      initial={{ x: -300 }}
      animate={{ x: 0 }}  // GPU-accelerated transform
      transition={{ duration: 0.3 }}
    >
      <nav>Menu items</nav>
    </motion.div>
  );
}
```

**Property mapping:**
- `top/left/right/bottom` → `x`, `y`
- `width/height` → `scale`, `scaleX`, `scaleY`
- CSS `transform: rotate()` → `rotate`

**When layout properties are needed:** Use the `layout` prop which uses FLIP technique to animate layout changes performantly via transforms.

Reference: [Framer Motion - Animation](https://motion.dev/docs/react-animation)
