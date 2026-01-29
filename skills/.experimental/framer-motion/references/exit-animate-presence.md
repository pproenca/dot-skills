---
title: Wrap Conditional Renders with AnimatePresence
impact: LOW
impactDescription: enables exit animations for unmounting components
tags: exit, animate-presence, unmount, conditional
---

## Wrap Conditional Renders with AnimatePresence

React immediately removes components from the DOM when conditionally rendered out. `AnimatePresence` defers removal until exit animations complete, enabling smooth transitions when elements leave the screen.

**Incorrect (exit animation never runs):**

```tsx
import { motion } from "framer-motion";

function NotificationBanner({ message, isVisible }: NotificationProps) {
  return (
    <>
      {isVisible && (
        <motion.div
          className="notification"
          initial={{ opacity: 0, y: -50 }}
          animate={{ opacity: 1, y: 0 }}
          exit={{ opacity: 0, y: -50 }}  // Never runs - component unmounts immediately
        >
          {message}
        </motion.div>
      )}
    </>
  );
}
```

**Correct (AnimatePresence enables exit animation):**

```tsx
import { motion, AnimatePresence } from "framer-motion";

function NotificationBanner({ message, isVisible }: NotificationProps) {
  return (
    <AnimatePresence>
      {isVisible && (
        <motion.div
          className="notification"
          initial={{ opacity: 0, y: -50 }}
          animate={{ opacity: 1, y: 0 }}
          exit={{ opacity: 0, y: -50 }}  // Runs before unmount
        >
          {message}
        </motion.div>
      )}
    </AnimatePresence>
  );
}
```

Reference: [Framer Motion - AnimatePresence](https://motion.dev/docs/react-animate-presence)
