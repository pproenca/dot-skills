---
title: Use Setter Return Value for URL Access
impact: MEDIUM
impactDescription: enables accurate URL tracking for analytics/sharing
tags: state, setter, return-value, url, analytics
---

## Use Setter Return Value for URL Access

The state setter returns a Promise that resolves to the new URL search string. Use this for analytics, logging, or when you need the resulting URL immediately.

**Incorrect (manually constructing URL):**

```tsx
'use client'
import { useQueryState, parseAsString } from 'nuqs'

export default function ShareButton() {
  const [query, setQuery] = useQueryState('q', parseAsString.withDefault(''))

  const share = () => {
    setQuery('shared-term')
    // Manual URL construction - may not match nuqs output
    const url = `${window.location.pathname}?q=shared-term`
    navigator.clipboard.writeText(url)
  }

  return <button onClick={share}>Share</button>
}
```

**Correct (use return value):**

```tsx
'use client'
import { useQueryState, parseAsString } from 'nuqs'

export default function ShareButton() {
  const [query, setQuery] = useQueryState('q', parseAsString.withDefault(''))

  const share = async () => {
    const searchString = await setQuery('shared-term')
    // searchString is "q=shared-term" or similar
    const url = `${window.location.origin}${window.location.pathname}?${searchString}`
    await navigator.clipboard.writeText(url)
  }

  return <button onClick={share}>Share</button>
}
```

**For analytics:**

```tsx
const trackSearch = async (term: string) => {
  const searchString = await setQuery(term)
  analytics.track('search', {
    term,
    url: `?${searchString}`
  })
}
```

**With useQueryStates:**

```tsx
const [coords, setCoords] = useQueryStates({
  lat: parseAsFloat,
  lng: parseAsFloat
})

const shareLocation = async () => {
  const searchString = await setCoords({ lat: 48.8566, lng: 2.3522 })
  // searchString: "lat=48.8566&lng=2.3522"
}
```

Reference: [nuqs Documentation](https://nuqs.dev/docs)
