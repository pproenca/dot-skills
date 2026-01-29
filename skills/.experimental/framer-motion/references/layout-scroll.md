---
title: Add layoutScroll to Scrollable Ancestors
impact: HIGH
impactDescription: fixes layout animations in scroll containers
tags: layout, layoutScroll, scroll, container
---

## Add layoutScroll to Scrollable Ancestors

Layout animations calculate element positions relative to the viewport. When a layout-animated element is inside a scrollable container, the scroll offset can cause incorrect position calculations. Add `layoutScroll` to the scrollable ancestor to account for scroll position.

**Incorrect (layout animation jumps due to scroll offset):**

```tsx
function MessageList({ messages }: Props) {
  return (
    <div className="message-container" style={{ overflowY: "auto", height: 400 }}>
      {/* When scrolled, new messages animate from wrong position */}
      {messages.map((message) => (
        <motion.div
          key={message.id}
          layout
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="message"
        >
          {message.text}
        </motion.div>
      ))}
    </div>
  );
}
```

**Correct (layoutScroll on scrollable container):**

```tsx
function MessageList({ messages }: Props) {
  return (
    <motion.div
      layoutScroll // Accounts for scroll offset in layout calculations
      className="message-container"
      style={{ overflowY: "auto", height: 400 }}
    >
      {messages.map((message) => (
        <motion.div
          key={message.id}
          layout
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="message"
        >
          {message.text}
        </motion.div>
      ))}
    </motion.div>
  );
}
```

**When to use layoutScroll:**
- Scrollable lists with reorderable items
- Chat interfaces with layout-animated messages
- Infinite scroll feeds with layout transitions
- Any `overflow: auto/scroll` container with layout animations inside

**Note:** Apply `layoutScroll` to ALL scrollable ancestors in the hierarchy, not just the immediate parent. For deeply nested scroll containers, each scrollable element needs the prop.

```tsx
<motion.div layoutScroll style={{ overflowY: "auto" }}>
  <motion.div layoutScroll style={{ overflowX: "auto" }}>
    <motion.div layout>Content</motion.div>
  </motion.div>
</motion.div>
```

Reference: [Framer Motion - Layout Scroll](https://www.framer.com/motion/layout-animations/#layout-scroll)
