---
title: Derive Values with useTransform Instead of useEffect
impact: CRITICAL
impactDescription: avoids React render cycle entirely for derived animations
tags: rerender, useTransform, useEffect, derived-values, performance
---

## Derive Values with useTransform Instead of useEffect

useTransform creates derived motion values that update synchronously with their source, completely bypassing React's render cycle. Using useEffect with setState to derive values causes unnecessary re-renders and creates visual lag between the source and derived values.

**Incorrect (useEffect creates render cycle and lag):**

```tsx
function ScrollProgress() {
  const { scrollYProgress } = useScroll();
  const [opacity, setOpacity] = useState(1);

  useEffect(() => {
    const unsubscribe = scrollYProgress.on('change', (v) => {
      setOpacity(1 - v);  // Triggers re-render on every scroll frame
    });
    return unsubscribe;
  }, [scrollYProgress]);

  return <motion.div style={{ opacity }} />;
}
```

**Correct (useTransform derives value without re-renders):**

```tsx
function ScrollProgress() {
  const { scrollYProgress } = useScroll();
  const opacity = useTransform(scrollYProgress, [0, 1], [1, 0]);  // No re-renders

  return <motion.div style={{ opacity }} />;
}
```

Reference: [Framer Motion - useTransform](https://www.framer.com/motion/use-transform/)
