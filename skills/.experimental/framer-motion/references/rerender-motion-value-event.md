---
title: Use Motion Value Events Instead of useEffect
impact: CRITICAL
impactDescription: avoids syncing motion values to React state, eliminating re-renders
tags: rerender, motion-value, onChange, useEffect, events
---

## Use Motion Value Events Instead of useEffect

Motion values provide event callbacks (onChange, onAnimationStart, onAnimationComplete) that execute outside React's render cycle. Using useEffect to watch motion value changes and sync to React state causes unnecessary re-renders. Use motion value events for side effects that do not need to trigger re-renders.

**Incorrect (useEffect syncs to state, causing re-renders):**

```tsx
function DragIndicator() {
  const x = useMotionValue(0);
  const [isDraggingRight, setIsDraggingRight] = useState(false);

  useEffect(() => {
    const unsubscribe = x.on('change', (latest) => {
      setIsDraggingRight(latest > 0);  // Re-renders on every frame
    });
    return unsubscribe;
  }, [x]);

  return (
    <motion.div drag="x" style={{ x }}>
      {isDraggingRight ? 'Moving right' : 'Moving left'}
    </motion.div>
  );
}
```

**Correct (motion value event updates DOM directly):**

```tsx
function DragIndicator() {
  const x = useMotionValue(0);
  const indicatorRef = useRef<HTMLSpanElement>(null);

  useEffect(() => {
    const unsubscribe = x.on('change', (latest) => {
      if (indicatorRef.current) {
        indicatorRef.current.textContent = latest > 0 ? 'Moving right' : 'Moving left';  // Direct DOM update
      }
    });
    return unsubscribe;
  }, [x]);

  return (
    <motion.div drag="x" style={{ x }}>
      <span ref={indicatorRef}>Moving left</span>
    </motion.div>
  );
}
```

Reference: [Framer Motion - Motion Value Events](https://www.framer.com/motion/motionvalue/#events)
