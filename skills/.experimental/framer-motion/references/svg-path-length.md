---
title: Use pathLength for Line Drawing Animations
impact: LOW-MEDIUM
impactDescription: 5× simpler line drawing code
tags: svg, path, animation, line-drawing
---

## Use pathLength for Line Drawing Animations

The `pathLength` property normalizes any path to a length of 1, enabling simple 0-1 progress animations. Without it, you must calculate the exact path length and manage complex `strokeDasharray` values that vary per path.

**Incorrect (manual strokeDasharray calculation):**

```tsx
import { motion } from "framer-motion";

function CheckmarkIcon() {
  // Must calculate exact path length (varies per path)
  const pathLength = 24.5; // Manual measurement required

  return (
    <svg viewBox="0 0 24 24" width={24} height={24}>
      <motion.path
        d="M4 12l6 6L20 6"
        fill="none"
        stroke="currentColor"
        strokeWidth={2}
        initial={{ strokeDasharray: pathLength, strokeDashoffset: pathLength }}
        animate={{ strokeDashoffset: 0 }}  // Breaks if path changes
        transition={{ duration: 0.5 }}
      />
    </svg>
  );
}
```

**Correct (normalized pathLength):**

```tsx
import { motion } from "framer-motion";

function CheckmarkIcon() {
  return (
    <svg viewBox="0 0 24 24" width={24} height={24}>
      <motion.path
        d="M4 12l6 6L20 6"
        fill="none"
        stroke="currentColor"
        strokeWidth={2}
        initial={{ pathLength: 0 }}
        animate={{ pathLength: 1 }}  // Works for any path, no calculation needed
        transition={{ duration: 0.5 }}
      />
    </svg>
  );
}
```

Reference: [Framer Motion - Path Animations](https://motion.dev/docs/react-animation#svg-line-drawing)
