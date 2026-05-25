---
title: Treat Suspense as the static/dynamic boundary, not a spinner
tags: shell, suspense, streaming, static-shell
---

## Treat Suspense as the static/dynamic boundary, not a spinner

The model treats `<Suspense>` as a loading-spinner convenience. Under PPR it is the **architectural seam**: everything outside a boundary is prerendered into the static shell and sent to the browser instantly; at the boundary, the *fallback* also ships in the shell while the *children* stream in at request time. Where you draw the boundary literally decides what is static versus dynamic — so place it deliberately, not just "wherever something loads."

```tsx
import { Suspense } from 'react'

export default function BlogPage() {
  return (
    <>
      {/* Static — prerendered into the shell, sent instantly */}
      <header>
        <h1>Welcome to the Blog</h1>
      </header>

      {/* Boundary: the skeleton ships in the shell; LatestPosts streams at request time */}
      <Suspense fallback={<BlogListSkeleton />}>
        <LatestPosts />
      </Suspense>
    </>
  )
}
```

Reference: [Fetching Data — streaming with Suspense](https://nextjs.org/docs/app/getting-started/fetching-data#with-suspense)
