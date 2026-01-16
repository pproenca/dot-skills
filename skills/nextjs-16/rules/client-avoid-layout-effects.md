---
title: Avoid useLayoutEffect in Server-Rendered Apps
impact: HIGH
impactDescription: useLayoutEffect blocks paint and causes hydration warnings; replacing with useEffect fixes visual flicker and console errors
tags: client, useLayoutEffect, useEffect, hydration
---

## Avoid useLayoutEffect in Server-Rendered Apps

`useLayoutEffect` runs synchronously after DOM mutations but before paint, blocking the browser. In server-rendered apps, it causes hydration warnings and delays Time to Interactive. Use `useEffect` unless you truly need to measure or mutate DOM before paint.

**Incorrect (useLayoutEffect causing issues):**

```typescript
'use client'

import { useLayoutEffect, useState } from 'react'

export default function Tooltip({ children, content }) {
  const [position, setPosition] = useState({ x: 0, y: 0 })

  // ❌ Causes hydration warning: useLayoutEffect does nothing on server
  // ❌ Blocks paint unnecessarily
  useLayoutEffect(() => {
    // Position calculation that doesn't actually need layout effect
    const rect = document.body.getBoundingClientRect()
    setPosition({ x: rect.width / 2, y: 100 })
  }, [])

  return (
    <div style={{ left: position.x, top: position.y }}>
      {content}
    </div>
  )
}
```

**Correct (useEffect for most cases):**

```typescript
'use client'

import { useEffect, useState } from 'react'

export default function Tooltip({ children, content }) {
  const [position, setPosition] = useState({ x: 0, y: 0 })

  // ✓ No hydration warning
  // ✓ Doesn't block paint
  useEffect(() => {
    const rect = document.body.getBoundingClientRect()
    setPosition({ x: rect.width / 2, y: 100 })
  }, [])

  return (
    <div style={{ left: position.x, top: position.y }}>
      {content}
    </div>
  )
}
```

**When useLayoutEffect IS appropriate (rare):**

```typescript
'use client'

import { useLayoutEffect, useRef } from 'react'

export default function MeasuredComponent() {
  const ref = useRef<HTMLDivElement>(null)

  // ✓ Appropriate: measuring DOM before paint to prevent flicker
  useLayoutEffect(() => {
    if (ref.current) {
      // Must run before paint to avoid visual jump
      const height = ref.current.offsetHeight
      ref.current.style.setProperty('--measured-height', `${height}px`)
    }
  }, [])

  return <div ref={ref}>Content that needs measurement</div>
}
```

**Pattern for isomorphic layout effects:**

```typescript
'use client'

import { useEffect, useLayoutEffect } from 'react'

// Use useEffect on server, useLayoutEffect on client
const useIsomorphicLayoutEffect =
  typeof window !== 'undefined' ? useLayoutEffect : useEffect

export default function Component() {
  useIsomorphicLayoutEffect(() => {
    // DOM measurement code
  }, [])
}
```

**When to use useLayoutEffect:**
- Measuring DOM elements before paint (prevent flicker)
- Synchronously updating DOM based on measurements
- Tooltip/popover positioning that must not jump

**When NOT to use useLayoutEffect:**
- Data fetching
- Event listeners
- Timers
- Most state updates

Reference: [React useLayoutEffect](https://react.dev/reference/react/useLayoutEffect)
