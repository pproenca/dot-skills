---
title: Smooth Scroll Animations with useSpring
impact: MEDIUM-HIGH
impactDescription: eliminates jittery scroll-linked animations with physics-based smoothing
tags: scroll, useSpring, scrollYProgress, smooth, easing
---

## Smooth Scroll Animations with useSpring

Raw scroll progress values change abruptly with each scroll event, causing jittery animations especially on trackpads or during fast scrolling. Wrapping scroll progress in useSpring adds physics-based smoothing that creates fluid, natural-feeling animations.

**Incorrect (raw scrollYProgress causes jittery animations):**

```tsx
import { motion, useScroll } from "framer-motion";

function ParallaxSection() {
  const { scrollYProgress } = useScroll();

  return (
    <motion.div
      className="parallax-bg"
      style={{ y: scrollYProgress }}  // Jittery, updates abruptly on each scroll tick
    />
  );
}
```

**Correct (useSpring smooths the animation):**

```tsx
import { motion, useScroll, useSpring } from "framer-motion";

function ParallaxSection() {
  const { scrollYProgress } = useScroll();
  const smoothProgress = useSpring(scrollYProgress, {
    stiffness: 100,
    damping: 30,
    restDelta: 0.001
  });

  return (
    <motion.div
      className="parallax-bg"
      style={{ y: smoothProgress }}  // Smooth, physics-based interpolation
    />
  );
}
```

Reference: [Framer Motion - useSpring](https://motion.dev/docs/react-use-spring)
