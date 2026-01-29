---
title: Use dragConstraints Ref for Automatic Boundaries
impact: MEDIUM
impactDescription: automatic boundary calculation, handles resize and scroll
tags: gesture, drag, dragConstraints, ref, boundaries
---

## Use dragConstraints Ref for Automatic Boundaries

The `dragConstraints` prop accepts a ref to a parent element, automatically calculating boundaries based on the container's dimensions. Manual pixel constraints require hardcoded values that break on different screen sizes and don't update when the container resizes.

**Incorrect (manual boundary calculation):**

```tsx
function DraggableCard({ children }: DraggableCardProps) {
  const [containerSize, setContainerSize] = useState({ width: 0, height: 0 });
  const cardSize = { width: 200, height: 150 };

  useEffect(() => {
    // Must manually track container size
    const updateSize = () => {
      const container = document.getElementById("drag-container");
      if (container) {
        setContainerSize({
          width: container.offsetWidth,
          height: container.offsetHeight,
        });
      }
    };
    updateSize();
    window.addEventListener("resize", updateSize);  // Manual resize handling
    return () => window.removeEventListener("resize", updateSize);
  }, []);

  return (
    <div id="drag-container" className="container">
      <motion.div
        drag
        dragConstraints={{  // Hardcoded calculations
          top: 0,
          left: 0,
          right: containerSize.width - cardSize.width,
          bottom: containerSize.height - cardSize.height,
        }}
        className="card"
      >
        {children}
      </motion.div>
    </div>
  );
}
```

**Correct (ref-based automatic boundaries):**

```tsx
function DraggableCard({ children }: DraggableCardProps) {
  const containerRef = useRef<HTMLDivElement>(null);

  return (
    <div ref={containerRef} className="container">
      <motion.div
        drag
        dragConstraints={containerRef}  // Automatic boundary calculation
        className="card"
      >
        {children}
      </motion.div>
    </div>
  );
}
```

Reference: [Framer Motion - Drag](https://www.framer.com/motion/gestures/#drag)
