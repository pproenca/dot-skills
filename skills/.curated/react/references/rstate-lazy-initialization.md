---
title: Pass a function to `useState` when the initial value is expensive — never compute it inline
impact: MEDIUM-HIGH
impactDescription: ensures expensive initial-value work runs once at mount, not on every render where the result is discarded
tags: rstate, lazy-initializer, init-once, useState-function-arg
---

## Pass a function to `useState` when the initial value is expensive — never compute it inline

**Pattern intent:** `useState(expression)` evaluates `expression` on every render even though React only uses the result the first time. For anything more expensive than a primitive or simple object literal, pass an initializer function — `useState(() => expr)` — so the work happens once at mount.

### Shapes to recognize

- `useState(parseMarkdown(props.content))` — `parseMarkdown` runs every render.
- `useState(JSON.parse(localStorage.getItem('x') ?? '{}'))` — touches storage on every render, throws if storage is unavailable past the first call.
- `useState({ heavy: buildHeavyMap(props.list) })` — same shape, hidden inside an object literal.
- `useState(transformItems(items))` where `transformItems` is O(n) — runs N items times every render.
- Workaround: a `useMemo` that *also* gets stored into `useState` — combines two memoization approaches, neither correctly.
- Workaround: a top-of-component `if (isFirstRender) { ... }` ref dance — manual gating that the function-arg form does for free.

The canonical resolution: `useState(() => expensiveExpression)`. The initializer is called once with no args; close over any props you need.

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
