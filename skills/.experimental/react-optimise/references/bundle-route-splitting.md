---
title: Split Code at Route Boundaries with React.lazy
impact: CRITICAL
impactDescription: 40-70% reduction in initial bundle size
tags: bundle, code-splitting, lazy-loading, routes
---

## Split Code at Route Boundaries with React.lazy

Every route a user never visits is wasted bytes in the initial bundle. Wrapping route components with `React.lazy` creates a separate chunk per route, so the browser downloads only the code for the current page. Combined with a `Suspense` boundary, the user sees a loading state instead of a blank screen while the chunk loads.

**Incorrect (all routes in a single bundle):**

```tsx
import { BrowserRouter, Routes, Route } from "react-router-dom"
import Dashboard from "./pages/Dashboard"
import OrderHistory from "./pages/OrderHistory"
import ProductCatalog from "./pages/ProductCatalog"
import UserSettings from "./pages/UserSettings"
import AdminPanel from "./pages/AdminPanel" // 120KB — most users never see this

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Dashboard />} />
        <Route path="/orders" element={<OrderHistory />} />
        <Route path="/products" element={<ProductCatalog />} />
        <Route path="/settings" element={<UserSettings />} />
        <Route path="/admin" element={<AdminPanel />} />
      </Routes>
    </BrowserRouter>
  )
}
```

**Correct (each route loads its own chunk):**

```tsx
import { BrowserRouter, Routes, Route } from "react-router-dom"
import { lazy, Suspense } from "react"
import { PageSkeleton } from "./components/PageSkeleton"

const Dashboard = lazy(() => import("./pages/Dashboard"))
const OrderHistory = lazy(() => import("./pages/OrderHistory"))
const ProductCatalog = lazy(() => import("./pages/ProductCatalog"))
const UserSettings = lazy(() => import("./pages/UserSettings"))
const AdminPanel = lazy(() => import("./pages/AdminPanel"))

function App() {
  return (
    <BrowserRouter>
      <Suspense fallback={<PageSkeleton />}>
        <Routes>
          <Route path="/" element={<Dashboard />} />
          <Route path="/orders" element={<OrderHistory />} />
          <Route path="/products" element={<ProductCatalog />} />
          <Route path="/settings" element={<UserSettings />} />
          <Route path="/admin" element={<AdminPanel />} />
        </Routes>
      </Suspense>
    </BrowserRouter>
  )
}
```

Reference: [React — Lazy-loading Components with Suspense](https://react.dev/reference/react/lazy)
