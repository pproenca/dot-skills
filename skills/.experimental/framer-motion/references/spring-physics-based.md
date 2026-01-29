---
title: Use Physics-Based Springs for Interruptible Animations
impact: MEDIUM
impactDescription: handles animation interruptions gracefully
tags: spring, physics, transition, interruptible, duration
---

## Use Physics-Based Springs for Interruptible Animations

Physics-based springs (stiffness/damping) simulate real-world motion and handle interruptions gracefully by preserving velocity. Duration-based transitions feel robotic and reset abruptly when interrupted mid-animation, breaking the illusion of physical objects.

**Incorrect (duration-based, resets on interruption):**

```tsx
import { motion } from "framer-motion";

function ModalDialog({ isOpen }: { isOpen: boolean }) {
  return (
    <motion.div
      className="modal"
      initial={{ scale: 0.8, opacity: 0 }}
      animate={{ scale: isOpen ? 1 : 0.8, opacity: isOpen ? 1 : 0 }}
      transition={{ duration: 0.3, ease: "easeOut" }}  // Resets abruptly if toggled mid-animation
    >
      <div className="modal-content">Dialog content</div>
    </motion.div>
  );
}
```

**Correct (physics-based, preserves velocity):**

```tsx
import { motion } from "framer-motion";

function ModalDialog({ isOpen }: { isOpen: boolean }) {
  return (
    <motion.div
      className="modal"
      initial={{ scale: 0.8, opacity: 0 }}
      animate={{ scale: isOpen ? 1 : 0.8, opacity: isOpen ? 1 : 0 }}
      transition={{ type: "spring", stiffness: 300, damping: 25 }}  // Smoothly reverses preserving momentum
    >
      <div className="modal-content">Dialog content</div>
    </motion.div>
  );
}
```

**Spring parameters:**
- `stiffness`: Higher = faster, snappier (default: 100)
- `damping`: Higher = less oscillation (default: 10)
- `mass`: Higher = heavier, slower (default: 1)

Reference: [Framer Motion - Transitions](https://motion.dev/docs/react-transitions)
