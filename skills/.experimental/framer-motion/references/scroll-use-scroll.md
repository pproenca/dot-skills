---
title: Use useScroll Hook for Scroll-Linked Animations
impact: MEDIUM-HIGH
impactDescription: avoids blocking main thread with scroll listeners
tags: scroll, useScroll, scroll-event, performance, motion-value
---

## Use useScroll Hook for Scroll-Linked Animations

The useScroll hook returns motion values that update via the browser's native ScrollTimeline API, enabling hardware-accelerated animations that remain smooth even during heavy JavaScript execution. Manual scroll event listeners run on the main thread and can cause significant jank.

**Incorrect (manual scroll event listener blocks main thread):**

```tsx
import { useState, useEffect } from "react";
import { motion } from "framer-motion";

function ProgressBar() {
  const [scrollProgress, setScrollProgress] = useState(0);

  useEffect(() => {
    const handleScroll = () => {
      const scrollTop = window.scrollY;
      const docHeight = document.documentElement.scrollHeight - window.innerHeight;
      setScrollProgress(scrollTop / docHeight);  // Re-renders on every scroll event
    };

    window.addEventListener("scroll", handleScroll);  // Blocks main thread
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  return (
    <motion.div
      className="progress-bar"
      style={{ scaleX: scrollProgress, transformOrigin: "left" }}
    />
  );
}
```

**Correct (useScroll with hardware acceleration):**

```tsx
import { motion, useScroll } from "framer-motion";

function ProgressBar() {
  const { scrollYProgress } = useScroll();  // Hardware-accelerated, no re-renders

  return (
    <motion.div
      className="progress-bar"
      style={{ scaleX: scrollYProgress, transformOrigin: "left" }}
    />
  );
}
```

Reference: [Framer Motion - useScroll](https://motion.dev/docs/react-use-scroll)
