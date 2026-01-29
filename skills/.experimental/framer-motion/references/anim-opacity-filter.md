---
title: Prefer Opacity and Filter for Visual Effects
impact: HIGH
impactDescription: avoids paint-triggering reflows
tags: anim, opacity, filter, gpu, compositing
---

## Prefer Opacity and Filter for Visual Effects

Opacity and filter are composite-only properties that run on the GPU compositor thread. Animating properties like background-color, box-shadow, or border triggers expensive paint operations on the main thread.

**Incorrect (paint-triggering properties):**

```tsx
import { motion } from "framer-motion";

function HoverButton() {
  return (
    <motion.button
      className="btn"
      initial={{ backgroundColor: "#3b82f6" }}
      whileHover={{ backgroundColor: "#1d4ed8" }}  // Triggers repaint every frame
      transition={{ duration: 0.2 }}
    >
      Click me
    </motion.button>
  );
}

function FadeCard() {
  return (
    <motion.div
      className="card"
      initial={{ boxShadow: "0 0 0 rgba(0,0,0,0)" }}
      animate={{ boxShadow: "0 10px 40px rgba(0,0,0,0.3)" }}  // Expensive shadow paint
      transition={{ duration: 0.3 }}
    >
      <p>Card content</p>
    </motion.div>
  );
}
```

**Correct (composite-only properties):**

```tsx
import { motion } from "framer-motion";

function HoverButton() {
  return (
    <motion.button
      className="btn btn-blue"
      initial={{ opacity: 1 }}
      whileHover={{ opacity: 0.8 }}  // GPU-accelerated, no repaint
      transition={{ duration: 0.2 }}
    >
      Click me
    </motion.button>
  );
}

function FadeCard() {
  return (
    <motion.div
      className="card card-with-shadow"
      initial={{ opacity: 0, filter: "blur(4px)" }}
      animate={{ opacity: 1, filter: "blur(0px)" }}  // Both GPU-accelerated
      transition={{ duration: 0.3 }}
    >
      <p>Card content</p>
    </motion.div>
  );
}
```

**GPU-accelerated properties:**
- `opacity` - visibility transitions
- `filter` - blur, brightness, contrast, grayscale, saturate
- `transform` (x, y, scale, rotate)

**Paint-triggering properties to avoid animating:**
- `backgroundColor`, `color`
- `boxShadow`, `textShadow`
- `border`, `borderRadius`
- `outline`

**Tip:** For color transitions, use CSS transitions on the element and control visibility with Motion's opacity.

Reference: [Framer Motion - Animation](https://motion.dev/docs/react-animation)
