---
title: Use mode="wait" for Sequential Page Transitions
impact: LOW
impactDescription: prevents overlapping content during page transitions
tags: exit, mode-wait, page-transition, routing
---

## Use mode="wait" for Sequential Page Transitions

By default, `AnimatePresence` renders entering and exiting elements simultaneously, causing layout overlap during transitions. Setting `mode="wait"` ensures the exiting element fully animates out before the entering element begins, preventing visual collisions.

**Incorrect (overlapping transitions):**

```tsx
import { motion, AnimatePresence } from "framer-motion";
import { useLocation } from "react-router-dom";

function PageTransition({ children }: { children: React.ReactNode }) {
  const location = useLocation();

  return (
    <AnimatePresence>
      <motion.div
        key={location.pathname}
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}  // Old and new pages render simultaneously, causing overlap
      >
        {children}
      </motion.div>
    </AnimatePresence>
  );
}
```

**Correct (sequential with mode="wait"):**

```tsx
import { motion, AnimatePresence } from "framer-motion";
import { useLocation } from "react-router-dom";

function PageTransition({ children }: { children: React.ReactNode }) {
  const location = useLocation();

  return (
    <AnimatePresence mode="wait">
      <motion.div
        key={location.pathname}
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}  // Old page exits fully before new page enters
      >
        {children}
      </motion.div>
    </AnimatePresence>
  );
}
```

**Mode options:**
- `"sync"` (default): Enter and exit animations happen simultaneously
- `"wait"`: Exit completes before enter begins
- `"popLayout"`: Exiting elements are popped from layout flow

Reference: [Framer Motion - AnimatePresence](https://motion.dev/docs/react-animate-presence#mode)
