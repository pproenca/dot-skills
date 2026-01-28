---
title: Defer Popup Rendering Until Needed
impact: MEDIUM
impactDescription: reduces popup open time by 100-300ms
tags: ui, popup, lazy-loading, performance
---

## Defer Popup Rendering Until Needed

Popups re-render every time they open. Defer heavy initialization until the popup is actually displayed to minimize perceived latency.

**Incorrect (heavy initialization on load):**

```typescript
// popup/main.tsx
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { initializeAnalytics, loadUserData, syncState } from '@/utils'

// Runs on every popup open
const queryClient = new QueryClient()
initializeAnalytics() // 50ms
const userData = await loadUserData() // 100ms network
await syncState() // 150ms

ReactDOM.createRoot(document.getElementById('root')!).render(
  <QueryClientProvider client={queryClient}>
    <App userData={userData} />
  </QueryClientProvider>
)
```

**Correct (deferred initialization):**

```typescript
// popup/main.tsx
import { lazy, Suspense } from 'react'

// Lazy load heavy components
const App = lazy(() => import('./App'))
const LoadingSpinner = () => <div className="spinner" />

ReactDOM.createRoot(document.getElementById('root')!).render(
  <Suspense fallback={<LoadingSpinner />}>
    <App />
  </Suspense>
)

// App.tsx - load data when component mounts
function App() {
  const [isReady, setIsReady] = useState(false)
  const [userData, setUserData] = useState<User | null>(null)

  useEffect(() => {
    // Initialize after first render (user sees UI skeleton)
    Promise.all([
      loadUserData(),
      import('@/utils/analytics').then(m => m.initializeAnalytics())
    ]).then(([data]) => {
      setUserData(data)
      setIsReady(true)
    })
  }, [])

  if (!isReady) return <PopupSkeleton />
  return <MainContent userData={userData} />
}
```

Reference: [React Lazy Loading](https://react.dev/reference/react/lazy)
