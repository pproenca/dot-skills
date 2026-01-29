---
title: Use layout="position" or "size" for Targeted Animations
impact: HIGH
impactDescription: animates only what changes, faster transitions
tags: layout, performance, position, size, optimization
---

## Use layout="position" or "size" for Targeted Animations

When only position OR size changes (not both), use `layout="position"` or `layout="size"` instead of `layout={true}`. This tells Framer Motion to skip measuring and animating the unchanged dimension, reducing computation.

**Incorrect (animates both position and size unnecessarily):**

```tsx
function TabPanel({ tabs, activeIndex }: Props) {
  return (
    <div className="tab-container">
      {tabs.map((tab, index) => (
        <motion.div
          key={tab.id}
          layout={true} // Animates position AND size
          className="tab"
        >
          {tab.label}
        </motion.div>
      ))}
      <motion.div
        layout={true} // Only position changes, size stays constant
        className="tab-indicator"
        style={{ width: TAB_WIDTH }}
      />
    </div>
  );
}
```

**Correct (animates only position for the indicator):**

```tsx
function TabPanel({ tabs, activeIndex }: Props) {
  return (
    <div className="tab-container">
      {tabs.map((tab, index) => (
        <motion.div
          key={tab.id}
          layout={true}
          className="tab"
        >
          {tab.label}
        </motion.div>
      ))}
      <motion.div
        layout="position" // Only animates position, skips size calculations
        className="tab-indicator"
        style={{ width: TAB_WIDTH }}
      />
    </div>
  );
}
```

**Guidelines:**
- `layout="position"` - Use when element moves but size stays constant (tab indicators, drag-and-drop)
- `layout="size"` - Use when element resizes in place but doesn't move (accordion panels, expandable cards)
- `layout={true}` - Use when both position and size change (grid reflows, responsive layouts)

Reference: [Framer Motion - Layout Prop](https://www.framer.com/motion/layout-animations/#layout)
