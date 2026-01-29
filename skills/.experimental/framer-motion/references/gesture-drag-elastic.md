---
title: Configure dragElastic for Natural Drag Feel
impact: MEDIUM
impactDescription: improved drag feel with elastic overshoot
tags: gesture, drag, dragElastic, momentum, UX
---

## Configure dragElastic for Natural Drag Feel

The `dragElastic` prop controls how much the element can be dragged past its constraints before snapping back. A value of 0 creates a hard stop that feels unresponsive, while values between 0.1-0.5 provide natural momentum that matches native app behavior.

**Incorrect (hard stop at boundaries):**

```tsx
function SwipeableItem({ item, onDismiss }: SwipeableItemProps) {
  const containerRef = useRef<HTMLDivElement>(null);

  return (
    <div ref={containerRef} className="swipe-container">
      <motion.div
        drag="x"
        dragConstraints={containerRef}
        dragElastic={0}  // Hard stop - feels rigid and unnatural
        onDragEnd={(_, info) => {
          if (Math.abs(info.offset.x) > 100) {
            onDismiss(item.id);
          }
        }}
        className="swipeable-item"
      >
        <span>{item.title}</span>
      </motion.div>
    </div>
  );
}
```

**Correct (elastic overshoot for natural feel):**

```tsx
function SwipeableItem({ item, onDismiss }: SwipeableItemProps) {
  const containerRef = useRef<HTMLDivElement>(null);

  return (
    <div ref={containerRef} className="swipe-container">
      <motion.div
        drag="x"
        dragConstraints={containerRef}
        dragElastic={0.2}  // Allows 20% overshoot - natural momentum feel
        onDragEnd={(_, info) => {
          if (Math.abs(info.offset.x) > 100) {
            onDismiss(item.id);
          }
        }}
        className="swipeable-item"
      >
        <span>{item.title}</span>
      </motion.div>
    </div>
  );
}
```

**Recommended values:**
- `0` - Hard stop (avoid unless intentional)
- `0.1-0.2` - Subtle overshoot, professional feel
- `0.3-0.5` - Noticeable elasticity, playful feel
- `1` - Full elasticity, equal to drag distance

Reference: [Framer Motion - Drag](https://www.framer.com/motion/gestures/#drag)
