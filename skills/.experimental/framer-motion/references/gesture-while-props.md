---
title: Use whileHover/whileTap Instead of Event Handlers
impact: MEDIUM
impactDescription: eliminates state updates and re-renders during gestures
tags: gesture, whileHover, whileTap, performance, event-handlers
---

## Use whileHover/whileTap Instead of Event Handlers

Framer Motion's `whileHover` and `whileTap` props are optimized internally to update styles without triggering React re-renders. Using `onMouseEnter`/`onMouseLeave` with useState causes unnecessary component re-renders and breaks memoization.

**Incorrect (state updates cause re-renders):**

```tsx
function ActionButton({ label, onClick }: ActionButtonProps) {
  const [isHovered, setIsHovered] = useState(false);  // State triggers re-renders
  const [isPressed, setIsPressed] = useState(false);

  return (
    <motion.button
      onMouseEnter={() => setIsHovered(true)}   // Re-render on hover
      onMouseLeave={() => setIsHovered(false)}  // Re-render on leave
      onMouseDown={() => setIsPressed(true)}    // Re-render on press
      onMouseUp={() => setIsPressed(false)}     // Re-render on release
      animate={{
        scale: isPressed ? 0.95 : isHovered ? 1.05 : 1,
        backgroundColor: isHovered ? "#3b82f6" : "#2563eb",
      }}
      onClick={onClick}
    >
      {label}
    </motion.button>
  );
}
```

**Correct (built-in gesture props, no re-renders):**

```tsx
function ActionButton({ label, onClick }: ActionButtonProps) {
  return (
    <motion.button
      whileHover={{ scale: 1.05, backgroundColor: "#3b82f6" }}  // Optimized internally
      whileTap={{ scale: 0.95 }}  // No state, no re-renders
      initial={{ backgroundColor: "#2563eb" }}
      onClick={onClick}
    >
      {label}
    </motion.button>
  );
}
```

Reference: [Framer Motion - Gestures](https://www.framer.com/motion/gestures/)
