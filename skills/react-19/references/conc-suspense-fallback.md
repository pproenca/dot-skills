---
title: Avoid Suspense Fallback Thrashing
impact: HIGH
impactDescription: prevents flickering, smoother UX
tags: conc, suspense, fallback, transitions
---

## Avoid Suspense Fallback Thrashing

Wrap navigations in transitions to prevent Suspense fallbacks from appearing during fast updates. This keeps the previous content visible while loading.

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
