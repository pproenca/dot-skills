---
title: Use Mini useAnimate for Simple Cases
impact: HIGH
impactDescription: 2.3kb vs 17kb for hybrid approach
tags: bundle, use-animate, mini, imperative-animations
---

## Use Mini useAnimate for Simple Cases

When you only need imperative animations without the declarative features of motion components, use `useAnimate` from `framer-motion/mini`. This provides the same animation capabilities at 2.3kb instead of requiring the full 17kb hybrid bundle.

**Incorrect (full useAnimate for simple imperative animation):**

```tsx
// components/NotificationBadge.tsx
import { useAnimate } from "framer-motion"; // Pulls in 17kb hybrid bundle

export function NotificationBadge({ count }: NotificationBadgeProps) {
  const [scope, animate] = useAnimate();

  const handleNewNotification = async () => {
    await animate(scope.current, { scale: 1.2 }, { duration: 0.1 });
    await animate(scope.current, { scale: 1 }, { duration: 0.1 });
  };

  return (
    <div ref={scope} className="badge">
      {count}
    </div>
  );
}
```

**Correct (mini useAnimate for simple imperative animation):**

```tsx
// components/NotificationBadge.tsx
import { useAnimate } from "framer-motion/mini"; // Only 2.3kb

export function NotificationBadge({ count }: NotificationBadgeProps) {
  const [scope, animate] = useAnimate();

  const handleNewNotification = async () => {
    await animate(scope.current, { scale: 1.2 }, { duration: 0.1 });
    await animate(scope.current, { scale: 1 }, { duration: 0.1 });
  };

  return (
    <div ref={scope} className="badge">
      {count}
    </div>
  );
}
```

**When mini is sufficient:**
- Imperative animations triggered by events
- Simple enter/exit animations on DOM elements
- Animations that do not need spring physics or complex sequencing

**When to use full useAnimate:**
- You need spring animations with custom damping/stiffness
- You are already using LazyMotion (no additional cost)
- You need to animate motion values or complex keyframes

Reference: [Framer Motion - Mini Animate](https://www.framer.com/motion/mini-animate/)
