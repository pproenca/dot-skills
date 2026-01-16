---
title: Use Lazy Initialization for Expensive Initial State
impact: MEDIUM
impactDescription: prevents expensive computation on every render
tags: state, useState, initialization, performance
---

## Use Lazy Initialization for Expensive Initial State

When initial state requires expensive computation, pass a function to useState. Otherwise, the computation runs on every render even though the result is only used once.

**Incorrect (expensive computation every render):**

```tsx
function EditorPage({ documentId }: { documentId: string }) {
  // parseDocument runs on EVERY render, result discarded after first
  const [content, setContent] = useState(parseDocument(documentId))  // 50ms wasted per render

  return <Editor content={content} onChange={setContent} />
}
```

**Correct (lazy initialization):**

```tsx
function EditorPage({ documentId }: { documentId: string }) {
  // parseDocument runs ONLY on initial render
  const [content, setContent] = useState(() => parseDocument(documentId))

  return <Editor content={content} onChange={setContent} />
}
```

**When to use lazy initialization:**
- Parsing large data structures
- Reading from localStorage/sessionStorage
- Creating complex initial objects
- Any computation taking >1ms

**With props dependency:**

```tsx
function FilteredList({ items, initialFilter }: Props) {
  // Expensive initial filter based on prop
  const [filtered, setFiltered] = useState(() =>
    items.filter(item => matchesFilter(item, initialFilter))
  )

  return <List items={filtered} />
}
```

**Note:** The initializer function receives no arguments. If you need props, reference them from the closure.

Reference: [useState Lazy Initialization](https://react.dev/reference/react/useState#avoiding-recreating-the-initial-state)
