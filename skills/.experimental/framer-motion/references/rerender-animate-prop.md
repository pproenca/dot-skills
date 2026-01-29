---
title: Use Stable Animate Values to Prevent Animation Restarts
impact: CRITICAL
impactDescription: prevents animation restart on unrelated re-renders
tags: rerender, animate, variants, object-reference, restart
---

## Use Stable Animate Values to Prevent Animation Restarts

Passing dynamic objects directly to the animate prop creates new references on every render, causing Framer Motion to restart the animation. Use variant names (strings) or memoized objects to ensure animations only restart when intentionally triggered.

**Incorrect (dynamic object restarts animation on every render):**

```tsx
function PulsingButton({ isActive }) {
  const [clicks, setClicks] = useState(0);

  return (
    <motion.button
      animate={{  // New object on every render, animation restarts
        scale: isActive ? 1.1 : 1,
        backgroundColor: isActive ? '#10b981' : '#6b7280',
      }}
      transition={{ duration: 0.3 }}
      onClick={() => setClicks(c => c + 1)}
    >
      Clicked {clicks} times
    </motion.button>
  );
}
```

**Correct (variant name provides stable reference):**

```tsx
const buttonVariants = {
  active: { scale: 1.1, backgroundColor: '#10b981' },
  inactive: { scale: 1, backgroundColor: '#6b7280' },
};

function PulsingButton({ isActive }) {
  const [clicks, setClicks] = useState(0);

  return (
    <motion.button
      variants={buttonVariants}
      animate={isActive ? 'active' : 'inactive'}  // String reference is stable
      transition={{ duration: 0.3 }}
      onClick={() => setClicks(c => c + 1)}
    >
      Clicked {clicks} times
    </motion.button>
  );
}
```

Reference: [Framer Motion - Animation](https://www.framer.com/motion/animation/)
