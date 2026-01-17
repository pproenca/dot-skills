# Next.js 16 App Router

**Version 0.1.0**  
Next.js Community  
January 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive performance optimization guide for Next.js 16 App Router applications, designed for AI agents and LLMs. Contains 40+ rules across 8 categories, prioritized by impact from critical (build optimization, caching strategy) to incremental (client components). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated refactoring and code generation.

---

## Table of Contents

1. [Build & Bundle Optimization](#1-build-bundle-optimization) — **CRITICAL**
   - 1.1 [Avoid Barrel File Imports in App Router](#11-avoid-barrel-file-imports-in-app-router)
   - 1.2 [Configure optimizePackageImports for Icon Libraries](#12-configure-optimizepackageimports-for-icon-libraries)
   - 1.3 [Configure Server External Packages for Node Dependencies](#13-configure-server-external-packages-for-node-dependencies)
   - 1.4 [Enable Turbopack File System Caching](#14-enable-turbopack-file-system-caching)
   - 1.5 [Use Dynamic Imports for Heavy Components](#15-use-dynamic-imports-for-heavy-components)
2. [Caching Strategy](#2-caching-strategy) — **CRITICAL**
   - 2.1 [Configure Fetch Cache Options Correctly](#21-configure-fetch-cache-options-correctly)
   - 2.2 [Configure Route Segment Caching with Exports](#22-configure-route-segment-caching-with-exports)
   - 2.3 [Use React cache() for Request Deduplication](#23-use-react-cache-for-request-deduplication)
   - 2.4 [Use revalidatePath for Route-Level Cache Invalidation](#24-use-revalidatepath-for-route-level-cache-invalidation)
   - 2.5 [Use revalidateTag with cacheLife Profiles](#25-use-revalidatetag-with-cachelife-profiles)
   - 2.6 [Use the 'use cache' Directive for Explicit Caching](#26-use-the-use-cache-directive-for-explicit-caching)
3. [Server Components & Data Fetching](#3-server-components-data-fetching) — **HIGH**
   - 3.1 [Avoid Client-Side Data Fetching for Initial Data](#31-avoid-client-side-data-fetching-for-initial-data)
   - 3.2 [Colocate Data Fetching with Components](#32-colocate-data-fetching-with-components)
   - 3.3 [Fetch Data in Parallel in Server Components](#33-fetch-data-in-parallel-in-server-components)
   - 3.4 [Handle Server Component Errors Gracefully](#34-handle-server-component-errors-gracefully)
   - 3.5 [Stream Server Components for Progressive Loading](#35-stream-server-components-for-progressive-loading)
   - 3.6 [Use Preload Pattern for Critical Data](#36-use-preload-pattern-for-critical-data)
4. [Routing & Navigation](#4-routing-navigation) — **HIGH**
   - 4.1 [Configure Link Prefetching Appropriately](#41-configure-link-prefetching-appropriately)
   - 4.2 [Use Intercepting Routes for Modal Patterns](#42-use-intercepting-routes-for-modal-patterns)
   - 4.3 [Use notFound() for Missing Resources](#43-use-notfound-for-missing-resources)
   - 4.4 [Use Parallel Routes for Independent Content](#44-use-parallel-routes-for-independent-content)
   - 4.5 [Use proxy.ts for Network Boundary Logic](#45-use-proxyts-for-network-boundary-logic)
5. [Server Actions & Mutations](#5-server-actions-mutations) — **MEDIUM-HIGH**
   - 5.1 [Handle Server Action Errors Gracefully](#51-handle-server-action-errors-gracefully)
   - 5.2 [Revalidate Cache After Mutations](#52-revalidate-cache-after-mutations)
   - 5.3 [Show Pending States with useFormStatus](#53-show-pending-states-with-useformstatus)
   - 5.4 [Use Optimistic Updates for Instant Feedback](#54-use-optimistic-updates-for-instant-feedback)
   - 5.5 [Use Server Actions for Form Submissions](#55-use-server-actions-for-form-submissions)
6. [Streaming & Loading States](#6-streaming-loading-states) — **MEDIUM**
   - 6.1 [Match Skeleton Dimensions to Actual Content](#61-match-skeleton-dimensions-to-actual-content)
   - 6.2 [Nest Suspense for Progressive Disclosure](#62-nest-suspense-for-progressive-disclosure)
   - 6.3 [Place Suspense Boundaries Strategically](#63-place-suspense-boundaries-strategically)
   - 6.4 [Use error.tsx for Route-Level Error Boundaries](#64-use-errortsx-for-route-level-error-boundaries)
   - 6.5 [Use loading.tsx for Route-Level Loading States](#65-use-loadingtsx-for-route-level-loading-states)
7. [Metadata & SEO](#7-metadata-seo) — **MEDIUM**
   - 7.1 [Configure Robots for Crawl Control](#71-configure-robots-for-crawl-control)
   - 7.2 [Generate Dynamic OpenGraph Images](#72-generate-dynamic-opengraph-images)
   - 7.3 [Generate Sitemaps Dynamically](#73-generate-sitemaps-dynamically)
   - 7.4 [Use generateMetadata for Dynamic Metadata](#74-use-generatemetadata-for-dynamic-metadata)
8. [Client Components](#8-client-components) — **LOW-MEDIUM**
   - 8.1 [Avoid Hydration Mismatches](#81-avoid-hydration-mismatches)
   - 8.2 [Load Third-Party Scripts Efficiently](#82-load-third-party-scripts-efficiently)
   - 8.3 [Minimize 'use client' Boundary Scope](#83-minimize-use-client-boundary-scope)
   - 8.4 [Pass Server Components as Children to Client Components](#84-pass-server-components-as-children-to-client-components)

---

## 1. Build & Bundle Optimization

**Impact: CRITICAL**

Turbopack configuration, optimizePackageImports, and dynamic imports reduce cold start times and bundle size by up to 70%.

### 1.1 Avoid Barrel File Imports in App Router

**Impact: CRITICAL (2-10× faster dev startup)**

Barrel files (index.ts with re-exports) prevent tree-shaking and slow down development. Import directly from source files instead.

**Incorrect (imports through barrel file):**

```typescript
// lib/utils/index.ts (barrel file)
export * from './formatDate'
export * from './formatCurrency'
export * from './validateEmail'
// ... 50 more exports

// app/dashboard/page.tsx
import { formatDate } from '@/lib/utils'
// Loads all 50+ modules even though only formatDate is used
```

**Correct (direct import):**

```typescript
// app/dashboard/page.tsx
import { formatDate } from '@/lib/utils/formatDate'
// Loads only the formatDate module
```

**Alternative (path aliases):**

```typescript
// tsconfig.json
{
  "compilerOptions": {
    "paths": {
      "@/utils/*": ["./lib/utils/*"]
    }
  }
}

// app/dashboard/page.tsx
import { formatDate } from '@/utils/formatDate'
```

**Note:** If you must use barrel files, configure `optimizePackageImports` or use explicit named exports instead of `export *`.

### 1.2 Configure optimizePackageImports for Icon Libraries

**Impact: CRITICAL (200-800ms faster imports, 50-80% smaller bundles)**

Icon libraries like `lucide-react` export hundreds of modules. Without optimization, importing one icon loads the entire library. Configure `optimizePackageImports` to automatically tree-shake unused exports.

**Incorrect (loads entire library):**

```typescript
// next.config.ts
const nextConfig = {
  // No optimization configured
}

// components/Header.tsx
import { Menu, X, Search } from 'lucide-react'
// Loads 1,583 modules, adds ~2.8s to dev startup
```

**Correct (loads only used icons):**

```typescript
// next.config.ts
const nextConfig = {
  experimental: {
    optimizePackageImports: ['lucide-react', '@heroicons/react', '@mui/icons-material']
  }
}

// components/Header.tsx
import { Menu, X, Search } from 'lucide-react'
// Loads only 3 modules (~2KB vs ~1MB)
```

**Note:** Next.js 16 automatically optimizes common libraries. Add custom libraries that export many modules.

Reference: [How we optimized package imports in Next.js](https://vercel.com/blog/how-we-optimized-package-imports-in-next-js)

### 1.3 Configure Server External Packages for Node Dependencies

**Impact: HIGH (prevents bundling issues, faster builds)**

Some Node.js packages with native bindings or complex dependencies should not be bundled. Use `serverExternalPackages` to exclude them from the server bundle.

**Incorrect (bundling native modules):**

```typescript
// next.config.ts
const nextConfig = {
  // No external packages configured
}

// lib/pdf.ts
import puppeteer from 'puppeteer'
// Build fails or produces oversized bundles
```

**Correct (excluding native modules):**

```typescript
// next.config.ts
const nextConfig = {
  serverExternalPackages: [
    'puppeteer',
    'sharp',
    'canvas',
    '@prisma/client',
    'bcrypt'
  ]
}

// lib/pdf.ts
import puppeteer from 'puppeteer'
// Loaded at runtime from node_modules
```

**Common packages to externalize:**
- Database drivers: `@prisma/client`, `pg`, `mysql2`
- Image processing: `sharp`, `canvas`
- Native bindings: `bcrypt`, `argon2`
- Browser automation: `puppeteer`, `playwright`

### 1.4 Enable Turbopack File System Caching

**Impact: CRITICAL (5-10× faster cold starts on large apps)**

Next.js 16 uses Turbopack by default with file system caching. Ensure your configuration doesn't disable these optimizations.

**Incorrect (disabling Turbopack features):**

```typescript
// next.config.ts
const nextConfig = {
  experimental: {
    turbo: {
      // Disabling caching slows down restarts
      persistentCaching: false
    }
  }
}
```

**Correct (leveraging Turbopack defaults):**

```typescript
// next.config.ts
const nextConfig = {
  // Turbopack is default in Next.js 16
  // File system caching is enabled by default
  experimental: {
    turbo: {
      // Add custom loaders if needed
      rules: {
        '*.svg': {
          loaders: ['@svgr/webpack'],
          as: '*.js'
        }
      }
    }
  }
}
```

**Development command:**

```bash
# Turbopack is now the default bundler
next dev

# Explicitly enable for clarity
next dev --turbopack
```

**Note:** Turbopack caches to `.next/cache/turbopack`. Don't add this to `.gitignore` locally for persistent caching across restarts.

Reference: [Next.js 16 Release Notes](https://nextjs.org/blog/next-16)

### 1.5 Use Dynamic Imports for Heavy Components

**Impact: CRITICAL (30-70% smaller initial bundle)**

Large components like charts, editors, or maps should load on demand. Use `next/dynamic` to split them into separate bundles that load only when rendered.

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

Reference: [Dynamic Imports](https://nextjs.org/docs/app/building-your-application/optimizing/lazy-loading)

---

## 2. Caching Strategy

**Impact: CRITICAL**

The 'use cache' directive, revalidateTag, and cacheLife profiles control data freshness and reduce server load by eliminating redundant fetches.

### 2.1 Configure Fetch Cache Options Correctly

**Impact: HIGH (controls data freshness per request)**

The `fetch` API in Server Components supports cache configuration. Understand the three modes: force-cache (default), no-store, and time-based revalidation.

**Incorrect (mixing cache strategies without intent):**

```typescript
export default async function Page() {
  // Static data that rarely changes - correct
  const config = await fetch('https://api.example.com/config')

  // User-specific data that should be fresh - WRONG
  const user = await fetch(`https://api.example.com/users/${userId}`)
  // Using default caching for dynamic data!
}
```

**Correct (explicit cache strategies):**

```typescript
export default async function Page() {
  // Static data - cache indefinitely
  const config = await fetch('https://api.example.com/config', {
    cache: 'force-cache'
  })

  // Dynamic data - never cache
  const user = await fetch(`https://api.example.com/users/${userId}`, {
    cache: 'no-store'
  })

  // Semi-dynamic - revalidate every 5 minutes
  const products = await fetch('https://api.example.com/products', {
    next: { revalidate: 300 }
  })

  // Tagged for on-demand revalidation
  const posts = await fetch('https://api.example.com/posts', {
    next: { tags: ['posts'] }
  })
}
```

**Cache strategy decision tree:**
- User-specific or real-time → `no-store`
- Changes hourly/daily → `next: { revalidate: N }`
- Static/rarely changes → `force-cache`
- Needs on-demand invalidation → `next: { tags: [...] }`

### 2.2 Configure Route Segment Caching with Exports

**Impact: MEDIUM-HIGH (controls caching at route level)**

Use route segment config exports to control caching behavior at the route level. These settings apply to the entire route segment.

**Incorrect (dynamic when static would work):**

```typescript
// app/about/page.tsx
export default async function AboutPage() {
  const team = await fetch('https://api.example.com/team')
  return <TeamSection team={team} />
}
// Defaults to dynamic rendering on every request
```

**Correct (explicit static generation):**

```typescript
// app/about/page.tsx
export const dynamic = 'force-static'
export const revalidate = 86400  // Revalidate daily

export default async function AboutPage() {
  const team = await fetch('https://api.example.com/team')
  return <TeamSection team={team} />
}
// Generated at build time, revalidated daily
```

**Segment config options:**

```typescript
// Force dynamic rendering (never cache)
export const dynamic = 'force-dynamic'

// Force static generation (build-time only)
export const dynamic = 'force-static'

// Revalidate time in seconds
export const revalidate = 3600  // 1 hour

// Generate static params for dynamic routes
export async function generateStaticParams() {
  const products = await getProducts()
  return products.map((p) => ({ slug: p.slug }))
}
```

**Decision matrix:**
- Static content → `force-static`
- User-specific/auth → `force-dynamic`
- Semi-static → `revalidate: N`

### 2.3 Use React cache() for Request Deduplication

**Impact: HIGH (eliminates duplicate fetches per request)**

Wrap data fetching functions with `cache()` to deduplicate identical calls within a single render pass. Multiple components can call the same function without triggering multiple fetches.

**Incorrect (duplicate fetches):**

```typescript
// lib/data.ts
export async function getUser(id: string) {
  const res = await fetch(`/api/users/${id}`)
  return res.json()
}

// components/Header.tsx
export async function Header({ userId }: { userId: string }) {
  const user = await getUser(userId)  // Fetch #1
  return <h1>Welcome, {user.name}</h1>
}

// components/Sidebar.tsx
export async function Sidebar({ userId }: { userId: string }) {
  const user = await getUser(userId)  // Fetch #2 - duplicate!
  return <nav>{user.role === 'admin' && <AdminLinks />}</nav>
}
```

**Correct (deduplicated with cache):**

```typescript
// lib/data.ts
import { cache } from 'react'

export const getUser = cache(async (id: string) => {
  const res = await fetch(`/api/users/${id}`)
  return res.json()
})

// components/Header.tsx
export async function Header({ userId }: { userId: string }) {
  const user = await getUser(userId)  // Fetch
  return <h1>Welcome, {user.name}</h1>
}

// components/Sidebar.tsx
export async function Sidebar({ userId }: { userId: string }) {
  const user = await getUser(userId)  // Cached result reused
  return <nav>{user.role === 'admin' && <AdminLinks />}</nav>
}
```

**Note:** React `cache()` deduplicates within a single request. For cross-request caching, use `unstable_cache` or the `'use cache'` directive.

### 2.4 Use revalidatePath for Route-Level Cache Invalidation

**Impact: HIGH (invalidates all cached data for a route)**

Use `revalidatePath` to invalidate all cached data associated with a specific route. Prefer `revalidateTag` for granular control.

**Incorrect (forgetting to revalidate after mutation):**

```typescript
'use server'

export async function createPost(formData: FormData) {
  const title = formData.get('title') as string
  const content = formData.get('content') as string

  await db.posts.create({ data: { title, content } })

  // User doesn't see new post until cache expires!
}
```

**Correct (revalidating after mutation):**

```typescript
'use server'

import { revalidatePath } from 'next/cache'
import { redirect } from 'next/navigation'

export async function createPost(formData: FormData) {
  const title = formData.get('title') as string
  const content = formData.get('content') as string

  const post = await db.posts.create({ data: { title, content } })

  revalidatePath('/posts')  // Invalidate posts list
  redirect(`/posts/${post.id}`)  // Navigate to new post
}
```

**Path patterns:**

```typescript
// Specific route
revalidatePath('/posts')

// Dynamic route
revalidatePath('/posts/[slug]', 'page')

// Layout and all child routes
revalidatePath('/dashboard', 'layout')

// Entire app (use sparingly)
revalidatePath('/', 'layout')
```

**Note:** `redirect` must be called after `revalidatePath` as it throws internally.

### 2.5 Use revalidateTag with cacheLife Profiles

**Impact: CRITICAL (stale-while-revalidate behavior, instant updates)**

Next.js 16 requires a `cacheLife` profile as the second argument to `revalidateTag`, enabling stale-while-revalidate behavior where users see cached content immediately while revalidation happens in the background.

**Incorrect (old revalidateTag API):**

```typescript
// app/actions.ts
'use server'

import { revalidateTag } from 'next/cache'

export async function updateProduct(id: string, data: FormData) {
  await db.products.update({ where: { id }, data })

  // Old API - no longer works in Next.js 16
  revalidateTag('products')
}
```

**Correct (revalidateTag with cacheLife):**

```typescript
// app/actions.ts
'use server'

import { revalidateTag } from 'next/cache'

export async function updateProduct(id: string, data: FormData) {
  await db.products.update({ where: { id }, data })

  // New API with cacheLife profile
  revalidateTag('products', 'hours')
}

// Cache profiles: 'max', 'hours', 'days', 'weeks'
// 'max' = immediate revalidation
// 'hours' = stale for up to 1 hour during revalidation
```

**Tagging cached data:**

```typescript
// lib/data.ts
'use cache'

import { cacheTag } from 'next/cache'

export async function getProducts() {
  cacheTag('products')
  const res = await fetch('https://api.store.com/products')
  return res.json()
}
```

Reference: [Next.js 16 Caching](https://nextjs.org/docs/app/building-your-application/caching)

### 2.6 Use the 'use cache' Directive for Explicit Caching

**Impact: CRITICAL (eliminates implicit caching confusion, explicit control)**

Next.js 16 introduces Cache Components with the `'use cache'` directive. Unlike implicit caching in previous versions, caching is now opt-in and explicit.

**Incorrect (relying on implicit caching):**

```typescript
// app/products/page.tsx
export default async function ProductsPage() {
  // In Next.js 15, this was cached by default
  // In Next.js 16, this fetches fresh data every request
  const products = await fetch('https://api.store.com/products')

  return <ProductList products={products} />
}
```

**Correct (explicit caching with 'use cache'):**

```typescript
// app/products/page.tsx
'use cache'

export default async function ProductsPage() {
  const products = await fetch('https://api.store.com/products')

  return <ProductList products={products} />
}
// Entire page is cached until manually invalidated
```

**Alternative (cache specific functions):**

```typescript
// lib/data.ts
import { unstable_cache } from 'next/cache'

export const getProducts = unstable_cache(
  async () => {
    const res = await fetch('https://api.store.com/products')
    return res.json()
  },
  ['products'],
  { revalidate: 3600 }  // Cache for 1 hour
)
```

Reference: [Next.js 16 Cache Components](https://nextjs.org/blog/next-16)

---

## 3. Server Components & Data Fetching

**Impact: HIGH**

Parallel fetching, React cache(), and streaming patterns eliminate server-side waterfalls and reduce Time to First Byte.

### 3.1 Avoid Client-Side Data Fetching for Initial Data

**Impact: MEDIUM-HIGH (eliminates client waterfalls, better SEO)**

Fetch initial page data in Server Components, not with `useEffect` or client-side libraries. Client-side fetching creates waterfalls and hurts SEO.

**Incorrect (client-side fetch with useEffect):**

```typescript
'use client'

import { useState, useEffect } from 'react'

export default function ProductsPage() {
  const [products, setProducts] = useState([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetch('/api/products')
      .then(res => res.json())
      .then(data => {
        setProducts(data)
        setLoading(false)
      })
  }, [])

  if (loading) return <Skeleton />
  return <ProductList products={products} />
}
// Waterfall: HTML → JS → Hydrate → Fetch → Render
// Empty for SEO crawlers
```

**Correct (Server Component fetch):**

```typescript
// app/products/page.tsx
export default async function ProductsPage() {
  const products = await fetch('https://api.store.com/products')
    .then(res => res.json())

  return <ProductList products={products} />
}
// Single request, data included in HTML, SEO-friendly
```

**When to use client-side fetching:**
- User-initiated actions (load more, search)
- Real-time updates (polling, WebSocket)
- After-interaction data (comments on expand)

**Recommended client-side library:**

```typescript
'use client'

import useSWR from 'swr'

export function SearchResults({ query }: { query: string }) {
  const { data, isLoading } = useSWR(
    query ? `/api/search?q=${query}` : null,
    fetcher
  )
  // Client fetch appropriate for user-initiated search
}
```

### 3.2 Colocate Data Fetching with Components

**Impact: HIGH (eliminates prop drilling, enables streaming)**

Fetch data where it's needed, not in parent components. This enables independent streaming and eliminates prop drilling.

**Incorrect (fetching in parent, prop drilling):**

```typescript
// app/dashboard/page.tsx
export default async function DashboardPage() {
  const user = await fetchUser()
  const orders = await fetchOrders(user.id)
  const notifications = await fetchNotifications(user.id)

  return (
    <Dashboard>
      <Header user={user} />
      <OrderList orders={orders} user={user} />
      <NotificationPanel notifications={notifications} userId={user.id} />
    </Dashboard>
  )
}
// All data fetched sequentially, no streaming possible
```

**Correct (colocated data fetching):**

```typescript
// app/dashboard/page.tsx
import { Suspense } from 'react'

export default function DashboardPage() {
  return (
    <Dashboard>
      <Suspense fallback={<HeaderSkeleton />}>
        <Header />
      </Suspense>
      <Suspense fallback={<OrdersSkeleton />}>
        <OrderList />
      </Suspense>
      <Suspense fallback={<NotificationsSkeleton />}>
        <NotificationPanel />
      </Suspense>
    </Dashboard>
  )
}

// components/OrderList.tsx
async function OrderList() {
  const user = await getUser()  // Deduplicated with cache()
  const orders = await fetchOrders(user.id)
  return <ul>{orders.map(o => <OrderItem key={o.id} order={o} />)}</ul>
}
// Each component fetches what it needs, streams independently
```

**Note:** Use `cache()` to deduplicate shared data like user across components.

### 3.3 Fetch Data in Parallel in Server Components

**Impact: HIGH (eliminates server-side waterfalls, 2-5× faster)**

Initiate all independent data fetches simultaneously using `Promise.all()`. Sequential awaits create server-side waterfalls that multiply latency.

**Incorrect (sequential fetches, 3 round trips):**

```typescript
// app/dashboard/page.tsx
export default async function DashboardPage() {
  const user = await fetchUser()           // 200ms
  const orders = await fetchOrders()       // 150ms
  const notifications = await fetchNotifications()  // 100ms
  // Total: 450ms (sequential)

  return (
    <Dashboard
      user={user}
      orders={orders}
      notifications={notifications}
    />
  )
}
```

**Correct (parallel fetches, 1 round trip):**

```typescript
// app/dashboard/page.tsx
export default async function DashboardPage() {
  const [user, orders, notifications] = await Promise.all([
    fetchUser(),           // 200ms
    fetchOrders(),         // 150ms (parallel)
    fetchNotifications()   // 100ms (parallel)
  ])
  // Total: 200ms (longest request)

  return (
    <Dashboard
      user={user}
      orders={orders}
      notifications={notifications}
    />
  )
}
```

**With dependent data:**

```typescript
export default async function DashboardPage() {
  // First fetch user (needed for subsequent queries)
  const user = await fetchUser()

  // Then fetch user-dependent data in parallel
  const [orders, preferences] = await Promise.all([
    fetchOrders(user.id),
    fetchPreferences(user.id)
  ])

  return <Dashboard user={user} orders={orders} preferences={preferences} />
}
```

### 3.4 Handle Server Component Errors Gracefully

**Impact: MEDIUM (prevents full page crashes, better UX)**

Use error boundaries and try/catch to handle failures gracefully. A single failed fetch shouldn't crash the entire page.

**Incorrect (unhandled error crashes page):**

```typescript
// app/dashboard/page.tsx
export default async function DashboardPage() {
  const analytics = await fetchAnalytics()  // If this fails, entire page crashes

  return (
    <div>
      <Header />
      <Analytics data={analytics} />
    </div>
  )
}
```

**Correct (graceful error handling):**

```typescript
// app/dashboard/page.tsx
import { Suspense } from 'react'
import { ErrorBoundary } from 'react-error-boundary'

export default function DashboardPage() {
  return (
    <div>
      <Header />
      <ErrorBoundary fallback={<AnalyticsError />}>
        <Suspense fallback={<AnalyticsSkeleton />}>
          <Analytics />
        </Suspense>
      </ErrorBoundary>
    </div>
  )
}

// Or use error.tsx for route-level errors
// app/dashboard/error.tsx
'use client'

export default function Error({
  error,
  reset
}: {
  error: Error
  reset: () => void
}) {
  return (
    <div>
      <h2>Something went wrong</h2>
      <button onClick={() => reset()}>Try again</button>
    </div>
  )
}
```

**Try/catch for specific components:**

```typescript
async function Analytics() {
  try {
    const data = await fetchAnalytics()
    return <AnalyticsChart data={data} />
  } catch (error) {
    return <AnalyticsUnavailable />
  }
}
```

### 3.5 Stream Server Components for Progressive Loading

**Impact: HIGH (faster Time to First Byte, progressive rendering)**

Split data-intensive Server Components and wrap them in Suspense to stream HTML progressively. Fast components render immediately while slow ones load.

**Incorrect (all-or-nothing rendering):**

```typescript
// app/page.tsx
export default async function Page() {
  const user = await fetchUser()           // 100ms
  const posts = await fetchPosts()         // 500ms
  const analytics = await fetchAnalytics() // 2000ms

  return (
    <div>
      <Header user={user} />
      <PostList posts={posts} />
      <Analytics data={analytics} />
    </div>
  )
}
// Nothing renders until analytics completes (2100ms)
```

**Correct (progressive streaming):**

```typescript
// app/page.tsx
import { Suspense } from 'react'

export default function Page() {
  return (
    <div>
      <Suspense fallback={<HeaderSkeleton />}>
        <Header />
      </Suspense>
      <Suspense fallback={<PostsSkeleton />}>
        <PostList />
      </Suspense>
      <Suspense fallback={<AnalyticsSkeleton />}>
        <Analytics />
      </Suspense>
    </div>
  )
}

// Each component fetches its own data
async function Header() {
  const user = await fetchUser()
  return <header>{user.name}</header>
}

async function Analytics() {
  const data = await fetchAnalytics()
  return <AnalyticsChart data={data} />
}
// Header renders in 100ms, Posts in 500ms, Analytics in 2000ms
```

**Benefits:**
- First paint happens immediately
- Each section appears as soon as its data is ready
- Slow components don't block fast ones

### 3.6 Use Preload Pattern for Critical Data

**Impact: MEDIUM-HIGH (starts fetches earlier in render tree)**

Export a `preload` function that initiates data fetching at the top of the component tree. This starts fetches earlier, reducing time to first byte.

**Incorrect (data fetch starts late in component tree):**

```typescript
// app/product/[id]/page.tsx
export default async function ProductPage({ params }: { params: { id: string } }) {
  return (
    <div>
      <Header />
      <Breadcrumbs />
      <ProductDetails id={params.id} />  {/* Fetch starts here */}
    </div>
  )
}

async function ProductDetails({ id }: { id: string }) {
  const product = await getProduct(id)  // Fetch delayed by parent render
  return <div>{product.name}</div>
}
```

**Correct (preload starts fetch immediately):**

```typescript
// lib/data.ts
import { cache } from 'react'

export const getProduct = cache(async (id: string) => {
  const res = await fetch(`/api/products/${id}`)
  return res.json()
})

export const preloadProduct = (id: string) => {
  void getProduct(id)  // Start fetch, don't await
}

// app/product/[id]/page.tsx
import { preloadProduct, getProduct } from '@/lib/data'

export default async function ProductPage({ params }: { params: { id: string } }) {
  preloadProduct(params.id)  // Start fetch immediately

  return (
    <div>
      <Header />
      <Breadcrumbs />
      <ProductDetails id={params.id} />
    </div>
  )
}

async function ProductDetails({ id }: { id: string }) {
  const product = await getProduct(id)  // Uses cached promise
  return <div>{product.name}</div>
}
```

**Note:** The `cache()` wrapper ensures the preloaded data is reused by child components.

---

## 4. Routing & Navigation

**Impact: HIGH**

Parallel routes, intercepting routes, prefetching, and proxy.ts optimize navigation performance and user experience.

### 4.1 Configure Link Prefetching Appropriately

**Impact: MEDIUM-HIGH (instant navigation for likely destinations)**

Next.js automatically prefetches linked routes. Control this behavior based on route importance and user likelihood to navigate.

**Incorrect (no prefetch consideration):**

```typescript
// Prefetches all links, including rarely used ones
export default function Navigation() {
  return (
    <nav>
      <Link href="/">Home</Link>
      <Link href="/products">Products</Link>
      <Link href="/admin/settings">Settings</Link>  {/* Rarely accessed */}
      <Link href="/terms">Terms</Link>  {/* Rarely accessed */}
    </nav>
  )
}
// Wastes bandwidth prefetching unlikely routes
```

**Correct (strategic prefetching):**

```typescript
export default function Navigation() {
  return (
    <nav>
      {/* High-traffic routes - prefetch (default) */}
      <Link href="/">Home</Link>
      <Link href="/products">Products</Link>

      {/* Low-traffic routes - disable prefetch */}
      <Link href="/admin/settings" prefetch={false}>Settings</Link>
      <Link href="/terms" prefetch={false}>Terms</Link>
    </nav>
  )
}
```

**Prefetch on hover for conditional routes:**

```typescript
'use client'

import { useRouter } from 'next/navigation'

export function ProductCard({ product }) {
  const router = useRouter()

  return (
    <div
      onMouseEnter={() => router.prefetch(`/product/${product.id}`)}
      onClick={() => router.push(`/product/${product.id}`)}
    >
      {product.name}
    </div>
  )
}
// Prefetches only when user shows intent
```

**Note:** In production, prefetching only loads the shared layout and static portions of the route.

### 4.2 Use Intercepting Routes for Modal Patterns

**Impact: HIGH (enables shareable modal URLs, better UX)**

Intercepting routes display content in a modal when navigating client-side, while showing the full page on direct access or refresh. Perfect for image galleries, login modals, and detail views.

**Incorrect (client-state modal without URL):**

```typescript
'use client'

export default function PhotoGallery({ photos }) {
  const [selectedPhoto, setSelectedPhoto] = useState(null)

  return (
    <div>
      {photos.map(photo => (
        <Image
          key={photo.id}
          onClick={() => setSelectedPhoto(photo)}
        />
      ))}
      {selectedPhoto && (
        <Modal onClose={() => setSelectedPhoto(null)}>
          <PhotoDetail photo={selectedPhoto} />
        </Modal>
      )}
    </div>
  )
}
// Modal not shareable, lost on refresh
```

**Correct (intercepting route):**

```text
app/
├── @modal/
│   ├── (.)photo/[id]/
│   │   └── page.tsx    # Shows in modal on client nav
│   └── default.tsx
├── photo/[id]/
│   └── page.tsx        # Shows full page on direct access
└── page.tsx            # Gallery
```

```typescript
// app/@modal/(.)photo/[id]/page.tsx
import { Modal } from '@/components/Modal'

export default async function PhotoModal({ params }: { params: { id: string } }) {
  const photo = await getPhoto(params.id)
  return (
    <Modal>
      <PhotoDetail photo={photo} />
    </Modal>
  )
}

// app/photo/[id]/page.tsx
export default async function PhotoPage({ params }: { params: { id: string } }) {
  const photo = await getPhoto(params.id)
  return <PhotoDetail photo={photo} />  // Full page
}
```

**Interception conventions:**
- `(.)` - Same level
- `(..)` - One level up
- `(..)(..)` - Two levels up
- `(...)` - From root

### 4.3 Use notFound() for Missing Resources

**Impact: MEDIUM (proper 404 handling, better SEO)**

Call `notFound()` when a dynamic resource doesn't exist. This renders the closest `not-found.tsx` and returns a proper 404 status code.

**Incorrect (rendering empty state for missing data):**

```typescript
// app/product/[id]/page.tsx
export default async function ProductPage({ params }: { params: { id: string } }) {
  const product = await getProduct(params.id)

  if (!product) {
    return <div>Product not found</div>  // Returns 200, bad for SEO
  }

  return <ProductDetail product={product} />
}
```

**Correct (using notFound()):**

```typescript
// app/product/[id]/page.tsx
import { notFound } from 'next/navigation'

export default async function ProductPage({ params }: { params: { id: string } }) {
  const product = await getProduct(params.id)

  if (!product) {
    notFound()  // Returns 404, renders not-found.tsx
  }

  return <ProductDetail product={product} />
}

// app/product/[id]/not-found.tsx
export default function ProductNotFound() {
  return (
    <div>
      <h2>Product Not Found</h2>
      <p>The product you're looking for doesn't exist.</p>
      <Link href="/products">Browse all products</Link>
    </div>
  )
}
```

**Benefits:**
- Correct 404 HTTP status for SEO
- Crawlers understand the page doesn't exist
- Custom UI for missing resources
- Can be nested per route segment

### 4.4 Use Parallel Routes for Independent Content

**Impact: HIGH (independent loading, streaming, error handling)**

Parallel routes (slots) render multiple pages simultaneously in the same layout. Each slot can have independent loading, error, and streaming states.

**Incorrect (sequential rendering in single page):**

```typescript
// app/dashboard/page.tsx
export default async function DashboardPage() {
  const analytics = await fetchAnalytics()  // Slow
  const notifications = await fetchNotifications()
  const activity = await fetchActivity()

  return (
    <div className="grid grid-cols-3">
      <Analytics data={analytics} />
      <Notifications data={notifications} />
      <Activity data={activity} />
    </div>
  )
}
// All sections wait for slowest fetch
```

**Correct (parallel routes with independent streaming):**

```text
app/dashboard/
├── layout.tsx
├── @analytics/
│   ├── page.tsx
│   └── loading.tsx
├── @notifications/
│   ├── page.tsx
│   └── loading.tsx
└── @activity/
    ├── page.tsx
    └── loading.tsx
```

```typescript
// app/dashboard/layout.tsx
export default function DashboardLayout({
  analytics,
  notifications,
  activity
}: {
  analytics: React.ReactNode
  notifications: React.ReactNode
  activity: React.ReactNode
}) {
  return (
    <div className="grid grid-cols-3">
      {analytics}
      {notifications}
      {activity}
    </div>
  )
}

// app/dashboard/@analytics/page.tsx
export default async function AnalyticsSlot() {
  const data = await fetchAnalytics()
  return <Analytics data={data} />
}
// Each slot streams independently
```

**Benefits:**
- Each slot loads independently
- Each slot has its own loading.tsx
- Each slot can have its own error.tsx

### 4.5 Use proxy.ts for Network Boundary Logic

**Impact: MEDIUM-HIGH (clearer network boundary, Node.js runtime)**

Next.js 16 replaces `middleware.ts` with `proxy.ts` for explicit network boundary logic. The proxy runs on Node.js runtime (not Edge), providing access to full Node.js APIs.

**Incorrect (old middleware.ts pattern):**

```typescript
// middleware.ts (deprecated in Next.js 16)
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export function middleware(request: NextRequest) {
  const token = request.cookies.get('token')
  if (!token) {
    return NextResponse.redirect(new URL('/login', request.url))
  }
}

export const config = {
  matcher: '/dashboard/:path*'
}
```

**Correct (proxy.ts in Next.js 16):**

```typescript
// proxy.ts
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export function proxy(request: NextRequest) {
  const token = request.cookies.get('token')

  // Full Node.js APIs available (not Edge)
  if (!token) {
    return NextResponse.redirect(new URL('/login', request.url))
  }

  // Add headers, rewrite, etc.
  const response = NextResponse.next()
  response.headers.set('x-custom-header', 'value')
  return response
}

export const config = {
  matcher: '/dashboard/:path*'
}
```

**Migration:**
1. Rename `middleware.ts` → `proxy.ts`
2. Rename exported function `middleware` → `proxy`
3. Update any Edge-specific code to use Node.js APIs

Reference: [Next.js 16 proxy.ts](https://nextjs.org/docs/app/building-your-application/routing/middleware)

---

## 5. Server Actions & Mutations

**Impact: MEDIUM-HIGH**

Form handling, revalidatePath, and redirect patterns enable secure, performant data mutations with proper cache invalidation.

### 5.1 Handle Server Action Errors Gracefully

**Impact: MEDIUM-HIGH (prevents silent failures, better error UX)**

Return error states from Server Actions instead of throwing. Use `useActionState` to manage form state and display errors.

**Incorrect (unhandled errors):**

```typescript
async function createPost(formData: FormData) {
  'use server'

  const title = formData.get('title') as string
  await db.posts.create({ data: { title } })
  // If validation fails or DB errors, user sees nothing
}
```

**Correct (returning error state):**

```typescript
// actions.ts
'use server'

type ActionState = {
  error?: string
  success?: boolean
}

export async function createPost(
  prevState: ActionState,
  formData: FormData
): Promise<ActionState> {
  const title = formData.get('title') as string

  if (!title || title.length < 3) {
    return { error: 'Title must be at least 3 characters' }
  }

  try {
    await db.posts.create({ data: { title } })
    revalidatePath('/posts')
    return { success: true }
  } catch (e) {
    return { error: 'Failed to create post. Please try again.' }
  }
}

// page.tsx
'use client'

import { useActionState } from 'react'
import { createPost } from './actions'

export default function NewPostForm() {
  const [state, formAction, isPending] = useActionState(createPost, {})

  return (
    <form action={formAction}>
      <input name="title" />
      {state.error && <p className="error">{state.error}</p>}
      <button disabled={isPending}>
        {isPending ? 'Creating...' : 'Create'}
      </button>
    </form>
  )
}
```

Reference: [useActionState](https://react.dev/reference/react/useActionState)

### 5.2 Revalidate Cache After Mutations

**Impact: MEDIUM (ensures fresh data after changes)**

Always invalidate relevant cached data after mutations. Use `revalidatePath` for routes and `revalidateTag` for tagged data.

**Incorrect (stale cache after mutation):**

```typescript
'use server'

export async function deletePost(postId: string) {
  await db.posts.delete({ where: { id: postId } })
  redirect('/posts')
  // Posts list still shows deleted post from cache!
}
```

**Correct (invalidating cache):**

```typescript
'use server'

import { revalidatePath, revalidateTag } from 'next/cache'
import { redirect } from 'next/navigation'

export async function deletePost(postId: string) {
  await db.posts.delete({ where: { id: postId } })

  // Option 1: Revalidate specific path
  revalidatePath('/posts')

  // Option 2: Revalidate by tag (more granular)
  revalidateTag('posts')

  redirect('/posts')
}

export async function updatePost(postId: string, formData: FormData) {
  await db.posts.update({
    where: { id: postId },
    data: { title: formData.get('title') }
  })

  // Revalidate both the list and detail pages
  revalidatePath('/posts')
  revalidatePath(`/posts/${postId}`)
}
```

**Revalidation strategies:**

```typescript
// Specific route
revalidatePath('/posts')

// Dynamic route with specific ID
revalidatePath(`/posts/${postId}`)

// All routes using a layout
revalidatePath('/dashboard', 'layout')

// By cache tag
revalidateTag('posts')

// Multiple tags
revalidateTag('posts')
revalidateTag(`post-${postId}`)
```

### 5.3 Show Pending States with useFormStatus

**Impact: MEDIUM-HIGH (better UX during form submission)**

Use `useFormStatus` to show loading indicators and disable buttons during form submission. This provides immediate feedback to users.

**Incorrect (no feedback during submission):**

```typescript
// app/posts/new/page.tsx
export default function NewPostPage() {
  async function createPost(formData: FormData) {
    'use server'
    await db.posts.create({ data: { title: formData.get('title') } })
  }

  return (
    <form action={createPost}>
      <input name="title" />
      <button type="submit">Create Post</button>
      {/* User clicks multiple times, no feedback */}
    </form>
  )
}
```

**Correct (pending state with useFormStatus):**

```typescript
// app/posts/new/page.tsx
import { SubmitButton } from './submit-button'

export default function NewPostPage() {
  async function createPost(formData: FormData) {
    'use server'
    await db.posts.create({ data: { title: formData.get('title') } })
  }

  return (
    <form action={createPost}>
      <input name="title" />
      <SubmitButton />
    </form>
  )
}

// submit-button.tsx
'use client'

import { useFormStatus } from 'react-dom'

export function SubmitButton() {
  const { pending } = useFormStatus()

  return (
    <button type="submit" disabled={pending}>
      {pending ? 'Creating...' : 'Create Post'}
    </button>
  )
}
```

**Note:** `useFormStatus` must be used in a child component of the form, not in the same component as the form element.

### 5.4 Use Optimistic Updates for Instant Feedback

**Impact: MEDIUM (instant UI response, better perceived performance)**

Use `useOptimistic` to update UI immediately before the server confirms. If the action fails, React reverts to the previous state.

**Incorrect (waiting for server response):**

```typescript
'use client'

import { useState } from 'react'

export function LikeButton({ postId, initialLikes }: { postId: string; initialLikes: number }) {
  const [likes, setLikes] = useState(initialLikes)
  const [isLiking, setIsLiking] = useState(false)

  async function handleLike() {
    setIsLiking(true)
    const newLikes = await likePost(postId)  // Wait for server
    setLikes(newLikes)
    setIsLiking(false)
  }

  return (
    <button onClick={handleLike} disabled={isLiking}>
      {likes} {isLiking ? '...' : '❤️'}
    </button>
  )
}
// 200-500ms delay before UI updates
```

**Correct (optimistic update):**

```typescript
'use client'

import { useOptimistic } from 'react'
import { likePost } from './actions'

export function LikeButton({ postId, initialLikes }: { postId: string; initialLikes: number }) {
  const [optimisticLikes, addOptimisticLike] = useOptimistic(
    initialLikes,
    (state, _) => state + 1
  )

  async function handleLike() {
    addOptimisticLike(null)  // Instant UI update
    await likePost(postId)   // Server update in background
    // If fails, React reverts automatically
  }

  return (
    <form action={handleLike}>
      <button type="submit">
        {optimisticLikes} ❤️
      </button>
    </form>
  )
}
// Instant feedback, reverts on failure
```

**When to use:**
- Like/vote buttons
- Adding items to cart
- Toggling favorites
- Any action where instant feedback improves UX

### 5.5 Use Server Actions for Form Submissions

**Impact: MEDIUM-HIGH (eliminates API routes, type-safe mutations)**

Server Actions handle form submissions directly without creating API routes. They're type-safe, progressively enhanced, and integrate with caching.

**Incorrect (API route for form handling):**

```typescript
// app/api/posts/route.ts
export async function POST(request: Request) {
  const data = await request.json()
  const post = await db.posts.create({ data })
  return Response.json(post)
}

// app/posts/new/page.tsx
'use client'

export default function NewPostPage() {
  const handleSubmit = async (e) => {
    e.preventDefault()
    const formData = new FormData(e.target)
    await fetch('/api/posts', {
      method: 'POST',
      body: JSON.stringify(Object.fromEntries(formData))
    })
  }
  // Requires client component, manual fetch, no type safety
}
```

**Correct (Server Action):**

```typescript
// app/posts/new/page.tsx
import { redirect } from 'next/navigation'
import { revalidatePath } from 'next/cache'

export default function NewPostPage() {
  async function createPost(formData: FormData) {
    'use server'

    const title = formData.get('title') as string
    const content = formData.get('content') as string

    const post = await db.posts.create({
      data: { title, content }
    })

    revalidatePath('/posts')
    redirect(`/posts/${post.id}`)
  }

  return (
    <form action={createPost}>
      <input name="title" required />
      <textarea name="content" />
      <button type="submit">Create Post</button>
    </form>
  )
}
// Works without JS, type-safe, integrated caching
```

**Benefits:**
- Progressive enhancement (works without JavaScript)
- Type-safe with TypeScript
- Direct cache invalidation
- No API route boilerplate

---

## 6. Streaming & Loading States

**Impact: MEDIUM**

Strategic Suspense boundaries, loading.tsx, and error.tsx enable progressive rendering and faster perceived performance.

### 6.1 Match Skeleton Dimensions to Actual Content

**Impact: MEDIUM (prevents layout shift, better CLS score)**

Loading skeletons should match the dimensions of actual content to prevent layout shift (CLS). Use fixed heights or aspect ratios.

**Incorrect (skeleton causes layout shift):**

```typescript
// loading.tsx
export default function Loading() {
  return <div className="h-8 w-full bg-gray-200 animate-pulse" />
}

// page.tsx
export default async function Page() {
  const data = await fetchData()
  return (
    <div className="h-64">  {/* Height doesn't match skeleton */}
      <Content data={data} />
    </div>
  )
}
// Page jumps from 32px to 256px when content loads
```

**Correct (skeleton matches content dimensions):**

```typescript
// loading.tsx
export default function Loading() {
  return (
    <div className="space-y-4">
      {/* Header skeleton - matches actual header height */}
      <div className="h-12 w-64 bg-gray-200 animate-pulse rounded" />

      {/* Card grid skeleton - matches actual card dimensions */}
      <div className="grid grid-cols-3 gap-4">
        {[1, 2, 3].map(i => (
          <div key={i} className="h-48 bg-gray-200 animate-pulse rounded" />
        ))}
      </div>
    </div>
  )
}

// page.tsx
export default async function Page() {
  const data = await fetchData()
  return (
    <div className="space-y-4">
      <h1 className="h-12 text-3xl">{data.title}</h1>
      <div className="grid grid-cols-3 gap-4">
        {data.cards.map(card => (
          <Card key={card.id} className="h-48" {...card} />
        ))}
      </div>
    </div>
  )
}
// No layout shift - skeleton and content have same dimensions
```

**Tips:**
- Use the same CSS classes for skeleton and content containers
- Set explicit heights on dynamic content
- Use `aspect-ratio` for images and videos

### 6.2 Nest Suspense for Progressive Disclosure

**Impact: LOW-MEDIUM (fine-grained loading control, better UX)**

Nest Suspense boundaries to create progressive loading experiences. Outer boundaries show first, inner boundaries refine as data loads.

**Incorrect (flat Suspense structure):**

```typescript
export default function ProductPage() {
  return (
    <div>
      <Suspense fallback={<ProductSkeleton />}>
        <ProductDetails />
      </Suspense>
      <Suspense fallback={<ReviewsSkeleton />}>
        <Reviews />
      </Suspense>
      <Suspense fallback={<RelatedSkeleton />}>
        <RelatedProducts />
      </Suspense>
    </div>
  )
}
// All sections load independently, no visual hierarchy
```

**Correct (nested progressive disclosure):**

```typescript
export default function ProductPage() {
  return (
    <div>
      {/* Product details load first - critical content */}
      <Suspense fallback={<ProductSkeleton />}>
        <ProductDetails />

        {/* Reviews load after product - secondary content */}
        <Suspense fallback={<ReviewsSkeleton />}>
          <Reviews />

          {/* Related products load last - tertiary content */}
          <Suspense fallback={<RelatedSkeleton />}>
            <RelatedProducts />
          </Suspense>
        </Suspense>
      </Suspense>
    </div>
  )
}
// Content reveals progressively: Product → Reviews → Related
```

**Alternative (prioritized parallel loading):**

```typescript
export default function ProductPage() {
  return (
    <div>
      {/* Critical path - no Suspense, blocks render */}
      <ProductHeader />

      <div className="grid grid-cols-2 gap-8">
        {/* Primary content */}
        <Suspense fallback={<DetailsSkeleton />}>
          <ProductDetails />
        </Suspense>

        {/* Secondary content - lower priority */}
        <Suspense fallback={<SidebarSkeleton />}>
          <ProductSidebar />
        </Suspense>
      </div>
    </div>
  )
}
```

### 6.3 Place Suspense Boundaries Strategically

**Impact: MEDIUM (faster perceived performance, progressive loading)**

Wrap slow components in Suspense to show meaningful content immediately. Place boundaries around content that fetches data independently.

**Incorrect (single Suspense for entire page):**

```typescript
// app/dashboard/page.tsx
import { Suspense } from 'react'

export default function DashboardPage() {
  return (
    <Suspense fallback={<FullPageLoader />}>
      <Dashboard />
    </Suspense>
  )
}
// User sees full-page spinner until everything loads
```

**Correct (granular Suspense boundaries):**

```typescript
// app/dashboard/page.tsx
import { Suspense } from 'react'

export default function DashboardPage() {
  return (
    <div className="grid grid-cols-3 gap-4">
      {/* Fast content renders immediately */}
      <Header />

      {/* Each section loads independently */}
      <Suspense fallback={<StatsSkeleton />}>
        <StatsWidget />
      </Suspense>

      <Suspense fallback={<ChartSkeleton />}>
        <RevenueChart />
      </Suspense>

      <Suspense fallback={<TableSkeleton />}>
        <RecentOrders />
      </Suspense>
    </div>
  )
}
// Header shows instantly, widgets stream in as they load
```

**Guidelines for Suspense boundaries:**
- Wrap each independent data-fetching component
- Group related components in single boundary
- Keep fallbacks similar in size to actual content (prevent layout shift)
- Prioritize above-the-fold content

### 6.4 Use error.tsx for Route-Level Error Boundaries

**Impact: MEDIUM (graceful error recovery, prevents full page crashes)**

Create `error.tsx` files to catch errors in route segments. Users can retry without navigating away or losing state.

**Incorrect (unhandled errors crash the page):**

```typescript
// app/dashboard/page.tsx
export default async function DashboardPage() {
  const data = await fetchData()  // If this throws, entire app crashes
  return <Dashboard data={data} />
}
```

**Correct (error.tsx catches and recovers):**

```typescript
// app/dashboard/error.tsx
'use client'  // Error components must be Client Components

import { useEffect } from 'react'

export default function DashboardError({
  error,
  reset
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  useEffect(() => {
    // Log to error reporting service
    console.error(error)
  }, [error])

  return (
    <div className="p-4 bg-red-50 rounded">
      <h2>Something went wrong loading the dashboard</h2>
      <button
        onClick={() => reset()}
        className="mt-2 px-4 py-2 bg-red-600 text-white rounded"
      >
        Try again
      </button>
    </div>
  )
}
```

**Error boundary hierarchy:**

```text
app/
├── error.tsx           # Catches errors in all routes
├── global-error.tsx    # Catches errors in root layout
└── dashboard/
    ├── error.tsx       # Catches errors in dashboard routes only
    └── page.tsx
```

**Note:** `error.tsx` doesn't catch errors in the same segment's `layout.tsx`. Place `error.tsx` in the parent segment to catch layout errors.

### 6.5 Use loading.tsx for Route-Level Loading States

**Impact: MEDIUM (automatic loading UI, instant navigation feedback)**

Create `loading.tsx` files to show instant loading UI during route transitions. Next.js automatically wraps the page in Suspense with this component as fallback.

**Incorrect (no loading state):**

```text
app/dashboard/
└── page.tsx
# Navigation to /dashboard shows blank screen until data loads
```

**Correct (loading.tsx for instant feedback):**

```text
app/dashboard/
├── loading.tsx
└── page.tsx
```

```typescript
// app/dashboard/loading.tsx
export default function DashboardLoading() {
  return (
    <div className="animate-pulse">
      <div className="h-8 bg-gray-200 rounded w-1/4 mb-4" />
      <div className="grid grid-cols-3 gap-4">
        <div className="h-32 bg-gray-200 rounded" />
        <div className="h-32 bg-gray-200 rounded" />
        <div className="h-32 bg-gray-200 rounded" />
      </div>
    </div>
  )
}

// app/dashboard/page.tsx
export default async function DashboardPage() {
  const data = await fetchDashboardData()
  return <Dashboard data={data} />
}
```

**Best practices:**
- Match skeleton structure to actual content
- Use CSS animations for polish
- Keep skeletons lightweight (no data fetching)
- Nest loading.tsx for granular control

```text
app/dashboard/
├── loading.tsx          # Dashboard skeleton
├── page.tsx
└── analytics/
    ├── loading.tsx      # Analytics-specific skeleton
    └── page.tsx
```

---

## 7. Metadata & SEO

**Impact: MEDIUM**

generateMetadata, sitemap generation, and OpenGraph optimization improve search visibility and social sharing.

### 7.1 Configure Robots for Crawl Control

**Impact: MEDIUM (prevents indexing of private pages)**

Use `robots.ts` and per-page robots metadata to control which pages search engines can crawl and index.

**Incorrect (no robots configuration):**

```typescript
// No robots.ts
// Search engines may index admin pages, staging URLs, etc.
```

**Correct (robots.ts for global rules):**

```typescript
// app/robots.ts
import type { MetadataRoute } from 'next'

export default function robots(): MetadataRoute.Robots {
  const baseUrl = process.env.NEXT_PUBLIC_BASE_URL

  return {
    rules: [
      {
        userAgent: '*',
        allow: '/',
        disallow: ['/admin/', '/api/', '/dashboard/']
      }
    ],
    sitemap: `${baseUrl}/sitemap.xml`
  }
}
```

**Per-page robots metadata:**

```typescript
// app/dashboard/page.tsx
import type { Metadata } from 'next'

export const metadata: Metadata = {
  robots: {
    index: false,
    follow: false,
    nocache: true,
    googleBot: {
      index: false,
      follow: false
    }
  }
}

export default function DashboardPage() {
  // Private dashboard content
}
```

**Common patterns:**
- `index: false` - Don't show in search results
- `follow: false` - Don't follow links on this page
- `nocache` - Don't cache this page
- `noarchive` - Don't show cached version in results

### 7.2 Generate Dynamic OpenGraph Images

**Impact: LOW-MEDIUM (better social sharing, higher CTR)**

Use `opengraph-image.tsx` to generate dynamic social preview images. This creates unique, branded images for each page.

**Incorrect (missing or generic OG images):**

```typescript
// No OG image configured
// Social shares show generic placeholder or nothing
```

**Correct (dynamic OG image generation):**

```typescript
// app/blog/[slug]/opengraph-image.tsx
import { ImageResponse } from 'next/og'

export const runtime = 'edge'
export const alt = 'Blog post cover'
export const size = { width: 1200, height: 630 }
export const contentType = 'image/png'

export default async function Image({
  params
}: {
  params: { slug: string }
}) {
  const post = await getPost(params.slug)

  return new ImageResponse(
    (
      <div
        style={{
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          width: '100%',
          height: '100%',
          backgroundColor: '#1a1a1a',
          color: 'white',
          padding: '40px'
        }}
      >
        <h1 style={{ fontSize: '60px', textAlign: 'center' }}>
          {post.title}
        </h1>
        <p style={{ fontSize: '30px', color: '#888' }}>
          {post.author} · {post.readTime} min read
        </p>
      </div>
    ),
    { ...size }
  )
}
```

**Static fallback for routes without dynamic image:**

```typescript
// app/opengraph-image.png
// Place a static image in the route for default OG image
```

Reference: [OpenGraph Images](https://nextjs.org/docs/app/api-reference/file-conventions/metadata/opengraph-image)

### 7.3 Generate Sitemaps Dynamically

**Impact: MEDIUM (improved crawlability, faster indexing)**

Create dynamic sitemaps that include all your pages with proper last-modified dates. This helps search engines discover and index content efficiently.

**Incorrect (static sitemap missing dynamic routes):**

```xml
<!-- public/sitemap.xml -->
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>https://example.com/</loc>
  </url>
  <url>
    <loc>https://example.com/about</loc>
  </url>
</urlset>
<!-- Missing all product pages! -->
```

**Correct (dynamic sitemap.ts):**

```typescript
// app/sitemap.ts
import type { MetadataRoute } from 'next'

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const products = await getProducts()
  const posts = await getPosts()

  const productUrls = products.map((product) => ({
    url: `https://example.com/products/${product.slug}`,
    lastModified: product.updatedAt,
    changeFrequency: 'weekly' as const,
    priority: 0.8
  }))

  const postUrls = posts.map((post) => ({
    url: `https://example.com/blog/${post.slug}`,
    lastModified: post.updatedAt,
    changeFrequency: 'monthly' as const,
    priority: 0.6
  }))

  return [
    {
      url: 'https://example.com',
      lastModified: new Date(),
      changeFrequency: 'daily',
      priority: 1
    },
    ...productUrls,
    ...postUrls
  ]
}
```

**For large sites (50,000+ URLs), split into multiple sitemaps:**

```typescript
// app/sitemap/[id]/route.ts
export async function GET(
  request: Request,
  { params }: { params: { id: string } }
) {
  const page = parseInt(params.id)
  const products = await getProductsPage(page, 10000)
  // Generate sitemap XML for this page
}
```

### 7.4 Use generateMetadata for Dynamic Metadata

**Impact: MEDIUM (dynamic SEO, social sharing optimization)**

Export `generateMetadata` to create dynamic metadata based on route parameters and fetched data. This enables unique titles, descriptions, and OpenGraph images per page.

**Incorrect (static metadata for dynamic pages):**

```typescript
// app/product/[id]/page.tsx
export const metadata = {
  title: 'Product',  // Same for all products!
  description: 'View product details'
}

export default async function ProductPage({ params }) {
  const product = await getProduct(params.id)
  return <ProductDetails product={product} />
}
```

**Correct (dynamic metadata per product):**

```typescript
// app/product/[id]/page.tsx
import type { Metadata } from 'next'

export async function generateMetadata({
  params
}: {
  params: { id: string }
}): Promise<Metadata> {
  const product = await getProduct(params.id)

  return {
    title: product.name,
    description: product.description,
    openGraph: {
      title: product.name,
      description: product.description,
      images: [
        {
          url: product.image,
          width: 1200,
          height: 630,
          alt: product.name
        }
      ]
    },
    twitter: {
      card: 'summary_large_image',
      title: product.name,
      description: product.description,
      images: [product.image]
    }
  }
}

export default async function ProductPage({ params }) {
  const product = await getProduct(params.id)  // Deduplicated with cache()
  return <ProductDetails product={product} />
}
```

**Note:** Next.js automatically deduplicates `fetch` calls, so `generateMetadata` and the page can call `getProduct` without duplicate requests.

---

## 8. Client Components

**Impact: LOW-MEDIUM**

Proper 'use client' boundaries and hydration optimization minimize client-side JavaScript and improve interactivity.

### 8.1 Avoid Hydration Mismatches

**Impact: LOW-MEDIUM (prevents React warnings, ensures correct rendering)**

Server and client must render identical HTML. Avoid browser-only APIs, timestamps, and random values during initial render.

**Incorrect (hydration mismatch):**

```typescript
'use client'

export function Greeting() {
  // Different on server vs client
  const time = new Date().toLocaleTimeString()

  return <p>Current time: {time}</p>
}
// Server renders "10:30:00", client hydrates with "10:30:01" → mismatch!
```

**Correct (defer client-only values):**

```typescript
'use client'

import { useState, useEffect } from 'react'

export function Greeting() {
  const [time, setTime] = useState<string | null>(null)

  useEffect(() => {
    setTime(new Date().toLocaleTimeString())
    const interval = setInterval(() => {
      setTime(new Date().toLocaleTimeString())
    }, 1000)
    return () => clearInterval(interval)
  }, [])

  // Render nothing or placeholder on server
  if (!time) return <p>Loading time...</p>

  return <p>Current time: {time}</p>
}
```

**Alternative (suppressHydrationWarning for known differences):**

```typescript
'use client'

export function Timestamp() {
  return (
    <time suppressHydrationWarning>
      {new Date().toLocaleTimeString()}
    </time>
  )
}
// Use sparingly - only when mismatch is intentional
```

**Common causes:**
- `Date.now()`, `Math.random()`
- `window.innerWidth`, `navigator.userAgent`
- Browser extensions modifying HTML
- Different locales on server/client

### 8.2 Load Third-Party Scripts Efficiently

**Impact: LOW-MEDIUM (prevents blocking, improves LCP)**

Use `next/script` for third-party scripts with appropriate loading strategies. Avoid blocking the main thread with synchronous scripts.

**Incorrect (blocking script in head):**

```typescript
// app/layout.tsx
export default function RootLayout({ children }) {
  return (
    <html>
      <head>
        <script src="https://analytics.example.com/script.js" />
        {/* Blocks rendering until script loads */}
      </head>
      <body>{children}</body>
    </html>
  )
}
```

**Correct (next/script with strategy):**

```typescript
// app/layout.tsx
import Script from 'next/script'

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        {children}

        {/* Analytics - load after page is interactive */}
        <Script
          src="https://analytics.example.com/script.js"
          strategy="afterInteractive"
        />

        {/* Chat widget - load when idle */}
        <Script
          src="https://chat.example.com/widget.js"
          strategy="lazyOnload"
        />

        {/* Critical script - load before interactive */}
        <Script
          id="gtm"
          strategy="beforeInteractive"
          dangerouslySetInnerHTML={{
            __html: `(function(w,d,s,l,i){...})(window,document,'script','dataLayer','GTM-XXX');`
          }}
        />
      </body>
    </html>
  )
}
```

**Strategy guide:**
- `beforeInteractive` - Critical scripts (rare)
- `afterInteractive` - Analytics, tracking (default)
- `lazyOnload` - Chat widgets, social buttons
- `worker` - Offload to web worker (experimental)

### 8.3 Minimize 'use client' Boundary Scope

**Impact: LOW-MEDIUM (reduces client JS, better performance)**

Keep `'use client'` boundaries as small as possible. Only the interactive parts need to be Client Components.

**Incorrect (entire page as Client Component):**

```typescript
'use client'

export default function ProductPage({ product }) {
  const [quantity, setQuantity] = useState(1)

  return (
    <div>
      <h1>{product.name}</h1>
      <p>{product.description}</p>  {/* Static, doesn't need client */}
      <img src={product.image} />   {/* Static, doesn't need client */}
      <Reviews reviews={product.reviews} />  {/* Static, doesn't need client */}

      {/* Only this needs interactivity */}
      <input value={quantity} onChange={e => setQuantity(+e.target.value)} />
      <button onClick={() => addToCart(product.id, quantity)}>Add to Cart</button>
    </div>
  )
}
// Entire page hydrates on client
```

**Correct (minimal Client Component):**

```typescript
// app/product/[id]/page.tsx (Server Component)
export default async function ProductPage({ params }) {
  const product = await getProduct(params.id)

  return (
    <div>
      <h1>{product.name}</h1>
      <p>{product.description}</p>
      <img src={product.image} />
      <Reviews reviews={product.reviews} />

      {/* Only interactive part is client */}
      <AddToCartButton productId={product.id} />
    </div>
  )
}

// components/AddToCartButton.tsx
'use client'

import { useState } from 'react'

export function AddToCartButton({ productId }: { productId: string }) {
  const [quantity, setQuantity] = useState(1)

  return (
    <div>
      <input value={quantity} onChange={e => setQuantity(+e.target.value)} />
      <button onClick={() => addToCart(productId, quantity)}>Add to Cart</button>
    </div>
  )
}
// Only button hydrates, rest is static HTML
```

### 8.4 Pass Server Components as Children to Client Components

**Impact: LOW-MEDIUM (keeps static content on server, reduces bundle)**

Client Components can render Server Components passed as children. This keeps static content server-rendered while adding interactivity.

**Incorrect (converting children to Client Components):**

```typescript
// components/Modal.tsx
'use client'

import { ProductDetails } from './ProductDetails'  // Forces this to be client

export function Modal({ productId }) {
  const [isOpen, setIsOpen] = useState(false)

  return (
    <>
      <button onClick={() => setIsOpen(true)}>View Details</button>
      {isOpen && (
        <div className="modal">
          <ProductDetails productId={productId} />  {/* Now client-rendered */}
        </div>
      )}
    </>
  )
}
```

**Correct (children pattern keeps server content):**

```typescript
// components/Modal.tsx
'use client'

import { ReactNode, useState } from 'react'

export function Modal({ children, trigger }: { children: ReactNode; trigger: string }) {
  const [isOpen, setIsOpen] = useState(false)

  return (
    <>
      <button onClick={() => setIsOpen(true)}>{trigger}</button>
      {isOpen && (
        <div className="modal">
          <button onClick={() => setIsOpen(false)}>Close</button>
          {children}  {/* Server Component passed as children */}
        </div>
      )}
    </>
  )
}

// app/product/[id]/page.tsx (Server Component)
export default async function ProductPage({ params }) {
  const product = await getProduct(params.id)

  return (
    <Modal trigger="View Details">
      <ProductDetails product={product} />  {/* Stays server-rendered */}
    </Modal>
  )
}
```

**Benefits:**
- `ProductDetails` remains a Server Component
- Data fetching happens on server
- Only Modal interactivity ships to client

---

## References

1. [https://nextjs.org/docs](https://nextjs.org/docs)
2. [https://nextjs.org/blog/next-16](https://nextjs.org/blog/next-16)
3. [https://react.dev](https://react.dev)
4. [https://vercel.com/blog](https://vercel.com/blog)