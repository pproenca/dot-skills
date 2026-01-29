---
title: Provide Unique Keys for AnimatePresence Children
impact: LOW
impactDescription: prevents wrong animations on list changes
tags: exit, keys, animate-presence, list
---

## Provide Unique Keys for AnimatePresence Children

`AnimatePresence` uses React keys to track which elements enter and exit. Missing or duplicate keys cause incorrect animations, with elements animating in place instead of properly entering/exiting, or animations being skipped entirely.

**Incorrect (missing or index-based keys):**

```tsx
import { motion, AnimatePresence } from "framer-motion";

function TodoList({ todos }: TodoListProps) {
  return (
    <ul>
      <AnimatePresence>
        {todos.map((todo, index) => (
          <motion.li
            key={index}  // Index keys cause wrong item to animate on removal
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: 20 }}
          >
            {todo.text}
          </motion.li>
        ))}
      </AnimatePresence>
    </ul>
  );
}
```

**Correct (unique stable keys):**

```tsx
import { motion, AnimatePresence } from "framer-motion";

function TodoList({ todos }: TodoListProps) {
  return (
    <ul>
      <AnimatePresence>
        {todos.map((todo) => (
          <motion.li
            key={todo.id}  // Unique ID tracks correct element for exit animation
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: 20 }}
          >
            {todo.text}
          </motion.li>
        ))}
      </AnimatePresence>
    </ul>
  );
}
```

Reference: [Framer Motion - AnimatePresence](https://motion.dev/docs/react-animate-presence)
