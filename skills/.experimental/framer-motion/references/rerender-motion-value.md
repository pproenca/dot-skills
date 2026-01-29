---
title: Use useMotionValue Instead of useState for Animated Values
impact: CRITICAL
impactDescription: eliminates re-renders on every animation frame (60+ renders/sec to 0)
tags: rerender, motion-value, useState, performance, animation-frame
---

## Use useMotionValue Instead of useState for Animated Values

Motion values update the DOM directly without triggering React re-renders. Using useState for animated values causes a full component re-render on every animation frame (60+ times per second), leading to severe performance degradation and janky animations.

**Incorrect (useState causes re-renders every frame):**

```tsx
function DraggableCard() {
  const [x, setX] = useState(0);  // Re-renders on every drag frame

  return (
    <motion.div
      drag="x"
      style={{ x }}
      onDrag={(_, info) => setX(info.point.x)}  // 60+ setState calls per second
    >
      <ExpensiveChildComponent />
    </motion.div>
  );
}
```

**Correct (useMotionValue bypasses React):**

```tsx
function DraggableCard() {
  const x = useMotionValue(0);  // Updates DOM directly, no re-renders

  return (
    <motion.div
      drag="x"
      style={{ x }}
      // No onDrag needed - motion value updates automatically
    >
      <ExpensiveChildComponent />
    </motion.div>
  );
}
```

Reference: [Framer Motion - Motion Values](https://www.framer.com/motion/motionvalue/)
