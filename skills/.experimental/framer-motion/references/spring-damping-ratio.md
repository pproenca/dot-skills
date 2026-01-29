---
title: Configure Damping to Control Oscillation
impact: MEDIUM
impactDescription: prevents excessive bouncing that distracts users and delays interaction
tags: spring, damping, oscillation, bounce, overshoot
---

## Configure Damping to Control Oscillation

Damping controls how quickly a spring settles. Under-damped springs (low damping) oscillate excessively, making UI elements bounce repeatedly before settling. This delays user interaction and feels unprofessional. Appropriate damping ensures elements settle quickly while maintaining a natural feel.

**Incorrect (under-damped, excessive bouncing):**

```tsx
import { motion } from "framer-motion";

function TooltipPopover({ isVisible }: { isVisible: boolean }) {
  return (
    <motion.div
      className="tooltip"
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: isVisible ? 1 : 0, y: isVisible ? 0 : 10 }}
      transition={{ type: "spring", stiffness: 400, damping: 8 }}  // Bounces 3-4 times before settling
    >
      <p>Helpful tooltip text</p>
    </motion.div>
  );
}
```

**Correct (appropriately damped, settles quickly):**

```tsx
import { motion } from "framer-motion";

function TooltipPopover({ isVisible }: { isVisible: boolean }) {
  return (
    <motion.div
      className="tooltip"
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: isVisible ? 1 : 0, y: isVisible ? 0 : 10 }}
      transition={{ type: "spring", stiffness: 400, damping: 25 }}  // Settles with minimal overshoot
    >
      <p>Helpful tooltip text</p>
    </motion.div>
  );
}
```

**Damping guidelines:**
- `damping < 10`: Very bouncy, use sparingly for playful UI
- `damping 15-25`: Slight overshoot, natural feel for most UI
- `damping > 30`: No overshoot, quick settle for functional elements
- Critical damping: `damping = 2 * sqrt(stiffness * mass)` for zero oscillation

Reference: [Framer Motion - Spring](https://motion.dev/docs/react-transitions#spring)
