---
title: Prefer useEffect Over useLayoutEffect
impact: MEDIUM
impactDescription: prevents blocking browser paint, improving perceived performance by 50-100ms
tags: client, useEffect, useLayoutEffect, paint, performance
---

## Prefer useEffect Over useLayoutEffect

useLayoutEffect runs synchronously after DOM mutations but before the browser paints, blocking visual updates. Most effects like data fetching, subscriptions, and analytics do not need synchronous DOM measurement and should use useEffect to allow the browser to paint first.

**Incorrect (blocks paint unnecessarily):**

```tsx
'use client'

import { useLayoutEffect, useState } from 'react'

export function NotificationBanner({ message }: { message: string }) {
  const [isVisible, setIsVisible] = useState(true)

  useLayoutEffect(() => {
    // Analytics tracking doesn't need DOM measurements
    // Blocks paint for no benefit
    trackBannerView(message)

    const timer = setTimeout(() => {
      setIsVisible(false)
    }, 5000)

    return () => clearTimeout(timer)
  }, [message])

  if (!isVisible) return null

  return <div className="banner">{message}</div>
}
```

**Correct (allows paint before effect):**

```tsx
'use client'

import { useEffect, useState } from 'react'

export function NotificationBanner({ message }: { message: string }) {
  const [isVisible, setIsVisible] = useState(true)

  useEffect(() => {
    // Browser paints banner immediately, then runs effect
    trackBannerView(message)

    const timer = setTimeout(() => {
      setIsVisible(false)
    }, 5000)

    return () => clearTimeout(timer)
  }, [message])

  if (!isVisible) return null

  return <div className="banner">{message}</div>
}
```

**When useLayoutEffect IS appropriate:**

```tsx
'use client'

import { useLayoutEffect, useRef, useState } from 'react'

export function Tooltip({ children, content }: TooltipProps) {
  const triggerRef = useRef<HTMLDivElement>(null)
  const [position, setPosition] = useState({ top: 0, left: 0 })

  useLayoutEffect(() => {
    // DOM measurement needed before paint to prevent flicker
    if (triggerRef.current) {
      const rect = triggerRef.current.getBoundingClientRect()
      setPosition({
        top: rect.bottom + 8,
        left: rect.left + rect.width / 2,
      })
    }
  }, [])

  return (
    <>
      <div ref={triggerRef}>{children}</div>
      <div style={{ position: 'fixed', ...position }}>{content}</div>
    </>
  )
}
```

**When to use useLayoutEffect:**
- Measuring DOM elements before displaying dependent UI
- Preventing visual flicker when position depends on measurements
- Synchronizing with third-party DOM libraries

Reference: [React useLayoutEffect](https://react.dev/reference/react/useLayoutEffect)
