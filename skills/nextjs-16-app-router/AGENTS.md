# Next.js 16 App Router

**Version 0.1.0**  
Next.js Community  
January 2026

> **Note:**
> This document is mainly for agents and LLMs to follow when maintaining,
> generating, or refactoring Next.js 16 App Router codebases. Humans may also find it useful,
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive performance optimization guide for Next.js 16 App Router applications, designed for AI agents and LLMs. Contains 45 rules across 8 categories, prioritized by impact from critical (eliminating waterfalls, reducing bundle size) to incremental (advanced patterns). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated refactoring and code generation.

---

## Table of Contents

1. [Async Data Fetching](#1-async-data-fetching) — **CRITICAL**
   - 1.1 [Avoid Awaiting Slow Data in Root Layouts](#11-avoid-awaiting-slow-data-in-root-layouts)
   - 1.2 [Prevent Client-Side Fetch Cascades](#12-prevent-client-side-fetch-cascades)
   - 1.3 [Start Fetches Early, Await When Value Needed](#13-start-fetches-early-await-when-value-needed)
   - 1.4 [Strategic Suspense Boundaries for Progressive Loading](#14-strategic-suspense-boundaries-for-progressive-loading)
   - 1.5 [Use loading.tsx for Instant Navigation Feedback](#15-use-loadingtsx-for-instant-navigation-feedback)
   - 1.6 [Use Promise.all() for Independent Data Fetches](#16-use-promiseall-for-independent-data-fetches)
2. [Bundle Optimization](#2-bundle-optimization) — **CRITICAL**
   - 2.1 [Configure optimizePackageImports in next.config.js](#21-configure-optimizepackageimports-in-nextconfigjs)
   - 2.2 [Import Directly from Source, Not Barrel Files](#22-import-directly-from-source-not-barrel-files)
   - 2.3 [Import Only What You Use from Libraries](#23-import-only-what-you-use-from-libraries)
   - 2.4 [Keep 'use client' Boundaries as Leaf Nodes](#24-keep-use-client-boundaries-as-leaf-nodes)
   - 2.5 [Use next/dynamic for Heavy Components](#25-use-nextdynamic-for-heavy-components)
3. [Server Components](#3-server-components) — **HIGH**
   - 3.1 [Default to Server Components](#31-default-to-server-components)
   - 3.2 [Fetch Data Where Needed Instead of Prop Drilling](#32-fetch-data-where-needed-instead-of-prop-drilling)
   - 3.3 [Fetch Shared Data in Layouts](#33-fetch-shared-data-in-layouts)
   - 3.4 [Pass Only Serializable Props to Client Components](#34-pass-only-serializable-props-to-client-components)
   - 3.5 [Use Async/Await Directly in Server Components](#35-use-asyncawait-directly-in-server-components)
   - 3.6 [Use server-only for Sensitive Code](#36-use-server-only-for-sensitive-code)
4. [Caching Strategies](#4-caching-strategies) — **HIGH**
   - 4.1 [Avoid Caching User-Specific or Frequently Changing Data](#41-avoid-caching-user-specific-or-frequently-changing-data)
   - 4.2 [Use fetch Cache Options Appropriately](#42-use-fetch-cache-options-appropriately)
   - 4.3 [Use React cache() for Request-Scoped Deduplication](#43-use-react-cache-for-request-scoped-deduplication)
   - 4.4 [Use revalidatePath and revalidateTag for On-Demand Revalidation](#44-use-revalidatepath-and-revalidatetag-for-on-demand-revalidation)
   - 4.5 [Use unstable_cache for Non-Fetch Data Sources](#45-use-unstablecache-for-non-fetch-data-sources)
5. [Rendering Patterns](#5-rendering-patterns) — **MEDIUM**
   - 5.1 [Avoid force-dynamic Unless Necessary](#51-avoid-force-dynamic-unless-necessary)
   - 5.2 [Combine Streaming with Dynamic Rendering](#52-combine-streaming-with-dynamic-rendering)
   - 5.3 [Default to Static Rendering](#53-default-to-static-rendering)
   - 5.4 [Use generateStaticParams for Dynamic Routes](#54-use-generatestaticparams-for-dynamic-routes)
   - 5.5 [Use Segment Config Options Appropriately](#55-use-segment-config-options-appropriately)
6. [Route Architecture](#6-route-architecture) — **MEDIUM**
   - 6.1 [Use Layouts for Persistent UI](#61-use-layouts-for-persistent-ui)
   - 6.2 [Use next/link for Client-Side Navigation](#62-use-nextlink-for-client-side-navigation)
   - 6.3 [Use not-found.tsx for Proper 404 Handling](#63-use-not-foundtsx-for-proper-404-handling)
   - 6.4 [Use Parallel Routes for Simultaneous Rendering](#64-use-parallel-routes-for-simultaneous-rendering)
   - 6.5 [Use Route Groups for Organization](#65-use-route-groups-for-organization)
7. [Client Components](#7-client-components) — **MEDIUM**
   - 7.1 [Prefer useEffect Over useLayoutEffect](#71-prefer-useeffect-over-uselayouteffect)
   - 7.2 [Push use client to Leaf Components](#72-push-use-client-to-leaf-components)
   - 7.3 [Use URL State for Shareable Application State](#73-use-url-state-for-shareable-application-state)
   - 7.4 [Use useCallback for Stable Event Handlers](#74-use-usecallback-for-stable-event-handlers)
   - 7.5 [Use useTransition for Non-Blocking Updates](#75-use-usetransition-for-non-blocking-updates)
8. [Advanced Patterns](#8-advanced-patterns) — **LOW**
   - 8.1 [Keep Middleware Fast and Lightweight](#81-keep-middleware-fast-and-lightweight)
   - 8.2 [Optimize Images with next/image Props](#82-optimize-images-with-nextimage-props)
   - 8.3 [Use error.tsx for Graceful Error Handling](#83-use-errortsx-for-graceful-error-handling)
   - 8.4 [Use generateMetadata for Dynamic SEO](#84-use-generatemetadata-for-dynamic-seo)
   - 8.5 [Use Intercepting Routes for Modal Patterns](#85-use-intercepting-routes-for-modal-patterns)
   - 8.6 [Use next/font for Self-Hosted Fonts](#86-use-nextfont-for-self-hosted-fonts)
   - 8.7 [Use Route Handlers with Proper Caching](#87-use-route-handlers-with-proper-caching)
   - 8.8 [Use Server Actions with Proper Error Handling](#88-use-server-actions-with-proper-error-handling)

---

## 1. Async Data Fetching

**Impact: CRITICAL**

Waterfalls are the #1 performance killer. Each sequential await adds full network latency, multiplying total request time.

### 1.1 Avoid Awaiting Slow Data in Root Layouts

**Impact: CRITICAL (eliminates 500-3000ms blocking delay on every navigation)**

Root layouts render on every page navigation. Awaiting slow data fetches in layouts blocks the entire application shell until data resolves. Move slow fetches to page components or wrap them in Suspense boundaries.

**Incorrect (slow fetch blocks all navigation):**

```typescript
// app/layout.tsx
export default async function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const analytics = await getAnalyticsConfig()  // 800ms blocks every page
  const featureFlags = await getFeatureFlags()  // 400ms compounds the delay

  return (
    <html>
      <body>
        <AnalyticsProvider config={analytics}>
          <FeatureFlagProvider flags={featureFlags}>
            <Navigation />
            {children}
          </FeatureFlagProvider>
        </AnalyticsProvider>
      </body>
    </html>
  )
}
// Every navigation waits 1200ms before anything renders
```

**Correct (layout renders instantly, data streams):**

```typescript
// app/layout.tsx
import { Suspense } from 'react'

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html>
      <body>
        <Suspense fallback={<NavSkeleton />}>
          <NavigationWithData />  {/* Fetches its own data, streams in */}
        </Suspense>
        {children}
      </body>
    </html>
  )
}

// app/components/NavigationWithData.tsx
async function NavigationWithData() {
  const [analytics, featureFlags] = await Promise.all([
    getAnalyticsConfig(),
    getFeatureFlags(),
  ])

  return (
    <AnalyticsProvider config={analytics}>
      <FeatureFlagProvider flags={featureFlags}>
        <Navigation />
      </FeatureFlagProvider>
    </AnalyticsProvider>
  )
}
// Shell renders instantly, navigation streams in
```

**Alternative (use cached data):**

```typescript
// app/layout.tsx
import { unstable_cache } from 'next/cache'

const getCachedConfig = unstable_cache(
  async () => getAnalyticsConfig(),
  ['analytics-config'],
  { revalidate: 3600 }  // Cache for 1 hour
)

export default async function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const analytics = await getCachedConfig()  // Fast cache hit after first load

  return (
    <html>
      <body>
        <AnalyticsProvider config={analytics}>
          <Navigation />
          {children}
        </AnalyticsProvider>
      </body>
    </html>
  )
}
```

**When blocking is acceptable:**
- Authentication checks that must complete before rendering
- Critical configuration that affects the entire page structure
- Data that is already cached and resolves in <50ms

Reference: [Layouts and Templates](https://nextjs.org/docs/app/building-your-application/routing/layouts-and-templates)

### 1.2 Prevent Client-Side Fetch Cascades

**Impact: CRITICAL (Eliminates 2-5 unnecessary client round trips, 500-2000ms savings)**

Client-side fetching with useEffect creates waterfalls: parent fetches, renders children, then children fetch. Each level adds a full network round trip. Move data fetching to Server Components where requests can be parallelized and streamed.

**Incorrect (client-side cascade, 3 sequential round trips):**

```typescript
'use client'

import { useEffect, useState } from 'react'

export default function DashboardPage() {
  const [user, setUser] = useState<User | null>(null)

  useEffect(() => {
    fetch('/api/user').then(r => r.json()).then(setUser)  // Round trip 1
  }, [])

  if (!user) return <Loading />

  return (
    <div>
      <UserHeader user={user} />
      <OrdersSection userId={user.id} />  {/* Mounts after user loads */}
    </div>
  )
}

function OrdersSection({ userId }: { userId: string }) {
  const [orders, setOrders] = useState<Order[]>([])

  useEffect(() => {
    fetch(`/api/orders?userId=${userId}`).then(r => r.json()).then(setOrders)  // Round trip 2
  }, [userId])

  if (!orders.length) return <Loading />

  return (
    <div>
      {orders.map(order => (
        <OrderCard key={order.id} orderId={order.id} />  {/* Round trip 3 per card */}
      ))}
    </div>
  )
}
// Total: 3+ sequential network round trips from browser
```

**Correct (Server Component parallel fetching):**

```typescript
// app/dashboard/page.tsx (Server Component by default)
import { Suspense } from 'react'

export default async function DashboardPage() {
  const user = await getUser()  // Server-side, fast

  return (
    <div>
      <UserHeader user={user} />
      <Suspense fallback={<OrdersSkeleton />}>
        <OrdersSection userId={user.id} />
      </Suspense>
    </div>
  )
}

async function OrdersSection({ userId }: { userId: string }) {
  const orders = await getOrders(userId)  // Server-side, no browser round trip

  return (
    <div>
      {orders.map(order => (
        <OrderCard key={order.id} order={order} />
      ))}
    </div>
  )
}
// Total: 1 server render with parallel DB/API calls
```

**Alternative (preload pattern for necessary client fetches):**

```typescript
// When client-side fetching is required (real-time updates, user interactions)
'use client'

import { useEffect, useState } from 'react'

// Preload function called before component mounts
export function preloadDashboard() {
  void fetch('/api/user')
  void fetch('/api/orders')
  void fetch('/api/notifications')
}

export default function DashboardPage() {
  const [data, setData] = useState<DashboardData | null>(null)

  useEffect(() => {
    // Fetch all data in parallel, requests may already be in-flight
    Promise.all([
      fetch('/api/user').then(r => r.json()),
      fetch('/api/orders').then(r => r.json()),
      fetch('/api/notifications').then(r => r.json()),
    ]).then(([user, orders, notifications]) => {
      setData({ user, orders, notifications })
    })
  }, [])

  if (!data) return <Loading />

  return (
    <div>
      <UserHeader user={data.user} />
      <OrdersSection orders={data.orders} />
      <NotificationList notifications={data.notifications} />
    </div>
  )
}
```

**When client fetching is appropriate:**
- Real-time data that changes frequently (use SWR/React Query)
- User-triggered actions (search, filters)
- Data that depends on client-only state (geolocation)

Reference: [Server Components](https://nextjs.org/docs/app/getting-started/server-and-client-components)

### 1.3 Start Fetches Early, Await When Value Needed

**Impact: CRITICAL (30-60% faster data loading by overlapping fetch with computation)**

When you await immediately, you block execution until the fetch completes. By starting fetches early (without await) and deferring the await until the value is needed, you allow fetches to run while other code executes, maximizing parallelism.

**Incorrect (await blocks immediately):**

```typescript
async function ProductPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params

  const product = await getProduct(id)       // Blocks here for 200ms
  const reviews = await getReviews(id)       // Then blocks here for 300ms

  // Expensive computation happens after both fetches complete
  const recommendations = computeRecommendations(product)
  const averageRating = calculateAverageRating(reviews)

  return (
    <div>
      <ProductDetails product={product} recommendations={recommendations} />
      <ReviewSection reviews={reviews} rating={averageRating} />
    </div>
  )
}
// Total: 500ms fetch + computation time
```

**Correct (start early, await when needed):**

```typescript
async function ProductPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params

  // Start fetches immediately (no await)
  const productPromise = getProduct(id)
  const reviewsPromise = getReviews(id)

  // Await only when values are needed
  const product = await productPromise       // 200ms elapsed
  const recommendations = computeRecommendations(product)  // Runs while reviews fetch continues

  const reviews = await reviewsPromise       // May already be complete
  const averageRating = calculateAverageRating(reviews)

  return (
    <div>
      <ProductDetails product={product} recommendations={recommendations} />
      <ReviewSection reviews={reviews} rating={averageRating} />
    </div>
  )
}
// Total: 300ms (fetches overlap with computation)
```

**Alternative (pass promises to child components):**

```typescript
async function ProductPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params

  // Start fetches, pass promises down
  const productPromise = getProduct(id)
  const reviewsPromise = getReviews(id)

  return (
    <div>
      <Suspense fallback={<ProductSkeleton />}>
        <ProductDetails productPromise={productPromise} />
      </Suspense>
      <Suspense fallback={<ReviewsSkeleton />}>
        <ReviewSection reviewsPromise={reviewsPromise} />
      </Suspense>
    </div>
  )
}

// Child component awaits the promise
async function ProductDetails({
  productPromise
}: {
  productPromise: Promise<Product>
}) {
  const product = await productPromise
  return <div>{product.name}</div>
}
```

**Benefits:**
- Fetches start immediately instead of waiting for previous code
- Computation and I/O can happen concurrently
- Enables streaming when combined with Suspense

Reference: [Data Fetching Patterns](https://nextjs.org/docs/app/getting-started/fetching-data)

### 1.4 Strategic Suspense Boundaries for Progressive Loading

**Impact: CRITICAL (50-80% faster perceived load, content streams as it resolves)**

Suspense boundaries control what content loads together. A single boundary blocks the entire page until the slowest component resolves. Strategic boundaries allow fast content to stream immediately while slow content loads independently.

**Incorrect (single boundary blocks everything):**

```typescript
import { Suspense } from 'react'

export default function DashboardPage() {
  return (
    <Suspense fallback={<PageSkeleton />}>
      <Header />              {/* Fast: 50ms */}
      <Sidebar />             {/* Fast: 100ms */}
      <AnalyticsChart />      {/* Slow: 2000ms - blocks entire page */}
      <RecentActivity />      {/* Medium: 300ms */}
    </Suspense>
  )
}
// User sees nothing for 2 seconds
```

**Correct (independent boundaries enable streaming):**

```typescript
import { Suspense } from 'react'

export default function DashboardPage() {
  return (
    <>
      <Header />  {/* No data fetching, renders immediately */}

      <div className="dashboard-grid">
        <Suspense fallback={<SidebarSkeleton />}>
          <Sidebar />  {/* Streams at 100ms */}
        </Suspense>

        <main>
          <Suspense fallback={<ChartSkeleton />}>
            <AnalyticsChart />  {/* Slow component isolated, streams at 2000ms */}
          </Suspense>
        </main>

        <aside>
          <Suspense fallback={<ActivitySkeleton />}>
            <RecentActivity />  {/* Streams at 300ms */}
          </Suspense>
        </aside>
      </div>
    </>
  )
}
// User sees header instantly, then content progressively
```

**Benefits:**
- Static content renders immediately without waiting
- Each section streams as its data resolves
- Slow components don't block fast components
- Better perceived performance and user experience

**Guidelines for boundary placement:**
- Place static/synchronous content outside all boundaries
- Wrap each independent data-fetching section
- Keep related content that should appear together in the same boundary
- Nest boundaries for progressive disclosure of complex sections

Reference: [Streaming with Suspense](https://nextjs.org/docs/app/getting-started/fetching-data#streaming)

### 1.5 Use loading.tsx for Instant Navigation Feedback

**Impact: CRITICAL (0ms perceived latency vs 1-3s blank screen)**

Without loading.tsx, users see no feedback during navigation to dynamic routes - the page appears frozen. The loading.tsx file creates an automatic Suspense boundary that displays immediately, providing instant visual feedback while server content renders.

**Incorrect (no loading state, navigation feels broken):**

```typescript
// app/products/[id]/page.tsx
export default async function ProductPage({
  params,
}: {
  params: Promise<{ id: string }>
}) {
  const { id } = await params
  const product = await getProduct(id)  // 800ms with no visual feedback
  const reviews = await getReviews(id)  // 400ms more of blank screen

  return (
    <div>
      <ProductDetails product={product} />
      <ReviewList reviews={reviews} />
    </div>
  )
}
// User clicks link, nothing happens for 1.2 seconds
```

**Correct (loading.tsx provides instant feedback):**

```typescript
// app/products/[id]/loading.tsx
export default function Loading() {
  return (
    <div className="product-page">
      <ProductDetailsSkeleton />
      <ReviewListSkeleton />
    </div>
  )
}

// app/products/[id]/page.tsx
export default async function ProductPage({
  params,
}: {
  params: Promise<{ id: string }>
}) {
  const { id } = await params
  const [product, reviews] = await Promise.all([
    getProduct(id),
    getReviews(id),
  ])

  return (
    <div>
      <ProductDetails product={product} />
      <ReviewList reviews={reviews} />
    </div>
  )
}
// User clicks link, skeleton appears instantly
```

**Alternative (granular loading with nested Suspense):**

```typescript
// app/products/[id]/loading.tsx
export default function Loading() {
  return <ProductDetailsSkeleton />  // Just the critical section
}

// app/products/[id]/page.tsx
import { Suspense } from 'react'

export default async function ProductPage({
  params,
}: {
  params: Promise<{ id: string }>
}) {
  const { id } = await params
  const product = await getProduct(id)

  return (
    <div>
      <ProductDetails product={product} />
      <Suspense fallback={<ReviewListSkeleton />}>
        <ReviewList productId={id} />  {/* Streams in separately */}
      </Suspense>
    </div>
  )
}
```

**Benefits:**
- Navigation triggers instantly instead of waiting for server
- Users understand the app is responding
- Skeleton layouts prevent layout shift when content loads
- Enables partial prefetching for dynamic routes

**Best practices for loading.tsx:**
- Match the skeleton structure to the actual page layout
- Keep skeletons lightweight (no data fetching)
- Use consistent skeleton components across similar pages
- Consider animated placeholders for better perceived performance

Reference: [Loading UI and Streaming](https://nextjs.org/docs/app/api-reference/file-conventions/loading)

### 1.6 Use Promise.all() for Independent Data Fetches

**Impact: CRITICAL (2-5× faster page loads, eliminates N-1 unnecessary round trips)**

Sequential awaits create request waterfalls where each fetch waits for the previous one to complete. When fetches are independent, use Promise.all() to execute them concurrently and reduce total wait time to the duration of the slowest request.

**Incorrect (sequential fetching creates waterfall):**

```typescript
async function DashboardPage() {
  const user = await getUser()              // 200ms
  const orders = await getOrders()          // 300ms waits for user to complete
  const notifications = await getNotifications()  // 150ms waits for orders
  // Total: 650ms sequential

  return (
    <div>
      <UserProfile user={user} />
      <OrderHistory orders={orders} />
      <NotificationList notifications={notifications} />
    </div>
  )
}
```

**Correct (parallel fetching eliminates waterfall):**

```typescript
async function DashboardPage() {
  // Start all fetches immediately, await together
  const [user, orders, notifications] = await Promise.all([
    getUser(),              // 200ms concurrent
    getOrders(),            // 300ms concurrent
    getNotifications(),     // 150ms concurrent
  ])
  // Total: 300ms (slowest request only)

  return (
    <div>
      <UserProfile user={user} />
      <OrderHistory orders={orders} />
      <NotificationList notifications={notifications} />
    </div>
  )
}
```

**Alternative (start early, await later):**

```typescript
async function DashboardPage() {
  // Initiate requests immediately (no await)
  const userPromise = getUser()
  const ordersPromise = getOrders()
  const notificationsPromise = getNotifications()

  // Await when values are needed
  const [user, orders, notifications] = await Promise.all([
    userPromise,
    ordersPromise,
    notificationsPromise,
  ])

  return (
    <div>
      <UserProfile user={user} />
      <OrderHistory orders={orders} />
      <NotificationList notifications={notifications} />
    </div>
  )
}
```

**When NOT to use:**
- When fetches depend on each other (e.g., need userId before fetching orders)
- When you want progressive streaming with Suspense boundaries instead

Reference: [Parallel Data Fetching](https://nextjs.org/docs/app/getting-started/fetching-data#parallel-data-fetching)

---

## 2. Bundle Optimization

**Impact: CRITICAL**

Initial bundle size directly impacts Time to Interactive and Largest Contentful Paint. Smaller bundles mean faster hydration.

### 2.1 Configure optimizePackageImports in next.config.js

**Impact: CRITICAL (Reduces compile time by 50-80%, eliminates 100KB-500KB of unused code per library)**

The `optimizePackageImports` option transforms barrel file imports into direct imports at build time. This eliminates the need to manually rewrite imports while achieving the same tree-shaking benefits, significantly improving both dev server startup and production bundle size.

**Incorrect (no optimization configured):**

```typescript
// next.config.js
/** @type {import('next').NextConfig} */
const nextConfig = {
  // Missing optimizePackageImports - barrel imports load entire libraries
}

module.exports = nextConfig
```

```typescript
// components/Dashboard.tsx
import { BarChart, LineChart } from 'recharts'
import { format, addDays } from 'date-fns'
import { Settings, User, Bell } from 'lucide-react'
// Each import loads the ENTIRE library without optimization
```

**Correct (optimizePackageImports configured):**

```typescript
// next.config.js
/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    optimizePackageImports: [
      'recharts',
      'date-fns',
      'lucide-react',
      '@heroicons/react',
      'lodash-es',
      '@radix-ui/react-icons',
    ],
  },
}

module.exports = nextConfig
```

```typescript
// components/Dashboard.tsx - same imports, now auto-optimized
import { BarChart, LineChart } from 'recharts'
import { format, addDays } from 'date-fns'
import { Settings, User, Bell } from 'lucide-react'
// Build transforms these to direct imports automatically
```

**Libraries already optimized by Next.js (no config needed):**
- `@mui/material`, `@mui/icons-material`
- `@headlessui/react`
- `@tanstack/react-query`
- `rxjs`
- `ramda`

**Benefits:**
- Developer convenience of barrel imports with tree-shaking performance
- Faster dev server compilation (50-80% improvement)
- Smaller production bundles without manual import rewrites
- Turbopack performs this optimization automatically

Reference: [optimizePackageImports](https://nextjs.org/docs/app/api-reference/config/next-config-js/optimizePackageImports)

### 2.2 Import Directly from Source, Not Barrel Files

**Impact: CRITICAL (200-800ms faster cold starts, prevents loading 10-100x more code than needed)**

Barrel files (index.ts re-exports) defeat tree-shaking by forcing bundlers to evaluate entire module graphs. A single import from a barrel file can pull in hundreds of unused components, destroying bundle performance.

**Incorrect (imports entire component library):**

```typescript
import { Button, Card, Modal } from '@/components'
// Loads ALL 50+ components from components/index.ts

import { formatDate, parseISO } from 'date-fns'
// Pulls in entire date-fns library (200KB+)

import { UserIcon, HomeIcon } from 'lucide-react'
// Loads all 1000+ icons into bundle
```

**Correct (direct imports enable tree-shaking):**

```typescript
import Button from '@/components/Button'
import Card from '@/components/Card'
import Modal from '@/components/Modal'

import { formatDate } from 'date-fns/formatDate'
import { parseISO } from 'date-fns/parseISO'

import { UserIcon } from 'lucide-react/dist/esm/icons/user'
import { HomeIcon } from 'lucide-react/dist/esm/icons/home'
```

**Alternative (configure optimizePackageImports):**

```typescript
// next.config.js - auto-transforms barrel imports at build time
/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    optimizePackageImports: ['date-fns', 'lucide-react', '@/components'],
  },
}

module.exports = nextConfig
```

**Common barrel file offenders:**
- Icon libraries (lucide-react, @heroicons/react, react-icons)
- Date utilities (date-fns, dayjs with plugins)
- UI component libraries (internal component folders)
- Lodash (use lodash-es or direct imports)

Reference: [Package Bundling Optimization](https://nextjs.org/docs/app/guides/package-bundling)

### 2.3 Import Only What You Use from Libraries

**Impact: CRITICAL (Prevents 50-500KB of dead code per library, 2-5x smaller vendor chunks)**

Named imports from ESM-compatible libraries enable tree-shaking, but importing entire namespaces or using CommonJS patterns bundles everything. One careless import can add hundreds of kilobytes of unused code to your production build.

**Incorrect (imports prevent tree-shaking):**

```typescript
import * as lodash from 'lodash'
// Bundles entire 70KB library for one function

import Lodash from 'lodash'
const result = Lodash.debounce(handler, 300)
// Default import loads everything

import moment from 'moment'
// moment is not tree-shakeable, always loads 300KB+
```

**Correct (named imports enable tree-shaking):**

```typescript
import { debounce } from 'lodash-es'
// Only bundles debounce (~2KB) from ESM version

import debounce from 'lodash/debounce'
// Direct path import, guaranteed single function

import { format } from 'date-fns'
// date-fns is ESM, tree-shakes to only used functions
```

**Alternative (check bundle impact with analyzer):**

```typescript
// next.config.js
const withBundleAnalyzer = require('@next/bundle-analyzer')({
  enabled: process.env.ANALYZE === 'true',
})

module.exports = withBundleAnalyzer({
  // your config
})
```

```bash
ANALYZE=true npm run build
```

**Library substitutions for better tree-shaking:**
| Instead of | Use |
|------------|-----|
| `lodash` | `lodash-es` or direct imports |
| `moment` | `date-fns` or `dayjs` |
| `axios` | Native `fetch` |
| `uuid` | `crypto.randomUUID()` |
| `classnames` | `clsx` (smaller) |

**When NOT to apply:**
- Libraries that don't support ESM (check package.json for "module" field)
- When you genuinely use 50%+ of a library's exports

Reference: [Analyzing Bundle Size](https://nextjs.org/docs/app/guides/package-bundling#analyzing-javascript-bundles)

### 2.4 Keep 'use client' Boundaries as Leaf Nodes

**Impact: CRITICAL (Reduces client JS by 40-70%, prevents cascading bundle bloat from parent components)**

When you mark a component with `'use client'`, all its imports and children become part of the client bundle. Placing `'use client'` too high in the component tree pulls server-only code into the client, dramatically increasing bundle size.

**Incorrect (client boundary too high):**

```typescript
'use client'
// Everything below ships to the client: 150KB+ unnecessarily

import { useState } from 'react'
import UserProfile from './UserProfile'
import RecentOrders from './RecentOrders'
import ProductRecommendations from './ProductRecommendations'

export default function DashboardPage({ user }) {
  const [activeTab, setActiveTab] = useState('profile')

  return (
    <div>
      <TabSelector active={activeTab} onChange={setActiveTab} />
      {activeTab === 'profile' && <UserProfile user={user} />}
      {activeTab === 'orders' && <RecentOrders userId={user.id} />}
      {activeTab === 'recs' && <ProductRecommendations />}
    </div>
  )
}
```

**Correct (client boundary at leaf node):**

```typescript
// DashboardPage.tsx - Server Component (no directive)
import UserProfile from './UserProfile'
import RecentOrders from './RecentOrders'
import ProductRecommendations from './ProductRecommendations'
import DashboardTabs from './DashboardTabs'

export default function DashboardPage({ user }) {
  return (
    <DashboardTabs
      profileContent={<UserProfile user={user} />}
      ordersContent={<RecentOrders userId={user.id} />}
      recsContent={<ProductRecommendations />}
    />
  )
}
```

```typescript
// DashboardTabs.tsx - Only the interactive part is client
'use client'

import { useState } from 'react'

export default function DashboardTabs({ profileContent, ordersContent, recsContent }) {
  const [activeTab, setActiveTab] = useState('profile')

  return (
    <div>
      <TabSelector active={activeTab} onChange={setActiveTab} />
      {activeTab === 'profile' && profileContent}
      {activeTab === 'orders' && ordersContent}
      {activeTab === 'recs' && recsContent}
    </div>
  )
}
```

**Pattern: Extract interactivity into small client components:**
- Button click handlers -> `<InteractiveButton />`
- Form state -> `<FormWithValidation />`
- Tabs/accordions -> pass content as children or props
- Search with debounce -> `<SearchInput />`

Reference: [Server and Client Components](https://nextjs.org/docs/app/getting-started/server-and-client-components)

### 2.5 Use next/dynamic for Heavy Components

**Impact: CRITICAL (Reduces initial JS bundle by 30-70%, improves Time to Interactive by 500ms-2s)**

Heavy components like charts, editors, and maps add significant weight to your initial bundle. Using `next/dynamic` defers loading until the component is needed, drastically reducing Time to Interactive and improving Core Web Vitals.

**Incorrect (loads entire chart library upfront):**

```typescript
import AnalyticsDashboard from '@/components/AnalyticsDashboard'
import RichTextEditor from '@/components/RichTextEditor'
// 200KB+ added to initial bundle even if user never views these

export default function AdminPage() {
  return (
    <div>
      <AnalyticsDashboard />
      <RichTextEditor />
    </div>
  )
}
```

**Correct (lazy loads heavy components):**

```typescript
import dynamic from 'next/dynamic'

const AnalyticsDashboard = dynamic(
  () => import('@/components/AnalyticsDashboard'),
  { loading: () => <DashboardSkeleton /> }
)
const RichTextEditor = dynamic(
  () => import('@/components/RichTextEditor'),
  { loading: () => <EditorSkeleton /> }
)

export default function AdminPage() {
  return (
    <div>
      <AnalyticsDashboard />
      <RichTextEditor />
    </div>
  )
}
```

**Alternative (disable SSR for browser-only components):**

```typescript
const MapView = dynamic(() => import('@/components/MapView'), {
  ssr: false, // Component uses window/document APIs
  loading: () => <MapPlaceholder />,
})
```

**When to use dynamic imports:**
- Chart libraries (recharts, chart.js, d3)
- Rich text editors (tiptap, slate, draft-js)
- Map components (mapbox, leaflet, google-maps)
- PDF viewers and heavy media players
- Components behind user interaction (modals, drawers)

Reference: [Lazy Loading in Next.js](https://nextjs.org/docs/app/guides/lazy-loading)

---

## 3. Server Components

**Impact: HIGH**

RSC boundary placement and data flow patterns determine how much JavaScript ships to the client and when content becomes interactive.

### 3.1 Default to Server Components

**Impact: HIGH (reduces client JavaScript by 30-60%, improves TTI by eliminating hydration overhead)**

In Next.js 16 App Router, components are Server Components by default. Only add 'use client' when you need browser interactivity. Every unnecessary 'use client' directive ships component code plus its dependencies to the browser, bloating your bundle.

**Incorrect (unnecessary client directive):**

```tsx
'use client'  // Ships entire component + dependencies to browser

import { formatCurrency } from '@/lib/formatters'

export function ProductCard({ product }: { product: Product }) {
  return (
    <article className="product-card">
      <h2>{product.name}</h2>
      <p className="price">{formatCurrency(product.price)}</p>
      <p>{product.description}</p>
    </article>
  )
}
// formatCurrency library now in client bundle despite no interactivity
```

**Correct (server component by default):**

```tsx
// No directive - Server Component by default
import { formatCurrency } from '@/lib/formatters'

export function ProductCard({ product }: { product: Product }) {
  return (
    <article className="product-card">
      <h2>{product.name}</h2>
      <p className="price">{formatCurrency(product.price)}</p>
      <p>{product.description}</p>
    </article>
  )
}
// Renders on server, only HTML sent to client
```

**When 'use client' is required:**
- Using hooks (useState, useEffect, useContext, useReducer)
- Adding event handlers (onClick, onChange, onSubmit)
- Accessing browser APIs (window, document, localStorage)
- Using client-only libraries (animation libraries, date pickers)

Reference: [Server Components](https://nextjs.org/docs/app/building-your-application/rendering/server-components)

### 3.2 Fetch Data Where Needed Instead of Prop Drilling

**Impact: HIGH (simplifies component tree, enables parallel fetching, removes 3-5 layers of prop passing)**

With Server Components, fetch data directly in the component that needs it rather than passing props through multiple layers. React's fetch deduplication ensures you won't make redundant requests, and components become self-contained and easier to move around.

**Incorrect (prop drilling through component tree):**

```tsx
// app/dashboard/page.tsx
export default async function DashboardPage() {
  const user = await getUser()
  const notifications = await getNotifications(user.id)
  const projects = await getProjects(user.id)

  return (
    <DashboardLayout
      user={user}
      notifications={notifications}
      projects={projects}  // Drilled 3 levels deep
    />
  )
}

// components/dashboard-layout.tsx
function DashboardLayout({ user, notifications, projects }) {
  return (
    <div>
      <Header user={user} notifications={notifications} />
      <Sidebar projects={projects} />  // Just passing through
      <Content projects={projects} />
    </div>
  )
}

// components/sidebar.tsx
function Sidebar({ projects }) {
  return <ProjectList projects={projects} />  // Finally used
}
```

**Correct (fetch where data is used):**

```tsx
// app/dashboard/page.tsx
export default function DashboardPage() {
  return (
    <div className="dashboard">
      <Header />
      <Sidebar />
      <Content />
    </div>
  )
}

// components/header.tsx (Server Component)
export async function Header() {
  const user = await getUser()
  const notifications = await getNotifications(user.id)

  return (
    <header>
      <UserMenu user={user} />
      <NotificationBell notifications={notifications} />
    </header>
  )
}

// components/sidebar.tsx (Server Component)
export async function Sidebar() {
  const user = await getUser()  // Deduped - same request as Header
  const projects = await getProjects(user.id)

  return <ProjectList projects={projects} />
}
// Each component is self-contained and independently testable
```

**Benefits:**
- Components are self-contained and reusable
- Parallel data fetching (Header and Sidebar fetch simultaneously)
- Easier refactoring - move components without rewiring props
- Clearer data dependencies per component

Reference: [Data Fetching Patterns](https://nextjs.org/docs/app/building-your-application/data-fetching/patterns#fetching-data-where-its-needed)

### 3.3 Fetch Shared Data in Layouts

**Impact: HIGH (eliminates duplicate database queries, reduces server load by 40-70% for repeated data)**

Layouts persist across page navigations and wrap all child pages. Fetch data needed by multiple pages in the layout once, rather than duplicating fetches in each page. Next.js automatically deduplicates identical fetch requests, but explicit layout fetching is clearer and more maintainable.

**Incorrect (duplicated fetches in pages):**

```tsx
// app/dashboard/settings/page.tsx
export default async function SettingsPage() {
  const user = await getCurrentUser()  // Fetched here
  const subscription = await getSubscription(user.id)

  return <SettingsForm user={user} subscription={subscription} />
}

// app/dashboard/billing/page.tsx
export default async function BillingPage() {
  const user = await getCurrentUser()  // Fetched AGAIN
  const invoices = await getInvoices(user.id)

  return <BillingHistory user={user} invoices={invoices} />
}

// app/dashboard/profile/page.tsx
export default async function ProfilePage() {
  const user = await getCurrentUser()  // Fetched AGAIN
  return <ProfileEditor user={user} />
}
// getCurrentUser called 3 times across navigation
```

**Correct (shared data in layout):**

```tsx
// app/dashboard/layout.tsx
import { DashboardNav } from '@/components/dashboard-nav'

export default async function DashboardLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const user = await getCurrentUser()  // Fetched once for all dashboard pages

  return (
    <div className="dashboard">
      <DashboardNav user={user} />
      <main>{children}</main>
    </div>
  )
}

// app/dashboard/settings/page.tsx
export default async function SettingsPage() {
  const user = await getCurrentUser()  // Deduped with layout fetch
  const subscription = await getSubscription(user.id)

  return <SettingsForm user={user} subscription={subscription} />
}
```

**Alternative - React cache for request deduplication:**

```tsx
import { cache } from 'react'

export const getCurrentUser = cache(async () => {
  const session = await getSession()
  return db.user.findUnique({ where: { id: session.userId } })
})
// Same function called multiple times returns cached result within request
```

Reference: [Layouts and Data Fetching](https://nextjs.org/docs/app/building-your-application/routing/layouts-and-templates#layouts)

### 3.4 Pass Only Serializable Props to Client Components

**Impact: HIGH (prevents hydration errors and runtime crashes at the RSC boundary)**

Data crossing from Server Components to Client Components must be JSON-serializable. Functions, class instances, Dates, Maps, and Sets cannot be serialized and will cause runtime errors or hydration mismatches that are difficult to debug.

**Incorrect (non-serializable props):**

```tsx
// app/dashboard/page.tsx (Server Component)
import { DashboardClient } from './dashboard-client'

export default async function DashboardPage() {
  const analytics = await getAnalytics()

  return (
    <DashboardClient
      analytics={analytics}
      lastUpdated={analytics.timestamp}  // Date object - not serializable
      onRefresh={() => revalidatePath('/dashboard')}  // Function - cannot cross boundary
      metrics={new Map(analytics.metrics)}  // Map - not serializable
    />
  )
}
```

**Correct (serializable props only):**

```tsx
// app/dashboard/page.tsx (Server Component)
import { DashboardClient } from './dashboard-client'
import { refreshDashboard } from './actions'

export default async function DashboardPage() {
  const analytics = await getAnalytics()

  return (
    <DashboardClient
      analytics={{
        pageViews: analytics.pageViews,
        sessions: analytics.sessions,
        bounceRate: analytics.bounceRate,
      }}
      lastUpdated={analytics.timestamp.toISOString()}  // Serialize to string
      refreshAction={refreshDashboard}  // Server Actions are serializable references
      metrics={Object.fromEntries(analytics.metrics)}  // Convert to plain object
    />
  )
}
```

**Serializable types:**
- Primitives: string, number, bigint, boolean, null, undefined
- Plain objects and arrays containing serializable values
- Server Actions (passed as serialized references)
- Typed arrays (Uint8Array, etc.)

**Not serializable:**
- Functions (except Server Actions)
- Date, Map, Set, WeakMap, WeakSet
- Class instances, Symbols, circular references

Reference: [Passing Props from Server to Client](https://nextjs.org/docs/app/building-your-application/rendering/composition-patterns#passing-props-from-server-to-client-components-serialization)

### 3.5 Use Async/Await Directly in Server Components

**Impact: HIGH (eliminates useEffect waterfalls, enables streaming, removes client-side loading states)**

Server Components can be async functions, allowing direct await at the component level. This eliminates the useEffect + useState pattern that causes client-side waterfalls and flash of loading states. Data fetches complete before HTML is sent, improving perceived performance.

**Incorrect (client-side fetching pattern):**

```tsx
'use client'

import { useState, useEffect } from 'react'

export function UserProfile({ userId }: { userId: string }) {
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)  // Client sees loading spinner first

  useEffect(() => {
    fetch(`/api/users/${userId}`)
      .then(res => res.json())
      .then(data => {
        setUser(data)
        setLoading(false)
      })
  }, [userId])  // Fetch starts AFTER hydration - waterfall

  if (loading) return <ProfileSkeleton />
  return <div>{user?.name}</div>
}
```

**Correct (async Server Component):**

```tsx
// No 'use client' - Server Component
import { getUser } from '@/lib/db'

export async function UserProfile({ userId }: { userId: string }) {
  const user = await getUser(userId)  // Fetches during server render

  return (
    <div>
      <h1>{user.name}</h1>
      <p>{user.email}</p>
      <p>Member since {user.createdAt.toLocaleDateString()}</p>
    </div>
  )
}
// HTML arrives with data already rendered
```

**Benefits:**
- Data fetches on server, closer to data source (lower latency)
- No loading spinner flash - content streams as ready
- Direct database/API access without exposing endpoints
- Automatic request deduplication with fetch cache

**When to still use client fetching:**
- User-initiated actions (search as you type)
- Real-time data (WebSocket connections)
- Data that changes based on client state

Reference: [Data Fetching in Server Components](https://nextjs.org/docs/app/building-your-application/data-fetching/fetching)

### 3.6 Use server-only for Sensitive Code

**Impact: HIGH (prevents accidental exposure of API keys, database credentials, and business logic to client bundles)**

Mark modules containing sensitive logic with the `server-only` package to trigger a build-time error if accidentally imported into a Client Component. This prevents API keys, database connections, and proprietary algorithms from leaking into the client bundle.

**Incorrect (sensitive code without protection):**

```typescript
// lib/analytics.ts
const INTERNAL_API_KEY = process.env.ANALYTICS_SECRET_KEY

export async function trackRevenue(amount: number, userId: string) {
  await fetch('https://internal-analytics.company.com/track', {
    headers: { 'X-API-Key': INTERNAL_API_KEY },  // Could leak to client
    body: JSON.stringify({ amount, userId, timestamp: Date.now() }),
  })
}

export function calculateCommission(revenue: number): number {
  // Proprietary business logic - should stay server-side
  return revenue * 0.15 + Math.min(revenue * 0.05, 1000)
}
```

**Correct (protected with server-only):**

```typescript
// lib/analytics.ts
import 'server-only'  // Build error if imported in Client Component

const INTERNAL_API_KEY = process.env.ANALYTICS_SECRET_KEY

export async function trackRevenue(amount: number, userId: string) {
  await fetch('https://internal-analytics.company.com/track', {
    headers: { 'X-API-Key': INTERNAL_API_KEY },
    body: JSON.stringify({ amount, userId, timestamp: Date.now() }),
  })
}

export function calculateCommission(revenue: number): number {
  return revenue * 0.15 + Math.min(revenue * 0.05, 1000)
}
// Importing in 'use client' component now fails at build time
```

**Installation:**

```bash
npm install server-only
```

**When to use server-only:**
- Database connection modules
- API route handlers with secrets
- Payment processing logic
- Authentication/authorization helpers
- Proprietary algorithms

**Alternative - client-only package:**

```typescript
import 'client-only'  // Ensures module only runs in browser

export function useLocalStorage(key: string) {
  // Browser-only code that would crash on server
  return window.localStorage.getItem(key)
}
```

Reference: [server-only Package](https://nextjs.org/docs/app/building-your-application/rendering/composition-patterns#keeping-server-only-code-out-of-the-client-environment)

---

## 4. Caching Strategies

**Impact: HIGH**

Proper use of fetch caching, unstable_cache, and revalidation eliminates redundant requests and reduces server load.

### 4.1 Avoid Caching User-Specific or Frequently Changing Data

**Impact: HIGH (prevents serving stale/wrong data to users, eliminates cache poisoning and privacy leaks)**

Caching user-specific data can leak private information between users or serve stale personalized content. Similarly, caching frequently changing data like inventory counts or live prices leads to poor user experience and potential business logic errors.

**Incorrect (caching user-specific data):**

```typescript
// app/lib/user.ts
import { unstable_cache } from 'next/cache'
import { db } from '@/lib/db'

// DANGEROUS: User A's cart could be served to User B
export const getUserCart = unstable_cache(
  async (userId: string) => {
    const cart = await db.cart.findUnique({
      where: { userId },
      include: { items: true },
    })
    return cart
  },
  ['user-cart'],
  { revalidate: 60 }
)

// DANGEROUS: Caching personalized recommendations
export const getUserRecommendations = unstable_cache(
  async (userId: string) => {
    return db.recommendation.findMany({ where: { userId } })
  },
  ['recommendations'],
  { revalidate: 300 }
)
```

**Correct (opt out of caching for user-specific data):**

```typescript
// app/lib/user.ts
import { unstable_noStore } from 'next/cache'
import { db } from '@/lib/db'

export async function getUserCart(userId: string) {
  unstable_noStore() // Explicitly opt out of caching
  const cart = await db.cart.findUnique({
    where: { userId },
    include: { items: true },
  })
  return cart
}

export async function getUserRecommendations(userId: string) {
  unstable_noStore()
  return db.recommendation.findMany({ where: { userId } })
}
```

**Data that should NOT be cached:**

```typescript
// app/lib/inventory.ts
import { unstable_noStore } from 'next/cache'

// Real-time inventory - stale data causes overselling
export async function getProductStock(productId: string) {
  unstable_noStore()
  const response = await fetch(`/api/inventory/${productId}`, {
    cache: 'no-store', // Also set on fetch for clarity
  })
  return response.json()
}

// Live pricing - must reflect current market conditions
export async function getCurrentPrice(productId: string) {
  unstable_noStore()
  return fetch(`/api/pricing/${productId}`, { cache: 'no-store' })
}

// Session-dependent data
export async function getUserSession() {
  unstable_noStore()
  return getServerSession(authOptions)
}
```

**Separate cacheable from non-cacheable data:**

```typescript
// app/products/[id]/page.tsx
import { unstable_cache } from 'next/cache'
import { unstable_noStore } from 'next/cache'

// CACHEABLE: Product details rarely change
const getProductDetails = unstable_cache(
  async (productId: string) => ({
    name: await db.product.findUnique({ where: { id: productId } }),
  }),
  ['product-details'],
  { tags: ['products'], revalidate: 3600 }
)

// NOT CACHEABLE: Stock changes constantly
async function getProductStock(productId: string) {
  unstable_noStore()
  return db.inventory.findUnique({ where: { productId } })
}

export default async function ProductPage({ params }: { params: { id: string } }) {
  // Parallel fetch: cached product + fresh stock
  const [product, stock] = await Promise.all([
    getProductDetails(params.id),
    getProductStock(params.id),
  ])

  return <ProductView product={product} stock={stock} />
}
```

**Categories of data by cacheability:**

| Cache Aggressively | Cache Briefly | Never Cache |
|--------------------|---------------|-------------|
| Product catalog | Search results | User sessions |
| Static content | Trending items | Shopping carts |
| Category lists | Public counters | Payment info |
| Feature flags | API rate limits | Real-time inventory |

Reference: [Next.js unstable_noStore](https://nextjs.org/docs/app/api-reference/functions/unstable_noStore) | [Opting out of caching](https://nextjs.org/docs/app/building-your-application/caching#opting-out)

### 4.2 Use fetch Cache Options Appropriately

**Impact: HIGH (eliminates redundant API calls, reduces server load by 60-90% for cacheable data)**

Next.js extends the native `fetch` API with caching options that control how responses are stored and reused. Choosing the wrong cache option leads to either stale data or unnecessary network requests on every page load.

**Incorrect (default behavior without explicit cache strategy):**

```typescript
// app/lib/products.ts
export async function getProducts() {
  // No cache option - behavior varies between dev and production
  const response = await fetch('https://api.example.com/products')
  return response.json()
}

export async function getProductById(productId: string) {
  // Same issue - implicit caching behavior is unpredictable
  const response = await fetch(`https://api.example.com/products/${productId}`)
  return response.json()
}
```

**Correct (explicit cache strategy for each use case):**

```typescript
// app/lib/products.ts
export async function getProducts() {
  // Static catalog - cache aggressively, revalidate hourly
  const response = await fetch('https://api.example.com/products', {
    next: { revalidate: 3600 },
  })
  return response.json()
}

export async function getProductById(productId: string) {
  // Individual product - cache with tag for targeted invalidation
  const response = await fetch(`https://api.example.com/products/${productId}`, {
    next: { tags: [`product-${productId}`], revalidate: 3600 },
  })
  return response.json()
}
```

**Cache options reference:**

```typescript
// force-cache: Maximum caching, persists until manually invalidated
fetch(url, { cache: 'force-cache' })

// no-store: Always fetch fresh, bypasses all caching
fetch(url, { cache: 'no-store' })

// Time-based revalidation: Cache for N seconds
fetch(url, { next: { revalidate: 60 } })

// Tag-based: Cache with tags for on-demand invalidation
fetch(url, { next: { tags: ['products'] } })

// Combined: Tags with time-based fallback
fetch(url, { next: { tags: ['products'], revalidate: 3600 } })
```

**When to use each option:**

| Option | Use Case |
|--------|----------|
| `force-cache` | Truly static data (config, feature flags) |
| `no-store` | User-specific data, real-time prices |
| `revalidate: N` | Semi-static data (product catalog, blog posts) |
| `tags: [...]` | Data that changes on specific events |

Reference: [Next.js fetch caching](https://nextjs.org/docs/app/api-reference/functions/fetch)

### 4.3 Use React cache() for Request-Scoped Deduplication

**Impact: HIGH (eliminates duplicate database calls within a single request, reduces queries from N to 1 per render tree)**

When multiple Server Components in the same render tree need the same data, each component triggers a separate database query. React's `cache()` function deduplicates these calls within a single request, ensuring the expensive operation runs only once.

**Incorrect (duplicate queries in same request):**

```typescript
// app/lib/user.ts
import { db } from '@/lib/db'

export async function getCurrentUser() {
  // Called 5 times across components = 5 database queries
  const user = await db.user.findUnique({
    where: { id: getCurrentUserId() },
    include: { preferences: true },
  })
  return user
}

// app/components/Header.tsx - calls getCurrentUser()
// app/components/Sidebar.tsx - calls getCurrentUser()
// app/components/UserAvatar.tsx - calls getCurrentUser()
// app/products/page.tsx - calls getCurrentUser()
// app/components/CartIcon.tsx - calls getCurrentUser()
```

**Correct (deduplicated with React cache):**

```typescript
// app/lib/user.ts
import { cache } from 'react'
import { db } from '@/lib/db'

export const getCurrentUser = cache(async () => {
  // Called 5 times across components = 1 database query
  const user = await db.user.findUnique({
    where: { id: getCurrentUserId() },
    include: { preferences: true },
  })
  return user
})

// All components call getCurrentUser() freely
// React deduplicates within the same request
```

**With parameters:**

```typescript
// app/lib/products.ts
import { cache } from 'react'
import { db } from '@/lib/db'

// Memoized per unique productId within the same request
export const getProductById = cache(async (productId: string) => {
  const product = await db.product.findUnique({
    where: { id: productId },
    include: { category: true, images: true },
  })
  return product
})

// app/products/[id]/page.tsx
const product = await getProductById(params.id) // Query 1

// app/products/[id]/components/ProductDetails.tsx
const product = await getProductById(params.id) // Deduplicated - no query

// app/products/[id]/components/RelatedProducts.tsx
const product = await getProductById(params.id) // Deduplicated - no query
```

**Combine with unstable_cache for cross-request caching:**

```typescript
// app/lib/products.ts
import { cache } from 'react'
import { unstable_cache } from 'next/cache'
import { db } from '@/lib/db'

// Inner: Cross-request cache (persists between requests)
const getCachedProduct = unstable_cache(
  async (productId: string) => {
    return db.product.findUnique({ where: { id: productId } })
  },
  ['product'],
  { tags: ['products'], revalidate: 3600 }
)

// Outer: Request-scoped deduplication (within single render)
export const getProductById = cache(async (productId: string) => {
  return getCachedProduct(productId)
})
```

**When to use each caching layer:**

| Layer | Scope | Purpose |
|-------|-------|---------|
| `cache()` | Single request | Deduplicate calls across component tree |
| `unstable_cache` | Cross-request | Persist data between different requests |
| `fetch` cache | Cross-request | Cache HTTP responses |

**Note:** `fetch` GET requests are automatically deduplicated within a request. Use `cache()` for database queries, ORM calls, and other non-fetch data sources.

Reference: [React cache](https://react.dev/reference/react/cache) | [Next.js Request Memoization](https://nextjs.org/docs/app/building-your-application/caching#request-memoization)

### 4.4 Use revalidatePath and revalidateTag for On-Demand Revalidation

**Impact: HIGH (ensures instant cache updates after mutations, eliminates stale data without sacrificing cache benefits)**

Time-based revalidation alone causes stale data after mutations. When a user updates a product, they expect to see changes immediately - not after the revalidation window expires. On-demand revalidation invalidates specific cache entries the moment data changes.

**Incorrect (no revalidation after mutation):**

```typescript
// app/actions/products.ts
'use server'

import { db } from '@/lib/db'

export async function updateProduct(productId: string, formData: FormData) {
  const name = formData.get('name') as string
  const price = parseFloat(formData.get('price') as string)

  await db.product.update({
    where: { id: productId },
    data: { name, price },
  })
  // Cache still serves stale data until time-based revalidation triggers
  return { success: true }
}
```

**Correct (on-demand revalidation after mutation):**

```typescript
// app/actions/products.ts
'use server'

import { revalidatePath, revalidateTag } from 'next/cache'
import { db } from '@/lib/db'

export async function updateProduct(productId: string, formData: FormData) {
  const name = formData.get('name') as string
  const price = parseFloat(formData.get('price') as string)

  await db.product.update({
    where: { id: productId },
    data: { name, price },
  })

  // Invalidate specific product and product list caches
  revalidateTag(`product-${productId}`)
  revalidateTag('products')

  return { success: true }
}
```

**Choose the right revalidation method:**

```typescript
'use server'

import { revalidatePath, revalidateTag } from 'next/cache'

// revalidatePath: Invalidate all cached data for a specific route
export async function createProduct(formData: FormData) {
  await db.product.create({ data: { /* ... */ } })

  // Revalidates /products page and all its data
  revalidatePath('/products')

  // Can also revalidate dynamic routes
  revalidatePath('/products/[id]', 'page')

  // Or entire layouts
  revalidatePath('/products', 'layout')
}

// revalidateTag: Surgical invalidation of tagged data only
export async function updateProductPrice(productId: string, price: number) {
  await db.product.update({
    where: { id: productId },
    data: { price },
  })

  // Only invalidates fetch/unstable_cache calls tagged with this
  revalidateTag(`product-${productId}`)
}
```

**Tag your data sources for targeted invalidation:**

```typescript
// app/lib/products.ts
import { unstable_cache } from 'next/cache'

// Tag cache entries for surgical revalidation
export const getProductById = (productId: string) =>
  unstable_cache(
    async () => db.product.findUnique({ where: { id: productId } }),
    [`product-${productId}`],
    { tags: [`product-${productId}`, 'products'] } // Multiple tags
  )()

// Fetch with tags
export async function getProductReviews(productId: string) {
  const response = await fetch(`/api/products/${productId}/reviews`, {
    next: { tags: [`product-${productId}-reviews`, 'reviews'] },
  })
  return response.json()
}
```

**Benefits of tag-based over path-based:**

| Approach | Scope | Use When |
|----------|-------|----------|
| `revalidatePath` | All data on a route | Page structure changed, layout update |
| `revalidateTag` | Only tagged data | Specific entity updated, surgical invalidation |

Reference: [Next.js revalidatePath](https://nextjs.org/docs/app/api-reference/functions/revalidatePath) | [revalidateTag](https://nextjs.org/docs/app/api-reference/functions/revalidateTag)

### 4.5 Use unstable_cache for Non-Fetch Data Sources

**Impact: HIGH (reduces database queries by 80-95% for repeated reads, cuts response time from 200ms to 5ms)**

The `fetch` cache only works with HTTP requests. Database queries, ORM calls, and other data sources bypass Next.js caching entirely unless wrapped with `unstable_cache`. Without it, every page render triggers a fresh database query.

**Incorrect (uncached database queries):**

```typescript
// app/lib/products.ts
import { db } from '@/lib/db'

export async function getProducts() {
  // Hits database on EVERY request - no caching
  const products = await db.product.findMany({
    where: { status: 'active' },
    orderBy: { createdAt: 'desc' },
  })
  return products
}

export async function getProductById(productId: string) {
  // Another uncached query - multiplies DB load under traffic
  const product = await db.product.findUnique({
    where: { id: productId },
  })
  return product
}
```

**Correct (cached with unstable_cache):**

```typescript
// app/lib/products.ts
import { unstable_cache } from 'next/cache'
import { db } from '@/lib/db'

export const getProducts = unstable_cache(
  async () => {
    const products = await db.product.findMany({
      where: { status: 'active' },
      orderBy: { createdAt: 'desc' },
    })
    return products
  },
  ['products-list'],
  { tags: ['products'], revalidate: 3600 }
)

export const getProductById = unstable_cache(
  async (productId: string) => {
    const product = await db.product.findUnique({
      where: { id: productId },
    })
    return product
  },
  ['product-detail'],
  { tags: ['products'], revalidate: 3600 }
)
```

**With dynamic cache keys:**

```typescript
// app/lib/products.ts
import { unstable_cache } from 'next/cache'
import { db } from '@/lib/db'

// Cache key includes the productId for separate cache entries
export const getProductById = (productId: string) =>
  unstable_cache(
    async () => {
      const product = await db.product.findUnique({
        where: { id: productId },
        include: { category: true, reviews: true },
      })
      return product
    },
    [`product-${productId}`],
    { tags: [`product-${productId}`, 'products'], revalidate: 3600 }
  )()

// Usage in Server Component
const product = await getProductById('prod_123')
```

**When NOT to use:**

- User-specific data (use `unstable_noStore` instead)
- Real-time data requiring sub-second freshness
- Data with complex invalidation requirements

```typescript
import { unstable_noStore } from 'next/cache'

export async function getUserCart(userId: string) {
  unstable_noStore() // Opt out of caching for user-specific data
  return db.cart.findUnique({ where: { userId } })
}
```

Reference: [Next.js unstable_cache](https://nextjs.org/docs/app/api-reference/functions/unstable_cache)

---

## 5. Rendering Patterns

**Impact: MEDIUM**

Choosing static vs dynamic rendering and using generateStaticParams affects Time to First Byte and edge cacheability.

### 5.1 Avoid force-dynamic Unless Necessary

**Impact: MEDIUM (prevents unnecessary server load, each dynamic request costs 50-500ms vs cached static)**

Setting `dynamic = 'force-dynamic'` disables all caching and renders every request on the server. This is rarely needed—most "dynamic" use cases can be solved with ISR, on-demand revalidation, or isolating dynamic parts with Suspense.

**Incorrect (force-dynamic for cacheable content):**

```typescript
// app/products/page.tsx
export const dynamic = 'force-dynamic'  // Every request hits the server

export default async function ProductsPage() {
  const products = await fetchProducts()
  // Products only change when inventory updates, not per-request
  return <ProductGrid products={products} />
}
```

**Correct (ISR with on-demand revalidation):**

```typescript
// app/products/page.tsx
export const revalidate = 300  // Cache for 5 minutes

export default async function ProductsPage() {
  const products = await fetchProducts()
  return <ProductGrid products={products} />
}

// app/api/revalidate/route.ts - trigger when inventory changes
import { revalidatePath } from 'next/cache'

export async function POST() {
  revalidatePath('/products')
  return Response.json({ revalidated: true })
}
```

**When force-dynamic is appropriate:**

```typescript
// Real-time stock trading data that must never be stale
export const dynamic = 'force-dynamic'

export default async function LiveTicker() {
  const prices = await fetchLiveStockPrices()
  return <StockTicker prices={prices} />
}
```

**Alternative: Isolate dynamic parts with Suspense:**

```typescript
// Static shell + dynamic user section
export default function ProductsPage() {
  return (
    <>
      <StaticProductGrid />
      <Suspense fallback={<CartSkeleton />}>
        <UserCart />  {/* Only this part is dynamic */}
      </Suspense>
    </>
  )
}
```

Reference: [Dynamic Rendering](https://nextjs.org/docs/app/building-your-application/rendering/server-components#dynamic-rendering)

### 5.2 Combine Streaming with Dynamic Rendering

**Impact: MEDIUM (reduces perceived load time by 40-60% by showing content progressively)**

When dynamic rendering is unavoidable, use Suspense boundaries to stream content progressively. This sends the static shell immediately while dynamic parts load, dramatically improving perceived performance.

**Incorrect (blocking dynamic render):**

```typescript
// app/dashboard/page.tsx
export default async function DashboardPage() {
  // User sees nothing until ALL data loads
  const analytics = await fetchAnalytics()
  const notifications = await fetchNotifications()
  const recommendations = await fetchRecommendations()

  return (
    <div>
      <AnalyticsPanel data={analytics} />
      <NotificationList items={notifications} />
      <RecommendationFeed items={recommendations} />
    </div>
  )
}
```

**Correct (streaming with Suspense):**

```typescript
// app/dashboard/page.tsx
import { Suspense } from 'react'

export default function DashboardPage() {
  return (
    <div>
      {/* Static header sent immediately */}
      <DashboardHeader />

      <Suspense fallback={<AnalyticsSkeleton />}>
        <AnalyticsPanel />
      </Suspense>

      <Suspense fallback={<NotificationSkeleton />}>
        <NotificationList />
      </Suspense>

      <Suspense fallback={<RecommendationSkeleton />}>
        <RecommendationFeed />
      </Suspense>
    </div>
  )
}

// Each component fetches its own data
async function AnalyticsPanel() {
  const analytics = await fetchAnalytics()
  return <AnalyticsView data={analytics} />
}
```

**Benefits of streaming:**

- Static shell (header, navigation) appears instantly
- Each section loads independently as data arrives
- Slow APIs don't block fast ones
- Users can interact with loaded sections immediately

**Use loading.tsx for route-level streaming:**

```typescript
// app/dashboard/loading.tsx
export default function DashboardLoading() {
  return <DashboardSkeleton />
}

// Automatically wraps page.tsx in Suspense
```

Reference: [Streaming with Suspense](https://nextjs.org/docs/app/building-your-application/routing/loading-ui-and-streaming)

### 5.3 Default to Static Rendering

**Impact: MEDIUM (enables edge caching and reduces TTFB by 50-200ms per request)**

Static rendering generates HTML at build time, allowing responses to be cached at the edge and served instantly. Dynamic rendering should be an explicit opt-in only when you need request-specific data like cookies, headers, or search params.

**Incorrect (unnecessary dynamic rendering):**

```typescript
// app/products/[slug]/page.tsx
import { headers } from 'next/headers'

export default async function ProductPage({
  params,
}: {
  params: Promise<{ slug: string }>
}) {
  const { slug } = await params
  // Calling headers() makes entire route dynamic even if not needed
  const headersList = await headers()
  const product = await fetchProduct(slug)

  return <ProductDetails product={product} />
}
```

**Correct (static by default):**

```typescript
// app/products/[slug]/page.tsx
export default async function ProductPage({
  params,
}: {
  params: Promise<{ slug: string }>
}) {
  const { slug } = await params
  const product = await fetchProduct(slug)

  return <ProductDetails product={product} />
}

// Explicitly generate static pages at build time
export async function generateStaticParams() {
  const products = await fetchAllProducts()
  return products.map((product) => ({ slug: product.slug }))
}
```

**When dynamic rendering is appropriate:**

- User-specific content (cookies for auth, preferences)
- Real-time data that cannot be stale (stock prices, inventory)
- Search results based on query parameters

Reference: [Static and Dynamic Rendering](https://nextjs.org/docs/app/building-your-application/rendering/server-components#static-rendering-default)

### 5.4 Use generateStaticParams for Dynamic Routes

**Impact: MEDIUM (pre-renders pages at build time, reducing TTFB from 200-500ms to <50ms)**

The `generateStaticParams` function tells Next.js which dynamic route segments to pre-render at build time. Without it, dynamic routes render on-demand, adding server processing time to each request.

**Incorrect (on-demand rendering for every request):**

```typescript
// app/blog/[slug]/page.tsx
export default async function BlogPost({
  params,
}: {
  params: Promise<{ slug: string }>
}) {
  const { slug } = await params
  // Every request triggers server-side rendering
  const post = await fetchPost(slug)

  return <Article post={post} />
}
```

**Correct (pre-rendered at build time):**

```typescript
// app/blog/[slug]/page.tsx
export default async function BlogPost({
  params,
}: {
  params: Promise<{ slug: string }>
}) {
  const { slug } = await params
  const post = await fetchPost(slug)

  return <Article post={post} />
}

export async function generateStaticParams() {
  const posts = await fetchAllPosts()
  return posts.map((post) => ({ slug: post.slug }))
}
```

**Partial pre-rendering for large datasets:**

```typescript
export async function generateStaticParams() {
  const posts = await fetchAllPosts()
  // Pre-render only the most popular posts, others render on-demand
  return posts.slice(0, 100).map((post) => ({ slug: post.slug }))
}
```

**Control fallback behavior:**

```typescript
// Return 404 for non-pre-rendered paths instead of on-demand rendering
export const dynamicParams = false

export async function generateStaticParams() {
  const posts = await fetchAllPosts()
  return posts.map((post) => ({ slug: post.slug }))
}
```

Reference: [generateStaticParams](https://nextjs.org/docs/app/api-reference/functions/generate-static-params)

### 5.5 Use Segment Config Options Appropriately

**Impact: MEDIUM (controls caching behavior, enables ISR with revalidate periods of seconds to hours)**

Segment configuration exports (`dynamic`, `revalidate`, `fetchCache`) provide fine-grained control over rendering and caching behavior. Use them intentionally to balance freshness with performance.

**Incorrect (mixing conflicting configurations):**

```typescript
// app/dashboard/page.tsx
export const dynamic = 'force-dynamic'
export const revalidate = 3600  // Conflicting: revalidate ignored with force-dynamic

export default async function Dashboard() {
  const stats = await fetchDashboardStats()
  return <DashboardView stats={stats} />
}
```

**Correct (coherent ISR configuration):**

```typescript
// app/dashboard/page.tsx
export const revalidate = 60  // Regenerate at most every 60 seconds

export default async function Dashboard() {
  const stats = await fetchDashboardStats()
  return <DashboardView stats={stats} />
}
```

**Common segment config patterns:**

```typescript
// Static page, never revalidate (default)
export const dynamic = 'force-static'

// ISR: revalidate every hour
export const revalidate = 3600

// Always fresh, no caching
export const dynamic = 'force-dynamic'

// Error if dynamic APIs used (catch accidental dynamic rendering)
export const dynamic = 'error'
```

**When to use each option:**

| Config | Use Case |
|--------|----------|
| `revalidate = N` | Content updates periodically (blog, products) |
| `force-static` | Ensure static even with dynamic-looking code |
| `dynamic = 'error'` | Catch accidental dynamic API usage in CI |

Reference: [Route Segment Config](https://nextjs.org/docs/app/api-reference/file-conventions/route-segment-config)

---

## 6. Route Architecture

**Impact: MEDIUM**

Layout composition, parallel routes, and Link prefetching strategies impact navigation performance and code organization.

### 6.1 Use Layouts for Persistent UI

**Impact: MEDIUM (eliminates re-renders of shared UI on navigation)**

Layouts wrap child routes and persist across navigation - they don't re-render or lose state when navigating between sibling routes. Place navigation, sidebars, and other shared UI in layouts to avoid unnecessary re-renders and preserve component state.

**Incorrect (shared UI in page causes re-render on navigation):**

```tsx
// app/dashboard/page.tsx
export default function DashboardPage() {
  return (
    <div>
      <Sidebar />           {/* Re-renders on every navigation */}
      <Navigation />        {/* Re-renders, loses hover/focus state */}
      <DashboardContent />
    </div>
  )
}

// app/settings/page.tsx
export default function SettingsPage() {
  return (
    <div>
      <Sidebar />           {/* Duplicate component, re-mounts */}
      <Navigation />        {/* Loses state from dashboard page */}
      <SettingsContent />
    </div>
  )
}
// Navigation between pages re-renders entire component tree
```

**Correct (layout preserves shared UI):**

```tsx
// app/(app)/layout.tsx
export default function AppLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="app-shell">
      <Sidebar />       {/* Renders once, persists across navigation */}
      <Navigation />    {/* State preserved during route changes */}
      <main>{children}</main>
    </div>
  )
}

// app/(app)/dashboard/page.tsx
export default function DashboardPage() {
  return <DashboardContent />
}

// app/(app)/settings/page.tsx
export default function SettingsPage() {
  return <SettingsContent />
}
// Only page content re-renders; layout components maintain state
```

**With stateful layout components:**

```tsx
// app/(app)/layout.tsx
export default function AppLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="app-shell">
      <CollapsibleSidebar />  {/* Collapse state persists */}
      <main>
        <SearchBar />         {/* Search input value persists */}
        {children}
      </main>
    </div>
  )
}
// User's UI preferences survive navigation
```

**Nested layouts for granular persistence:**

```tsx
// app/(app)/dashboard/layout.tsx
export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  return (
    <>
      <DashboardTabs />  {/* Persists only within /dashboard/* routes */}
      {children}
    </>
  )
}
// Tab selection state preserved when navigating between dashboard sub-pages
```

**When NOT to use layouts:**
- UI that should refresh on navigation (notification counts)
- Content that varies based on specific page data
- Components that should re-fetch data on every visit

Reference: [Layouts and Templates](https://nextjs.org/docs/app/building-your-application/routing/layouts-and-templates)

### 6.2 Use next/link for Client-Side Navigation

**Impact: MEDIUM (instant navigation with automatic prefetching)**

The Link component enables client-side navigation without full page reloads. It automatically prefetches linked pages in the viewport, making subsequent navigation feel instant. Using anchor tags forces a full page reload, losing client state and re-downloading assets.

**Incorrect (anchor tag causes full page reload):**

```tsx
export function NavigationMenu() {
  return (
    <nav>
      <a href="/dashboard">Dashboard</a>  {/* Full reload, loses state */}
      <a href="/settings">Settings</a>
      <a href="/analytics">Analytics</a>
    </nav>
  )
}
// Each click reloads entire page, re-executes JavaScript, resets scroll
```

**Correct (Link enables instant navigation):**

```tsx
import Link from 'next/link'

export function NavigationMenu() {
  return (
    <nav>
      <Link href="/dashboard">Dashboard</Link>
      <Link href="/settings">Settings</Link>
      <Link href="/analytics">Analytics</Link>
    </nav>
  )
}
// Client-side navigation preserves state, prefetched pages load instantly
```

**With prefetch control for less critical links:**

```tsx
import Link from 'next/link'

export function NavigationMenu() {
  return (
    <nav>
      <Link href="/dashboard">Dashboard</Link>
      <Link href="/settings" prefetch={false}>Settings</Link>  {/* Less visited */}
      <Link href="/admin" prefetch={false}>Admin</Link>  {/* Rarely used */}
    </nav>
  )
}
// Disable prefetch for infrequently visited pages to save bandwidth
```

**When to use anchor tags:**
- External links to other domains
- Download links with the download attribute
- Links that intentionally need a full reload

Reference: [Link Component](https://nextjs.org/docs/app/api-reference/components/link)

### 6.3 Use not-found.tsx for Proper 404 Handling

**Impact: MEDIUM (prevents SEO penalties from incorrect 500 error responses)**

Use `not-found.tsx` files and the `notFound()` function to handle missing resources gracefully. This returns proper 404 HTTP status codes for SEO, provides user-friendly error pages, and can be customized per route segment.

**Incorrect (throwing errors or redirecting on missing data):**

```tsx
// app/products/[slug]/page.tsx
export default async function ProductPage({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params
  const product = await fetchProduct(slug)

  if (!product) {
    throw new Error('Product not found')  // Returns 500, not 404
  }

  return <ProductDetails product={product} />
}
// Search engines see 500 error, bad for SEO and user experience
```

**Correct (notFound() returns proper 404):**

```tsx
import { notFound } from 'next/navigation'

// app/products/[slug]/page.tsx
export default async function ProductPage({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params
  const product = await fetchProduct(slug)

  if (!product) {
    notFound()  // Returns 404 status, renders not-found.tsx
  }

  return <ProductDetails product={product} />
}
```

```tsx
// app/products/[slug]/not-found.tsx
export default function ProductNotFound() {
  return (
    <div className="not-found">
      <h1>Product Not Found</h1>
      <p>The product you're looking for doesn't exist or has been removed.</p>
      <Link href="/products">Browse all products</Link>
    </div>
  )
}
// Context-specific 404 page with relevant navigation
```

**Root-level not-found for global fallback:**

```tsx
// app/not-found.tsx
import Link from 'next/link'

export default function GlobalNotFound() {
  return (
    <div className="not-found">
      <h1>Page Not Found</h1>
      <p>We couldn't find what you were looking for.</p>
      <Link href="/">Return home</Link>
    </div>
  )
}
// Catches all unmatched routes application-wide
```

**With metadata for SEO:**

```tsx
// app/not-found.tsx
import { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'Page Not Found',
  robots: { index: false },  // Don't index 404 pages
}

export default function GlobalNotFound() {
  return (
    <div className="not-found">
      <h1>404 - Page Not Found</h1>
      <p>This page doesn't exist.</p>
    </div>
  )
}
```

**Segment-specific not-found pages:**

```text
app/
├── not-found.tsx                    # Global fallback
├── products/
│   └── [slug]/
│       └── not-found.tsx            # Product-specific 404
├── users/
│   └── [id]/
│       └── not-found.tsx            # User-specific 404
└── blog/
    └── [slug]/
        └── not-found.tsx            # Article-specific 404
```

Reference: [not-found.js](https://nextjs.org/docs/app/api-reference/file-conventions/not-found)

### 6.4 Use Parallel Routes for Simultaneous Rendering

**Impact: MEDIUM (2-5× faster perceived load with independent streaming)**

Parallel routes use the `@slot` folder convention to render multiple pages simultaneously in the same layout. Each slot loads independently with its own loading and error states. This is ideal for dashboards, split views, and modal patterns.

**Incorrect (sequential component loading in single page):**

```tsx
// app/dashboard/page.tsx
export default async function DashboardPage() {
  const metrics = await fetchMetrics()     // Waits for metrics
  const activity = await fetchActivity()   // Then waits for activity
  const notifications = await fetchNotifications()  // Then waits for notifications

  return (
    <div className="dashboard-grid">
      <MetricsPanel data={metrics} />
      <ActivityFeed data={activity} />
      <NotificationsList data={notifications} />
    </div>
  )
}
// Total time = sum of all fetch times, single loading state for entire page
```

**Correct (parallel routes with independent loading):**

```text
app/dashboard/
├── layout.tsx
├── page.tsx
├── @metrics/
│   ├── page.tsx
│   └── loading.tsx              # Independent skeleton
├── @activity/
│   ├── page.tsx
│   └── loading.tsx
└── @notifications/
    ├── page.tsx
    └── loading.tsx
```

```tsx
// app/dashboard/layout.tsx
export default function DashboardLayout({
  children,
  metrics,
  activity,
  notifications,
}: {
  children: React.ReactNode
  metrics: React.ReactNode
  activity: React.ReactNode
  notifications: React.ReactNode
}) {
  return (
    <div className="dashboard-grid">
      {metrics}        {/* Streams independently */}
      {activity}       {/* Streams independently */}
      {notifications}  {/* Streams independently */}
      {children}
    </div>
  )
}
// Each slot renders as soon as its data arrives
```

```tsx
// app/dashboard/@metrics/page.tsx
export default async function MetricsSlot() {
  const metrics = await fetchMetrics()
  return <MetricsPanel data={metrics} />
}
// Isolated fetching - doesn't block other slots
```

**With conditional slot rendering:**

```tsx
// app/dashboard/layout.tsx
export default function DashboardLayout({
  children,
  modal,
}: {
  children: React.ReactNode
  modal: React.ReactNode
}) {
  return (
    <>
      {children}
      {modal}  {/* Rendered alongside children when route matches */}
    </>
  )
}
// Modal slot renders when navigating to /dashboard/settings as intercepted route
```

**When to use parallel routes:**
- Dashboard panels that load different data
- Split-screen or multi-pane layouts
- Modal overlays that preserve background content
- Conditional content based on authentication state

Reference: [Parallel Routes](https://nextjs.org/docs/app/building-your-application/routing/parallel-routes)

### 6.5 Use Route Groups for Organization

**Impact: MEDIUM (enables separate layouts without URL nesting overhead)**

Route groups use parentheses syntax `(groupName)` to organize routes logically without affecting the URL structure. This enables separate layouts for different sections, team-based code organization, and cleaner folder hierarchies without polluting URLs.

**Incorrect (flat structure creates organizational chaos):**

```text
app/
├── marketing-home/page.tsx        # URL: /marketing-home - ugly
├── marketing-about/page.tsx       # URL: /marketing-about
├── marketing-pricing/page.tsx
├── app-dashboard/page.tsx         # URL: /app-dashboard - redundant
├── app-settings/page.tsx
├── app-analytics/page.tsx
└── layout.tsx                     # One layout for everything
```

**Correct (route groups organize without URL impact):**

```text
app/
├── (marketing)/
│   ├── layout.tsx                 # Marketing layout with hero nav
│   ├── page.tsx                   # URL: /
│   ├── about/page.tsx             # URL: /about
│   └── pricing/page.tsx           # URL: /pricing
├── (app)/
│   ├── layout.tsx                 # App layout with sidebar
│   ├── dashboard/page.tsx         # URL: /dashboard
│   ├── settings/page.tsx          # URL: /settings
│   └── analytics/page.tsx         # URL: /analytics
└── layout.tsx                     # Root layout
```

**Multiple root layouts for different experiences:**

```tsx
// app/(marketing)/layout.tsx
export default function MarketingLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <MarketingHeader />
        {children}
        <MarketingFooter />
      </body>
    </html>
  )
}

// app/(app)/layout.tsx
export default function AppLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <Sidebar />
        <main>{children}</main>
      </body>
    </html>
  )
}
// Each section has completely different chrome, sharing no layout code
```

**Benefits:**
- Clean URLs without organizational prefixes
- Different layouts per section without route nesting
- Team-based folder ownership (marketing team owns `(marketing)/`)
- Easier refactoring since URLs are decoupled from folder names

Reference: [Route Groups](https://nextjs.org/docs/app/building-your-application/routing/route-groups)

---

## 7. Client Components

**Impact: MEDIUM**

Hydration boundary placement, state management patterns, and event handlers affect client-side interactivity and bundle size.

### 7.1 Prefer useEffect Over useLayoutEffect

**Impact: MEDIUM (prevents blocking browser paint, improving perceived performance by 50-100ms)**

useLayoutEffect runs synchronously after DOM mutations but before the browser paints, blocking visual updates. Most effects like data fetching, subscriptions, and analytics do not need synchronous DOM measurement and should use useEffect to allow the browser to paint first.

**Incorrect (blocks paint unnecessarily):**

```tsx
'use client'

import { useLayoutEffect, useState } from 'react'

export function NotificationBanner({ message }: { message: string }) {
  const [isVisible, setIsVisible] = useState(true)

  useLayoutEffect(() => {
    // Analytics tracking doesn't need DOM measurements
    // Blocks paint for no benefit
    trackBannerView(message)

    const timer = setTimeout(() => {
      setIsVisible(false)
    }, 5000)

    return () => clearTimeout(timer)
  }, [message])

  if (!isVisible) return null

  return <div className="banner">{message}</div>
}
```

**Correct (allows paint before effect):**

```tsx
'use client'

import { useEffect, useState } from 'react'

export function NotificationBanner({ message }: { message: string }) {
  const [isVisible, setIsVisible] = useState(true)

  useEffect(() => {
    // Browser paints banner immediately, then runs effect
    trackBannerView(message)

    const timer = setTimeout(() => {
      setIsVisible(false)
    }, 5000)

    return () => clearTimeout(timer)
  }, [message])

  if (!isVisible) return null

  return <div className="banner">{message}</div>
}
```

**When useLayoutEffect IS appropriate:**

```tsx
'use client'

import { useLayoutEffect, useRef, useState } from 'react'

export function Tooltip({ children, content }: TooltipProps) {
  const triggerRef = useRef<HTMLDivElement>(null)
  const [position, setPosition] = useState({ top: 0, left: 0 })

  useLayoutEffect(() => {
    // DOM measurement needed before paint to prevent flicker
    if (triggerRef.current) {
      const rect = triggerRef.current.getBoundingClientRect()
      setPosition({
        top: rect.bottom + 8,
        left: rect.left + rect.width / 2,
      })
    }
  }, [])

  return (
    <>
      <div ref={triggerRef}>{children}</div>
      <div style={{ position: 'fixed', ...position }}>{content}</div>
    </>
  )
}
```

**When to use useLayoutEffect:**
- Measuring DOM elements before displaying dependent UI
- Preventing visual flicker when position depends on measurements
- Synchronizing with third-party DOM libraries

Reference: [React useLayoutEffect](https://react.dev/reference/react/useLayoutEffect)

### 7.2 Push use client to Leaf Components

**Impact: MEDIUM (reduces hydration JS by 30-50% by keeping parent trees server-rendered)**

Placing 'use client' on wrapper components forces the entire subtree to become client components, even children that need no interactivity. Moving the boundary to leaf components keeps maximum code server-rendered and reduces JavaScript shipped to the browser.

**Incorrect (client boundary too high):**

```tsx
'use client'
// Entire ProductPage becomes client component including static content

import { useState } from 'react'

export function ProductPage({ product }: { product: Product }) {
  const [quantity, setQuantity] = useState(1)

  return (
    <div>
      <h1>{product.name}</h1>
      <p>{product.description}</p>
      <ProductSpecs specs={product.specs} />
      <ReviewsList reviews={product.reviews} />
      {/* Only this small section needs interactivity */}
      <div>
        <input
          type="number"
          value={quantity}
          onChange={(e) => setQuantity(Number(e.target.value))}
        />
        <button>Add to Cart</button>
      </div>
    </div>
  )
}
```

**Correct (client boundary at leaf):**

```tsx
import { QuantitySelector } from './QuantitySelector'

export function ProductPage({ product }: { product: Product }) {
  return (
    <div>
      <h1>{product.name}</h1>
      <p>{product.description}</p>
      <ProductSpecs specs={product.specs} />
      <ReviewsList reviews={product.reviews} />
      <QuantitySelector productId={product.id} />
    </div>
  )
}
```

```tsx
'use client'
// Only this small component ships as client JS

import { useState } from 'react'

export function QuantitySelector({ productId }: { productId: string }) {
  const [quantity, setQuantity] = useState(1)

  return (
    <div>
      <input
        type="number"
        value={quantity}
        onChange={(e) => setQuantity(Number(e.target.value))}
      />
      <button>Add to Cart</button>
    </div>
  )
}
```

**When NOT to use:** When the entire component tree genuinely requires client-side state or effects, a higher boundary reduces prop drilling complexity.

Reference: [Next.js Client Components](https://nextjs.org/docs/app/building-your-application/rendering/client-components#moving-client-components-down-the-tree)

### 7.3 Use URL State for Shareable Application State

**Impact: MEDIUM (enables shareable links, browser history, and server-side rendering of filtered views)**

Filter states, pagination, and view modes stored in useState are lost on page refresh and cannot be shared via URL. Using URL search params makes state bookmarkable, shareable, and enables server-side rendering of the filtered view.

**Incorrect (state lost on refresh):**

```tsx
'use client'

import { useState } from 'react'

export function ProductFilters({ products }: { products: Product[] }) {
  const [category, setCategory] = useState<string>('all')
  const [sortBy, setSortBy] = useState<string>('price')
  const [page, setPage] = useState(1)
  // State lost on refresh, users can't share filtered results

  const filteredProducts = filterProducts(products, { category, sortBy, page })

  return (
    <div>
      <select value={category} onChange={(e) => setCategory(e.target.value)}>
        <option value="all">All Categories</option>
        <option value="electronics">Electronics</option>
      </select>
      <ProductGrid products={filteredProducts} />
      <Pagination current={page} onChange={setPage} />
    </div>
  )
}
```

**Correct (state persisted in URL):**

```tsx
'use client'

import { useSearchParams, useRouter, usePathname } from 'next/navigation'
import { useCallback } from 'react'

export function ProductFilters({ products }: { products: Product[] }) {
  const searchParams = useSearchParams()
  const router = useRouter()
  const pathname = usePathname()

  const category = searchParams.get('category') ?? 'all'
  const sortBy = searchParams.get('sort') ?? 'price'
  const page = Number(searchParams.get('page') ?? 1)

  const updateParams = useCallback((updates: Record<string, string>) => {
    const params = new URLSearchParams(searchParams.toString())
    Object.entries(updates).forEach(([key, value]) => {
      params.set(key, value)
    })
    router.push(`${pathname}?${params.toString()}`)
  }, [searchParams, router, pathname])

  const filteredProducts = filterProducts(products, { category, sortBy, page })

  return (
    <div>
      <select
        value={category}
        onChange={(e) => updateParams({ category: e.target.value, page: '1' })}
      >
        <option value="all">All Categories</option>
        <option value="electronics">Electronics</option>
      </select>
      <ProductGrid products={filteredProducts} />
      <Pagination
        current={page}
        onChange={(p) => updateParams({ page: String(p) })}
      />
    </div>
  )
}
```

**Benefits:**
- Users can bookmark and share filtered views
- Browser back/forward navigation works naturally
- Server components can read searchParams for SSR
- Analytics can track filter usage from URLs

**When NOT to use:** For ephemeral UI state like modal open/close, dropdown expansion, or form input before submission, useState is more appropriate.

Reference: [Next.js useSearchParams](https://nextjs.org/docs/app/api-reference/functions/use-search-params)

### 7.4 Use useCallback for Stable Event Handlers

**Impact: MEDIUM (prevents unnecessary re-renders of memoized children on every parent render)**

Functions created inside components get new references on every render. When passed as props to memoized children or used in dependency arrays, these unstable references trigger unnecessary re-renders and effect re-runs.

**Incorrect (unstable callback reference):**

```tsx
'use client'

import { memo, useState } from 'react'

function FilterPanel({ filters, onFilterChange }: FilterPanelProps) {
  const [searchQuery, setSearchQuery] = useState('')

  const handleCategorySelect = (category: string) => {
    onFilterChange({ ...filters, category })
  }
  // New function created every render, defeats memo below

  return (
    <div>
      <SearchInput value={searchQuery} onChange={setSearchQuery} />
      <CategoryList
        categories={filters.availableCategories}
        onSelect={handleCategorySelect}
      />
    </div>
  )
}

const CategoryList = memo(function CategoryList({
  categories,
  onSelect,
}: CategoryListProps) {
  // Re-renders on every FilterPanel render despite memo
  return (
    <ul>
      {categories.map((cat) => (
        <li key={cat} onClick={() => onSelect(cat)}>{cat}</li>
      ))}
    </ul>
  )
})
```

**Correct (stable callback with useCallback):**

```tsx
'use client'

import { memo, useState, useCallback } from 'react'

function FilterPanel({ filters, onFilterChange }: FilterPanelProps) {
  const [searchQuery, setSearchQuery] = useState('')

  const handleCategorySelect = useCallback((category: string) => {
    onFilterChange({ ...filters, category })
  }, [filters, onFilterChange])

  return (
    <div>
      <SearchInput value={searchQuery} onChange={setSearchQuery} />
      <CategoryList
        categories={filters.availableCategories}
        onSelect={handleCategorySelect}
      />
    </div>
  )
}

const CategoryList = memo(function CategoryList({
  categories,
  onSelect,
}: CategoryListProps) {
  // Only re-renders when categories or onSelect actually change
  return (
    <ul>
      {categories.map((cat) => (
        <li key={cat} onClick={() => onSelect(cat)}>{cat}</li>
      ))}
    </ul>
  )
})
```

**When NOT to use:** For simple components without memoized children or effects depending on the callback, the overhead of useCallback may not be worth the added complexity.

Reference: [React useCallback](https://react.dev/reference/react/useCallback)

### 7.5 Use useTransition for Non-Blocking Updates

**Impact: MEDIUM (maintains 60fps input responsiveness during heavy renders)**

Expensive state updates like filtering large lists can freeze the UI, making inputs feel unresponsive. useTransition marks updates as non-urgent, allowing React to interrupt rendering to handle user input and keep the interface responsive.

**Incorrect (UI freezes during filter):**

```tsx
'use client'

import { useState } from 'react'

export function SearchableProductList({ products }: { products: Product[] }) {
  const [query, setQuery] = useState('')
  const [filteredProducts, setFilteredProducts] = useState(products)

  const handleSearch = (value: string) => {
    setQuery(value)
    // Expensive filter blocks input, UI feels laggy
    const filtered = products.filter((p) =>
      p.name.toLowerCase().includes(value.toLowerCase()) ||
      p.description.toLowerCase().includes(value.toLowerCase())
    )
    setFilteredProducts(filtered)
  }

  return (
    <div>
      <input
        value={query}
        onChange={(e) => handleSearch(e.target.value)}
        placeholder="Search products..."
      />
      <ProductGrid products={filteredProducts} />
    </div>
  )
}
```

**Correct (non-blocking with useTransition):**

```tsx
'use client'

import { useState, useTransition } from 'react'

export function SearchableProductList({ products }: { products: Product[] }) {
  const [query, setQuery] = useState('')
  const [filteredProducts, setFilteredProducts] = useState(products)
  const [isPending, startTransition] = useTransition()

  const handleSearch = (value: string) => {
    setQuery(value)  // Urgent: update input immediately
    startTransition(() => {
      // Non-urgent: can be interrupted if user types again
      const filtered = products.filter((p) =>
        p.name.toLowerCase().includes(value.toLowerCase()) ||
        p.description.toLowerCase().includes(value.toLowerCase())
      )
      setFilteredProducts(filtered)
    })
  }

  return (
    <div>
      <input
        value={query}
        onChange={(e) => handleSearch(e.target.value)}
        placeholder="Search products..."
      />
      {isPending && <LoadingSpinner />}
      <ProductGrid products={filteredProducts} />
    </div>
  )
}
```

**With router navigation:**

```tsx
'use client'

import { useTransition } from 'react'
import { useRouter } from 'next/navigation'

export function TabNavigation({ tabs }: { tabs: Tab[] }) {
  const [isPending, startTransition] = useTransition()
  const router = useRouter()

  const handleTabChange = (tabId: string) => {
    startTransition(() => {
      router.push(`/dashboard/${tabId}`)
    })
  }

  return (
    <nav className={isPending ? 'opacity-70' : ''}>
      {tabs.map((tab) => (
        <button key={tab.id} onClick={() => handleTabChange(tab.id)}>
          {tab.label}
        </button>
      ))}
    </nav>
  )
}
```

**When NOT to use:** For quick, simple state updates that render instantly, the overhead of useTransition adds unnecessary complexity.

Reference: [React useTransition](https://react.dev/reference/react/useTransition)

---

## 8. Advanced Patterns

**Impact: LOW**

Middleware optimization, metadata generation, image and font loading provide incremental performance gains.

### 8.1 Keep Middleware Fast and Lightweight

**Impact: LOW (Reduces TTFB by 10-50ms per request by avoiding blocking operations)**

Middleware runs on every matching request before the page renders. Heavy computations, database calls, or complex logic in middleware block the entire request, adding latency to Time to First Byte. Keep middleware focused on lightweight tasks like redirects, rewrites, and header modifications.

**Incorrect (heavy computation in middleware):**

```typescript
// middleware.ts
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export async function middleware(request: NextRequest) {
  // Database call blocks every request - adds 50-200ms latency
  const user = await fetch(`${process.env.API_URL}/users/verify`, {
    headers: { cookie: request.headers.get('cookie') || '' },
  }).then((res) => res.json())

  const permissions = await fetch(`${process.env.API_URL}/permissions/${user.id}`)
    .then((res) => res.json())

  if (!permissions.canAccess) {
    return NextResponse.redirect(new URL('/unauthorized', request.url))
  }

  return NextResponse.next()
}
```

**Correct (lightweight token check with deferred verification):**

```typescript
// middleware.ts
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export async function middleware(request: NextRequest) {
  const sessionToken = request.cookies.get('session')?.value

  if (!sessionToken) {
    return NextResponse.redirect(new URL('/login', request.url))
  }

  // Pass token to page for full verification - no blocking fetch
  const requestHeaders = new Headers(request.headers)
  requestHeaders.set('x-session-token', sessionToken)

  return NextResponse.next({
    request: { headers: requestHeaders },
  })
}
```

**What middleware should do:**
- Check for presence of auth tokens (not validate them)
- Redirect based on simple conditions (locale, feature flags)
- Set headers or rewrite URLs
- Rate limiting with edge-compatible stores

**What middleware should NOT do:**
- Database queries or API calls that block rendering
- Complex data transformations
- Session validation (defer to route handlers)
- Heavy cryptographic operations

Reference: [Next.js Middleware](https://nextjs.org/docs/app/building-your-application/routing/middleware)

### 8.2 Optimize Images with next/image Props

**Impact: LOW (Improves LCP by 100-500ms and eliminates Cumulative Layout Shift from images)**

Unoptimized images cause layout shifts when they load and delay Largest Contentful Paint. Using `next/image` with `priority` for above-the-fold images, `sizes` for responsive loading, and `placeholder` for perceived performance eliminates CLS and improves LCP scores.

**Incorrect (missing optimization props):**

```tsx
// components/ProductHero.tsx
import Image from 'next/image'

export function ProductHero({ product }: { product: Product }) {
  return (
    <div className="hero-banner">
      <Image
        src={product.heroImage}
        alt={product.name}
        width={1200}
        height={600}
        // Missing priority - LCP image loads with low priority
        // Missing sizes - downloads oversized image on mobile
      />
    </div>
  )
}
```

**Correct (optimized with priority, sizes, and placeholder):**

```tsx
// components/ProductHero.tsx
import Image from 'next/image'

export function ProductHero({ product }: { product: Product }) {
  return (
    <div className="hero-banner">
      <Image
        src={product.heroImage}
        alt={product.name}
        width={1200}
        height={600}
        priority // Preloads LCP image - improves LCP by 100-500ms
        sizes="(max-width: 768px) 100vw, (max-width: 1200px) 80vw, 1200px"
        placeholder="blur"
        blurDataURL={product.heroImageBlur}
      />
    </div>
  )
}
```

**When to use each prop:**

| Prop | Use Case |
|------|----------|
| `priority` | Above-the-fold images, hero banners, LCP candidates |
| `sizes` | Responsive images that change size at breakpoints |
| `placeholder="blur"` | Large images where loading state is visible |
| `fill` | Images that should fill their container |

**Alternative (fill mode for responsive containers):**

```tsx
<div className="relative aspect-video">
  <Image
    src={product.heroImage}
    alt={product.name}
    fill
    sizes="(max-width: 768px) 100vw, 50vw"
    className="object-cover"
    priority
  />
</div>
```

Reference: [Image Optimization](https://nextjs.org/docs/app/building-your-application/optimizing/images)

### 8.3 Use error.tsx for Graceful Error Handling

**Impact: LOW (Prevents full page crashes and maintains partial UI during errors)**

Unhandled errors in Server Components crash the entire page, showing users a blank screen or generic error. Using `error.tsx` creates error boundaries that catch errors at the route segment level, allowing the rest of the page to remain functional and providing users with recovery options.

**Incorrect (no error boundary causes full page crash):**

```tsx
// app/dashboard/analytics/page.tsx
export default async function AnalyticsPage() {
  const data = await fetchAnalyticsData()
  // If this throws, entire page crashes - user sees nothing

  return (
    <div>
      <h1>Analytics Dashboard</h1>
      <AnalyticsChart data={data} />
    </div>
  )
}
```

**Correct (error.tsx catches and handles errors gracefully):**

```tsx
// app/dashboard/analytics/error.tsx
'use client'

export default function AnalyticsError({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  return (
    <div className="error-container">
      <h2>Failed to load analytics</h2>
      <p>There was a problem loading your analytics data.</p>
      <button onClick={() => reset()}>Try again</button>
    </div>
  )
}
```

```tsx
// app/dashboard/analytics/page.tsx
export default async function AnalyticsPage() {
  const data = await fetchAnalyticsData()
  // If this throws, error.tsx catches it - dashboard layout stays visible

  return (
    <div>
      <h1>Analytics Dashboard</h1>
      <AnalyticsChart data={data} />
    </div>
  )
}
```

**Alternative (global-error.tsx for root layout errors):**

```tsx
// app/global-error.tsx
'use client'

export default function GlobalError({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  return (
    <html>
      <body>
        <h1>Something went wrong</h1>
        <button onClick={() => reset()}>Try again</button>
      </body>
    </html>
  )
}
```

**Error boundary placement:**
- Place `error.tsx` at route segments where failures are isolated
- Use `global-error.tsx` for root layout errors (must include `<html>` and `<body>`)
- Nest error boundaries for granular error recovery

Reference: [Error Handling](https://nextjs.org/docs/app/building-your-application/routing/error-handling)

### 8.4 Use generateMetadata for Dynamic SEO

**Impact: LOW (2-3× better click-through rates with accurate page metadata)**

Static metadata objects cannot include dynamic content like product names or article titles. Using `generateMetadata` allows you to fetch data and generate accurate metadata per page, improving search engine indexing and social media previews with the correct titles, descriptions, and images.

**Incorrect (static metadata ignores page content):**

```tsx
// app/products/[slug]/page.tsx
export const metadata = {
  title: 'Product Details',
  description: 'View product information',
  // Generic metadata - search engines see same title for every product
}

export default async function ProductPage({
  params,
}: {
  params: Promise<{ slug: string }>
}) {
  const { slug } = await params
  const product = await getProduct(slug)
  return <ProductDetails product={product} />
}
```

**Correct (dynamic metadata matches page content):**

```tsx
// app/products/[slug]/page.tsx
import type { Metadata } from 'next'

export async function generateMetadata({
  params,
}: {
  params: Promise<{ slug: string }>
}): Promise<Metadata> {
  const { slug } = await params
  const product = await getProduct(slug)

  return {
    title: `${product.name} | Our Store`,
    description: product.description.slice(0, 160),
    openGraph: {
      title: product.name,
      description: product.description,
      images: [{ url: product.imageUrl, width: 1200, height: 630 }],
    },
  }
}

export default async function ProductPage({
  params,
}: {
  params: Promise<{ slug: string }>
}) {
  const { slug } = await params
  const product = await getProduct(slug)
  return <ProductDetails product={product} />
}
```

**Benefits:**
- Search engines index accurate page titles and descriptions
- Social media shares display correct product images and text
- Request deduplication ensures `getProduct` is called only once

**Alternative (combine with static base metadata):**

```tsx
// app/layout.tsx - base metadata inherited by all pages
export const metadata: Metadata = {
  metadataBase: new URL('https://example.com'),
  title: { default: 'Our Store', template: '%s | Our Store' },
  openGraph: { siteName: 'Our Store' },
}
```

Reference: [Generating Metadata](https://nextjs.org/docs/app/building-your-application/optimizing/metadata)

### 8.5 Use Intercepting Routes for Modal Patterns

**Impact: LOW (Enables shareable modal URLs while preserving navigation context)**

Traditional modals break browser navigation and cannot be shared via URL. Intercepting routes allow you to display content in a modal when navigating client-side while showing the full page when accessed directly, giving users shareable URLs and proper back button behavior.

**Incorrect (modal without URL - not shareable):**

```tsx
// app/photos/page.tsx
'use client'

import { useState } from 'react'

export default function PhotoGallery() {
  const [selectedPhoto, setSelectedPhoto] = useState<Photo | null>(null)
  // Modal state lost on refresh - URL not shareable
  // Back button closes entire page instead of modal

  return (
    <div>
      {photos.map((photo) => (
        <div key={photo.id} onClick={() => setSelectedPhoto(photo)}>
          <PhotoThumbnail photo={photo} />
        </div>
      ))}
      {selectedPhoto && (
        <Modal onClose={() => setSelectedPhoto(null)}>
          <PhotoDetail photo={selectedPhoto} />
        </Modal>
      )}
    </div>
  )
}
```

**Correct (intercepting route with shareable modal URL):**

```tsx
// app/photos/page.tsx
import Link from 'next/link'

export default function PhotoGallery() {
  return (
    <div>
      {photos.map((photo) => (
        <Link key={photo.id} href={`/photos/${photo.id}`}>
          <PhotoThumbnail photo={photo} />
        </Link>
      ))}
    </div>
  )
}
```

```tsx
// app/photos/[id]/page.tsx - Direct access shows full page
export default async function PhotoPage({
  params,
}: {
  params: Promise<{ id: string }>
}) {
  const { id } = await params
  const photo = await getPhoto(id)

  return <PhotoDetail photo={photo} />
}
```

```tsx
// app/@modal/(.)photos/[id]/page.tsx - Intercepts to show modal
export default async function PhotoModal({
  params,
}: {
  params: Promise<{ id: string }>
}) {
  const { id } = await params
  const photo = await getPhoto(id)

  return (
    <Modal>
      <PhotoDetail photo={photo} />
    </Modal>
  )
}
```

```tsx
// app/layout.tsx - Renders both slots
export default function RootLayout({
  children,
  modal,
}: {
  children: React.ReactNode
  modal: React.ReactNode
}) {
  return (
    <html>
      <body>
        {children}
        {modal}
      </body>
    </html>
  )
}
```

**Interception conventions:**
- `(.)` - Same level
- `(..)` - One level up
- `(..)(..)` - Two levels up
- `(...)` - From root

Reference: [Intercepting Routes](https://nextjs.org/docs/app/building-your-application/routing/intercepting-routes)

### 8.6 Use next/font for Self-Hosted Fonts

**Impact: LOW (Eliminates layout shift from font loading and removes external font requests)**

External font services like Google Fonts add render-blocking requests and cause layout shift when fonts swap. Using `next/font` self-hosts fonts, eliminates external network requests, and applies `font-display: swap` automatically to prevent invisible text during loading.

**Incorrect (external font causes layout shift and extra requests):**

```tsx
// app/layout.tsx
import './globals.css'

// globals.css contains:
// @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;700&display=swap');
// Adds 100-300ms blocking request + causes CLS when font loads

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className="font-inter">{children}</body>
    </html>
  )
}
```

**Correct (self-hosted with next/font):**

```tsx
// app/layout.tsx
import { Inter } from 'next/font/google'

const inter = Inter({
  subsets: ['latin'],
  display: 'swap', // Ensures text visible during font load
  variable: '--font-inter',
})

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en" className={inter.variable}>
      <body className={inter.className}>{children}</body>
    </html>
  )
}
```

**Alternative (local custom fonts):**

```tsx
import localFont from 'next/font/local'

const brandFont = localFont({
  src: [
    { path: './fonts/Brand-Regular.woff2', weight: '400' },
    { path: './fonts/Brand-Bold.woff2', weight: '700' },
  ],
  display: 'swap',
  variable: '--font-brand',
})
```

**Benefits:**
- Zero external network requests for fonts
- Automatic font subsetting reduces file size
- No Cumulative Layout Shift from font swapping
- Fonts are cached with your application assets

**Best practices:**
- Use `subsets` to include only needed character sets
- Specify only the `weight` values your design uses
- Use CSS variables for flexible font application

Reference: [Font Optimization](https://nextjs.org/docs/app/building-your-application/optimizing/fonts)

### 8.7 Use Route Handlers with Proper Caching

**Impact: LOW (Enables edge caching for API responses and reduces server load)**

Route Handlers without caching configuration regenerate responses on every request, increasing server load and response times. Using the `dynamic` export and cache headers enables edge caching for appropriate endpoints, reducing latency and server costs.

**Incorrect (no caching - regenerates every request):**

```typescript
// app/api/products/route.ts
import { NextResponse } from 'next/server'

export async function GET() {
  const products = await db.products.findMany()
  // Runs database query on every request - no caching
  return NextResponse.json(products)
}
```

**Correct (cached with revalidation):**

```typescript
// app/api/products/route.ts
import { NextResponse } from 'next/server'

export const dynamic = 'force-static'
export const revalidate = 3600 // Cache for 1 hour

export async function GET() {
  const products = await db.products.findMany()

  return NextResponse.json(products, {
    headers: {
      'Cache-Control': 'public, s-maxage=3600, stale-while-revalidate=86400',
    },
  })
}
```

**Alternative (dynamic routes with request-based caching):**

```typescript
// app/api/products/[category]/route.ts
import { NextRequest, NextResponse } from 'next/server'

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ category: string }> }
) {
  const { category } = await params
  const products = await db.products.findMany({
    where: { category },
  })

  return NextResponse.json(products, {
    headers: {
      'Cache-Control': 'public, s-maxage=600, stale-while-revalidate=1200',
    },
  })
}
```

**Caching strategies by endpoint type:**

| Endpoint Type | Strategy |
|---------------|----------|
| Static data (categories, config) | `force-static` with long revalidate |
| Semi-dynamic (product lists) | Short revalidate (5-60 min) |
| User-specific data | `force-dynamic`, no cache |
| Real-time data | `force-dynamic` with streaming |

**When NOT to cache:**
- User-specific or authenticated responses
- Data that must be real-time accurate
- POST/PUT/DELETE mutations

Reference: [Route Handlers](https://nextjs.org/docs/app/building-your-application/routing/route-handlers)

### 8.8 Use Server Actions with Proper Error Handling

**Impact: LOW (Enables type-safe mutations with automatic form state management)**

Server Actions that throw errors or return inconsistent responses make client-side error handling difficult. Using a consistent return pattern with success/error states enables proper form validation feedback and prevents unhandled promise rejections from crashing the UI.

**Incorrect (throws errors without structured response):**

```tsx
// app/actions/user.ts
'use server'

export async function updateUserProfile(formData: FormData) {
  const name = formData.get('name') as string

  if (!name || name.length < 2) {
    throw new Error('Name must be at least 2 characters')
    // Throwing causes unhandled rejection on client
  }

  await db.users.update({ where: { id: userId }, data: { name } })
  // No return value - client cannot confirm success
}
```

**Correct (structured response with error handling):**

```tsx
// app/actions/user.ts
'use server'

import { revalidatePath } from 'next/cache'

type ActionResult = {
  success: boolean
  message: string
  errors?: Record<string, string[]>
}

export async function updateUserProfile(
  prevState: ActionResult,
  formData: FormData
): Promise<ActionResult> {
  const name = formData.get('name') as string

  if (!name || name.length < 2) {
    return {
      success: false,
      message: 'Validation failed',
      errors: { name: ['Name must be at least 2 characters'] },
    }
  }

  try {
    await db.users.update({ where: { id: userId }, data: { name } })
    revalidatePath('/profile')
    return { success: true, message: 'Profile updated successfully' }
  } catch (error) {
    return { success: false, message: 'Failed to update profile' }
  }
}
```

```tsx
// app/profile/edit/page.tsx
'use client'

import { useActionState } from 'react'
import { updateUserProfile } from '@/app/actions/user'

export default function EditProfileForm() {
  const [state, formAction, isPending] = useActionState(updateUserProfile, {
    success: false,
    message: '',
  })

  return (
    <form action={formAction}>
      <input name="name" aria-describedby="name-error" />
      {state.errors?.name && (
        <p id="name-error" className="error">{state.errors.name[0]}</p>
      )}
      <button type="submit" disabled={isPending}>
        {isPending ? 'Saving...' : 'Save'}
      </button>
      {state.message && (
        <p className={state.success ? 'success' : 'error'}>{state.message}</p>
      )}
    </form>
  )
}
```

**Benefits:**
- Type-safe form state with predictable structure
- Field-level validation errors for better UX
- Automatic pending state with `useActionState`
- No unhandled promise rejections

Reference: [Server Actions and Mutations](https://nextjs.org/docs/app/building-your-application/data-fetching/server-actions-and-mutations)

---

## References

1. [https://nextjs.org/docs](https://nextjs.org/docs)
2. [https://react.dev](https://react.dev)
3. [https://vercel.com/blog](https://vercel.com/blog)
4. [https://web.dev/vitals](https://web.dev/vitals)