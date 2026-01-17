---
title: Handle Controlled Input Value Properly
impact: HIGH
impactDescription: prevents uncontrolled to controlled warnings
tags: state, controlled-inputs, forms, null-handling, react
---

## Handle Controlled Input Value Properly

React requires controlled inputs to always have a defined `value`. Since nuqs returns `null` when a parameter is absent, you must provide a fallback for input elements.

**Incorrect (uncontrolled warning):**

```tsx
'use client'
import { useQueryState } from 'nuqs'

export default function SearchBox() {
  const [query, setQuery] = useQueryState('q')
  // query is string | null

  return (
    <input
      value={query} // Warning: value is null initially
      onChange={e => setQuery(e.target.value)}
    />
  )
}
// Warning: A component is changing an uncontrolled input to be controlled
```

**Correct (fallback value):**

```tsx
'use client'
import { useQueryState } from 'nuqs'

export default function SearchBox() {
  const [query, setQuery] = useQueryState('q')

  return (
    <input
      value={query ?? ''} // Fallback to empty string
      onChange={e => setQuery(e.target.value || null)}
    />
  )
}
```

**Alternative (withDefault):**

```tsx
'use client'
import { useQueryState, parseAsString } from 'nuqs'

export default function SearchBox() {
  const [query, setQuery] = useQueryState('q', parseAsString.withDefault(''))
  // query is string (never null)

  return (
    <input
      value={query} // No fallback needed
      onChange={e => setQuery(e.target.value)}
    />
  )
}
```

**For select elements:**

```tsx
const [sort, setSort] = useQueryState(
  'sort',
  parseAsStringLiteral(['asc', 'desc'] as const).withDefault('asc')
)

<select value={sort} onChange={e => setSort(e.target.value as typeof sort)}>
  <option value="asc">Ascending</option>
  <option value="desc">Descending</option>
</select>
```

Reference: [React Controlled Components](https://react.dev/reference/react-dom/components/input#controlling-an-input-with-a-state-variable)
