---
title: Build the canonical page as a static shell with one dynamic hole
tags: compose, suspense, static-shell, recipe
---

## Build the canonical page as a static shell with one dynamic hole

Faced with a page that mixes static and personalized content, the model makes the whole page either static (stale personalization) or fully dynamic (no instant shell). The canonical PPR page is neither: static chrome renders into the shell and ships instantly, and exactly the personalized/uncached leaf sits behind one `<Suspense>`. This is the simplest case and the baseline every other recipe builds on.

```tsx
import { Suspense } from 'react'
import { cookies } from 'next/headers'

export default function HomePage() {
  return (
    <main>
      {/* Static shell — instant */}
      <Hero />
      <FeatureGrid />

      {/* One dynamic hole — streams in at request time */}
      <Suspense fallback={<GreetingSkeleton />}>
        <PersonalGreeting />
      </Suspense>
    </main>
  )
}

async function PersonalGreeting() {
  const name = (await cookies()).get('name')?.value
  return name ? <p>Welcome back, {name}</p> : <p>Welcome</p>
}
```

Reference: [Partial Prerendering](https://nextjs.org/docs/app/getting-started/partial-prerendering)
