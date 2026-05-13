---
title: Modal/lightbox detail views with shareable URLs should use intercepting routes — not client-state modals
impact: HIGH
impactDescription: enables shareable modal URLs, browser back-button support, and refresh-survives-modal behavior with one routing convention
tags: route, intercepting-routes, shareable-modal, deep-link
---

## Modal/lightbox detail views with shareable URLs should use intercepting routes — not client-state modals

**Pattern intent:** when a detail view should appear as a modal on internal navigation but as a full page on direct visit / refresh / share, intercepting routes are the React-native way. The URL is real, the back button works, and refresh-on-modal opens the full page.

### Shapes to recognize

- A photo gallery / product list where clicking an item opens a `useState`-driven modal — URL doesn't change; refresh closes the modal; sharing the URL doesn't deep-link to the item.
- A "view profile" overlay that captures click events and renders a positioned div — same problem; not shareable.
- A modal whose state is held in a `<Dialog open>` boolean tracked in URL search params via `?modal=...` — *almost* there, but loses the page semantics on refresh.
- A workaround using `router.push(path, { shallow: true })` (a Pages-Router-era trick) — doesn't exist in App Router.
- Two parallel implementations of the same view: a modal version in `'use client'` and a page version in a Server Component — should be one intercepting route with two entry paths.

The canonical resolution: create `app/@modal/(.)<path>/page.tsx` (interception convention: `(.)` same level, `(..)` one up, `(...)` from root) that renders the content inside a `<Modal>` wrapper. The full-page version lives at `app/<path>/page.tsx`. Both fetch the same data via a shared cached fetcher.

Reference: [Intercepting Routes](https://nextjs.org/docs/app/building-your-application/routing/intercepting-routes)

**Incorrect (client-state modal without URL):**

```typescript
'use client'

export default function PhotoGallery({ photos }) {
  const [selectedPhoto, setSelectedPhoto] = useState(null)

  return (
    <div>
      {photos.map(photo => (
        <Image
          key={photo.id}
          onClick={() => setSelectedPhoto(photo)}
        />
      ))}
      {selectedPhoto && (
        <Modal onClose={() => setSelectedPhoto(null)}>
          <PhotoDetail photo={selectedPhoto} />
        </Modal>
      )}
    </div>
  )
}
// Modal not shareable, lost on refresh
```

**Correct (intercepting route):**

```text
app/
├── @modal/
│   ├── (.)photo/[id]/
│   │   └── page.tsx    # Shows in modal on client nav
│   └── default.tsx
├── photo/[id]/
│   └── page.tsx        # Shows full page on direct access
└── page.tsx            # Gallery
```

```typescript
// app/@modal/(.)photo/[id]/page.tsx
import { Modal } from '@/components/Modal'

export default async function PhotoModal({ params }: { params: { id: string } }) {
  const photo = await getPhoto(params.id)
  return (
    <Modal>
      <PhotoDetail photo={photo} />
    </Modal>
  )
}

// app/photo/[id]/page.tsx
export default async function PhotoPage({ params }: { params: { id: string } }) {
  const photo = await getPhoto(params.id)
  return <PhotoDetail photo={photo} />  // Full page
}
```

**Interception conventions:**
- `(.)` - Same level
- `(..)` - One level up
- `(..)(..)` - Two levels up
- `(...)` - From root
