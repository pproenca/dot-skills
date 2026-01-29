---
title: Use willChange Prop Judiciously
impact: HIGH
impactDescription: reduces paint time when used correctly
tags: anim, will-change, optimization, memory, gpu
---

## Use willChange Prop Judiciously

The `willChange` prop hints to the browser that an element will animate, allowing it to optimize ahead of time. However, overusing it creates unnecessary GPU layers, increases memory usage, and can actually hurt performance.

**Incorrect (excessive willChange):**

```tsx
import { motion } from "framer-motion";

function CardGrid({ items }) {
  return (
    <div className="grid">
      {items.map((item) => (
        <motion.div
          key={item.id}
          className="card"
          style={{ willChange: "transform, opacity, filter, box-shadow" }}  // Too many properties
          whileHover={{ scale: 1.05 }}
        >
          <motion.img
            src={item.image}
            style={{ willChange: "transform" }}  // Every image gets a layer
          />
          <motion.p style={{ willChange: "opacity" }}>{item.title}</motion.p>  // Overkill
        </motion.div>
      ))}
    </div>
  );
}
```

**Correct (targeted willChange):**

```tsx
import { motion } from "framer-motion";
import { useState } from "react";

function CardGrid({ items }) {
  const [hoveredId, setHoveredId] = useState(null);

  return (
    <div className="grid">
      {items.map((item) => (
        <motion.div
          key={item.id}
          className="card"
          style={{
            willChange: hoveredId === item.id ? "transform" : "auto"  // Only when needed
          }}
          onHoverStart={() => setHoveredId(item.id)}
          onHoverEnd={() => setHoveredId(null)}
          whileHover={{ scale: 1.05 }}
        >
          <img src={item.image} />
          <p>{item.title}</p>
        </motion.div>
      ))}
    </div>
  );
}
```

**When to use willChange:**
- Complex animations that stutter without it
- Elements that animate frequently (navigation, modals)
- Large elements where layer creation cost is justified

**When NOT to use willChange:**
- Simple opacity/transform animations (Motion handles this)
- Static elements that rarely animate
- Many elements at once (100+ cards in a grid)
- As a "just in case" optimization

**Motion's automatic optimization:** Motion already promotes elements to their own compositor layer during animation. Manual `willChange` is rarely needed.

**Alternative approach:**

```tsx
// Let Motion handle layer promotion automatically
<motion.div
  whileHover={{ scale: 1.05 }}
  transition={{ type: "spring", stiffness: 300 }}
>
  {/* Motion creates GPU layer only during animation */}
</motion.div>
```

Reference: [MDN - will-change](https://developer.mozilla.org/en-US/docs/Web/CSS/will-change)
