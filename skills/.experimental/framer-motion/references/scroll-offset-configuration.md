---
title: Configure Scroll Offsets for Precise Animation Triggers
impact: MEDIUM-HIGH
impactDescription: precise animation trigger control
tags: scroll, offset, useScroll, viewport, trigger
---

## Configure Scroll Offsets for Precise Animation Triggers

The offset option in useScroll defines when scroll progress starts (0) and ends (1) relative to the target element and viewport. Without custom offsets, animations may trigger too early or too late, causing awkward timing as users scroll.

**Incorrect (default offset starts animation too early):**

```tsx
import { useRef } from "react";
import { motion, useScroll, useTransform } from "framer-motion";

function FadeInCard() {
  const ref = useRef<HTMLDivElement>(null);
  const { scrollYProgress } = useScroll({
    target: ref
    // Default offset: ["start start", "end end"]
    // Animation completes before card is fully visible
  });

  const opacity = useTransform(scrollYProgress, [0, 1], [0, 1]);

  return (
    <motion.div ref={ref} className="card" style={{ opacity }}>
      <p>Card content fades in awkwardly</p>
    </motion.div>
  );
}
```

**Correct (custom offset for natural reveal):**

```tsx
import { useRef } from "react";
import { motion, useScroll, useTransform } from "framer-motion";

function FadeInCard() {
  const ref = useRef<HTMLDivElement>(null);
  const { scrollYProgress } = useScroll({
    target: ref,
    offset: ["start end", "start center"]
    // Starts when element top enters viewport bottom
    // Ends when element top reaches viewport center
  });

  const opacity = useTransform(scrollYProgress, [0, 1], [0, 1]);

  return (
    <motion.div ref={ref} className="card" style={{ opacity }}>
      <p>Card content fades in naturally</p>
    </motion.div>
  );
}
```

**Offset format:** `["<target> <viewport>", "<target> <viewport>"]`
- First value: when progress equals 0
- Second value: when progress equals 1
- Keywords: `start`, `center`, `end`, or pixel/percentage values

**Common offset patterns:**
- `["start end", "end start"]` - full viewport traversal
- `["start end", "start center"]` - reveal as element enters
- `["center center", "end start"]` - animate from center to exit

Reference: [Framer Motion - useScroll Offsets](https://motion.dev/docs/react-use-scroll#scroll-offsets)
