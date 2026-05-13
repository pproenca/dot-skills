---
title: Preserve hidden subtree state across navigation instead of unmounting
impact: HIGH
impactDescription: eliminates navigation re-render cost, preserves user input state across tab/page switches
tags: conc, state-preservation, hidden-mount, pre-render, tab-switching
---

## Preserve hidden subtree state across navigation instead of unmounting

**Pattern intent:** when the user navigates between tabs or screens that they'll return to, the unrendered side's state (form drafts, scroll position, expensive trees) should survive — not be torn down and rebuilt.

### Shapes to recognize

- Conditional rendering `{page === 'x' && <X/>}` for tab/route switching that destroys mid-edit state on switch.
- Multi-step wizard rendering only the current step — earlier steps lose form values on Back.
- Modal/Drawer that unmounts on close and remounts on open, losing in-progress input.
- Workaround: `display: none` on a wrapper to "preserve" state — works, but the subtree still runs effects and the framework can't prioritize.
- Workaround: storing draft state in a parent `useState` to survive child unmount — the parent ends up owning state that conceptually belongs to the child.

The canonical resolution is `<Activity mode="hidden">` (React 19.2), which keeps the subtree mounted, defers its effects, and enables background pre-rendering.

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
