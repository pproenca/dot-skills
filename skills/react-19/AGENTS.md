# React 19

**Version 0.1.0**  
React Community  
January 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive performance optimization guide for React 19 applications, designed for AI agents and LLMs. Contains 40+ rules across 8 categories, prioritized by impact from critical (concurrent rendering, server components) to incremental (component patterns). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated refactoring and code generation.

---

## Table of Contents

1. [Concurrent Rendering](#1-concurrent-rendering) — **CRITICAL**
   - 1.1 [Avoid Suspense Fallback Thrashing](#11-avoid-suspense-fallback-thrashing)
   - 1.2 [Leverage Automatic Batching for Fewer Renders](#12-leverage-automatic-batching-for-fewer-renders)
   - 1.3 [Use useDeferredValue for Derived Expensive Values](#13-use-usedeferredvalue-for-derived-expensive-values)
   - 1.4 [Use useTransition for Non-Blocking Updates](#14-use-usetransition-for-non-blocking-updates)
   - 1.5 [Write Concurrent-Safe Components](#15-write-concurrent-safe-components)
2. [Server Components](#2-server-components) — **CRITICAL**
   - 2.1 [Avoid Client-Only Libraries in Server Components](#21-avoid-client-only-libraries-in-server-components)
   - 2.2 [Enable Streaming with Nested Suspense](#22-enable-streaming-with-nested-suspense)
   - 2.3 [Fetch Data in Server Components](#23-fetch-data-in-server-components)
   - 2.4 [Minimize Server/Client Boundary Crossings](#24-minimize-serverclient-boundary-crossings)
   - 2.5 [Pass Only Serializable Props to Client Components](#25-pass-only-serializable-props-to-client-components)
   - 2.6 [Use Composition to Mix Server and Client Components](#26-use-composition-to-mix-server-and-client-components)
3. [Actions & Forms](#3-actions-forms) — **HIGH**
   - 3.1 [Use Form Actions Instead of onSubmit](#31-use-form-actions-instead-of-onsubmit)
   - 3.2 [Use useActionState for Form State Management](#32-use-useactionstate-for-form-state-management)
   - 3.3 [Use useFormStatus for Submit Button State](#33-use-useformstatus-for-submit-button-state)
   - 3.4 [Use useOptimistic for Instant UI Feedback](#34-use-useoptimistic-for-instant-ui-feedback)
   - 3.5 [Validate Forms on Server with Actions](#35-validate-forms-on-server-with-actions)
4. [Data Fetching](#4-data-fetching) — **HIGH**
   - 4.1 [Fetch Data in Parallel with Promise.all](#41-fetch-data-in-parallel-with-promiseall)
   - 4.2 [Use cache() for Request Deduplication](#42-use-cache-for-request-deduplication)
   - 4.3 [Use Error Boundaries with Suspense](#43-use-error-boundaries-with-suspense)
   - 4.4 [Use Suspense for Declarative Loading States](#44-use-suspense-for-declarative-loading-states)
   - 4.5 [Use the use() Hook for Promises in Render](#45-use-the-use-hook-for-promises-in-render)
5. [State Management](#5-state-management) — **MEDIUM-HIGH**
   - 5.1 [Calculate Derived Values During Render](#51-calculate-derived-values-during-render)
   - 5.2 [Split Context to Prevent Unnecessary Re-renders](#52-split-context-to-prevent-unnecessary-re-renders)
   - 5.3 [Use Functional State Updates for Derived Values](#53-use-functional-state-updates-for-derived-values)
   - 5.4 [Use Lazy Initialization for Expensive Initial State](#54-use-lazy-initialization-for-expensive-initial-state)
   - 5.5 [Use useReducer for Complex State Logic](#55-use-usereducer-for-complex-state-logic)
6. [Memoization & Performance](#6-memoization-performance) — **MEDIUM**
   - 6.1 [Avoid Premature Memoization](#61-avoid-premature-memoization)
   - 6.2 [Leverage React Compiler for Automatic Memoization](#62-leverage-react-compiler-for-automatic-memoization)
   - 6.3 [Use React.memo for Expensive Pure Components](#63-use-reactmemo-for-expensive-pure-components)
   - 6.4 [Use useCallback for Stable Function References](#64-use-usecallback-for-stable-function-references)
   - 6.5 [Use useMemo for Expensive Calculations](#65-use-usememo-for-expensive-calculations)
7. [Effects & Events](#7-effects-events) — **MEDIUM**
   - 7.1 [Always Clean Up Effect Side Effects](#71-always-clean-up-effect-side-effects)
   - 7.2 [Avoid Effects for Derived State and User Events](#72-avoid-effects-for-derived-state-and-user-events)
   - 7.3 [Avoid Object and Array Dependencies in Effects](#73-avoid-object-and-array-dependencies-in-effects)
   - 7.4 [Use useEffectEvent for Non-Reactive Logic](#74-use-useeffectevent-for-non-reactive-logic)
   - 7.5 [Use useSyncExternalStore for External Subscriptions](#75-use-usesyncexternalstore-for-external-subscriptions)
8. [Component Patterns](#8-component-patterns) — **LOW-MEDIUM**
   - 8.1 [Choose Controlled vs Uncontrolled Appropriately](#81-choose-controlled-vs-uncontrolled-appropriately)
   - 8.2 [Prefer Composition Over Props Explosion](#82-prefer-composition-over-props-explosion)
   - 8.3 [Use Key to Reset Component State](#83-use-key-to-reset-component-state)
   - 8.4 [Use Render Props for Inversion of Control](#84-use-render-props-for-inversion-of-control)

---

## 1. Concurrent Rendering

**Impact: CRITICAL**

useTransition, useDeferredValue, and automatic batching enable non-blocking UI updates, improving responsiveness by up to 40%.

### 1.1 Avoid Suspense Fallback Thrashing

**Impact: HIGH (prevents flickering, smoother UX)**

Wrap navigations in transitions to prevent Suspense fallbacks from appearing during fast updates. This keeps the previous content visible while loading.

**Incorrect (fallback shows on every navigation):**

```typescript
function App() {
  const [page, setPage] = useState('home')

  return (
    <div>
      <nav>
        <button onClick={() => setPage('home')}>Home</button>
        <button onClick={() => setPage('about')}>About</button>
      </nav>
      <Suspense fallback={<Spinner />}>
        {page === 'home' ? <Home /> : <About />}
      </Suspense>
    </div>
  )
}
// Spinner flashes on every page change
```

**Correct (transition keeps previous content):**

```typescript
import { useState, useTransition, Suspense } from 'react'

function App() {
  const [page, setPage] = useState('home')
  const [isPending, startTransition] = useTransition()

  function navigate(newPage: string) {
    startTransition(() => {
      setPage(newPage)
    })
  }

  return (
    <div>
      <nav style={{ opacity: isPending ? 0.7 : 1 }}>
        <button onClick={() => navigate('home')}>Home</button>
        <button onClick={() => navigate('about')}>About</button>
      </nav>
      <Suspense fallback={<Spinner />}>
        {page === 'home' ? <Home /> : <About />}
      </Suspense>
    </div>
  )
}
// Previous page stays visible while new page loads
```

**Benefits:**
- No layout shift from fallback
- Previous content remains visible
- Navigation feels instant with visual feedback (opacity)

### 1.2 Leverage Automatic Batching for Fewer Renders

**Impact: HIGH (32% fewer renders in heavy updates)**

React 19 automatically batches state updates in all contexts: event handlers, promises, setTimeout, and native events. Understand this to avoid unnecessary workarounds.

**Incorrect (forcing synchronous updates):**

```typescript
import { flushSync } from 'react-dom'

function handleClick() {
  // Don't do this - breaks automatic batching
  flushSync(() => {
    setCount(c => c + 1)
  })
  flushSync(() => {
    setFlag(f => !f)
  })
}
// Two renders instead of one
```

**Correct (letting React batch automatically):**

```typescript
function handleClick() {
  // React batches these - single render
  setCount(c => c + 1)
  setFlag(f => !f)
}

async function handleSubmit() {
  const data = await fetchData()
  // React 19 batches even in async callbacks
  setData(data)
  setLoading(false)
  setError(null)
}
// Single render for all three updates
```

**When flushSync is appropriate:**

```typescript
function handleInput(e: React.ChangeEvent<HTMLInputElement>) {
  const value = e.target.value
  setQuery(value)

  // Rare: need DOM measurement before next paint
  flushSync(() => {
    setResults(search(value))
  })
  // Now can measure DOM synchronously
  scrollToTop()
}
```

**Note:** If you have code using `unstable_batchedUpdates`, you can remove it - React 19 batches everywhere automatically.

### 1.3 Use useDeferredValue for Derived Expensive Values

**Impact: CRITICAL (prevents jank in derived computations)**

Use `useDeferredValue` to defer updates to derived values that trigger expensive re-renders. The deferred value lags behind the source during heavy updates.

**Incorrect (expensive derived render blocks UI):**

```typescript
function SearchPage() {
  const [query, setQuery] = useState('')

  return (
    <div>
      <input
        value={query}
        onChange={e => setQuery(e.target.value)}
      />
      {/* SearchResults re-renders on every keystroke */}
      <SearchResults query={query} />
    </div>
  )
}

function SearchResults({ query }: { query: string }) {
  // Expensive computation runs on every character typed
  const results = useMemo(() => searchDatabase(query), [query])
  return <ResultsList results={results} />
}
```

**Correct (deferred value for expensive child):**

```typescript
import { useState, useDeferredValue } from 'react'

function SearchPage() {
  const [query, setQuery] = useState('')
  const deferredQuery = useDeferredValue(query)
  const isStale = query !== deferredQuery

  return (
    <div>
      <input
        value={query}
        onChange={e => setQuery(e.target.value)}
      />
      <div style={{ opacity: isStale ? 0.7 : 1 }}>
        <SearchResults query={deferredQuery} />
      </div>
    </div>
  )
}
// Input updates immediately, results update when React is idle
```

**Difference from useTransition:**
- `useTransition` - You control when transition starts
- `useDeferredValue` - React controls when value updates
- Use `useDeferredValue` when you don't control the state update

### 1.4 Use useTransition for Non-Blocking Updates

**Impact: CRITICAL (keeps UI responsive during heavy updates)**

Wrap expensive state updates in `startTransition` to keep the UI responsive. React will interrupt the transition if higher-priority updates occur.

**Incorrect (blocking state update):**

```typescript
function SearchResults() {
  const [query, setQuery] = useState('')
  const [results, setResults] = useState([])

  function handleSearch(value: string) {
    setQuery(value)
    // Expensive filtering blocks UI
    const filtered = filterResults(allItems, value)  // 1000+ items
    setResults(filtered)
  }

  return (
    <div>
      <input onChange={e => handleSearch(e.target.value)} />
      {/* Input feels sluggish during filtering */}
      <ResultsList results={results} />
    </div>
  )
}
```

**Correct (non-blocking with useTransition):**

```typescript
import { useState, useTransition } from 'react'

function SearchResults() {
  const [query, setQuery] = useState('')
  const [results, setResults] = useState([])
  const [isPending, startTransition] = useTransition()

  function handleSearch(value: string) {
    setQuery(value)  // High priority - updates immediately
    startTransition(() => {
      // Low priority - can be interrupted
      const filtered = filterResults(allItems, value)
      setResults(filtered)
    })
  }

  return (
    <div>
      <input onChange={e => handleSearch(e.target.value)} />
      {isPending && <Spinner />}
      <ResultsList results={results} />
    </div>
  )
}
// Input stays responsive while results update in background
```

**When to use:**
- Filtering large lists
- Tab switches with heavy content
- Route transitions
- Any expensive re-render that shouldn't block input

### 1.5 Write Concurrent-Safe Components

**Impact: MEDIUM-HIGH (prevents bugs in concurrent rendering)**

React may pause, interrupt, and restart renders. Avoid side effects during render and ensure components are idempotent.

**Incorrect (side effects during render):**

```typescript
let globalId = 0

function UserCard({ user }) {
  // Side effect during render - will run multiple times in concurrent mode
  const id = globalId++
  logView(user.id)  // Analytics called multiple times!

  return (
    <div id={`card-${id}`}>
      {user.name}
    </div>
  )
}
```

**Correct (side effects in effects, stable IDs):**

```typescript
import { useId, useEffect } from 'react'

function UserCard({ user }) {
  const id = useId()  // Stable across renders

  useEffect(() => {
    // Side effects in useEffect - runs once after commit
    logView(user.id)
  }, [user.id])

  return (
    <div id={id}>
      {user.name}
    </div>
  )
}
```

**Concurrent-safe patterns:**

```typescript
// ✅ Pure calculations during render
const fullName = `${firstName} ${lastName}`

// ✅ Memoized expensive calculations
const sorted = useMemo(() => items.sort(compare), [items])

// ✅ Stable references with useId
const inputId = useId()

// ❌ Mutations during render
items.push(newItem)

// ❌ Subscriptions during render
window.addEventListener('resize', handler)

// ❌ External state reads without sync
const width = window.innerWidth
```

---

## 2. Server Components

**Impact: CRITICAL**

Proper server/client boundaries and data fetching patterns reduce client JavaScript by 38% and eliminate client-side waterfalls.

### 2.1 Avoid Client-Only Libraries in Server Components

**Impact: MEDIUM-HIGH (prevents build errors, correct component placement)**

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

### 2.2 Enable Streaming with Nested Suspense

**Impact: MEDIUM-HIGH (progressive loading, faster TTFB)**

Use multiple Suspense boundaries to stream HTML progressively. Fast components appear immediately while slow ones load.

**Incorrect (single Suspense blocks all content):**

```typescript
export default function Page() {
  return (
    <Suspense fallback={<FullPageSpinner />}>
      <FastHeader />      {/* Ready in 50ms */}
      <SlowAnalytics />   {/* Takes 2000ms */}
      <FastFooter />      {/* Ready in 50ms */}
    </Suspense>
  )
}
// Nothing appears until SlowAnalytics completes
```

**Correct (granular Suspense for streaming):**

```typescript
export default function Page() {
  return (
    <>
      {/* No Suspense - renders immediately */}
      <StaticNav />

      <Suspense fallback={<HeaderSkeleton />}>
        <FastHeader />
      </Suspense>

      <main>
        <Suspense fallback={<ContentSkeleton />}>
          <MainContent />
        </Suspense>

        <Suspense fallback={<AnalyticsSkeleton />}>
          <SlowAnalytics />
        </Suspense>
      </main>

      {/* Static footer - no Suspense needed */}
      <StaticFooter />
    </>
  )
}
// StaticNav and StaticFooter appear instantly
// Header streams in at 50ms
// MainContent streams when ready
// Analytics streams at 2000ms
```

**Streaming order:**
1. Static HTML (no async) - immediate
2. Fast async components - as they resolve
3. Slow async components - when ready

### 2.3 Fetch Data in Server Components

**Impact: CRITICAL (38% less client JS, no client waterfalls)**

Fetch data directly in Server Components using async/await. This eliminates client-side waterfalls and reduces JavaScript bundle size.

**Incorrect (client-side data fetching):**

```typescript
'use client'

import { useState, useEffect } from 'react'

export function UserProfile({ userId }: { userId: string }) {
  const [user, setUser] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetch(`/api/users/${userId}`)
      .then(res => res.json())
      .then(data => {
        setUser(data)
        setLoading(false)
      })
  }, [userId])

  if (loading) return <Skeleton />
  return <Profile user={user} />
}
// Waterfall: HTML → JS → Hydrate → Fetch → Render
```

**Correct (Server Component data fetching):**

```typescript
// Server Component - no 'use client' directive
export async function UserProfile({ userId }: { userId: string }) {
  const user = await fetch(`https://api.example.com/users/${userId}`)
    .then(res => res.json())

  return <Profile user={user} />
}
// Single request, data in HTML, no client JS for fetching
```

**With loading state:**

```typescript
import { Suspense } from 'react'

export function UserProfileWrapper({ userId }: { userId: string }) {
  return (
    <Suspense fallback={<Skeleton />}>
      <UserProfile userId={userId} />
    </Suspense>
  )
}

async function UserProfile({ userId }: { userId: string }) {
  const user = await getUser(userId)
  return <Profile user={user} />
}
```

### 2.4 Minimize Server/Client Boundary Crossings

**Impact: CRITICAL (reduces serialization overhead, smaller bundles)**

Each `'use client'` boundary requires serializing props from server to client. Push boundaries as low as possible in the component tree.

**Incorrect (boundary too high, serializes too much):**

```typescript
// components/ProductPage.tsx
'use client'  // Entire page is client-rendered

export function ProductPage({ product, reviews, related }) {
  const [quantity, setQuantity] = useState(1)

  return (
    <div>
      <h1>{product.name}</h1>
      <p>{product.description}</p>
      <ReviewsList reviews={reviews} />       {/* Static content */}
      <RelatedProducts products={related} />  {/* Static content */}

      {/* Only this needs client */}
      <input value={quantity} onChange={e => setQuantity(+e.target.value)} />
    </div>
  )
}
// All product data serialized across boundary
```

**Correct (boundary pushed to leaf):**

```typescript
// components/ProductPage.tsx (Server Component)
export function ProductPage({ product, reviews, related }) {
  return (
    <div>
      <h1>{product.name}</h1>
      <p>{product.description}</p>
      <ReviewsList reviews={reviews} />
      <RelatedProducts products={related} />

      <QuantitySelector productId={product.id} />
    </div>
  )
}

// components/QuantitySelector.tsx
'use client'

export function QuantitySelector({ productId }: { productId: string }) {
  const [quantity, setQuantity] = useState(1)
  return <input value={quantity} onChange={e => setQuantity(+e.target.value)} />
}
// Only productId crosses boundary - minimal serialization
```

**Rule of thumb:** Only the interactive "islands" need `'use client'`.

### 2.5 Pass Only Serializable Props to Client Components

**Impact: HIGH (prevents runtime errors, ensures correct hydration)**

Props passed from Server to Client Components must be JSON-serializable. Functions, classes, and complex objects cannot cross the boundary.

**Incorrect (non-serializable props):**

```typescript
// Server Component
export function ProductPage({ product }) {
  function handleAddToCart() {  // Function - not serializable
    console.log('Added!')
  }

  return (
    <ProductCard
      product={product}
      onAdd={handleAddToCart}      // ❌ Function
      formatter={new Intl.NumberFormat()}  // ❌ Class instance
      today={new Date()}           // ❌ Date object
    />
  )
}
// Error: Functions cannot be passed to Client Components
```

**Correct (serializable props only):**

```typescript
// Server Component
export function ProductPage({ product }) {
  return (
    <ProductCard
      productId={product.id}      // ✅ String
      productName={product.name}  // ✅ String
      price={product.price}       // ✅ Number
      tags={product.tags}         // ✅ Array of primitives
      metadata={{                 // ✅ Plain object
        sku: product.sku,
        inStock: product.inStock
      }}
      createdAt={product.createdAt.toISOString()}  // ✅ String, not Date
    />
  )
}

// components/ProductCard.tsx
'use client'

export function ProductCard({ productId, productName, price }) {
  function handleAddToCart() {
    // Define action in Client Component
    addToCart(productId)
  }

  return (
    <button onClick={handleAddToCart}>
      Add {productName} - ${price}
    </button>
  )
}
```

**Serializable types:** strings, numbers, booleans, null, arrays, plain objects, Dates (as ISO strings).

### 2.6 Use Composition to Mix Server and Client Components

**Impact: HIGH (maintains server rendering for static content)**

Pass Server Components as children or props to Client Components. This keeps server content server-rendered while adding client interactivity.

**Incorrect (importing Server Component in Client):**

```typescript
// components/Accordion.tsx
'use client'

import { ServerContent } from './ServerContent'  // ❌ Forces client rendering

export function Accordion() {
  const [isOpen, setIsOpen] = useState(false)

  return (
    <div>
      <button onClick={() => setIsOpen(!isOpen)}>Toggle</button>
      {isOpen && <ServerContent />}  {/* Now client-rendered */}
    </div>
  )
}
```

**Correct (composition with children):**

```typescript
// components/Accordion.tsx
'use client'

import { ReactNode, useState } from 'react'

export function Accordion({ children }: { children: ReactNode }) {
  const [isOpen, setIsOpen] = useState(false)

  return (
    <div>
      <button onClick={() => setIsOpen(!isOpen)}>Toggle</button>
      {isOpen && children}
    </div>
  )
}

// page.tsx (Server Component)
export default async function Page() {
  const data = await fetchData()

  return (
    <Accordion>
      <ServerContent data={data} />  {/* Stays server-rendered */}
    </Accordion>
  )
}
```

**Alternative (named slots):**

```typescript
// components/Layout.tsx
'use client'

export function Layout({
  header,
  sidebar,
  main
}: {
  header: ReactNode
  sidebar: ReactNode
  main: ReactNode
}) {
  const [sidebarOpen, setSidebarOpen] = useState(true)
  // Client logic for layout

  return (
    <div>
      {header}
      {sidebarOpen && sidebar}
      {main}
    </div>
  )
}
// All slots can be Server Components
```

---

## 3. Actions & Forms

**Impact: HIGH**

useActionState, useOptimistic, and form actions provide declarative mutation handling with automatic pending states.

### 3.1 Use Form Actions Instead of onSubmit

**Impact: HIGH (progressive enhancement, simpler code)**

React 19 supports the `action` prop on forms. This provides progressive enhancement - forms work even without JavaScript.

**Incorrect (onSubmit requires JavaScript):**

```typescript
'use client'

function ContactForm() {
  async function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault()
    const formData = new FormData(e.currentTarget)
    await sendMessage(formData)
  }

  return (
    <form onSubmit={handleSubmit}>
      <input name="email" type="email" />
      <textarea name="message" />
      <button type="submit">Send</button>
    </form>
  )
}
// Doesn't work if JS fails to load
```

**Correct (form action):**

```typescript
// With Server Action
import { sendMessage } from './actions'

function ContactForm() {
  return (
    <form action={sendMessage}>
      <input name="email" type="email" required />
      <textarea name="message" required />
      <button type="submit">Send</button>
    </form>
  )
}
// Works without JS - progressive enhancement

// actions.ts
'use server'

export async function sendMessage(formData: FormData) {
  const email = formData.get('email') as string
  const message = formData.get('message') as string

  await db.messages.create({ data: { email, message } })
  redirect('/thank-you')
}
```

**With client-side action:**

```typescript
'use client'

function SearchForm() {
  async function search(formData: FormData) {
    const query = formData.get('query') as string
    // Client-side handling
    router.push(`/search?q=${query}`)
  }

  return (
    <form action={search}>
      <input name="query" />
      <button>Search</button>
    </form>
  )
}
```

### 3.2 Use useActionState for Form State Management

**Impact: HIGH (declarative form handling, automatic pending states)**

`useActionState` provides declarative form handling with built-in pending state, error handling, and progressive enhancement.

**Incorrect (manual form state management):**

```typescript
'use client'

import { useState } from 'react'

function LoginForm() {
  const [email, setEmail] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    setLoading(true)
    setError('')

    try {
      await login(email)
    } catch (e) {
      setError(e.message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <form onSubmit={handleSubmit}>
      <input value={email} onChange={e => setEmail(e.target.value)} />
      {error && <p>{error}</p>}
      <button disabled={loading}>{loading ? 'Loading...' : 'Login'}</button>
    </form>
  )
}
```

**Correct (useActionState):**

```typescript
'use client'

import { useActionState } from 'react'
import { login } from './actions'

function LoginForm() {
  const [state, formAction, isPending] = useActionState(
    async (prevState: { error?: string }, formData: FormData) => {
      const email = formData.get('email') as string
      const result = await login(email)
      if (result.error) return { error: result.error }
      return {}
    },
    { error: undefined }
  )

  return (
    <form action={formAction}>
      <input name="email" type="email" required />
      {state.error && <p className="error">{state.error}</p>}
      <button disabled={isPending}>
        {isPending ? 'Logging in...' : 'Login'}
      </button>
    </form>
  )
}
// Works without JS, automatic pending state, error handling
```

Reference: [useActionState](https://react.dev/reference/react/useActionState)

### 3.3 Use useFormStatus for Submit Button State

**Impact: MEDIUM-HIGH (proper loading indicators, prevents double submission)**

`useFormStatus` reads the pending state of the parent form. Use it for submit buttons to show loading state and prevent double submission.

**Incorrect (no pending state):**

```typescript
function ContactForm() {
  return (
    <form action={sendMessage}>
      <input name="email" />
      <button type="submit">Send</button>
      {/* No feedback during submission */}
    </form>
  )
}
```

**Correct (useFormStatus in child component):**

```typescript
import { useFormStatus } from 'react-dom'

function SubmitButton({ children }: { children: React.ReactNode }) {
  const { pending } = useFormStatus()

  return (
    <button type="submit" disabled={pending}>
      {pending ? 'Sending...' : children}
    </button>
  )
}

function ContactForm() {
  return (
    <form action={sendMessage}>
      <input name="email" required />
      <textarea name="message" required />
      <SubmitButton>Send Message</SubmitButton>
    </form>
  )
}
```

**Important:** `useFormStatus` must be called from a component that is a child of the `<form>`. It won't work in the same component as the form.

**With more status info:**

```typescript
function FormStatus() {
  const { pending, data, method, action } = useFormStatus()

  if (!pending) return null

  return (
    <div className="status">
      Submitting {data?.get('email')} via {method}...
    </div>
  )
}
```

### 3.4 Use useOptimistic for Instant UI Feedback

**Impact: HIGH (instant perceived response, auto-rollback on failure)**

`useOptimistic` shows a temporary state immediately while the actual action runs in the background. If it fails, React automatically reverts.

**Incorrect (waiting for server response):**

```typescript
'use client'

function TodoList({ todos }: { todos: Todo[] }) {
  async function handleAdd(formData: FormData) {
    const title = formData.get('title') as string
    await addTodo(title)  // UI waits for server
  }

  return (
    <form action={handleAdd}>
      <input name="title" />
      <button>Add</button>
      <ul>
        {todos.map(todo => <li key={todo.id}>{todo.title}</li>)}
      </ul>
    </form>
  )
}
// 200-500ms delay before new todo appears
```

**Correct (optimistic update):**

```typescript
'use client'

import { useOptimistic } from 'react'
import { addTodo } from './actions'

function TodoList({ todos }: { todos: Todo[] }) {
  const [optimisticTodos, addOptimisticTodo] = useOptimistic(
    todos,
    (state, newTodo: Todo) => [...state, newTodo]
  )

  async function handleAdd(formData: FormData) {
    const title = formData.get('title') as string

    addOptimisticTodo({
      id: crypto.randomUUID(),  // Temporary ID
      title,
      pending: true
    })

    await addTodo(title)  // Server confirms in background
  }

  return (
    <form action={handleAdd}>
      <input name="title" />
      <button>Add</button>
      <ul>
        {optimisticTodos.map(todo => (
          <li key={todo.id} style={{ opacity: todo.pending ? 0.5 : 1 }}>
            {todo.title}
          </li>
        ))}
      </ul>
    </form>
  )
}
// Todo appears instantly with pending style
```

### 3.5 Validate Forms on Server with Actions

**Impact: MEDIUM (secure validation, consistent error handling)**

Always validate form data on the server, even with client-side validation. Return structured errors for display.

**Incorrect (client-only validation):**

```typescript
'use client'

function SignupForm() {
  function handleSubmit(formData: FormData) {
    const email = formData.get('email') as string
    if (!email.includes('@')) {
      alert('Invalid email')  // Only client validation
      return
    }
    signup(formData)  // Server trusts input
  }

  return (
    <form action={handleSubmit}>
      <input name="email" type="email" />
      <button>Sign Up</button>
    </form>
  )
}
```

**Correct (server validation with error state):**

```typescript
// actions.ts
'use server'

import { z } from 'zod'

const signupSchema = z.object({
  email: z.string().email('Invalid email format'),
  password: z.string().min(8, 'Password must be 8+ characters')
})

type State = {
  errors?: { email?: string[]; password?: string[] }
  success?: boolean
}

export async function signup(prevState: State, formData: FormData): Promise<State> {
  const result = signupSchema.safeParse({
    email: formData.get('email'),
    password: formData.get('password')
  })

  if (!result.success) {
    return { errors: result.error.flatten().fieldErrors }
  }

  await createUser(result.data)
  return { success: true }
}

// SignupForm.tsx
'use client'

import { useActionState } from 'react'
import { signup } from './actions'

function SignupForm() {
  const [state, formAction] = useActionState(signup, {})

  return (
    <form action={formAction}>
      <input name="email" type="email" />
      {state.errors?.email && <p className="error">{state.errors.email[0]}</p>}

      <input name="password" type="password" />
      {state.errors?.password && <p className="error">{state.errors.password[0]}</p>}

      <button>Sign Up</button>
    </form>
  )
}
```

---

## 4. Data Fetching

**Impact: HIGH**

The use() hook, Suspense for data, and cache() for deduplication enable efficient async data patterns.

### 4.1 Fetch Data in Parallel with Promise.all

**Impact: MEDIUM-HIGH (eliminates waterfalls, 2-5× faster)**

When multiple data fetches are independent, run them in parallel. Sequential awaits create waterfalls that multiply latency.

**Incorrect (sequential fetching):**

```typescript
async function Dashboard() {
  const user = await fetchUser()           // 200ms
  const orders = await fetchOrders()       // 150ms
  const analytics = await fetchAnalytics() // 300ms
  // Total: 650ms (sum of all)

  return (
    <div>
      <UserCard user={user} />
      <OrderList orders={orders} />
      <AnalyticsChart data={analytics} />
    </div>
  )
}
```

**Correct (parallel fetching):**

```typescript
async function Dashboard() {
  const [user, orders, analytics] = await Promise.all([
    fetchUser(),       // 200ms
    fetchOrders(),     // 150ms (parallel)
    fetchAnalytics()   // 300ms (parallel)
  ])
  // Total: 300ms (max of all)

  return (
    <div>
      <UserCard user={user} />
      <OrderList orders={orders} />
      <AnalyticsChart data={analytics} />
    </div>
  )
}
```

**With error handling:**

```typescript
async function Dashboard() {
  const results = await Promise.allSettled([
    fetchUser(),
    fetchOrders(),
    fetchAnalytics()
  ])

  const user = results[0].status === 'fulfilled' ? results[0].value : null
  const orders = results[1].status === 'fulfilled' ? results[1].value : []
  const analytics = results[2].status === 'fulfilled' ? results[2].value : null

  return (
    <div>
      {user ? <UserCard user={user} /> : <UserError />}
      <OrderList orders={orders} />
      {analytics && <AnalyticsChart data={analytics} />}
    </div>
  )
}
```

### 4.2 Use cache() for Request Deduplication

**Impact: HIGH (eliminates duplicate fetches per render)**

Wrap data fetching functions with `cache()` to deduplicate identical calls within a single render tree. Multiple components can fetch the same data without duplicate requests.

**Incorrect (duplicate fetches):**

```typescript
// lib/data.ts
export async function getUser(id: string) {
  console.log('Fetching user', id)  // Logs multiple times!
  const res = await fetch(`/api/users/${id}`)
  return res.json()
}

// components/Header.tsx
async function Header() {
  const user = await getUser('123')  // Fetch #1
  return <h1>Welcome, {user.name}</h1>
}

// components/Sidebar.tsx
async function Sidebar() {
  const user = await getUser('123')  // Fetch #2 - duplicate!
  return <nav>{user.role === 'admin' && <AdminNav />}</nav>
}
```

**Correct (deduplicated with cache):**

```typescript
// lib/data.ts
import { cache } from 'react'

export const getUser = cache(async (id: string) => {
  console.log('Fetching user', id)  // Logs once
  const res = await fetch(`/api/users/${id}`)
  return res.json()
})

// components/Header.tsx
async function Header() {
  const user = await getUser('123')  // Fetch
  return <h1>Welcome, {user.name}</h1>
}

// components/Sidebar.tsx
async function Sidebar() {
  const user = await getUser('123')  // Cached result reused
  return <nav>{user.role === 'admin' && <AdminNav />}</nav>
}
```

**Note:** `cache()` deduplicates within a single server request. For cross-request caching, use your framework's caching mechanism.

### 4.3 Use Error Boundaries with Suspense

**Impact: MEDIUM (graceful error recovery, isolated failures)**

Pair Suspense boundaries with Error Boundaries to handle both loading and error states. Failed components don't crash the entire page.

**Incorrect (unhandled errors crash page):**

```typescript
function Dashboard() {
  return (
    <Suspense fallback={<Spinner />}>
      <Analytics />  {/* If this throws, entire page crashes */}
      <Orders />
    </Suspense>
  )
}
```

**Correct (Error Boundary isolates failures):**

```typescript
import { ErrorBoundary } from 'react-error-boundary'

function Dashboard() {
  return (
    <div>
      <ErrorBoundary fallback={<AnalyticsError />}>
        <Suspense fallback={<AnalyticsSkeleton />}>
          <Analytics />
        </Suspense>
      </ErrorBoundary>

      <ErrorBoundary fallback={<OrdersError />}>
        <Suspense fallback={<OrdersSkeleton />}>
          <Orders />
        </Suspense>
      </ErrorBoundary>
    </div>
  )
}
// Analytics failure doesn't affect Orders
```

**With retry capability:**

```typescript
function ErrorFallback({ error, resetErrorBoundary }) {
  return (
    <div className="error-panel">
      <p>Something went wrong: {error.message}</p>
      <button onClick={resetErrorBoundary}>Try again</button>
    </div>
  )
}

function Dashboard() {
  return (
    <ErrorBoundary
      FallbackComponent={ErrorFallback}
      onReset={() => {
        // Reset any state that might have caused the error
      }}
    >
      <Suspense fallback={<DashboardSkeleton />}>
        <DashboardContent />
      </Suspense>
    </ErrorBoundary>
  )
}
```

### 4.4 Use Suspense for Declarative Loading States

**Impact: HIGH (cleaner code, coordinated loading UI)**

Wrap data-fetching components in Suspense to declare loading UI. This eliminates manual loading state management.

**Incorrect (manual loading state):**

```typescript
'use client'

function Dashboard() {
  const [stats, setStats] = useState(null)
  const [users, setUsers] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    Promise.all([fetchStats(), fetchUsers()])
      .then(([s, u]) => {
        setStats(s)
        setUsers(u)
        setLoading(false)
      })
  }, [])

  if (loading) return <DashboardSkeleton />

  return (
    <div>
      <Stats data={stats} />
      <UserList users={users} />
    </div>
  )
}
```

**Correct (Suspense with async components):**

```typescript
import { Suspense } from 'react'

function Dashboard() {
  return (
    <div>
      <Suspense fallback={<StatsSkeleton />}>
        <Stats />
      </Suspense>
      <Suspense fallback={<UserListSkeleton />}>
        <UserList />
      </Suspense>
    </div>
  )
}

async function Stats() {
  const stats = await fetchStats()
  return <StatsDisplay data={stats} />
}

async function UserList() {
  const users = await fetchUsers()
  return <UserListDisplay users={users} />
}
// Each section loads independently with its own skeleton
```

**Benefits:**
- Declarative loading states
- Independent loading per section
- No manual loading state management
- Automatic error boundary integration

### 4.5 Use the use() Hook for Promises in Render

**Impact: HIGH (cleaner async component code, Suspense integration)**

The `use()` hook reads values from Promises and Context during render. It integrates with Suspense for declarative loading states.

**Incorrect (useEffect for data fetching):**

```typescript
'use client'

import { useState, useEffect } from 'react'

function UserProfile({ userId }: { userId: string }) {
  const [user, setUser] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchUser(userId).then(data => {
      setUser(data)
      setLoading(false)
    })
  }, [userId])

  if (loading) return <Skeleton />
  return <Profile user={user} />
}
```

**Correct (use() with Suspense):**

```typescript
'use client'

import { use, Suspense } from 'react'

function UserProfile({ userPromise }: { userPromise: Promise<User> }) {
  const user = use(userPromise)  // Suspends until resolved
  return <Profile user={user} />
}

function UserPage({ userId }: { userId: string }) {
  const userPromise = fetchUser(userId)  // Start fetch

  return (
    <Suspense fallback={<Skeleton />}>
      <UserProfile userPromise={userPromise} />
    </Suspense>
  )
}
```

**use() with Context (conditional reading):**

```typescript
import { use } from 'react'

function Button({ showTheme }: { showTheme: boolean }) {
  // Can read context conditionally - not possible with useContext
  if (showTheme) {
    const theme = use(ThemeContext)
    return <button className={theme.button}>Click</button>
  }
  return <button>Click</button>
}
```

**Note:** `use()` can be called conditionally, unlike other hooks. It works in loops and conditionals.

---

## 5. State Management

**Impact: MEDIUM-HIGH**

Proper useState patterns, useReducer for complex state, and context optimization prevent unnecessary re-renders.

### 5.1 Calculate Derived Values During Render

**Impact: MEDIUM (eliminates sync bugs, simpler code)**

Don't store values that can be calculated from existing state or props. Calculate them during render instead.

**Incorrect (derived state in useState):**

```typescript
function ProductList({ products }: { products: Product[] }) {
  const [filter, setFilter] = useState('')
  const [filteredProducts, setFilteredProducts] = useState(products)

  useEffect(() => {
    setFilteredProducts(
      products.filter(p => p.name.includes(filter))
    )
  }, [products, filter])
  // Extra state, effect, potential sync bugs

  return (
    <div>
      <input value={filter} onChange={e => setFilter(e.target.value)} />
      {filteredProducts.map(p => <ProductCard key={p.id} product={p} />)}
    </div>
  )
}
```

**Correct (calculated during render):**

```typescript
function ProductList({ products }: { products: Product[] }) {
  const [filter, setFilter] = useState('')

  // Calculated during render - always in sync
  const filteredProducts = products.filter(p =>
    p.name.toLowerCase().includes(filter.toLowerCase())
  )

  return (
    <div>
      <input value={filter} onChange={e => setFilter(e.target.value)} />
      {filteredProducts.map(p => <ProductCard key={p.id} product={p} />)}
    </div>
  )
}
```

**With memoization for expensive calculations:**

```typescript
function ProductList({ products }: { products: Product[] }) {
  const [filter, setFilter] = useState('')

  const filteredProducts = useMemo(() =>
    products.filter(p => expensiveMatch(p, filter)),
    [products, filter]
  )

  return (/* ... */)
}
```

Reference: [You Might Not Need an Effect](https://react.dev/learn/you-might-not-need-an-effect)

### 5.2 Split Context to Prevent Unnecessary Re-renders

**Impact: MEDIUM (reduces re-renders from context changes)**

When context contains multiple values, split it so components only subscribe to what they need. This prevents re-renders when unrelated values change.

**Incorrect (single context with multiple values):**

```typescript
const AppContext = createContext({
  user: null,
  theme: 'light',
  notifications: []
})

function ThemeButton() {
  const { theme } = useContext(AppContext)
  // Re-renders when user or notifications change!
  return <button className={theme}>Toggle</button>
}
```

**Correct (split contexts):**

```typescript
const UserContext = createContext<User | null>(null)
const ThemeContext = createContext<'light' | 'dark'>('light')
const NotificationContext = createContext<Notification[]>([])

function ThemeButton() {
  const theme = useContext(ThemeContext)
  // Only re-renders when theme changes
  return <button className={theme}>Toggle</button>
}

function AppProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState(null)
  const [theme, setTheme] = useState('light')
  const [notifications, setNotifications] = useState([])

  return (
    <UserContext.Provider value={user}>
      <ThemeContext.Provider value={theme}>
        <NotificationContext.Provider value={notifications}>
          {children}
        </NotificationContext.Provider>
      </ThemeContext.Provider>
    </UserContext.Provider>
  )
}
```

**Alternative (memoized selectors):**

```typescript
const AppContext = createContext({ user: null, theme: 'light' })

function useTheme() {
  const { theme } = useContext(AppContext)
  return useMemo(() => theme, [theme])
}
// Still re-renders on context change, but minimizes work
```

### 5.3 Use Functional State Updates for Derived Values

**Impact: MEDIUM-HIGH (prevents stale closures, stable callbacks)**

When new state depends on previous state, use the functional form of setState. This prevents stale closure bugs and enables stable callbacks.

**Incorrect (stale closure with direct state):**

```typescript
function Counter() {
  const [count, setCount] = useState(0)

  const increment = useCallback(() => {
    setCount(count + 1)  // Captures count at creation time
  }, [count])  // Must include count - callback recreated every render

  return <button onClick={increment}>{count}</button>
}
// increment recreated on every count change
```

**Correct (functional update, stable callback):**

```typescript
function Counter() {
  const [count, setCount] = useState(0)

  const increment = useCallback(() => {
    setCount(c => c + 1)  // Always uses latest count
  }, [])  // Empty deps - never recreated

  return <button onClick={increment}>{count}</button>
}
// increment is stable, safe to pass to memoized children
```

**Multiple updates in sequence:**

```typescript
function handleClick() {
  // Incorrect - all use same count value
  setCount(count + 1)
  setCount(count + 1)
  setCount(count + 1)
  // Result: count + 1 (not count + 3)

  // Correct - each update sees previous result
  setCount(c => c + 1)
  setCount(c => c + 1)
  setCount(c => c + 1)
  // Result: count + 3
}
```

### 5.4 Use Lazy Initialization for Expensive Initial State

**Impact: MEDIUM-HIGH (prevents expensive computation on every render)**

Pass a function to useState for expensive initial values. The function runs only on first render, not on every re-render.

**Incorrect (expensive computation on every render):**

```typescript
function Editor() {
  // parseMarkdown runs on EVERY render, even though result is ignored
  const [content, setContent] = useState(parseMarkdown(initialContent))

  return <textarea value={content} onChange={e => setContent(e.target.value)} />
}
// parseMarkdown wasted on re-renders
```

**Correct (lazy initialization):**

```typescript
function Editor() {
  // parseMarkdown runs only on first render
  const [content, setContent] = useState(() => parseMarkdown(initialContent))

  return <textarea value={content} onChange={e => setContent(e.target.value)} />
}
```

**Common use cases for lazy initialization:**

```typescript
// Reading from localStorage
const [user, setUser] = useState(() => {
  const saved = localStorage.getItem('user')
  return saved ? JSON.parse(saved) : null
})

// Complex object creation
const [formState, setFormState] = useState(() => ({
  fields: createDefaultFields(),
  validation: initializeValidation(),
  touched: new Set()
}))

// Expensive transformation
const [data, setData] = useState(() =>
  rawData.map(item => transformItem(item))
)
```

**Note:** The initializer function receives no arguments. If you need props, create a closure: `useState(() => computeFrom(props.value))`

### 5.5 Use useReducer for Complex State Logic

**Impact: MEDIUM (clearer state transitions, easier testing)**

When state has multiple sub-values or complex update logic, useReducer provides clearer state transitions and easier testing.

**Incorrect (multiple related useState calls):**

```typescript
function ShoppingCart() {
  const [items, setItems] = useState([])
  const [total, setTotal] = useState(0)
  const [discount, setDiscount] = useState(0)
  const [loading, setLoading] = useState(false)

  function addItem(item) {
    setItems([...items, item])
    setTotal(total + item.price)
    // Easy to forget to update all related state
  }

  function applyDiscount(code) {
    setLoading(true)
    // Complex logic spread across multiple setters
  }
}
```

**Correct (useReducer for related state):**

```typescript
type CartState = {
  items: Item[]
  total: number
  discount: number
  loading: boolean
}

type CartAction =
  | { type: 'ADD_ITEM'; item: Item }
  | { type: 'REMOVE_ITEM'; id: string }
  | { type: 'APPLY_DISCOUNT'; code: string; amount: number }
  | { type: 'SET_LOADING'; loading: boolean }

function cartReducer(state: CartState, action: CartAction): CartState {
  switch (action.type) {
    case 'ADD_ITEM':
      return {
        ...state,
        items: [...state.items, action.item],
        total: state.total + action.item.price
      }
    case 'APPLY_DISCOUNT':
      return {
        ...state,
        discount: action.amount,
        loading: false
      }
    default:
      return state
  }
}

function ShoppingCart() {
  const [state, dispatch] = useReducer(cartReducer, initialState)

  function addItem(item: Item) {
    dispatch({ type: 'ADD_ITEM', item })
  }
}
// All state transitions in one place, testable, predictable
```

---

## 6. Memoization & Performance

**Impact: MEDIUM**

Strategic useMemo, useCallback, and React Compiler integration reduce computation and stabilize references.

### 6.1 Avoid Premature Memoization

**Impact: MEDIUM (memoization has overhead, measure first)**

Memoization has costs: storing previous values and comparing. Don't memoize everything - profile first and optimize bottlenecks.

**Incorrect (memoizing everything):**

```typescript
function SimpleList({ items }: { items: string[] }) {
  // Unnecessary - simple calculation
  const count = useMemo(() => items.length, [items])

  // Unnecessary - string concatenation is fast
  const title = useMemo(() => `${count} items`, [count])

  // Unnecessary - simple callback on simple component
  const handleClick = useCallback((id: string) => {
    console.log(id)
  }, [])

  return (
    <ul>
      <li>{title}</li>
      {items.map(item => (
        <li key={item} onClick={() => handleClick(item)}>{item}</li>
      ))}
    </ul>
  )
}
// Memoization overhead exceeds the cost it's trying to save
```

**Correct (memoize only what's needed):**

```typescript
function SimpleList({ items }: { items: string[] }) {
  // No memoization needed for cheap operations
  const count = items.length
  const title = `${count} items`

  return (
    <ul>
      <li>{title}</li>
      {items.map(item => (
        <li key={item}>{item}</li>
      ))}
    </ul>
  )
}
```

**When to memoize:**
- React Profiler shows component is slow
- Large arrays (1000+ items) with expensive operations
- Passing callbacks to many memoized children
- Complex object creation passed as props

**When NOT to memoize:**
- Simple calculations (length, concatenation)
- Components that render fast (<16ms)
- Dependencies change on every render
- Development-only "optimization"

### 6.2 Leverage React Compiler for Automatic Memoization

**Impact: MEDIUM (automatic optimization, less manual code)**

React Compiler (stable in React 19) automatically memoizes components and values. Reduce manual useMemo/useCallback when compiler is enabled.

**Incorrect (verbose manual memoization):**

```typescript
function ProductPage({ product }: { product: Product }) {
  const formattedPrice = useMemo(() =>
    formatCurrency(product.price),
    [product.price]
  )

  const handleAddToCart = useCallback(() => {
    addToCart(product.id)
  }, [product.id])

  const relatedProducts = useMemo(() =>
    products.filter(p => p.category === product.category),
    [products, product.category]
  )

  return (
    <div>
      <h1>{product.name}</h1>
      <p>{formattedPrice}</p>
      <AddButton onClick={handleAddToCart} />
      <RelatedList products={relatedProducts} />
    </div>
  )
}
// Lots of manual memoization boilerplate
```

**Correct (React Compiler handles memoization):**

```typescript
function ProductPage({ product }: { product: Product }) {
  // Compiler automatically memoizes these
  const formattedPrice = formatCurrency(product.price)

  function handleAddToCart() {
    addToCart(product.id)
  }

  const relatedProducts = products.filter(
    p => p.category === product.category
  )

  return (
    <div>
      <h1>{product.name}</h1>
      <p>{formattedPrice}</p>
      <AddButton onClick={handleAddToCart} />
      <RelatedList products={relatedProducts} />
    </div>
  )
}
// Cleaner code, compiler handles memoization
```

**Enabling React Compiler:**

```javascript
// babel.config.js
module.exports = {
  plugins: [
    ['babel-plugin-react-compiler', {}]
  ]
}
```

**Note:** Still use manual memoization for edge cases the compiler can't optimize, and measure with React Profiler.

### 6.3 Use React.memo for Expensive Pure Components

**Impact: MEDIUM (skips re-render when props unchanged)**

Wrap components in memo() to skip re-renders when props are the same. Effective for expensive renders with stable props.

**Incorrect (re-renders on parent state change):**

```typescript
function ProductList({ products }: { products: Product[] }) {
  return products.map(product => (
    <ProductCard key={product.id} product={product} />
  ))
}

function ProductCard({ product }: { product: Product }) {
  // Expensive render with lots of calculations
  const rating = calculateRating(product.reviews)
  const availability = checkInventory(product.id)

  return (
    <div>
      <h3>{product.name}</h3>
      <Rating value={rating} />
      <Availability status={availability} />
    </div>
  )
}
// Every ProductCard re-renders when any parent state changes
```

**Correct (memoized component):**

```typescript
import { memo } from 'react'

const ProductCard = memo(function ProductCard({ product }: { product: Product }) {
  const rating = calculateRating(product.reviews)
  const availability = checkInventory(product.id)

  return (
    <div>
      <h3>{product.name}</h3>
      <Rating value={rating} />
      <Availability status={availability} />
    </div>
  )
})
// Only re-renders when product prop changes
```

**Custom comparison for complex props:**

```typescript
const ProductCard = memo(
  function ProductCard({ product, onClick }) {
    // ...
  },
  (prevProps, nextProps) => {
    // Return true if props are equal (skip re-render)
    return prevProps.product.id === nextProps.product.id &&
           prevProps.product.updatedAt === nextProps.product.updatedAt
  }
)
```

**Note:** Ensure props passed to memo'd components are stable (primitives, memoized objects/functions).

### 6.4 Use useCallback for Stable Function References

**Impact: MEDIUM (prevents child re-renders from reference changes)**

Wrap callbacks in useCallback when passing them to memoized children. Without stable references, memo() is ineffective.

**Incorrect (new function reference on every render):**

```typescript
function Parent() {
  const [count, setCount] = useState(0)

  function handleClick() {
    console.log('clicked')
  }

  return (
    <div>
      <p>{count}</p>
      <button onClick={() => setCount(c => c + 1)}>Increment</button>
      <ExpensiveChild onClick={handleClick} />
    </div>
  )
}

const ExpensiveChild = memo(function ExpensiveChild({ onClick }) {
  // Re-renders every time Parent renders because handleClick is new
  return <button onClick={onClick}>Click me</button>
})
```

**Correct (stable callback with useCallback):**

```typescript
import { useCallback, memo, useState } from 'react'

function Parent() {
  const [count, setCount] = useState(0)

  const handleClick = useCallback(() => {
    console.log('clicked')
  }, [])  // Empty deps = stable reference

  return (
    <div>
      <p>{count}</p>
      <button onClick={() => setCount(c => c + 1)}>Increment</button>
      <ExpensiveChild onClick={handleClick} />
    </div>
  )
}

const ExpensiveChild = memo(function ExpensiveChild({ onClick }) {
  // Only re-renders if onClick reference changes
  return <button onClick={onClick}>Click me</button>
})
```

**Combine with functional setState:**

```typescript
const handleIncrement = useCallback(() => {
  setCount(c => c + 1)  // Functional form - no dependency on count
}, [])  // Stable forever
```

### 6.5 Use useMemo for Expensive Calculations

**Impact: MEDIUM (skips expensive recalculation on re-renders)**

Wrap expensive computations in useMemo to cache results between renders. Only recalculate when dependencies change.

**Incorrect (recalculates on every render):**

```typescript
function AnalyticsChart({ data, filter }: { data: DataPoint[]; filter: Filter }) {
  // Expensive aggregation runs on every render
  const aggregated = data
    .filter(d => matchesFilter(d, filter))
    .reduce((acc, d) => aggregate(acc, d), initialAcc)

  return <Chart data={aggregated} />
}
// Parent re-render → expensive calculation runs
```

**Correct (memoized calculation):**

```typescript
import { useMemo } from 'react'

function AnalyticsChart({ data, filter }: { data: DataPoint[]; filter: Filter }) {
  const aggregated = useMemo(() => {
    return data
      .filter(d => matchesFilter(d, filter))
      .reduce((acc, d) => aggregate(acc, d), initialAcc)
  }, [data, filter])

  return <Chart data={aggregated} />
}
// Only recalculates when data or filter changes
```

**When to use useMemo:**
- Large array transformations (filter, map, reduce)
- Complex object computations
- Expensive algorithms (sorting, searching)

**When NOT to use useMemo:**
- Simple calculations (addition, string concatenation)
- When the component rarely re-renders
- When dependencies change on every render

**Note:** With React Compiler (React 19+), manual memoization becomes less necessary as the compiler handles it automatically.

---

## 7. Effects & Events

**Impact: MEDIUM**

Proper useEffect patterns, useEffectEvent for non-reactive logic, and avoiding unnecessary effects improve reliability.

### 7.1 Always Clean Up Effect Side Effects

**Impact: MEDIUM (prevents memory leaks, stale callbacks)**

Return a cleanup function from effects that set up subscriptions, timers, or event listeners. This prevents memory leaks and stale callbacks.

**Incorrect (no cleanup):**

```typescript
function Timer() {
  const [seconds, setSeconds] = useState(0)

  useEffect(() => {
    const id = setInterval(() => {
      setSeconds(s => s + 1)
    }, 1000)
    // No cleanup - interval keeps running after unmount!
  }, [])

  return <span>{seconds}s</span>
}
// Memory leak: interval runs forever
```

**Correct (cleanup function):**

```typescript
function Timer() {
  const [seconds, setSeconds] = useState(0)

  useEffect(() => {
    const id = setInterval(() => {
      setSeconds(s => s + 1)
    }, 1000)

    return () => clearInterval(id)  // Cleanup on unmount
  }, [])

  return <span>{seconds}s</span>
}
```

**Cleanup patterns:**

```typescript
// Event listeners
useEffect(() => {
  const handler = () => { /* ... */ }
  window.addEventListener('resize', handler)
  return () => window.removeEventListener('resize', handler)
}, [])

// Abort fetch on unmount
useEffect(() => {
  const controller = new AbortController()

  fetch('/api/data', { signal: controller.signal })
    .then(res => res.json())
    .then(setData)

  return () => controller.abort()
}, [])

// WebSocket connection
useEffect(() => {
  const ws = new WebSocket(url)
  ws.onmessage = handleMessage
  return () => ws.close()
}, [url])
```

### 7.2 Avoid Effects for Derived State and User Events

**Impact: MEDIUM (eliminates sync bugs, simpler code)**

Effects synchronize with external systems. Don't use them for: updating state based on props/state, or handling user events.

**Incorrect (effect for derived state):**

```typescript
function Form() {
  const [firstName, setFirstName] = useState('')
  const [lastName, setLastName] = useState('')
  const [fullName, setFullName] = useState('')

  useEffect(() => {
    setFullName(`${firstName} ${lastName}`)
  }, [firstName, lastName])
  // Extra render, potential sync bugs

  return <input value={fullName} disabled />
}
```

**Correct (calculate during render):**

```typescript
function Form() {
  const [firstName, setFirstName] = useState('')
  const [lastName, setLastName] = useState('')

  // Calculate during render - always in sync
  const fullName = `${firstName} ${lastName}`

  return <input value={fullName} disabled />
}
```

**Incorrect (effect for user event):**

```typescript
function BuyButton({ product }) {
  useEffect(() => {
    // ❌ Analytics for user action in effect
    if (product.wasAddedToCart) {
      trackPurchase(product)
    }
  }, [product])
}
```

**Correct (handle in event handler):**

```typescript
function BuyButton({ product }) {
  function handleClick() {
    addToCart(product)
    trackPurchase(product)  // ✅ In event handler
  }

  return <button onClick={handleClick}>Buy</button>
}
```

Reference: [You Might Not Need an Effect](https://react.dev/learn/you-might-not-need-an-effect)

### 7.3 Avoid Object and Array Dependencies in Effects

**Impact: MEDIUM (prevents infinite loops, unnecessary re-runs)**

Objects and arrays created during render have new references each time. Move them outside the component, inside the effect, or memoize them.

**Incorrect (object dependency causes infinite loop):**

```typescript
function ChatRoom({ roomId }) {
  const options = { roomId, serverUrl: 'https://chat.example.com' }

  useEffect(() => {
    const connection = createConnection(options)
    connection.connect()
    return () => connection.disconnect()
  }, [options])  // New object every render = infinite loop!
}
```

**Correct (extract primitive dependencies):**

```typescript
function ChatRoom({ roomId }) {
  useEffect(() => {
    const options = { roomId, serverUrl: 'https://chat.example.com' }
    const connection = createConnection(options)
    connection.connect()
    return () => connection.disconnect()
  }, [roomId])  // Primitive dependency, stable
}
```

**Alternative (memoize if object must be prop):**

```typescript
function ChatRoom({ roomId }) {
  const options = useMemo(() => ({
    roomId,
    serverUrl: 'https://chat.example.com'
  }), [roomId])

  useEffect(() => {
    const connection = createConnection(options)
    connection.connect()
    return () => connection.disconnect()
  }, [options])  // Stable reference when roomId is same
}
```

**Best practice:** Always use primitive values in dependency arrays when possible. If you need an object, create it inside the effect.

### 7.4 Use useEffectEvent for Non-Reactive Logic

**Impact: MEDIUM (separates reactive from non-reactive code)**

`useEffectEvent` creates a function that always sees the latest values but doesn't trigger effect re-runs. Use it for "event-like" behavior inside effects.

**Incorrect (including non-reactive values in deps):**

```typescript
function ChatRoom({ roomId, theme }) {
  useEffect(() => {
    const connection = createConnection(roomId)
    connection.on('message', (msg) => {
      // theme is needed but shouldn't reconnect when it changes
      showNotification(msg, theme)
    })
    connection.connect()
    return () => connection.disconnect()
  }, [roomId, theme])  // Reconnects when theme changes!
}
```

**Correct (useEffectEvent for non-reactive logic):**

```typescript
import { useEffect, useEffectEvent } from 'react'

function ChatRoom({ roomId, theme }) {
  // Non-reactive: doesn't cause effect to re-run
  const onMessage = useEffectEvent((msg: Message) => {
    showNotification(msg, theme)  // Always reads latest theme
  })

  useEffect(() => {
    const connection = createConnection(roomId)
    connection.on('message', onMessage)
    connection.connect()
    return () => connection.disconnect()
  }, [roomId])  // Only reconnects when roomId changes
}
```

**When to use useEffectEvent:**
- Reading latest props/state in effect callbacks
- Logging/analytics that shouldn't re-trigger effects
- Side effects that depend on current values but aren't "about" those values

**Note:** `useEffectEvent` is stable in React 19.2. It replaces the pattern of suppressing exhaustive-deps warnings.

### 7.5 Use useSyncExternalStore for External Subscriptions

**Impact: MEDIUM (correct subscription handling, SSR compatible)**

For subscribing to external data sources (browser APIs, third-party stores), use `useSyncExternalStore` instead of manual useEffect subscriptions.

**Incorrect (manual subscription in effect):**

```typescript
function NetworkStatus() {
  const [isOnline, setIsOnline] = useState(true)

  useEffect(() => {
    function handleOnline() { setIsOnline(true) }
    function handleOffline() { setIsOnline(false) }

    window.addEventListener('online', handleOnline)
    window.addEventListener('offline', handleOffline)

    return () => {
      window.removeEventListener('online', handleOnline)
      window.removeEventListener('offline', handleOffline)
    }
  }, [])
  // Manual cleanup, no SSR support, potential race conditions

  return <span>{isOnline ? 'Online' : 'Offline'}</span>
}
```

**Correct (useSyncExternalStore):**

```typescript
import { useSyncExternalStore } from 'react'

function subscribe(callback: () => void) {
  window.addEventListener('online', callback)
  window.addEventListener('offline', callback)
  return () => {
    window.removeEventListener('online', callback)
    window.removeEventListener('offline', callback)
  }
}

function NetworkStatus() {
  const isOnline = useSyncExternalStore(
    subscribe,
    () => navigator.onLine,      // Client value
    () => true                    // Server value (SSR)
  )

  return <span>{isOnline ? 'Online' : 'Offline'}</span>
}
```

**For browser storage:**

```typescript
function useLocalStorage(key: string) {
  return useSyncExternalStore(
    (callback) => {
      window.addEventListener('storage', callback)
      return () => window.removeEventListener('storage', callback)
    },
    () => localStorage.getItem(key),
    () => null  // SSR fallback
  )
}
```

Reference: [You Might Not Need an Effect](https://react.dev/learn/you-might-not-need-an-effect)

---

## 8. Component Patterns

**Impact: LOW-MEDIUM**

Composition over inheritance, render props, and children patterns enable flexible, reusable components.

### 8.1 Choose Controlled vs Uncontrolled Appropriately

**Impact: LOW-MEDIUM (correct data flow, proper form handling)**

Controlled components get values from props. Uncontrolled components manage their own state. Choose based on whether you need to react to every change.

**Incorrect (controlled for simple submission-only form):**

```typescript
function SimpleForm() {
  function handleSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault()
    const formData = new FormData(e.currentTarget)
    const name = formData.get('name')
    // Use name on submit
  }

  return (
    <form onSubmit={handleSubmit}>
      <input name="name" defaultValue="John" />
      <button>Submit</button>
    </form>
  )
}
// Less code, works for simple forms
```

**Correct (uncontrolled for simple form, controlled for validation):**

```typescript
function ValidatedForm() {
  const [email, setEmail] = useState('')
  const isValid = email.includes('@')

  return (
    <form>
      <input
        value={email}
        onChange={e => setEmail(e.target.value)}
        className={isValid ? '' : 'error'}
      />
      {!isValid && <span>Enter valid email</span>}
      <button disabled={!isValid}>Submit</button>
    </form>
  )
}
// React to every keystroke
```

**Decision guide:**
| Need | Use |
|------|-----|
| Submit-only validation | Uncontrolled |
| Real-time validation | Controlled |
| Conditional UI based on value | Controlled |
| Third-party form library | Check library docs |
| Maximum simplicity | Uncontrolled |
| Programmatic value changes | Controlled |

### 8.2 Prefer Composition Over Props Explosion

**Impact: LOW-MEDIUM (more flexible, reusable components)**

Instead of passing many configuration props, accept children or render props. This makes components more flexible and reusable.

**Incorrect (props explosion):**

```typescript
function Card({
  title,
  subtitle,
  icon,
  actions,
  footer,
  headerBg,
  bodyPadding,
  showBorder
}: CardProps) {
  return (
    <div className={showBorder ? 'border' : ''}>
      <header style={{ background: headerBg }}>
        {icon}
        <h2>{title}</h2>
        <span>{subtitle}</span>
        {actions}
      </header>
      <div style={{ padding: bodyPadding }}>
        {/* Where's the content? */}
      </div>
      {footer}
    </div>
  )
}
// Hard to extend, many optional props
```

**Correct (composition with children):**

```typescript
function Card({ children }: { children: ReactNode }) {
  return <div className="card">{children}</div>
}

function CardHeader({ children }: { children: ReactNode }) {
  return <header className="card-header">{children}</header>
}

function CardBody({ children }: { children: ReactNode }) {
  return <div className="card-body">{children}</div>
}

// Usage - flexible composition
<Card>
  <CardHeader>
    <Icon name="user" />
    <h2>User Profile</h2>
    <Button>Edit</Button>
  </CardHeader>
  <CardBody>
    <ProfileForm />
  </CardBody>
</Card>
```

**Benefits:**
- Each component has single responsibility
- Easy to add new variants
- TypeScript infers children correctly
- No prop drilling through layers

### 8.3 Use Key to Reset Component State

**Impact: LOW-MEDIUM (correct state isolation, proper resets)**

When you need to fully reset a component's internal state, change its key. This unmounts the old instance and mounts a fresh one.

**Incorrect (state persists between items):**

```typescript
function UserEditor({ user }: { user: User }) {
  const [draft, setDraft] = useState(user.bio)

  // When user changes, draft keeps old value!
  return (
    <textarea value={draft} onChange={e => setDraft(e.target.value)} />
  )
}

function App() {
  const [selectedUser, setSelectedUser] = useState(users[0])

  return (
    <div>
      <UserList onSelect={setSelectedUser} />
      <UserEditor user={selectedUser} />
    </div>
  )
}
// Switching users shows stale draft text
```

**Correct (key forces fresh instance):**

```typescript
function App() {
  const [selectedUser, setSelectedUser] = useState(users[0])

  return (
    <div>
      <UserList onSelect={setSelectedUser} />
      <UserEditor key={selectedUser.id} user={selectedUser} />
    </div>
  )
}
// Each user gets fresh editor state
```

**Alternative (controlled reset with effect):**

```typescript
function UserEditor({ user }: { user: User }) {
  const [draft, setDraft] = useState(user.bio)

  // Sync when user changes
  useEffect(() => {
    setDraft(user.bio)
  }, [user.id])

  return (
    <textarea value={draft} onChange={e => setDraft(e.target.value)} />
  )
}
// Works but key approach is cleaner
```

**Use key reset for:**
- Form editors switching between items
- Chat components switching rooms
- Any stateful component that should reset on prop change

### 8.4 Use Render Props for Inversion of Control

**Impact: LOW-MEDIUM (flexible rendering, shared logic)**

Render props let parent components control how data is rendered while child components manage state and logic.

**Incorrect (fixed rendering in reusable component):**

```typescript
function DataFetcher({ url }: { url: string }) {
  const [data, setData] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetch(url).then(res => res.json()).then(setData).finally(() => setLoading(false))
  }, [url])

  if (loading) return <Spinner />
  return <pre>{JSON.stringify(data)}</pre>  // Fixed rendering
}
// Can't customize how data is displayed
```

**Correct (render prop for flexible rendering):**

```typescript
function DataFetcher<T>({
  url,
  render,
  fallback
}: {
  url: string
  render: (data: T) => ReactNode
  fallback?: ReactNode
}) {
  const [data, setData] = useState<T | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetch(url).then(res => res.json()).then(setData).finally(() => setLoading(false))
  }, [url])

  if (loading) return fallback ?? <Spinner />
  if (!data) return null
  return <>{render(data)}</>
}

// Usage - caller controls rendering
<DataFetcher
  url="/api/users"
  render={(users) => (
    <UserList users={users} />
  )}
  fallback={<UserListSkeleton />}
/>
```

**Alternative (children as function):**

```typescript
<DataFetcher url="/api/users">
  {(users) => <UserList users={users} />}
</DataFetcher>
```

---

## References

1. [https://react.dev](https://react.dev)
2. [https://react.dev/blog/2024/12/05/react-19](https://react.dev/blog/2024/12/05/react-19)
3. [https://react.dev/blog/2025/10/01/react-19-2](https://react.dev/blog/2025/10/01/react-19-2)
4. [https://react.dev/learn/you-might-not-need-an-effect](https://react.dev/learn/you-might-not-need-an-effect)
5. [https://github.com/facebook/react](https://github.com/facebook/react)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |