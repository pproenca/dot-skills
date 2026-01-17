---
title: Use urlKeys for Shorter URLs
impact: LOW
impactDescription: reduces URL length with abbreviated parameter names
tags: advanced, urlKeys, serializer, url-length, abbreviation
---

## Use urlKeys for Shorter URLs

Map verbose parameter names to shorter URL keys for cleaner, more shareable URLs while keeping descriptive names in code.

**Without urlKeys:**

```tsx
'use client'
import { useQueryStates, parseAsFloat, parseAsInteger } from 'nuqs'

export default function MapView() {
  const [coords, setCoords] = useQueryStates({
    latitude: parseAsFloat.withDefault(0),
    longitude: parseAsFloat.withDefault(0),
    zoomLevel: parseAsInteger.withDefault(10)
  })
  // URL: ?latitude=48.8566&longitude=2.3522&zoomLevel=12
  // Long and harder to share

  return <Map {...coords} />
}
```

**With urlKeys:**

```tsx
'use client'
import { useQueryStates, parseAsFloat, parseAsInteger } from 'nuqs'

export default function MapView() {
  const [coords, setCoords] = useQueryStates(
    {
      latitude: parseAsFloat.withDefault(0),
      longitude: parseAsFloat.withDefault(0),
      zoomLevel: parseAsInteger.withDefault(10)
    },
    {
      urlKeys: {
        latitude: 'lat',
        longitude: 'lng',
        zoomLevel: 'z'
      }
    }
  )
  // URL: ?lat=48.8566&lng=2.3522&z=12
  // Shorter, cleaner URLs

  // Code still uses descriptive names
  console.log(coords.latitude, coords.longitude, coords.zoomLevel)

  return <Map {...coords} />
}
```

**With createSerializer:**

```tsx
import { createSerializer, parseAsFloat, parseAsInteger } from 'nuqs/server'

const serialize = createSerializer(
  {
    latitude: parseAsFloat,
    longitude: parseAsFloat,
    zoomLevel: parseAsInteger
  },
  {
    urlKeys: {
      latitude: 'lat',
      longitude: 'lng',
      zoomLevel: 'z'
    }
  }
)

const url = serialize({ latitude: 48.8566, longitude: 2.3522, zoomLevel: 12 })
// Result: lat=48.8566&lng=2.3522&z=12
```

**When to use urlKeys:**
- Shareable URLs with length constraints
- SEO-friendly short URLs
- API compatibility with specific param names
- Migration from existing URL structures

Reference: [nuqs urlKeys](https://nuqs.dev/docs/utilities)
