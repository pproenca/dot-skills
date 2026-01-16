---
title: Use Intercepting Routes for Modal Patterns
impact: LOW
impactDescription: Enables shareable modal URLs while preserving navigation context
tags: advanced, intercepting-routes, modals, navigation, ux
---

## Use Intercepting Routes for Modal Patterns

Traditional modals break browser navigation and cannot be shared via URL. Intercepting routes allow you to display content in a modal when navigating client-side while showing the full page when accessed directly, giving users shareable URLs and proper back button behavior.

**Incorrect (modal without URL - not shareable):**

```tsx
// app/photos/page.tsx
'use client'

import { useState } from 'react'

export default function PhotoGallery() {
  const [selectedPhoto, setSelectedPhoto] = useState<Photo | null>(null)
  // Modal state lost on refresh - URL not shareable
  // Back button closes entire page instead of modal

  return (
    <div>
      {photos.map((photo) => (
        <div key={photo.id} onClick={() => setSelectedPhoto(photo)}>
          <PhotoThumbnail photo={photo} />
        </div>
      ))}
      {selectedPhoto && (
        <Modal onClose={() => setSelectedPhoto(null)}>
          <PhotoDetail photo={selectedPhoto} />
        </Modal>
      )}
    </div>
  )
}
```

**Correct (intercepting route with shareable modal URL):**

```tsx
// app/photos/page.tsx
import Link from 'next/link'

export default function PhotoGallery() {
  return (
    <div>
      {photos.map((photo) => (
        <Link key={photo.id} href={`/photos/${photo.id}`}>
          <PhotoThumbnail photo={photo} />
        </Link>
      ))}
    </div>
  )
}
```

```tsx
// app/photos/[id]/page.tsx - Direct access shows full page
export default async function PhotoPage({
  params,
}: {
  params: Promise<{ id: string }>
}) {
  const { id } = await params
  const photo = await getPhoto(id)

  return <PhotoDetail photo={photo} />
}
```

```tsx
// app/@modal/(.)photos/[id]/page.tsx - Intercepts to show modal
export default async function PhotoModal({
  params,
}: {
  params: Promise<{ id: string }>
}) {
  const { id } = await params
  const photo = await getPhoto(id)

  return (
    <Modal>
      <PhotoDetail photo={photo} />
    </Modal>
  )
}
```

```tsx
// app/layout.tsx - Renders both slots
export default function RootLayout({
  children,
  modal,
}: {
  children: React.ReactNode
  modal: React.ReactNode
}) {
  return (
    <html>
      <body>
        {children}
        {modal}
      </body>
    </html>
  )
}
```

**Interception conventions:**
- `(.)` - Same level
- `(..)` - One level up
- `(..)(..)` - Two levels up
- `(...)` - From root

Reference: [Intercepting Routes](https://nextjs.org/docs/app/building-your-application/routing/intercepting-routes)
