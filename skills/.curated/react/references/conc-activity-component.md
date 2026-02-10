---
title: Use Activity for Pre-Rendering and State Preservation
impact: HIGH
impactDescription: eliminates navigation re-render cost, preserves user input state
tags: conc, activity, pre-render, state-preservation
---

## Use Activity for Pre-Rendering and State Preservation

`<Activity>` (React 19.2) controls rendering priority for parts of your app. Hidden activities defer updates and unmount effects without destroying state, enabling instant navigation and background pre-rendering.

**Incorrect (conditional rendering destroys state):**

```typescript
function App() {
  const [page, setPage] = useState('inbox')

  return (
    <div>
      <nav>
        <button onClick={() => setPage('inbox')}>Inbox</button>
        <button onClick={() => setPage('compose')}>Compose</button>
      </nav>
      {page === 'inbox' && <Inbox />}
      {page === 'compose' && <ComposeEmail />}
    </div>
  )
}
// Switching tabs destroys ComposeEmail state — user loses draft
```

**Correct (Activity preserves state):**

```typescript
import { Activity } from 'react'

function App() {
  const [page, setPage] = useState('inbox')

  return (
    <div>
      <nav>
        <button onClick={() => setPage('inbox')}>Inbox</button>
        <button onClick={() => setPage('compose')}>Compose</button>
      </nav>
      <Activity mode={page === 'inbox' ? 'visible' : 'hidden'}>
        <Inbox />
      </Activity>
      <Activity mode={page === 'compose' ? 'visible' : 'hidden'}>
        <ComposeEmail />
      </Activity>
    </div>
  )
}
// ComposeEmail state preserved — user's draft survives tab switches
```

**Pre-rendering likely navigation targets:**

```typescript
function ProductPage({ productId }: { productId: string }) {
  return (
    <div>
      <ProductDetails productId={productId} />
      {/* Pre-render checkout while user browses */}
      <Activity mode="hidden">
        <Suspense fallback={null}>
          <Checkout productId={productId} />
        </Suspense>
      </Activity>
    </div>
  )
}
// Checkout loads data and CSS in background — instant when user clicks Buy
```

**When to use:**
- Tab interfaces where users switch back and forth
- Pre-rendering likely next pages for instant navigation
- Preserving form state during multi-step workflows

Reference: [React 19.2 Blog Post](https://react.dev/blog/2025/10/01/react-19-2)
