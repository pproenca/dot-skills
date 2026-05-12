---
title: Avoid Client-Only Libraries in Server Components
impact: MEDIUM-HIGH
impactDescription: prevents build errors, correct component placement
tags: rsc, libraries, client-only, server
---

## Avoid Client-Only Libraries in Server Components

Libraries that use browser APIs (window, document, localStorage) cannot run in Server Components. Import them only in Client Components.

**Incorrect (client library in Server Component):**

```typescript
// page.tsx (Server Component)
import { motion } from 'framer-motion'  // ❌ Uses browser APIs

export default function Page() {
  return (
    <motion.div animate={{ opacity: 1 }}>
      Hello
    </motion.div>
  )
}
// Error: window is not defined
```

**Correct (client library in Client Component):**

```typescript
// components/AnimatedSection.tsx
'use client'

import { motion } from 'framer-motion'

export function AnimatedSection({ children }: { children: React.ReactNode }) {
  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
    >
      {children}
    </motion.div>
  )
}

// page.tsx (Server Component)
import { AnimatedSection } from '@/components/AnimatedSection'

export default async function Page() {
  const data = await fetchData()

  return (
    <AnimatedSection>
      <ServerContent data={data} />
    </AnimatedSection>
  )
}
```

**How to identify a client-only library** (rather than memorizing a list — most popular packages now ship dual entries):

- Touches `window`, `document`, `localStorage`, `navigator`, or other browser-only globals
- Uses refs to manipulate DOM (canvas, intersection observers, gesture handlers)
- Reads from `useSyncExternalStore` against a browser-only store
- Has a `'use client'` directive at the top of its entry point, or its package docs explicitly say "client component only"

**Common categories that typically need `'use client'`:**
- Animation libraries with browser-driven timing
- Client-side state stores (when initialized with `localStorage`/`sessionStorage` hydration)
- Toast/modal/portal libraries that mount to `document.body`
- Canvas/SVG chart libraries that measure DOM
- Form libraries that rely on refs and uncontrolled inputs

**Always check the package's docs** — many libraries (e.g., framer-motion v11+, several auth SDKs) now publish dedicated server-safe entry points. The pattern "wrap in a thin client component" is the safe default when unsure.
