# ProductSearch — with skill

```tsx
import { useState, useTransition, useMemo } from 'react'

interface Product {
  id: number
  name: string
}

// ~5,000 products generated once at module level so the reference is stable
// across renders (lazy initializer pattern from rule 5.4).
const ALL_PRODUCTS: Product[] = Array.from({ length: 5000 }, (_, i) => ({
  id: i + 1,
  name: `Product ${i + 1} — ${['Alpha', 'Beta', 'Gamma', 'Delta', 'Epsilon'][i % 5]} ${String.fromCharCode(65 + (i % 26))}`,
}))

export function ProductSearch() {
  // One state cell for the raw input value — updates at high priority.
  const [query, setQuery] = useState('')

  // useTransition (rule 1.5): marks the filtering work as low-priority and
  // interruptible so keystrokes never block while the list re-renders.
  const [isPending, startTransition] = useTransition()

  // A second state cell carries the committed (transitioned) query that drives
  // the expensive filter. The input reads `query` for immediate display;
  // the list reads `committedQuery` at deferred priority.
  const [committedQuery, setCommittedQuery] = useState('')

  function handleChange(e: React.ChangeEvent<HTMLInputElement>) {
    const value = e.target.value
    setQuery(value)           // high priority — input stays responsive
    startTransition(() => {   // low priority — can be interrupted
      setCommittedQuery(value)
    })
  }

  // useMemo (rule 6.5): the filter over 5,000 items is measurably expensive;
  // skip it when committedQuery hasn't changed. The derived list is computed
  // in render (rule 5.1) — no useState + useEffect mirroring.
  const filteredProducts = useMemo(
    () =>
      committedQuery.trim() === ''
        ? ALL_PRODUCTS
        : ALL_PRODUCTS.filter(p =>
            p.name.toLowerCase().includes(committedQuery.toLowerCase())
          ),
    [committedQuery]
  )

  return (
    <div>
      <input
        type="search"
        value={query}
        onChange={handleChange}
        placeholder="Search products…"
        aria-label="Search products"
      />
      {isPending && <span aria-live="polite"> Filtering…</span>}
      <p>{filteredProducts.length} result{filteredProducts.length !== 1 ? 's' : ''}</p>
      <ul>
        {filteredProducts.map(p => (
          <li key={p.id}>{p.name}</li>
        ))}
      </ul>
    </div>
  )
}
```

## Approach

The component uses `useTransition` (skill rule 1.5 — CRITICAL) to split the
onChange handler into two priorities: `setQuery` updates the controlled input
immediately at high priority so keystrokes are never blocked, while
`setCommittedQuery` inside `startTransition` marks the expensive filter work as
interruptible low-priority work. The filtered list is derived in render with
`useMemo` rather than mirrored into a separate `useState` + `useEffect` (rule
5.1), eliminating the derived-state-drift bug class; `useMemo` is justified here
because filtering 5,000 items on every render is measurably expensive and the
`committedQuery` dep is a stable primitive string (rule 6.5).
