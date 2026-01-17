---
title: Throttle Rapid URL Updates
impact: MEDIUM
impactDescription: prevents browser history API rate limiting
tags: perf, throttleMs, rate-limiting, typing, slider
---

## Throttle Rapid URL Updates

Browsers rate-limit History API calls. Rapid updates (typing, sliders, dragging) can exceed this limit, causing dropped updates. Use `throttleMs` to batch updates.

**Incorrect (every keystroke updates URL):**

```tsx
'use client'
import { useQueryState, parseAsString } from 'nuqs'

export default function SearchBox() {
  const [query, setQuery] = useQueryState('q', parseAsString.withDefault(''))
  // Every keystroke pushes to history
  // Browser may throttle after ~100 rapid updates

  return (
    <input
      value={query}
      onChange={e => setQuery(e.target.value)}
    />
  )
}
```

**Correct (throttled updates):**

```tsx
'use client'
import { useQueryState, parseAsString } from 'nuqs'

export default function SearchBox() {
  const [query, setQuery] = useQueryState('q', parseAsString.withDefault('').withOptions({
    throttleMs: 300 // Batch updates every 300ms
  }))
  // UI updates instantly, URL updates at most every 300ms

  return (
    <input
      value={query}
      onChange={e => setQuery(e.target.value)}
    />
  )
}
```

**For sliders and drag operations:**

```tsx
'use client'
import { useQueryState, parseAsInteger } from 'nuqs'

export default function VolumeSlider() {
  const [volume, setVolume] = useQueryState('volume', parseAsInteger.withDefault(50).withOptions({
    throttleMs: 100 // More responsive for continuous input
  }))

  return (
    <input
      type="range"
      min={0}
      max={100}
      value={volume}
      onChange={e => setVolume(Number(e.target.value))}
    />
  )
}
```

**Override per-update:**

```tsx
// Normal updates use default throttle
setQuery('new value')

// Force immediate update (e.g., on blur)
setQuery('final value', { throttleMs: 0 })
```

**Note:** Minimum throttle is 50ms. UI state updates instantly regardless of throttle.

Reference: [nuqs Throttling](https://nuqs.dev/docs/options)
