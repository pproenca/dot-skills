---
title: Quarantine browser-API-dependent libraries inside Client Component wrappers
impact: MEDIUM-HIGH
impactDescription: prevents build/runtime errors from browser-only globals running in Server Component context
tags: rsc, libraries, client-only, server, wrapper-island
---

## Quarantine browser-API-dependent libraries inside Client Component wrappers

**Pattern intent:** any library that touches `window`/`document`/`localStorage`/refs-to-DOM must be reached only through a thin `'use client'` wrapper component. The Server Component imports the wrapper, not the library.

### Shapes to recognize

- `import { motion } from 'framer-motion'` (or any animation lib) at the top of a `page.tsx` / `layout.tsx` / other Server Component — the build will fail or the runtime will throw "window is not defined".
- Top-level imports of toast libraries, chart libraries, or portal-mounting libraries (`react-hot-toast`, `chart.js`, `react-modal`) in a file with no `'use client'` directive.
- A "server-safe" library used in a Server Component that *internally* calls `localStorage` lazily — the error appears only on first render, not at import time.
- Workaround: dynamically importing the library inside an inline `useEffect` to "delay" it — the surrounding component is already on the client; you bought nothing and added a render gap.
- Workaround: SSR-guarding every reference with `typeof window !== 'undefined'` — works for SSR but defeats the bundle-shrinking purpose of Server Components.

The canonical resolution: create a small `'use client'` wrapper component that imports the library; have the Server Component import only that wrapper.

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
