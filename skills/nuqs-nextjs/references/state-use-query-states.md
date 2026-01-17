---
title: Use useQueryStates for Related Parameters
impact: HIGH
impactDescription: atomic updates prevent intermediate invalid states
tags: state, useQueryStates, batching, atomic, related-params
---

## Use useQueryStates for Related Parameters

When multiple URL parameters are logically related (like coordinates, date ranges, or filters), use `useQueryStates` for atomic updates. Multiple `useQueryState` calls update the URL independently, causing intermediate states.

**Incorrect (separate hooks, non-atomic):**

```tsx
'use client'
import { useQueryState, parseAsFloat } from 'nuqs'

export default function MapView() {
  const [lat, setLat] = useQueryState('lat', parseAsFloat.withDefault(0))
  const [lng, setLng] = useQueryState('lng', parseAsFloat.withDefault(0))
  const [zoom, setZoom] = useQueryState('zoom', parseAsFloat.withDefault(10))

  const goToParis = () => {
    setLat(48.8566)   // URL update 1
    setLng(2.3522)    // URL update 2
    setZoom(12)       // URL update 3
    // Three separate URL updates, three history entries if using push
  }

  return <button onClick={goToParis}>Go to Paris</button>
}
```

**Correct (single hook, atomic):**

```tsx
'use client'
import { useQueryStates, parseAsFloat, parseAsInteger } from 'nuqs'

export default function MapView() {
  const [coords, setCoords] = useQueryStates({
    lat: parseAsFloat.withDefault(0),
    lng: parseAsFloat.withDefault(0),
    zoom: parseAsInteger.withDefault(10)
  })

  const goToParis = () => {
    setCoords({
      lat: 48.8566,
      lng: 2.3522,
      zoom: 12
    })
    // Single atomic URL update
  }

  return (
    <div>
      <p>Location: {coords.lat}, {coords.lng} (zoom: {coords.zoom})</p>
      <button onClick={goToParis}>Go to Paris</button>
    </div>
  )
}
```

**Partial updates also work:**

```tsx
// Only update zoom, keep lat/lng
setCoords({ zoom: 15 })

// Update lat/lng, keep zoom
setCoords({ lat: 51.5074, lng: -0.1278 })
```

Reference: [nuqs useQueryStates](https://nuqs.dev/docs/usequerystates)
