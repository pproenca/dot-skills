---
title: Split heavy components that aren't visible at first paint into separately loaded chunks
impact: CRITICAL
impactDescription: 30-70% smaller initial bundle when modals, charts, editors, or maps are deferred until they're actually rendered
tags: build, dynamic-import, code-split, deferred-load
---

## Split heavy components that aren't visible at first paint into separately loaded chunks

**Pattern intent:** every component imported at the top of a route ships in the initial bundle, even if it's only rendered conditionally (modals, charts, editors, maps). Splitting them into a dynamically-loaded chunk means the browser fetches them only when they're actually rendered.

### Shapes to recognize

- A top-level `import HeavyChart from '...'` followed by `{open && <HeavyChart/>}` — the component ships even when `open` is always false.
- A modal/drawer/dialog component imported eagerly and rendered conditionally — `{isOpen && <SettingsModal/>}` ships ~100KB the user never sees.
- A code editor, video player, chart library, or map component imported in a layout — even pages that don't use it pay the cost.
- A "feature flag protected" component imported normally and gated by `if (flag)` — the gated path still ships.
- Workaround: a `React.lazy(() => import(...))` instead of `next/dynamic` — works for client components but loses Next.js's SSR/loading-state integration; prefer `next/dynamic` in App Router code.
- An `<iframe src="..." />` hack to defer heavy components — works but loses SSR and styling integration.

The canonical resolution: `const X = dynamic(() => import('./X'), { loading: () => <XSkeleton/> })`. Add `ssr: false` only when the component genuinely cannot SSR (e.g., touches `window` at module scope).

Reference: [Dynamic Imports](https://nextjs.org/docs/app/building-your-application/optimizing/lazy-loading)

**Incorrect (always included in main bundle):**

```typescript
import HeavyChart from '@/components/HeavyChart'
import CodeEditor from '@/components/CodeEditor'

export default function Dashboard() {
  const [showChart, setShowChart] = useState(false)

  return (
    <div>
      {showChart && <HeavyChart />}
      <CodeEditor />
    </div>
  )
}
// Both components in initial bundle (~500KB added)
```

**Correct (loaded on demand):**

```typescript
import dynamic from 'next/dynamic'

const HeavyChart = dynamic(() => import('@/components/HeavyChart'), {
  loading: () => <ChartSkeleton />
})

const CodeEditor = dynamic(() => import('@/components/CodeEditor'), {
  ssr: false  // Client-only component
})

export default function Dashboard() {
  const [showChart, setShowChart] = useState(false)

  return (
    <div>
      {showChart && <HeavyChart />}
      <CodeEditor />
    </div>
  )
}
// Components loaded only when rendered
```

**When to use `ssr: false`:** For components that access browser APIs (window, document) or libraries without SSR support.

---

### In disguise — `React.lazy` + `useEffect`-triggered import instead of `next/dynamic`

The grep-friendly anti-pattern is a top-level `import HeavyChart`. The disguise is the developer realizing it's heavy and reaching for `React.lazy` plus a manual `useEffect` to "kick off the import." This produces a working result but loses Next.js's SSR/loading-state integration and is harder to type-check.

**Incorrect — in disguise (React.lazy + useEffect kick-off):**

```typescript
'use client'

import { useState, useEffect, lazy, Suspense } from 'react'

const HeavyChart = lazy(() => import('@/components/HeavyChart'))

export function ChartSection({ data }: { data: ChartData }) {
  const [shouldLoad, setShouldLoad] = useState(false)

  useEffect(() => {
    const id = setTimeout(() => setShouldLoad(true), 0)
    return () => clearTimeout(id)
  }, [])

  if (!shouldLoad) return <ChartSkeleton />
  return (
    <Suspense fallback={<ChartSkeleton />}>
      <HeavyChart data={data} />
    </Suspense>
  )
}
```

What's wrong: the manual `useEffect` + `setTimeout` reinvents the loading delay; `React.lazy` is client-only; the skeleton appears twice (once gated by `shouldLoad`, once by `Suspense`); the import path isn't SSR-aware.

**Correct — `next/dynamic` with platform integration:**

```typescript
'use client'

import dynamic from 'next/dynamic'

const HeavyChart = dynamic(() => import('@/components/HeavyChart'), {
  loading: () => <ChartSkeleton />,
  ssr: false, // only if the chart genuinely cannot SSR
})

export function ChartSection({ data }: { data: ChartData }) {
  return <HeavyChart data={data} />
}
```

The fallback, the SSR semantics, and the lazy-load triggering are all platform-managed.

Final reference: [Dynamic Imports](https://nextjs.org/docs/app/building-your-application/optimizing/lazy-loading)
