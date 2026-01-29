---
title: Define Variants Outside Component or with useMemo
impact: CRITICAL
impactDescription: prevents new object reference each render triggering animation restarts
tags: rerender, variants, useMemo, object-reference, stability
---

## Define Variants Outside Component or with useMemo

Defining variants objects inside a component creates new object references on every render. Framer Motion detects these as "new" variants and may restart animations or cause unnecessary diffing. Define variants outside the component or memoize them to maintain stable references.

**Incorrect (inline variants create new reference each render):**

```tsx
function FadeInCard({ isVisible }) {
  const [count, setCount] = useState(0);

  const cardVariants = {  // New object created on every render
    hidden: { opacity: 0, y: 20 },
    visible: { opacity: 1, y: 0 },
  };

  return (
    <motion.div
      variants={cardVariants}
      initial="hidden"
      animate={isVisible ? 'visible' : 'hidden'}
    />
  );
}
```

**Correct (variants defined outside component):**

```tsx
const cardVariants = {  // Stable reference, created once
  hidden: { opacity: 0, y: 20 },
  visible: { opacity: 1, y: 0 },
};

function FadeInCard({ isVisible }) {
  const [count, setCount] = useState(0);

  return (
    <motion.div
      variants={cardVariants}
      initial="hidden"
      animate={isVisible ? 'visible' : 'hidden'}
    />
  );
}
```

Reference: [Framer Motion - Variants](https://www.framer.com/motion/animation/#variants)
