---
title: Use Dynamic Imports for Route-Level Splitting
impact: CRITICAL
impactDescription: reduces initial bundle by 30-70%
tags: bundle, dynamic-import, lazy-loading, routes
---

## Use Dynamic Imports for Route-Level Splitting

Load route components dynamically so users only download code for the page they visit. This dramatically reduces initial bundle size.

**Incorrect (eager loading all routes):**

```javascript
// router.js
import Home from './pages/Home'
import Dashboard from './pages/Dashboard'
import Settings from './pages/Settings'
import Analytics from './pages/Analytics'

const routes = [
  { path: '/', component: Home },
  { path: '/dashboard', component: Dashboard },
  { path: '/settings', component: Settings },
  { path: '/analytics', component: Analytics }
]
// All pages in initial bundle
```

**Correct (lazy loading routes):**

```javascript
// router.js (React)
import { lazy, Suspense } from 'react'

const Home = lazy(() => import('./pages/Home'))
const Dashboard = lazy(() => import('./pages/Dashboard'))
const Settings = lazy(() => import('./pages/Settings'))
const Analytics = lazy(() => import('./pages/Analytics'))

function App() {
  return (
    <Suspense fallback={<Loading />}>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/settings" element={<Settings />} />
        <Route path="/analytics" element={<Analytics />} />
      </Routes>
    </Suspense>
  )
}
// Each page loads only when visited
```

**Vue equivalent:**

```javascript
// router.js (Vue)
const routes = [
  { path: '/', component: () => import('./pages/Home.vue') },
  { path: '/dashboard', component: () => import('./pages/Dashboard.vue') }
]
```

Reference: [Building for Production](https://vite.dev/guide/build)
