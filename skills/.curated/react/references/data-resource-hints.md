---
title: Reach for the imperative resource-hint APIs from `react-dom` instead of hand-rendering `<link rel="preload">`
impact: MEDIUM
impactDescription: 100-500ms saved on critical above-the-fold assets; deduped automatically; usable from event handlers and Server Components alike
tags: data, resource-hints, preload-api, dedup-link
---

## Reach for the imperative resource-hint APIs from `react-dom` instead of hand-rendering `<link rel="preload">`

**Pattern intent:** when telling the browser "fetch this resource ahead of time," the right call is `preload(url, opts)` / `preconnect(origin)` / `prefetchDNS(origin)` / `preinit(url, opts)` from `react-dom`. They dedupe across renders, work from event handlers, and integrate with the streaming HTML.

### Shapes to recognize

- `<link rel="preload" as="image" href={url}>` rendered as JSX inside a component — re-renders create duplicate links; calling from event handlers is awkward.
- `useEffect(() => { document.head.appendChild(linkEl) }, [])` to inject a preload tag imperatively — works but invents the dedup story from scratch.
- A `useEffect` that does `fetch(url)` purely to warm a cache — kind of works for `as: 'fetch'` cases, but `preload` is more semantic and the browser may schedule it differently.
- A "preload everything" component that renders a list of `<link>` elements that mostly aren't above-the-fold — wastes bandwidth and competes with the actual critical resources.
- `<link rel="preconnect" href={origin}>` rendered inline for an origin you never actually fetch from — observable in Network panel as an idle preconnect; should be removed or downgraded to `prefetchDNS`.

The canonical resolution: call `preload`/`preconnect`/`prefetchDNS`/`preinit` from `react-dom`. Pick the right one per the table below. Calls are idempotent — safe to make from render and from event handlers.

**Incorrect (manual link tags, no deduplication):**

```typescript
function ProductGallery({ imageUrls }: { imageUrls: string[] }) {
  // ❌ Re-renders create duplicate links, hard to manage from handlers
  return (
    <>
      {imageUrls.slice(0, 3).map((url) => (
        <link key={url} rel="preload" as="image" href={url} />
      ))}
      <Gallery images={imageUrls} />
    </>
  )
}
```

**Correct (preload from react-dom):**

```typescript
import { preload } from 'react-dom'

function ProductGallery({ imageUrls }: { imageUrls: string[] }) {
  // Preload first three images for instant rendering
  imageUrls.slice(0, 3).forEach((url) => preload(url, { as: 'image' }))

  return <Gallery images={imageUrls} />
}
// React inserts deduplicated <link rel="preload"> tags in <head>
```

---

**Choose the right API:**

| API | When to use | Example |
|-----|-------------|---------|
| `prefetchDNS(href)` | You _might_ request from this origin later (low cost, low confidence) | Analytics scripts loaded conditionally |
| `preconnect(href)` | You _will_ request from this origin (TLS handshake matters) | Your API host before first fetch |
| `preload(href, opts)` | You know the exact resource — eager fetch, no execute | Above-the-fold image, hero font, CSS |
| `preinit(href, opts)` | You want React to fetch AND execute the resource | Critical third-party script, deferred stylesheet |

---

**Hero image and critical font (above the fold):**

```typescript
import { preload, preconnect } from 'react-dom'

export default function HomePage() {
  preconnect('https://images.example.com')
  preload('https://images.example.com/hero.webp', { as: 'image', fetchPriority: 'high' })
  preload('/fonts/inter-var.woff2', { as: 'font', type: 'font/woff2', crossOrigin: 'anonymous' })

  return <Hero />
}
```

**Conditional preload from an event handler:**

```typescript
'use client'

import { preload } from 'react-dom'

function ProductCard({ product }: { product: Product }) {
  function handleHover() {
    // Warm the cache as the user hovers — instant click target
    preload(`/api/products/${product.id}`, { as: 'fetch' })
    preload(product.heroImage, { as: 'image' })
  }

  return (
    <a href={`/products/${product.id}`} onMouseEnter={handleHover}>
      {product.name}
    </a>
  )
}
```

**Notes:**
- The APIs are safe to call in render — they are idempotent and deduplicate by URL.
- `fetchPriority: 'high'` is honored by the browser for resource priority hints.
- In Server Components, calling these emits headers and link tags in the streamed HTML.
- For dynamically discovered resources (e.g., during route transitions), prefer the imperative APIs over rendering `<link>` JSX.

Reference: [React v19 — Resource Loading APIs](https://react.dev/blog/2024/12/05/react-19#support-for-preloading-resources)
