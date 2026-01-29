---
title: Use useSpring for Reactive Spring Values
impact: MEDIUM
impactDescription: prevents abrupt value jumps
tags: spring, useSpring, hook, reactive, motion-value
---

## Use useSpring for Reactive Spring Values

The `useSpring` hook creates a motion value that animates with spring physics whenever its target changes. Without it, derived values or externally-controlled animations jump abruptly to new values. useSpring ensures smooth, physics-based transitions that feel natural and can be interrupted gracefully.

**Incorrect (abrupt value changes):**

```tsx
import { motion, useMotionValue, useTransform } from "framer-motion";

function ProgressIndicator({ progress }: { progress: number }) {
  const scaleX = useMotionValue(progress);  // Jumps instantly when progress changes

  // Update motion value imperatively
  useEffect(() => {
    scaleX.set(progress);  // Abrupt jump, no animation
  }, [progress, scaleX]);

  return (
    <div className="progress-container">
      <motion.div className="progress-bar" style={{ scaleX, originX: 0 }} />
      <span>{Math.round(progress * 100)}%</span>
    </div>
  );
}
```

**Correct (smooth spring transitions):**

```tsx
import { motion, useSpring, useTransform } from "framer-motion";

function ProgressIndicator({ progress }: { progress: number }) {
  const scaleX = useSpring(progress, { stiffness: 100, damping: 20 });  // Animates smoothly to new value

  // useSpring automatically animates when progress prop changes

  return (
    <div className="progress-container">
      <motion.div className="progress-bar" style={{ scaleX, originX: 0 }} />
      <span>{Math.round(progress * 100)}%</span>
    </div>
  );
}
```

**useSpring options:**
- Accepts same spring config: `stiffness`, `damping`, `mass`
- Can accept a MotionValue as source: `useSpring(motionValue, config)`
- Returns a MotionValue that can be used in style props or transformed

Reference: [Framer Motion - useSpring](https://motion.dev/docs/react-use-spring)
