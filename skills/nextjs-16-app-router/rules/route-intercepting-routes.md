---
title: Use Intercepting Routes for Modal Patterns
impact: HIGH
impactDescription: enables shareable modal URLs, better UX
tags: route, intercepting-routes, modal, navigation
---

## Use Intercepting Routes for Modal Patterns

Intercepting routes display content in a modal when navigating client-side, while showing the full page on direct access or refresh. Perfect for image galleries, login modals, and detail views.

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
