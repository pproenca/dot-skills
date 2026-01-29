---
title: Use onTapCancel for Interrupted Gesture Cleanup
impact: MEDIUM
impactDescription: prevents stuck states on interrupted gestures
tags: gesture, onTapCancel, onTap, cleanup, state-management
---

## Use onTapCancel for Interrupted Gesture Cleanup

When a tap gesture is interrupted (pointer leaves element or becomes a drag), `onTap` never fires. Without `onTapCancel`, any state changes made in `onTapStart` won't be reverted, leaving the UI in an inconsistent state. Always pair `onTapStart` with both `onTap` and `onTapCancel`.

**Incorrect (missing cancel handling):**

```tsx
function InteractiveCard({ item, onSelect }: InteractiveCardProps) {
  const [isPressing, setIsPressing] = useState(false);

  return (
    <motion.div
      className="interactive-card"
      onTapStart={() => {
        setIsPressing(true);  // State set on tap start
        playHapticFeedback();
      }}
      onTap={() => {
        setIsPressing(false);
        onSelect(item.id);
      }}
      // Missing onTapCancel - if user drags away, isPressing stays true!
      animate={{ scale: isPressing ? 0.97 : 1 }}
    >
      <span>{item.title}</span>
    </motion.div>
  );
}
```

**Correct (complete gesture handling with cancel):**

```tsx
function InteractiveCard({ item, onSelect }: InteractiveCardProps) {
  const [isPressing, setIsPressing] = useState(false);

  return (
    <motion.div
      className="interactive-card"
      onTapStart={() => {
        setIsPressing(true);
        playHapticFeedback();
      }}
      onTap={() => {
        setIsPressing(false);
        onSelect(item.id);
      }}
      onTapCancel={() => {
        setIsPressing(false);  // Cleanup when tap is interrupted
      }}
      animate={{ scale: isPressing ? 0.97 : 1 }}
    >
      <span>{item.title}</span>
    </motion.div>
  );
}
```

**When onTapCancel fires:**
- Pointer leaves the element bounds
- Gesture transitions to a drag
- Another touch point is detected (multi-touch)
- The element is unmounted during the tap

Reference: [Framer Motion - Gestures](https://www.framer.com/motion/gestures/#tap)
