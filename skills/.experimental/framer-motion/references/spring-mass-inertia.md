---
title: Adjust Mass for Heavier or Lighter Animation Feel
impact: MEDIUM
impactDescription: improved perceived weight for large elements
tags: spring, mass, inertia, weight, large-elements
---

## Adjust Mass for Heavier or Lighter Animation Feel

Mass controls the inertia of animated elements. Default mass (1) works for small UI elements, but large elements like fullscreen modals or heavy cards feel unnaturally light and jittery. Increasing mass makes animations feel weightier and more grounded, matching user expectations of physical objects.

**Incorrect (default mass on large element):**

```tsx
import { motion } from "framer-motion";

function FullscreenDrawer({ isOpen }: { isOpen: boolean }) {
  return (
    <motion.div
      className="drawer-fullscreen"
      initial={{ x: "100%" }}
      animate={{ x: isOpen ? 0 : "100%" }}
      transition={{ type: "spring", stiffness: 300, damping: 30 }}  // Feels too light for fullscreen element
    >
      <div className="drawer-content">
        <h2>Settings Panel</h2>
        <nav>Navigation items</nav>
      </div>
    </motion.div>
  );
}
```

**Correct (increased mass for weight):**

```tsx
import { motion } from "framer-motion";

function FullscreenDrawer({ isOpen }: { isOpen: boolean }) {
  return (
    <motion.div
      className="drawer-fullscreen"
      initial={{ x: "100%" }}
      animate={{ x: isOpen ? 0 : "100%" }}
      transition={{ type: "spring", stiffness: 300, damping: 30, mass: 1.5 }}  // Feels appropriately heavy
    >
      <div className="drawer-content">
        <h2>Settings Panel</h2>
        <nav>Navigation items</nav>
      </div>
    </motion.div>
  );
}
```

**Mass guidelines:**
- `mass: 0.5-0.8`: Light, snappy micro-interactions (buttons, icons)
- `mass: 1`: Default, suitable for cards, menus, tooltips
- `mass: 1.2-2`: Heavy elements (drawers, modals, large panels)
- Higher mass requires proportionally higher stiffness to maintain responsiveness

Reference: [Framer Motion - Spring](https://motion.dev/docs/react-transitions#spring)
