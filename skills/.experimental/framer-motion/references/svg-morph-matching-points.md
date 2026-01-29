---
title: Match Point Counts for Smooth Path Morphing
impact: LOW-MEDIUM
impactDescription: avoids expensive interpolation and visual glitches during morphing
tags: svg, morph, path, interpolation
---

## Match Point Counts for Smooth Path Morphing

When morphing between SVG paths, matching the number and type of path commands ensures smooth interpolation. Mismatched paths require Framer Motion to guess intermediate points, causing unpredictable visual artifacts and more expensive calculations.

**Incorrect (mismatched path points):**

```tsx
import { motion } from "framer-motion";

function MorphingIcon({ isActive }: { isActive: boolean }) {
  // Circle: 4 points, Star: 10 points - causes interpolation issues
  const circlePath = "M50,25 A25,25 0 1,1 50,75 A25,25 0 1,1 50,25";
  const starPath = "M50,5 L61,40 L98,40 L68,62 L79,97 L50,75 L21,97 L32,62 L2,40 L39,40 Z";

  return (
    <svg viewBox="0 0 100 100" width={100} height={100}>
      <motion.path
        d={isActive ? starPath : circlePath}  // Point count mismatch causes glitchy morph
        fill="gold"
        transition={{ duration: 0.5 }}
      />
    </svg>
  );
}
```

**Correct (matched path points):**

```tsx
import { motion } from "framer-motion";

function MorphingIcon({ isActive }: { isActive: boolean }) {
  // Both paths have 10 points for smooth interpolation
  const circlePath = "M50,25 L50,25 L75,50 L75,50 L50,75 L50,75 L25,50 L25,50 L50,25 L50,25";
  const starPath = "M50,5 L61,40 L98,40 L68,62 L79,97 L50,75 L21,97 L32,62 L2,40 L39,40";

  return (
    <svg viewBox="0 0 100 100" width={100} height={100}>
      <motion.path
        d={isActive ? starPath : circlePath}  // Matched points morph smoothly
        fill="gold"
        transition={{ duration: 0.5 }}
      />
    </svg>
  );
}
```

**Tip:** Use tools like [flubber](https://github.com/veltman/flubber) or design both shapes with the same point count in your SVG editor.

Reference: [Framer Motion - Animating SVG paths](https://motion.dev/docs/react-animation#svg)
