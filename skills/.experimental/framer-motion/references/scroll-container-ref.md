---
title: Track Scroll Within Specific Containers Using container Option
impact: MEDIUM-HIGH
impactDescription: enables scroll tracking in nested scrollable elements
tags: scroll, container, useScroll, nested, overflow
---

## Track Scroll Within Specific Containers Using container Option

By default, useScroll tracks the page scroll. To track scroll progress within a specific scrollable container (like a sidebar, modal, or nested scroll area), pass a container ref. Without this, scroll animations in nested containers won't respond to the container's scroll position.

**Incorrect (tracks page scroll instead of container):**

```tsx
import { useRef } from "react";
import { motion, useScroll } from "framer-motion";

function ScrollableGallery() {
  const containerRef = useRef<HTMLDivElement>(null);
  const { scrollXProgress } = useScroll();  // Tracks page scroll, not container

  return (
    <div
      ref={containerRef}
      className="gallery"
      style={{ overflowX: "auto", display: "flex" }}
    >
      {images.map((src, i) => (
        <img key={i} src={src} alt="" />
      ))}
      <motion.div
        className="scroll-indicator"
        style={{ scaleX: scrollXProgress }}  // Doesn't respond to gallery scroll
      />
    </div>
  );
}
```

**Correct (container ref tracks nested scroll):**

```tsx
import { useRef } from "react";
import { motion, useScroll } from "framer-motion";

function ScrollableGallery() {
  const containerRef = useRef<HTMLDivElement>(null);
  const { scrollXProgress } = useScroll({
    container: containerRef  // Tracks this container's horizontal scroll
  });

  return (
    <div
      ref={containerRef}
      className="gallery"
      style={{ overflowX: "auto", display: "flex" }}
    >
      {images.map((src, i) => (
        <img key={i} src={src} alt="" />
      ))}
      <motion.div
        className="scroll-indicator"
        style={{ scaleX: scrollXProgress }}  // Responds to gallery scroll
      />
    </div>
  );
}
```

**Combining container and target:**

```tsx
const { scrollYProgress } = useScroll({
  container: scrollContainerRef,  // Track scroll of this container
  target: elementRef,             // Track this element's position within container
  offset: ["start end", "end start"]
});
```

Reference: [Framer Motion - useScroll Container](https://motion.dev/docs/react-use-scroll#scroll-container)
