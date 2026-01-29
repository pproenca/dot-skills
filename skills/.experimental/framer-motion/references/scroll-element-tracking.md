---
title: Track Specific Elements Entering Viewport with useScroll target
impact: MEDIUM-HIGH
impactDescription: 5× less code than manual IntersectionObserver
tags: scroll, useScroll, target, viewport, intersection-observer
---

## Track Specific Elements Entering Viewport with useScroll target

The useScroll hook accepts a target ref to track a specific element's position relative to the viewport. This provides scroll progress from 0 to 1 as the element enters and exits the viewport. Manual IntersectionObserver setup is verbose and doesn't provide continuous progress values.

**Incorrect (manual IntersectionObserver setup):**

```tsx
import { useState, useEffect, useRef } from "react";
import { motion } from "framer-motion";

function RevealSection() {
  const ref = useRef<HTMLDivElement>(null);
  const [isVisible, setIsVisible] = useState(false);

  useEffect(() => {
    const observer = new IntersectionObserver(
      ([entry]) => setIsVisible(entry.isIntersecting),
      { threshold: 0.5 }
    );
    if (ref.current) observer.observe(ref.current);
    return () => observer.disconnect();
  }, []);  // Verbose setup, binary visibility only

  return (
    <motion.div
      ref={ref}
      animate={{ opacity: isVisible ? 1 : 0 }}  // Abrupt transition, no progress
    >
      <h2>Section Content</h2>
    </motion.div>
  );
}
```

**Correct (useScroll with target ref):**

```tsx
import { useRef } from "react";
import { motion, useScroll, useTransform } from "framer-motion";

function RevealSection() {
  const ref = useRef<HTMLDivElement>(null);
  const { scrollYProgress } = useScroll({
    target: ref,
    offset: ["start end", "end start"]
  });  // Continuous progress as element scrolls through viewport

  const opacity = useTransform(scrollYProgress, [0, 0.5, 1], [0, 1, 0]);

  return (
    <motion.div ref={ref} style={{ opacity }}>
      <h2>Section Content</h2>
    </motion.div>
  );
}
```

Reference: [Framer Motion - useScroll Element Position](https://motion.dev/docs/react-use-scroll#element-position)
