---
title: Use motion.path and motion.circle for SVG Animation
impact: LOW-MEDIUM
impactDescription: correct transform-origin for SVG elements
tags: svg, motion-components, transform, animation
---

## Use motion.path and motion.circle for SVG Animation

Framer Motion's SVG components (motion.path, motion.circle, motion.rect, etc.) handle SVG-specific quirks like transform origin and attribute animation. Regular SVG elements with CSS animations have inconsistent transform origin behavior across browsers.

**Incorrect (CSS animation on SVG elements):**

```tsx
import { useState } from "react";

function PulsingCircle() {
  const [isActive, setIsActive] = useState(false);

  return (
    <svg viewBox="0 0 100 100" width={100} height={100}>
      <circle
        cx={50}
        cy={50}
        r={20}
        fill="blue"
        style={{
          transform: isActive ? "scale(1.5)" : "scale(1)",  // Transform origin issues in SVG
          transition: "transform 0.3s",
        }}
        onClick={() => setIsActive(!isActive)}
      />
    </svg>
  );
}
```

**Correct (motion.circle with proper transforms):**

```tsx
import { motion } from "framer-motion";
import { useState } from "react";

function PulsingCircle() {
  const [isActive, setIsActive] = useState(false);

  return (
    <svg viewBox="0 0 100 100" width={100} height={100}>
      <motion.circle
        cx={50}
        cy={50}
        r={20}
        fill="blue"
        animate={{ scale: isActive ? 1.5 : 1 }}  // Handles transform origin correctly
        transition={{ duration: 0.3 }}
        onClick={() => setIsActive(!isActive)}
      />
    </svg>
  );
}
```

Reference: [Framer Motion - SVG](https://motion.dev/docs/react-animation#svg)
