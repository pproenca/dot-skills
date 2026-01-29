---
title: Animate Transforms Independently
impact: HIGH
impactDescription: enables different easing and duration per transform vs single timing for all
tags: anim, transform, independent, timing, easing
---

## Animate Transforms Independently

Motion allows animating `x`, `y`, `scale`, and `rotate` as independent values with their own timing. CSS combines these into a single `transform` property, forcing identical timing. Independent transforms enable richer, more natural animations.

**Incorrect (combined transform with single timing):**

```tsx
import { motion } from "framer-motion";

function BouncingBall() {
  return (
    <motion.div
      className="ball"
      animate={{
        transform: "translateY(-100px) scale(1.2) rotate(180deg)"  // All same timing
      }}
      transition={{ duration: 0.5, ease: "easeOut" }}
    />
  );
}

function FloatingCard() {
  return (
    <motion.div
      className="card"
      style={{
        transform: `translateX(${x}px) translateY(${y}px) scale(${scale})`  // Manual string
      }}
      animate={{ x: 100, y: -50, scale: 1.1 }}
      transition={{ duration: 0.3 }}  // Same duration for all
    />
  );
}
```

**Correct (independent transform properties):**

```tsx
import { motion } from "framer-motion";

function BouncingBall() {
  return (
    <motion.div
      className="ball"
      animate={{
        y: -100,
        scale: 1.2,
        rotate: 180
      }}
      transition={{
        y: { type: "spring", stiffness: 300, damping: 10 },  // Bouncy vertical
        scale: { duration: 0.3, ease: "easeOut" },           // Quick scale
        rotate: { duration: 0.8, ease: "linear" }            // Slow spin
      }}
    />
  );
}

function FloatingCard() {
  return (
    <motion.div
      className="card"
      animate={{ x: 100, y: -50, scale: 1.1 }}
      transition={{
        x: { type: "spring", stiffness: 100 },  // Springy horizontal
        y: { type: "spring", stiffness: 200 },  // Stiffer vertical
        scale: { delay: 0.1, duration: 0.2 }    // Delayed scale pop
      }}
    />
  );
}
```

**Available independent transforms:**
- `x`, `y`, `z` - translation
- `scale`, `scaleX`, `scaleY` - scaling
- `rotate`, `rotateX`, `rotateY`, `rotateZ` - rotation
- `skew`, `skewX`, `skewY` - skewing

**Practical example - card flip with stagger:**

```tsx
function FlipCard({ isFlipped }) {
  return (
    <motion.div
      className="card"
      animate={{
        rotateY: isFlipped ? 180 : 0,
        scale: isFlipped ? 1.1 : 1,
        y: isFlipped ? -20 : 0
      }}
      transition={{
        rotateY: { duration: 0.6, ease: [0.4, 0, 0.2, 1] },  // Smooth flip
        scale: { duration: 0.3, delay: 0.15 },               // Scale at midpoint
        y: { type: "spring", stiffness: 200, delay: 0.1 }    // Lift with spring
      }}
    />
  );
}
```

Reference: [Framer Motion - Transitions](https://motion.dev/docs/react-transitions)
