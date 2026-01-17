---
title: Lazy Load Heavy Components
impact: MEDIUM
impactDescription: reduces initial bundle by 30-50%
tags: perf, lazy-loading, dynamic-import, code-splitting, bundle
---

## Lazy Load Heavy Components

Use dynamic imports for heavy components (charts, editors, modals with complex content) to reduce initial bundle size and improve Time to Interactive.

**Incorrect (all components in initial bundle):**

```tsx
import { DataChart } from "@/components/data-chart" // 150KB
import { RichTextEditor } from "@/components/rich-text-editor" // 200KB
import { CodeEditor } from "@/components/code-editor" // 300KB

function Dashboard() {
  const [showChart, setShowChart] = useState(false)
  const [showEditor, setShowEditor] = useState(false)

  return (
    <div>
      {/* All 650KB loaded even if never used */}
      {showChart && <DataChart data={chartData} />}
      {showEditor && <RichTextEditor />}
    </div>
  )
}
```

**Correct (lazy loaded with Suspense):**

```tsx
import dynamic from "next/dynamic"
import { Skeleton } from "@/components/ui/skeleton"

const DataChart = dynamic(() => import("@/components/data-chart"), {
  loading: () => <Skeleton className="h-[400px] w-full" />,
})

const RichTextEditor = dynamic(() => import("@/components/rich-text-editor"), {
  loading: () => <Skeleton className="h-[300px] w-full" />,
  ssr: false, // Disable SSR for browser-only components
})

const CodeEditor = dynamic(() => import("@/components/code-editor"), {
  loading: () => <Skeleton className="h-[400px] w-full" />,
  ssr: false,
})

function Dashboard() {
  const [showChart, setShowChart] = useState(false)
  const [showEditor, setShowEditor] = useState(false)

  return (
    <div>
      {/* Components loaded only when rendered */}
      {showChart && <DataChart data={chartData} />}
      {showEditor && <RichTextEditor />}
    </div>
  )
}
```

**For React without Next.js:**

```tsx
import { lazy, Suspense } from "react"
import { Skeleton } from "@/components/ui/skeleton"

const DataChart = lazy(() => import("@/components/data-chart"))

function Dashboard() {
  return (
    <Suspense fallback={<Skeleton className="h-[400px] w-full" />}>
      <DataChart data={chartData} />
    </Suspense>
  )
}
```

**When to lazy load:**
- Components over 50KB
- Components not visible on initial render
- Components behind user interaction (modals, tabs)
- Heavy third-party integrations (charts, maps, editors)

Reference: [Next.js Dynamic Imports](https://nextjs.org/docs/pages/building-your-application/optimizing/lazy-loading)
