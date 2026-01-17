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

**Common client-only libraries:**
- Animation: framer-motion, react-spring
- State: zustand (browser storage), jotai (atoms)
- UI: react-hot-toast, react-modal
- Charts: recharts, chart.js (canvas)
- Forms: react-hook-form (needs refs)
