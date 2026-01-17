---
title: Use Lazy Initialization for Expensive Initial State
impact: MEDIUM-HIGH
impactDescription: prevents expensive computation on every render
tags: state, useState, lazy, initialization
---

## Use Lazy Initialization for Expensive Initial State

Pass a function to useState for expensive initial values. The function runs only on first render, not on every re-render.

**Incorrect (expensive computation on every render):**

```typescript
function Editor() {
  // parseMarkdown runs on EVERY render, even though result is ignored
  const [content, setContent] = useState(parseMarkdown(initialContent))

  return <textarea value={content} onChange={e => setContent(e.target.value)} />
}
// parseMarkdown wasted on re-renders
```

**Correct (lazy initialization):**

```typescript
function Editor() {
  // parseMarkdown runs only on first render
  const [content, setContent] = useState(() => parseMarkdown(initialContent))

  return <textarea value={content} onChange={e => setContent(e.target.value)} />
}
```

**Common use cases for lazy initialization:**

```typescript
// Reading from localStorage
const [user, setUser] = useState(() => {
  const saved = localStorage.getItem('user')
  return saved ? JSON.parse(saved) : null
})

// Complex object creation
const [formState, setFormState] = useState(() => ({
  fields: createDefaultFields(),
  validation: initializeValidation(),
  touched: new Set()
}))

// Expensive transformation
const [data, setData] = useState(() =>
  rawData.map(item => transformItem(item))
)
```

**Note:** The initializer function receives no arguments. If you need props, create a closure: `useState(() => computeFrom(props.value))`
