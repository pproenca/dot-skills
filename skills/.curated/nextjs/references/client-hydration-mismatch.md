---
title: SSR and client initial render must produce identical HTML — defer browser-only or time-varying values to a post-mount effect
impact: LOW-MEDIUM
impactDescription: eliminates hydration mismatch warnings; prevents visible content shifts on first paint
tags: client, hydration-mismatch, post-mount-effect, ssr-safe
---

## SSR and client initial render must produce identical HTML — defer browser-only or time-varying values to a post-mount effect

**Pattern intent:** during hydration, React asserts that the client's first render matches the server's HTML. Time-of-day, `Math.random`, `window.innerWidth`, and `navigator.userAgent` produce different values per environment and trip the assertion.

### Shapes to recognize

- A component rendering `new Date().toLocaleTimeString()` directly in JSX — server renders one time, client hydrates with another a moment later.
- A `Math.random()` driving a JSX value (random tip, rotating banner) — different per render.
- A `window.innerWidth`-driven conditional in render — undefined on server, defined on client.
- A `localStorage.getItem(...)` read in render — undefined on server, populated on client.
- A locale-dependent value (`new Date().toLocaleDateString(locale)`) where server locale differs from client.
- A workaround `suppressHydrationWarning` slapped on every component — masks the symptom, hides real bugs.
- A "loading" state initialized to `false` on server, immediately set to `true` in a `useEffect` — causes a flash; should render placeholder until effect runs.

The canonical resolution: render a placeholder (or nothing) on first render; populate the time/random/storage-dependent value in a `useEffect` after mount. Use `suppressHydrationWarning` only on the specific element (a `<time>` tag, not the whole subtree) when the mismatch is *intentional*.

**Incorrect (hydration mismatch):**

```typescript
'use client'

export function Greeting() {
  // Different on server vs client
  const time = new Date().toLocaleTimeString()

  return <p>Current time: {time}</p>
}
// Server renders "10:30:00", client hydrates with "10:30:01" → mismatch!
```

**Correct (defer client-only values):**

```typescript
'use client'

import { useState, useEffect } from 'react'

export function Greeting() {
  const [time, setTime] = useState<string | null>(null)

  useEffect(() => {
    setTime(new Date().toLocaleTimeString())
    const interval = setInterval(() => {
      setTime(new Date().toLocaleTimeString())
    }, 1000)
    return () => clearInterval(interval)
  }, [])

  // Render nothing or placeholder on server
  if (!time) return <p>Loading time...</p>

  return <p>Current time: {time}</p>
}
```

**Alternative (suppressHydrationWarning for known differences):**

```typescript
'use client'

export function Timestamp() {
  return (
    <time suppressHydrationWarning>
      {new Date().toLocaleTimeString()}
    </time>
  )
}
// Use sparingly - only when mismatch is intentional
```

**Common causes:**
- `Date.now()`, `Math.random()`
- `window.innerWidth`, `navigator.userAgent`
- Browser extensions modifying HTML
- Different locales on server/client
