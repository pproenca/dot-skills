---
title: Use Keyframe Arrays for Complex Sequences
impact: HIGH
impactDescription: avoids re-renders from chained animate calls
tags: anim, keyframes, sequence, multi-step, interpolation
---

## Use Keyframe Arrays for Complex Sequences

Keyframe arrays define multi-step animations in a single declaration, allowing Motion to interpolate smoothly between values. Chaining multiple `animate` calls or using `useEffect` for sequences causes unnecessary re-renders and timing issues.

**Incorrect (chained animations with state):**

```tsx
import { motion, useAnimation } from "framer-motion";
import { useEffect } from "react";

function PulsingDot() {
  const controls = useAnimation();

  useEffect(() => {
    const sequence = async () => {
      await controls.start({ scale: 1.5 });    // First animation
      await controls.start({ scale: 0.8 });    // Wait, then second
      await controls.start({ scale: 1 });      // Wait, then third
      sequence();  // Loop (causes re-renders)
    };
    sequence();
  }, [controls]);

  return <motion.div className="dot" animate={controls} />;
}

function ShakingButton() {
  const controls = useAnimation();

  const handleError = async () => {
    await controls.start({ x: -10 });
    await controls.start({ x: 10 });
    await controls.start({ x: -10 });
    await controls.start({ x: 10 });
    await controls.start({ x: 0 });  // Five separate animations
  };

  return (
    <motion.button animate={controls} onClick={handleError}>
      Submit
    </motion.button>
  );
}
```

**Correct (keyframe arrays):**

```tsx
import { motion } from "framer-motion";

function PulsingDot() {
  return (
    <motion.div
      className="dot"
      animate={{
        scale: [1, 1.5, 0.8, 1]  // All keyframes in one array
      }}
      transition={{
        duration: 1.5,
        repeat: Infinity,
        ease: "easeInOut",
        times: [0, 0.3, 0.7, 1]  // Control timing of each keyframe
      }}
    />
  );
}

function ShakingButton() {
  const [isError, setIsError] = useState(false);

  return (
    <motion.button
      animate={isError ? { x: [0, -10, 10, -10, 10, 0] } : { x: 0 }}
      transition={{ duration: 0.4 }}
      onAnimationComplete={() => setIsError(false)}
      onClick={() => setIsError(true)}
    >
      Submit
    </motion.button>
  );
}
```

**Keyframe features:**

```tsx
// Multiple properties with keyframes
<motion.div
  animate={{
    x: [0, 100, 100, 0],
    y: [0, 0, 100, 100],
    rotate: [0, 90, 180, 270]
  }}
  transition={{
    duration: 2,
    times: [0, 0.25, 0.5, 0.75],  // Sync timing across properties
    ease: ["easeIn", "linear", "easeOut"]  // Different ease per segment
  }}
/>

// Starting from current value with null
<motion.div
  animate={{
    opacity: [null, 0.5, 1]  // null = start from current value
  }}
  transition={{ duration: 0.5 }}
/>

// Looping with repeat
<motion.div
  animate={{ rotate: [0, 360] }}
  transition={{
    duration: 2,
    repeat: Infinity,
    repeatType: "loop",  // "loop" | "reverse" | "mirror"
    ease: "linear"
  }}
/>
```

**When to use keyframes vs variants:**
- Keyframes: Single element, continuous motion, loops
- Variants + staggerChildren: Multiple elements, orchestrated sequences

Reference: [Framer Motion - Keyframes](https://motion.dev/docs/react-animation#keyframes)
