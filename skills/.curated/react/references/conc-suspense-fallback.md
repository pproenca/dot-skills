---
title: Keep previous content visible across navigation by wrapping the update in a transition
impact: HIGH
impactDescription: prevents 200-500ms layout shift flicker on every navigation
tags: conc, suspense-fallback, navigation-flicker, transition-wrap
---

## Keep previous content visible across navigation by wrapping the update in a transition

**Pattern intent:** during a navigation or state change that triggers Suspense, the previous content should remain on screen until the next is ready — not flash to a fallback and back.

### Shapes to recognize

- Plain `setPage(next)` outside any transition, where each route boundary is wrapped in `<Suspense fallback={<Spinner/>}>`. Every click causes a Spinner flash.
- "Loading…" text that appears for ~200ms on every tab click — a tell-tale unwrapped state update.
- Manual workaround: rendering both pages with `display:none` to dodge the fallback. Solves the symptom, not the cause.
- Manual workaround: a `setTimeout(() => setPage(...), 100)` to "let the new page warm up" — a homemade transition that's worse than the real one.
- Filter UI where each keystroke flashes a skeleton — same cause, different shape.

The canonical resolution is `useTransition` + `startTransition` around the state update that triggers Suspense.

**Incorrect (fallback shows on every navigation):**

```typescript
function App() {
  const [page, setPage] = useState('home')

  return (
    <div>
      <nav>
        <button onClick={() => setPage('home')}>Home</button>
        <button onClick={() => setPage('about')}>About</button>
      </nav>
      <Suspense fallback={<Spinner />}>
        {page === 'home' ? <Home /> : <About />}
      </Suspense>
    </div>
  )
}
// Spinner flashes on every page change
```

**Correct (transition keeps previous content):**

```typescript
import { useState, useTransition, Suspense } from 'react'

function App() {
  const [page, setPage] = useState('home')
  const [isPending, startTransition] = useTransition()

  function navigate(newPage: string) {
    startTransition(() => {
      setPage(newPage)
    })
  }

  return (
    <div>
      <nav style={{ opacity: isPending ? 0.7 : 1 }}>
        <button onClick={() => navigate('home')}>Home</button>
        <button onClick={() => navigate('about')}>About</button>
      </nav>
      <Suspense fallback={<Spinner />}>
        {page === 'home' ? <Home /> : <About />}
      </Suspense>
    </div>
  )
}
// Previous page stays visible while new page loads
```

**Benefits:**
- No layout shift from fallback
- Previous content remains visible
- Navigation feels instant with visual feedback (opacity)
