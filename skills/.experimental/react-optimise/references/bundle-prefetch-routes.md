---
title: Prefetch Likely Next Routes on Interaction
impact: CRITICAL
impactDescription: 200-1000ms faster perceived navigation
tags: bundle, prefetch, navigation, user-experience
---

## Prefetch Likely Next Routes on Interaction

Code-split routes introduce a network round-trip when the user navigates. Prefetching the chunk on hover or focus eliminates this delay by loading the code before the click fires. The browser's idle time between hover and click (200-400ms average) is enough to fetch most route chunks over a fast connection.

**Incorrect (chunk loads after click, user sees loading state):**

```tsx
import { lazy, Suspense } from "react"
import { Link, Routes, Route } from "react-router-dom"

const ProductCatalog = lazy(() => import("./pages/ProductCatalog"))
const OrderHistory = lazy(() => import("./pages/OrderHistory"))

function Navigation() {
  return (
    <nav>
      <Link to="/products">Products</Link>
      <Link to="/orders">Orders</Link>
    </nav>
  )
}

function App() {
  return (
    <Suspense fallback={<PageSkeleton />}>
      <Navigation />
      <Routes>
        <Route path="/products" element={<ProductCatalog />} />
        <Route path="/orders" element={<OrderHistory />} />
      </Routes>
    </Suspense>
  )
}
```

**Correct (prefetch on hover loads chunk before navigation):**

```tsx
import { lazy, Suspense } from "react"
import { Link, Routes, Route } from "react-router-dom"

const productCatalogImport = () => import("./pages/ProductCatalog")
const orderHistoryImport = () => import("./pages/OrderHistory")

const ProductCatalog = lazy(productCatalogImport)
const OrderHistory = lazy(orderHistoryImport)

function PrefetchLink({
  to,
  prefetch,
  children,
}: {
  to: string
  prefetch: () => Promise<unknown>
  children: React.ReactNode
}) {
  const handlePrefetch = () => { prefetch() } // fires on hover, loads chunk

  return (
    <Link to={to} onMouseEnter={handlePrefetch} onFocus={handlePrefetch}>
      {children}
    </Link>
  )
}

function Navigation() {
  return (
    <nav>
      <PrefetchLink to="/products" prefetch={productCatalogImport}>
        Products
      </PrefetchLink>
      <PrefetchLink to="/orders" prefetch={orderHistoryImport}>
        Orders
      </PrefetchLink>
    </nav>
  )
}

function App() {
  return (
    <Suspense fallback={<PageSkeleton />}>
      <Navigation />
      <Routes>
        <Route path="/products" element={<ProductCatalog />} />
        <Route path="/orders" element={<OrderHistory />} />
      </Routes>
    </Suspense>
  )
}
```

Reference: [web.dev — Prefetching Resources](https://web.dev/articles/link-prefetch)
