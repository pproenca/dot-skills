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

Comprehensive performance optimization guide for React 19 applications, designed for AI agents and LLMs. Contains 42 rules across 8 categories, prioritized by impact from critical (Actions, data fetching, Suspense) to incremental (DOM optimizations, hydration). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated refactoring and code generation.

---

## Table of Contents

1. [Actions & Async Patterns](#1-actions-async-patterns) — **CRITICAL**
   - 1.1 [Avoid Sequential Action Calls](#11-avoid-sequential-action-calls)
   - 1.2 [Use Form Actions Instead of onSubmit Handlers](#12-use-form-actions-instead-of-onsubmit-handlers)
   - 1.3 [Use Server Actions for Mutations](#13-use-server-actions-for-mutations)
   - 1.4 [Use useActionState for Form State Management](#14-use-useactionstate-for-form-state-management)
   - 1.5 [Use useFormStatus for Nested Form Components](#15-use-useformstatus-for-nested-form-components)
   - 1.6 [Wrap Actions with Error Boundaries](#16-wrap-actions-with-error-boundaries)
2. [Data Fetching & Suspense](#2-data-fetching-suspense) — **CRITICAL**
   - 2.1 [Fetch Data in Parallel with Promise.all](#21-fetch-data-in-parallel-with-promiseall)
   - 2.2 [Never Create Promises During Render](#22-never-create-promises-during-render)
   - 2.3 [Pair Suspense with Error Boundaries](#23-pair-suspense-with-error-boundaries)
   - 2.4 [Place Suspense Boundaries Strategically](#24-place-suspense-boundaries-strategically)
   - 2.5 [Use the use Hook Conditionally](#25-use-the-use-hook-conditionally)
   - 2.6 [Use the use Hook for Promise Reading](#26-use-the-use-hook-for-promise-reading)
3. [Server Components](#3-server-components) — **HIGH**
   - 3.1 [Default to Server Components](#31-default-to-server-components)
   - 3.2 [Isolate Interactivity into Client Islands](#32-isolate-interactivity-into-client-islands)
   - 3.3 [Pass Only Serializable Data to Client Components](#33-pass-only-serializable-data-to-client-components)
   - 3.4 [Preload Data to Avoid Waterfalls](#34-preload-data-to-avoid-waterfalls)
   - 3.5 [Use React cache() for Request Deduplication](#35-use-react-cache-for-request-deduplication)
4. [React Compiler Optimization](#4-react-compiler-optimization) — **HIGH**
   - 4.1 [Apply use-no-memo Directive to Opt Out of Compilation](#41-apply-use-no-memo-directive-to-opt-out-of-compilation)
   - 4.2 [Follow Rules of React for Compiler Compatibility](#42-follow-rules-of-react-for-compiler-compatibility)
   - 4.3 [Trust the Compiler for Memoization](#43-trust-the-compiler-for-memoization)
   - 4.4 [Use Manual Memoization for Effect Dependencies](#44-use-manual-memoization-for-effect-dependencies)
5. [State Management](#5-state-management) — **MEDIUM-HIGH**
   - 5.1 [Use Functional setState for Derived Updates](#51-use-functional-setstate-for-derived-updates)
   - 5.2 [Use Lazy Initialization for Expensive Initial State](#52-use-lazy-initialization-for-expensive-initial-state)
   - 5.3 [Use useDeferredValue for Non-Urgent Updates](#53-use-usedeferredvalue-for-non-urgent-updates)
   - 5.4 [Use useOptimistic for Instant Feedback](#54-use-useoptimistic-for-instant-feedback)
   - 5.5 [Use useTransition for Non-Blocking State Updates](#55-use-usetransition-for-non-blocking-state-updates)
6. [Rendering Optimization](#6-rendering-optimization) — **MEDIUM**
   - 6.1 [Avoid Cascading State Updates in Effects](#61-avoid-cascading-state-updates-in-effects)
   - 6.2 [Enable Streaming SSR with Suspense](#62-enable-streaming-ssr-with-suspense)
   - 6.3 [Leverage Concurrent Rendering by Default](#63-leverage-concurrent-rendering-by-default)
   - 6.4 [Memoize Expensive Child Components](#64-memoize-expensive-child-components)
   - 6.5 [Pass Children as Props to Avoid Re-renders](#65-pass-children-as-props-to-avoid-re-renders)
   - 6.6 [Use Stable Keys for List Rendering](#66-use-stable-keys-for-list-rendering)
7. [Component Patterns](#7-component-patterns) — **MEDIUM**
   - 7.1 [Apply use-server Directive for Server Actions Only](#71-apply-use-server-directive-for-server-actions-only)
   - 7.2 [Define Document Metadata in Components](#72-define-document-metadata-in-components)
   - 7.3 [Place Context Providers Outside Client Boundaries](#73-place-context-providers-outside-client-boundaries)
   - 7.4 [Place use client at Component Boundaries](#74-place-use-client-at-component-boundaries)
   - 7.5 [Use ref as a Prop Instead of forwardRef](#75-use-ref-as-a-prop-instead-of-forwardref)
8. [DOM & Hydration](#8-dom-hydration) — **LOW-MEDIUM**
   - 8.1 [Handle Hydration Mismatches Properly](#81-handle-hydration-mismatches-properly)
   - 8.2 [Preload Critical Resources](#82-preload-critical-resources)
   - 8.3 [Use Custom Elements with Full Prop Support](#83-use-custom-elements-with-full-prop-support)
   - 8.4 [Use Ref Cleanup Functions](#84-use-ref-cleanup-functions)
   - 8.5 [Use Stylesheet Precedence for CSS Loading](#85-use-stylesheet-precedence-for-css-loading)

---

## 1. Actions & Async Patterns

**Impact: CRITICAL**

Actions are React 19's paradigm shift for handling mutations. Improper action patterns cause request waterfalls, poor pending states, and broken error handling.

### 1.1 Avoid Sequential Action Calls

**Impact: CRITICAL (2-5× improvement for independent mutations)**

When multiple actions have no dependencies, execute them concurrently. Sequential awaits add full round-trip latency for each operation.

**Incorrect (sequential execution, 3 round trips):**

```tsx
async function handleBulkUpdate(items: Item[]) {
  const updatedItems: Item[] = []

  for (const item of items) {
    const result = await updateItem(item)  // Waits for each one
    updatedItems.push(result)
  }

  return updatedItems
}
```

**Correct (parallel execution, 1 round trip):**

```tsx
async function handleBulkUpdate(items: Item[]) {
  const results = await Promise.all(
    items.map(item => updateItem(item))  // All requests fire simultaneously
  )

  return results
}
```

**Alternative (with error isolation):**

```tsx
async function handleBulkUpdate(items: Item[]) {
  const results = await Promise.allSettled(
    items.map(item => updateItem(item))
  )

  const succeeded = results
    .filter((r): r is PromiseFulfilledResult<Item> => r.status === 'fulfilled')
    .map(r => r.value)

  return succeeded
}
```

**When NOT to use this pattern:**
- Actions depend on results from previous actions
- Server has rate limiting that requires sequential requests
- Order of operations matters for data consistency

Reference: [React 19 Actions](https://react.dev/blog/2024/12/05/react-19#actions)

### 1.2 Use Form Actions Instead of onSubmit Handlers

**Impact: CRITICAL (eliminates manual pending/error state management, automatic form reset)**

React 19 form actions handle pending states, errors, and form resets automatically. Manual onSubmit handlers require managing these states yourself and break progressive enhancement.

**Incorrect (manual state management, no progressive enhancement):**

```tsx
function ContactForm() {
  const [isPending, setIsPending] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()  // Breaks without JS
    setIsPending(true)
    setError(null)
    const formData = new FormData(e.target as HTMLFormElement)
    const result = await submitContact(formData)
    setIsPending(false)
    if (result.error) setError(result.error)
  }

  return (
    <form onSubmit={handleSubmit}>
      <input name="email" type="email" />
      <button disabled={isPending}>Submit</button>
      {error && <p>{error}</p>}
    </form>
  )
}
```

**Correct (automatic state management, works without JS):**

```tsx
function ContactForm() {
  const [error, submitAction, isPending] = useActionState(
    async (prevState: string | null, formData: FormData) => {
      const result = await submitContact(formData)
      if (result.error) return result.error
      redirect('/success')
      return null
    },
    null
  )

  return (
    <form action={submitAction}>
      <input name="email" type="email" />
      <button disabled={isPending}>Submit</button>
      {error && <p>{error}</p>}
    </form>
  )
}
```

**Benefits:**
- Form works without JavaScript (progressive enhancement)
- Automatic pending state via `isPending`
- Automatic form reset on successful submission
- Cleaner error handling with previous state access

Reference: [React 19 Actions](https://react.dev/blog/2024/12/05/react-19#actions)

### 1.3 Use Server Actions for Mutations

**Impact: CRITICAL (zero client-side mutation code, automatic revalidation, smaller bundles)**

Server Actions move mutation logic to the server, eliminating client-side API calls and reducing bundle size. They integrate directly with form actions and handle revalidation automatically.

**Incorrect (client-side API calls):**

```tsx
// app/actions.ts - runs on client
async function updateUser(formData: FormData) {
  const response = await fetch('/api/users', {
    method: 'POST',
    body: formData,
  })
  if (!response.ok) throw new Error('Failed to update')
  return response.json()
}

// app/profile/page.tsx
'use client'
function ProfilePage() {
  const handleSubmit = async (formData: FormData) => {
    await updateUser(formData)  // Client fetches API
    router.refresh()  // Manual revalidation
  }

  return <form action={handleSubmit}>...</form>
}
```

**Correct (server-side mutation):**

```tsx
// app/actions.ts - runs on server only
'use server'

import { revalidatePath } from 'next/cache'
import { db } from '@/lib/db'

export async function updateUser(formData: FormData) {
  const name = formData.get('name') as string
  await db.user.update({ where: { id: userId }, data: { name } })
  revalidatePath('/profile')  // Automatic revalidation
}

// app/profile/page.tsx - can be Server Component
import { updateUser } from './actions'

function ProfilePage() {
  return (
    <form action={updateUser}>  {/* Direct server call */}
      <input name="name" />
      <button>Save</button>
    </form>
  )
}
```

**Benefits:**
- No API route boilerplate
- Direct database access from actions
- Automatic cache revalidation
- Credentials stay server-side
- Smaller client bundles

Reference: [Server Actions](https://react.dev/reference/rsc/server-actions)

### 1.4 Use useActionState for Form State Management

**Impact: CRITICAL (eliminates 3-4 useState calls per form, centralizes action lifecycle)**

The `useActionState` hook consolidates pending state, error handling, and result management into a single API. Manual useState patterns are verbose and error-prone.

**Incorrect (multiple useState hooks, manual orchestration):**

```tsx
function UpdateProfile() {
  const [name, setName] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [isPending, setIsPending] = useState(false)
  const [lastResult, setLastResult] = useState<Profile | null>(null)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setIsPending(true)
    setError(null)
    try {
      const result = await updateProfile(name)
      setLastResult(result)
    } catch (err) {
      setError(err.message)
    } finally {
      setIsPending(false)
    }
  }

  return <form onSubmit={handleSubmit}>...</form>
}
```

**Correct (single hook manages entire lifecycle):**

```tsx
function UpdateProfile() {
  const [state, submitAction, isPending] = useActionState(
    async (prev: ActionState, formData: FormData) => {
      const name = formData.get('name') as string
      try {
        const profile = await updateProfile(name)
        return { profile, error: null }
      } catch (err) {
        return { profile: prev.profile, error: err.message }
      }
    },
    { profile: null, error: null }
  )

  return (
    <form action={submitAction}>
      <input name="name" defaultValue={state.profile?.name} />
      <button disabled={isPending}>Save</button>
      {state.error && <p className="error">{state.error}</p>}
    </form>
  )
}
```

**Benefits:**
- Single source of truth for action state
- Previous state accessible in action function
- Automatic pending state tracking
- Works with Server Actions directly

Reference: [useActionState](https://react.dev/reference/react/useActionState)

### 1.5 Use useFormStatus for Nested Form Components

**Impact: CRITICAL (eliminates prop drilling for form state, enables reusable submit buttons)**

The `useFormStatus` hook provides form pending state to any component inside a form without prop drilling. This enables truly reusable form components.

**Incorrect (prop drilling pending state):**

```tsx
function SubmitButton({ isPending }: { isPending: boolean }) {
  return <button disabled={isPending}>{isPending ? 'Saving...' : 'Save'}</button>
}

function ContactForm() {
  const [state, action, isPending] = useActionState(submitContact, null)

  return (
    <form action={action}>
      <input name="email" />
      <SubmitButton isPending={isPending} />  {/* Must pass prop */}
    </form>
  )
}

function ProfileForm() {
  const [state, action, isPending] = useActionState(updateProfile, null)

  return (
    <form action={action}>
      <input name="name" />
      <SubmitButton isPending={isPending} />  {/* Must pass prop again */}
    </form>
  )
}
```

**Correct (automatic form state access):**

```tsx
function SubmitButton({ children }: { children: React.ReactNode }) {
  const { pending } = useFormStatus()  // Reads from nearest parent form
  return <button disabled={pending}>{pending ? 'Saving...' : children}</button>
}

function ContactForm() {
  const [state, action] = useActionState(submitContact, null)

  return (
    <form action={action}>
      <input name="email" />
      <SubmitButton>Send</SubmitButton>  {/* No props needed */}
    </form>
  )
}

function ProfileForm() {
  const [state, action] = useActionState(updateProfile, null)

  return (
    <form action={action}>
      <input name="name" />
      <SubmitButton>Save</SubmitButton>  {/* Same component, no props */}
    </form>
  )
}
```

**Note:** `useFormStatus` must be called from a component rendered inside a `<form>`. It cannot be called from the same component that renders the form.

Reference: [useFormStatus](https://react.dev/reference/react-dom/hooks/useFormStatus)

### 1.6 Wrap Actions with Error Boundaries

**Impact: CRITICAL (prevents unhandled rejections from crashing the app)**

Actions that throw errors will propagate to the nearest Error Boundary. Without proper boundaries, a single failed action can crash your entire application.

**Incorrect (no error boundary, crash on failure):**

```tsx
function CheckoutPage() {
  const [state, submitOrder] = useActionState(async (prev, formData) => {
    const result = await processPayment(formData)  // Throws on failure
    return result
  }, null)

  return (
    <form action={submitOrder}>
      <CardInput />
      <button>Pay Now</button>
    </form>
  )
}

// If processPayment throws, the entire page crashes
```

**Correct (error boundary catches failures):**

```tsx
function CheckoutPage() {
  return (
    <ErrorBoundary fallback={<PaymentErrorFallback />}>
      <PaymentForm />
    </ErrorBoundary>
  )
}

function PaymentForm() {
  const [state, submitOrder] = useActionState(async (prev, formData) => {
    const result = await processPayment(formData)
    if (result.error) {
      return { error: result.error }  // Handled errors stay in state
    }
    redirect('/confirmation')
    return { error: null }
  }, { error: null })

  return (
    <form action={submitOrder}>
      <CardInput />
      <button>Pay Now</button>
      {state.error && <p className="error">{state.error}</p>}
    </form>
  )
}

function PaymentErrorFallback() {
  return (
    <div>
      <h2>Payment failed</h2>
      <button onClick={() => window.location.reload()}>Try again</button>
    </div>
  )
}
```

**Best practices:**
- Return errors in state for recoverable failures
- Let Error Boundaries catch unexpected exceptions
- Provide meaningful fallback UI with recovery options

Reference: [Error Boundaries with Actions](https://react.dev/reference/react/useActionState#displaying-errors-with-an-error-boundary)

---

## 2. Data Fetching & Suspense

**Impact: CRITICAL**

The `use` hook and Suspense boundaries determine initial load performance. Misusing promises in render or improper boundary placement blocks streaming and creates waterfalls.

### 2.1 Fetch Data in Parallel with Promise.all

**Impact: CRITICAL (2-5× faster data loading, eliminates sequential waterfalls)**

Sequential awaits in async components create waterfalls where each fetch waits for the previous one. Use Promise.all to fetch independent data concurrently.

**Incorrect (sequential fetching, 3 round trips):**

```tsx
async function DashboardPage() {
  const user = await fetchUser()           // 200ms
  const orders = await fetchOrders()       // 300ms (waits for user)
  const notifications = await fetchNotifications()  // 150ms (waits for orders)
  // Total: 650ms

  return (
    <div>
      <UserHeader user={user} />
      <OrderList orders={orders} />
      <NotificationBell notifications={notifications} />
    </div>
  )
}
```

**Correct (parallel fetching, 1 round trip):**

```tsx
async function DashboardPage() {
  const [user, orders, notifications] = await Promise.all([
    fetchUser(),           // 200ms
    fetchOrders(),         // 300ms (concurrent)
    fetchNotifications(),  // 150ms (concurrent)
  ])
  // Total: 300ms (max of all three)

  return (
    <div>
      <UserHeader user={user} />
      <OrderList orders={orders} />
      <NotificationBell notifications={notifications} />
    </div>
  )
}
```

**Alternative (with Suspense streaming):**

```tsx
async function DashboardPage() {
  // Start all fetches immediately
  const userPromise = fetchUser()
  const ordersPromise = fetchOrders()
  const notificationsPromise = fetchNotifications()

  return (
    <div>
      <Suspense fallback={<HeaderSkeleton />}>
        <UserHeader userPromise={userPromise} />
      </Suspense>
      <Suspense fallback={<OrdersSkeleton />}>
        <OrderList ordersPromise={ordersPromise} />
      </Suspense>
      <Suspense fallback={<BellSkeleton />}>
        <NotificationBell notificationsPromise={notificationsPromise} />
      </Suspense>
    </div>
  )
}
// Each component streams as its data resolves
```

Reference: [Parallel Data Fetching](https://react.dev/reference/react/Suspense#revealing-content-together-at-once)

### 2.2 Never Create Promises During Render

**Impact: CRITICAL (prevents infinite re-render loops)**

Creating promises inside a component that calls `use` causes infinite re-renders. Each render creates a new promise, which triggers a new render when resolved.

**Incorrect (promise created during render):**

```tsx
function UserProfile({ userId }: { userId: string }) {
  const userPromise = fetchUser(userId)  // New promise every render!
  const user = use(userPromise)  // Infinite loop

  return <div>{user.name}</div>
}
```

**Correct (promise created outside render):**

```tsx
// Option 1: Pass promise from parent
function UserProfile({ userPromise }: { userPromise: Promise<User> }) {
  const user = use(userPromise)
  return <div>{user.name}</div>
}

function ProfilePage({ userId }: { userId: string }) {
  const userPromise = useMemo(() => fetchUser(userId), [userId])

  return (
    <Suspense fallback={<Skeleton />}>
      <UserProfile userPromise={userPromise} />
    </Suspense>
  )
}

// Option 2: Use React cache() for deduplication
import { cache } from 'react'

const fetchUser = cache(async (userId: string) => {
  const res = await fetch(`/api/users/${userId}`)
  return res.json()
})

function UserProfile({ userId }: { userId: string }) {
  const user = use(fetchUser(userId))  // Cached per request
  return <div>{user.name}</div>
}

// Option 3: Create in Server Component
async function ProfilePage({ userId }: { userId: string }) {
  const userPromise = fetchUser(userId)  // Server Components don't re-render

  return (
    <Suspense fallback={<Skeleton />}>
      <UserProfile userPromise={userPromise} />
    </Suspense>
  )
}
```

**Best practices:**
- Create promises in Server Components (stable across renders)
- Use caching libraries (SWR, React Query) for Client Components
- Wrap with useMemo if creating in parent component

Reference: [use Hook Caveats](https://react.dev/reference/react/use#caveats)

### 2.3 Pair Suspense with Error Boundaries

**Impact: HIGH (prevents unhandled promise rejections from crashing the UI)**

When a promise passed to `use` rejects, it throws an error. Without an Error Boundary, this crashes the component tree. Always wrap Suspense boundaries with Error Boundaries for resilient data fetching.

**Incorrect (rejected promise crashes the page):**

```tsx
function ProductPage({ productId }: { productId: string }) {
  return (
    <Suspense fallback={<ProductSkeleton />}>
      <ProductDetails productId={productId} />
    </Suspense>
  )
}

function ProductDetails({ productId }: { productId: string }) {
  const product = use(fetchProduct(productId))  // Throws on 404
  return <div>{product.name}</div>
}
// 404 crashes the entire page
```

**Correct (error boundary provides fallback):**

```tsx
function ProductPage({ productId }: { productId: string }) {
  return (
    <ErrorBoundary
      fallback={<ProductError />}
      onError={(error) => logError(error)}
    >
      <Suspense fallback={<ProductSkeleton />}>
        <ProductDetails productId={productId} />
      </Suspense>
    </ErrorBoundary>
  )
}

function ProductDetails({ productId }: { productId: string }) {
  const product = use(fetchProduct(productId))
  return <div>{product.name}</div>
}

function ProductError() {
  return (
    <div className="error-state">
      <h2>Product not found</h2>
      <Link href="/products">Browse all products</Link>
    </div>
  )
}
```

**With retry capability:**

```tsx
function ProductPage({ productId }: { productId: string }) {
  const [key, setKey] = useState(0)

  return (
    <ErrorBoundary
      key={key}
      fallback={
        <div>
          <p>Failed to load product</p>
          <button onClick={() => setKey(k => k + 1)}>Retry</button>
        </div>
      }
    >
      <Suspense fallback={<ProductSkeleton />}>
        <ProductDetails productId={productId} />
      </Suspense>
    </ErrorBoundary>
  )
}
```

Reference: [Error Boundaries with Suspense](https://react.dev/reference/react/Suspense#providing-a-fallback-for-server-errors-and-client-only-content)

### 2.4 Place Suspense Boundaries Strategically

**Impact: CRITICAL (enables progressive streaming, faster perceived load times)**

Suspense boundaries control what loads together. Too few boundaries block the entire page; too many create jarring loading states. Place boundaries around independent content sections.

**Incorrect (single boundary blocks everything):**

```tsx
export default function DashboardPage() {
  return (
    <Suspense fallback={<PageSkeleton />}>
      <Header />           {/* Fast */}
      <Sidebar />          {/* Fast */}
      <MainContent />      {/* Slow - blocks everything */}
      <RecentActivity />   {/* Medium */}
    </Suspense>
  )
}
// User sees nothing until slowest component resolves
```

**Correct (independent boundaries enable streaming):**

```tsx
export default function DashboardPage() {
  return (
    <>
      <Header />  {/* No data fetching, renders immediately */}

      <div className="layout">
        <Suspense fallback={<SidebarSkeleton />}>
          <Sidebar />
        </Suspense>

        <main>
          <Suspense fallback={<ContentSkeleton />}>
            <MainContent />  {/* Slow component isolated */}
          </Suspense>
        </main>

        <aside>
          <Suspense fallback={<ActivitySkeleton />}>
            <RecentActivity />
          </Suspense>
        </aside>
      </div>
    </>
  )
}
// Each section streams independently as data arrives
```

**Guidelines for boundary placement:**
- Wrap each independent data-fetching section
- Keep related content in the same boundary
- Static content should be outside all boundaries
- Nest boundaries for progressive disclosure

Reference: [Suspense](https://react.dev/reference/react/Suspense)

### 2.5 Use the use Hook Conditionally

**Impact: HIGH (avoids unnecessary suspense and data fetching)**

Unlike other hooks, `use` can be called inside conditionals and loops. This allows you to skip data fetching when it's not needed, avoiding unnecessary network requests and suspense.

**Incorrect (useContext always runs, can't be conditional):**

```tsx
function FeaturePanel({ showAdvanced }: { showAdvanced: boolean }) {
  const advancedConfig = useContext(AdvancedConfigContext)  // Always reads

  return (
    <div>
      <BasicSettings />
      {showAdvanced && <AdvancedSettings config={advancedConfig} />}
    </div>
  )
}
```

**Correct (use only reads when needed):**

```tsx
function FeaturePanel({ showAdvanced }: { showAdvanced: boolean }) {
  return (
    <div>
      <BasicSettings />
      {showAdvanced && <AdvancedSettings />}
    </div>
  )
}

function AdvancedSettings() {
  const config = use(AdvancedConfigContext)  // Only reads when rendered
  return <div>{config.featureFlags.map(f => <Flag key={f.id} flag={f} />)}</div>
}
```

**With promises (skip fetch when unnecessary):**

```tsx
function UserAvatar({ userId, showDetails }: Props) {
  // Only fetch full profile if details are shown
  const user = showDetails
    ? use(fetchFullProfile(userId))
    : use(fetchBasicProfile(userId))

  return (
    <div>
      <img src={user.avatar} alt={user.name} />
      {showDetails && <span>{user.bio}</span>}
    </div>
  )
}
```

**Benefits:**
- Skip expensive operations when not needed
- Reduce unnecessary context subscriptions
- Cleaner conditional data fetching logic

Reference: [use Hook](https://react.dev/reference/react/use#reading-context-with-use)

### 2.6 Use the use Hook for Promise Reading

**Impact: CRITICAL (eliminates useEffect/useState boilerplate, integrates with Suspense)**

The `use` hook reads promises during render and integrates with Suspense. Traditional useEffect patterns require managing loading states manually and cause waterfalls.

**Incorrect (useEffect waterfall, manual loading state):**

```tsx
function UserProfile({ userId }: { userId: string }) {
  const [user, setUser] = useState<User | null>(null)
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    setIsLoading(true)
    fetchUser(userId)
      .then(setUser)
      .finally(() => setIsLoading(false))
  }, [userId])

  if (isLoading) return <Skeleton />  // Two renders: loading then data
  if (!user) return null

  return <div>{user.name}</div>
}
```

**Correct (Suspense integration, single render path):**

```tsx
function UserProfile({ userPromise }: { userPromise: Promise<User> }) {
  const user = use(userPromise)  // Suspends until resolved

  return <div>{user.name}</div>
}

// Parent provides the promise
function ProfilePage({ userId }: { userId: string }) {
  const userPromise = fetchUser(userId)  // Created outside render

  return (
    <Suspense fallback={<Skeleton />}>
      <UserProfile userPromise={userPromise} />
    </Suspense>
  )
}
```

**Benefits:**
- No useState/useEffect boilerplate
- Automatic Suspense integration
- Can be called conditionally (unlike hooks)
- Works in loops and early returns

**When NOT to use this pattern:**
- Promise created during render (causes infinite re-renders)
- Need fine-grained control over loading states

Reference: [use Hook](https://react.dev/reference/react/use)

---

## 3. Server Components

**Impact: HIGH**

Server-first architecture reduces bundle size by 25-60% and improves Time-to-Interactive. Wrong client/server boundaries negate these gains entirely.

### 3.1 Default to Server Components

**Impact: HIGH (25-60% smaller bundles, faster TTI)**

In React 19, components are Server Components by default. Only add 'use client' when you need interactivity. Starting with Client Components and converting later is backwards and wastes bundle size.

**Incorrect (unnecessary client component):**

```tsx
'use client'  // Unnecessary - no interactivity

import { formatDate } from '@/lib/utils'

export function ArticleCard({ article }: { article: Article }) {
  return (
    <article>
      <h2>{article.title}</h2>
      <time>{formatDate(article.publishedAt)}</time>
      <p>{article.excerpt}</p>
    </article>
  )
}
// Entire component + formatDate shipped to client
```

**Correct (server component by default):**

```tsx
// No directive needed - Server Component by default
import { formatDate } from '@/lib/utils'

export function ArticleCard({ article }: { article: Article }) {
  return (
    <article>
      <h2>{article.title}</h2>
      <time>{formatDate(article.publishedAt)}</time>
      <p>{article.excerpt}</p>
    </article>
  )
}
// Renders on server, only HTML sent to client
```

**When to add 'use client':**
- Using hooks (useState, useEffect, useContext)
- Using browser APIs (window, document, localStorage)
- Adding event handlers (onClick, onChange)
- Using client-only libraries

Reference: [Server Components](https://react.dev/reference/rsc/server-components)

### 3.2 Isolate Interactivity into Client Islands

**Impact: HIGH (minimizes client bundle, maximizes server rendering)**

Don't mark entire sections as 'use client'. Extract only the interactive parts into small Client Components while keeping the rest as Server Components.

**Incorrect (entire section is client):**

```tsx
'use client'

export function ProductSection({ products }: { products: Product[] }) {
  const [sortBy, setSortBy] = useState('price')

  const sorted = [...products].sort((a, b) => a[sortBy] - b[sortBy])

  return (
    <section>
      <h2>Featured Products</h2>
      <SortDropdown value={sortBy} onChange={setSortBy} />
      <div className="grid">
        {sorted.map(p => (
          <ProductCard key={p.id} product={p} />  {/* Static, but bundled */}
        ))}
      </div>
    </section>
  )
}
// Everything ships to client, including ProductCard
```

**Correct (only interactive part is client):**

```tsx
// Server Component - renders on server
export function ProductSection({ products }: { products: Product[] }) {
  return (
    <section>
      <h2>Featured Products</h2>
      <SortableProductGrid products={products} />
    </section>
  )
}

// Client island - only the interactive logic
'use client'
function SortableProductGrid({ products }: { products: Product[] }) {
  const [sortBy, setSortBy] = useState('price')
  const sorted = [...products].sort((a, b) => a[sortBy] - b[sortBy])

  return (
    <>
      <SortDropdown value={sortBy} onChange={setSortBy} />
      <div className="grid">
        {sorted.map(p => (
          <ProductCard key={p.id} product={p} />
        ))}
      </div>
    </>
  )
}

// Server Component - can be composed inside client
function ProductCard({ product }: { product: Product }) {
  return (
    <article>
      <img src={product.image} alt={product.name} />
      <h3>{product.name}</h3>
      <AddToCartButton productId={product.id} />  {/* Another small island */}
    </article>
  )
}
```

**Guidelines:**
- Static content = Server Component
- Event handlers = Client Component
- Keep client islands as small as possible

Reference: [Composing Client and Server Components](https://react.dev/reference/rsc/use-client#how-use-client-marks-client-code)

### 3.3 Pass Only Serializable Data to Client Components

**Impact: HIGH (prevents runtime errors and hydration mismatches)**

Data passed from Server Components to Client Components must be JSON-serializable. Functions, classes, Dates, and symbols will cause runtime errors or silent failures.

**Incorrect (non-serializable props):**

```tsx
// Server Component
async function UserPage() {
  const user = await getUser()

  return (
    <UserCard
      user={user}
      createdAt={user.createdAt}  // Date object - not serializable
      onEdit={() => console.log('edit')}  // Function - not serializable
      settings={new Map(user.settings)}  // Map - not serializable
    />
  )
}

// Client Component
'use client'
function UserCard({ user, createdAt, onEdit, settings }) {
  // Runtime error: functions and Dates can't cross the server/client boundary
}
```

**Correct (serializable props only):**

```tsx
// Server Component
async function UserPage() {
  const user = await getUser()

  return (
    <UserCard
      user={{
        id: user.id,
        name: user.name,
        email: user.email,
      }}
      createdAt={user.createdAt.toISOString()}  // String is serializable
      settings={Object.fromEntries(user.settings)}  // Plain object
    />
  )
}

// Client Component
'use client'
function UserCard({ user, createdAt, settings }) {
  const date = new Date(createdAt)  // Reconstruct on client

  const handleEdit = () => {
    // Define handlers in Client Component
  }

  return (
    <div>
      <h2>{user.name}</h2>
      <time>{date.toLocaleDateString()}</time>
      <button onClick={handleEdit}>Edit</button>
    </div>
  )
}
```

**Serializable types:**
- Primitives (string, number, boolean, null, undefined)
- Plain objects and arrays
- Server Actions (special case - serialized as references)

Reference: [Serializable Props](https://react.dev/reference/rsc/use-client#serializable-types)

### 3.4 Preload Data to Avoid Waterfalls

**Impact: HIGH (eliminates parent-child fetch waterfalls)**

In Server Component trees, child components can't start fetching until their parent finishes rendering. Use the preload pattern to start fetches early and deduplicate with cache().

**Incorrect (waterfall between parent and child):**

```tsx
// Parent fetches, then child fetches sequentially
async function ProductPage({ productId }: { productId: string }) {
  const product = await getProduct(productId)  // 200ms

  return (
    <div>
      <ProductDetails product={product} />
      <ReviewSection productId={productId} />  {/* Can't start until parent done */}
    </div>
  )
}

async function ReviewSection({ productId }: { productId: string }) {
  const reviews = await getReviews(productId)  // 300ms (starts after 200ms)
  return <ReviewList reviews={reviews} />
}
// Total: 500ms
```

**Correct (preload eliminates waterfall):**

```tsx
// lib/data.ts
import { cache } from 'react'

export const getProduct = cache(async (id: string) => {
  return db.product.findUnique({ where: { id } })
})

export const getReviews = cache(async (productId: string) => {
  return db.review.findMany({ where: { productId } })
})

// Preload function starts fetches without awaiting
export function preloadProductData(productId: string) {
  void getProduct(productId)
  void getReviews(productId)
}

// Page starts both fetches immediately
async function ProductPage({ productId }: { productId: string }) {
  preloadProductData(productId)  // Start both fetches

  const product = await getProduct(productId)  // Already in flight

  return (
    <div>
      <ProductDetails product={product} />
      <ReviewSection productId={productId} />
    </div>
  )
}

async function ReviewSection({ productId }: { productId: string }) {
  const reviews = await getReviews(productId)  // Returns cached/in-flight result
  return <ReviewList reviews={reviews} />
}
// Total: 300ms (max of both)
```

Reference: [Preloading Data](https://react.dev/reference/react/cache#preload-data)

### 3.5 Use React cache() for Request Deduplication

**Impact: HIGH (eliminates duplicate fetches within a single request)**

When multiple Server Components need the same data, wrap the fetch function with `cache()` to deduplicate calls within a single request. Without caching, the same query runs multiple times.

**Incorrect (duplicate fetches per request):**

```tsx
// lib/data.ts
export async function getUser(id: string) {
  console.log('Fetching user...')  // Logs multiple times!
  return db.user.findUnique({ where: { id } })
}

// components/Header.tsx
export async function Header() {
  const user = await getUser(userId)  // First fetch
  return <nav>{user.name}</nav>
}

// components/Sidebar.tsx
export async function Sidebar() {
  const user = await getUser(userId)  // Second fetch - wasteful!
  return <aside>Welcome, {user.name}</aside>
}
```

**Correct (deduplicated with cache):**

```tsx
// lib/data.ts
import { cache } from 'react'

export const getUser = cache(async (id: string) => {
  console.log('Fetching user...')  // Logs once per request
  return db.user.findUnique({ where: { id } })
})

// components/Header.tsx
export async function Header() {
  const user = await getUser(userId)  // Cached
  return <nav>{user.name}</nav>
}

// components/Sidebar.tsx
export async function Sidebar() {
  const user = await getUser(userId)  // Returns cached result
  return <aside>Welcome, {user.name}</aside>
}
```

**Note:** `cache()` creates a per-request cache. It does not persist across requests. For cross-request caching, use `unstable_cache` (Next.js) or a caching layer like Redis.

**When to use cache():**
- Database queries used in multiple components
- Expensive computations with the same inputs
- Any function called multiple times with same arguments per request

Reference: [React cache()](https://react.dev/reference/react/cache)

---

## 4. React Compiler Optimization

**Impact: HIGH**

React Compiler handles automatic memoization, but edge cases and third-party libraries can break compilation. Understanding limits prevents silent performance regressions.

### 4.1 Apply use-no-memo Directive to Opt Out of Compilation

**Impact: MEDIUM-HIGH (enables debugging and third-party library compatibility)**

When the compiler causes issues with specific components or you need to debug performance, use the 'use no memo' directive to skip compilation for that component.

**Incorrect (fighting compiler behavior):**

```tsx
// Trying to force re-renders the compiler prevents
function DebugComponent({ data }: { data: Data }) {
  console.log('Render count check')  // May not log due to memoization

  // Hack to break memoization
  const breakMemo = Math.random()

  return <div data-debug={breakMemo}>{data.value}</div>
}
```

**Correct (explicit opt-out):**

```tsx
'use no memo'

function DebugComponent({ data }: { data: Data }) {
  console.log('Render count check')  // Always logs

  return <div>{data.value}</div>
}
```

**Opting out specific hooks:**

```tsx
function ComponentWithThirdParty({ items }: { items: Item[] }) {
  // Third-party library needs exact reference
  // eslint-disable-next-line react-compiler/react-compiler
  const stableRef = useMemo(() => createThirdPartyConfig(items), [items])

  return <ThirdPartyChart config={stableRef} />
}
```

**When to opt out:**
- Debugging render behavior
- Third-party libraries requiring exact reference identity
- Legacy code with intentional impure patterns
- Performance profiling specific components

**Note:** Opt-out should be temporary. Fix the underlying issue when possible.

Reference: [Opting Out of Compilation](https://react.dev/learn/react-compiler/introduction#opting-out)

### 4.2 Follow Rules of React for Compiler Compatibility

**Impact: HIGH (enables compiler optimization, prevents silent failures)**

React Compiler assumes components follow the Rules of React. Violating these rules causes the compiler to skip optimization or produce incorrect output. Code that "worked" before may break when compiled.

**Incorrect (violates Rules of React):**

```tsx
// Mutating props
function BadComponent({ items }: { items: Item[] }) {
  items.sort((a, b) => a.name.localeCompare(b.name))  // Mutates prop!
  return <List items={items} />
}

// Reading from mutable external state during render
let globalCounter = 0
function CounterDisplay() {
  globalCounter++  // Side effect during render!
  return <span>{globalCounter}</span>
}

// Conditional hooks
function ConditionalHooks({ showExtra }: { showExtra: boolean }) {
  const [count, setCount] = useState(0)
  if (showExtra) {
    const [extra, setExtra] = useState('')  // Hook in conditional!
  }
  return <div>{count}</div>
}
```

**Correct (follows Rules of React):**

```tsx
// Create new sorted array
function GoodComponent({ items }: { items: Item[] }) {
  const sortedItems = [...items].sort((a, b) => a.name.localeCompare(b.name))
  return <List items={sortedItems} />
}

// Use state for mutable values
function CounterDisplay() {
  const [counter, setCounter] = useState(0)

  useEffect(() => {
    setCounter(c => c + 1)
  }, [])

  return <span>{counter}</span>
}

// Hooks at top level
function ConditionalContent({ showExtra }: { showExtra: boolean }) {
  const [count, setCount] = useState(0)
  const [extra, setExtra] = useState('')  // Always called

  return (
    <div>
      {count}
      {showExtra && <span>{extra}</span>}
    </div>
  )
}
```

**Rules the compiler enforces:**
- Components must be pure (same input = same output)
- Don't mutate props, state, or context
- Hooks must be called unconditionally at the top level
- Don't call hooks inside loops, conditions, or nested functions

Reference: [Rules of React](https://react.dev/reference/rules)

### 4.3 Trust the Compiler for Memoization

**Impact: HIGH (removes 80% of manual useMemo/useCallback, cleaner code)**

React Compiler automatically memoizes values and callbacks at build time. Manual useMemo and useCallback are usually unnecessary and add code complexity without improving performance.

**Incorrect (manual memoization everywhere):**

```tsx
function ProductList({ products, onSelect }: Props) {
  const sortedProducts = useMemo(
    () => [...products].sort((a, b) => a.price - b.price),
    [products]
  )

  const handleSelect = useCallback(
    (id: string) => onSelect(id),
    [onSelect]
  )

  const formatPrice = useCallback(
    (price: number) => `$${price.toFixed(2)}`,
    []
  )

  return (
    <ul>
      {sortedProducts.map(product => (
        <ProductItem
          key={product.id}
          product={product}
          onSelect={handleSelect}
          formatPrice={formatPrice}
        />
      ))}
    </ul>
  )
}
```

**Correct (let compiler optimize):**

```tsx
function ProductList({ products, onSelect }: Props) {
  const sortedProducts = [...products].sort((a, b) => a.price - b.price)

  const handleSelect = (id: string) => onSelect(id)

  const formatPrice = (price: number) => `$${price.toFixed(2)}`

  return (
    <ul>
      {sortedProducts.map(product => (
        <ProductItem
          key={product.id}
          product={product}
          onSelect={handleSelect}
          formatPrice={formatPrice}
        />
      ))}
    </ul>
  )
}
// Compiler automatically memoizes what needs memoizing
```

**When manual memoization is still needed:**
- Third-party libraries requiring stable references
- Values used as effect dependencies with specific identity requirements
- Opting out of compiler optimization for debugging

Reference: [React Compiler Introduction](https://react.dev/learn/react-compiler/introduction)

### 4.4 Use Manual Memoization for Effect Dependencies

**Impact: MEDIUM-HIGH (prevents unwanted effect re-runs with memoized dependencies)**

React Compiler's memoization is optimized for rendering, not for effect dependency identity. When a value is used as an effect dependency, manual memoization may still be needed to prevent unwanted re-runs.

**Incorrect (effect runs too often):**

```tsx
function SearchResults({ query, filters }: Props) {
  const searchParams = { query, ...filters }  // New object every render

  useEffect(() => {
    fetchResults(searchParams)  // Runs every render!
  }, [searchParams])

  return <Results />
}
```

**Correct (stable dependency):**

```tsx
function SearchResults({ query, filters }: Props) {
  const searchParams = useMemo(
    () => ({ query, ...filters }),
    [query, filters]  // Only changes when inputs change
  )

  useEffect(() => {
    fetchResults(searchParams)  // Runs only when params change
  }, [searchParams])

  return <Results />
}
```

**Alternative (primitive dependencies):**

```tsx
function SearchResults({ query, filters }: Props) {
  useEffect(() => {
    // Inline the object creation in the effect
    const searchParams = { query, ...filters }
    fetchResults(searchParams)
  }, [query, filters.category, filters.sort])  // Primitives as deps

  return <Results />
}
```

**When manual memoization helps:**
- Objects/arrays used as effect dependencies
- Callbacks passed to third-party libraries with identity checks
- Values compared with `===` by external code

Reference: [React Compiler and Effects](https://react.dev/learn/react-compiler/introduction#how-does-react-compiler-work)

---

## 5. State Management

**Impact: MEDIUM-HIGH**

New hooks like useOptimistic and useDeferredValue replace verbose patterns. Misuse causes stale UI, unnecessary renders, or broken optimistic updates.

### 5.1 Use Functional setState for Derived Updates

**Impact: MEDIUM (prevents stale closure bugs, enables stable callbacks)**

When updating state based on the previous value, use the functional form. This prevents stale closure bugs and allows callbacks to remain stable across renders.

**Incorrect (stale closure, unstable callback):**

```tsx
function Counter() {
  const [count, setCount] = useState(0)

  const increment = useCallback(() => {
    setCount(count + 1)  // Captures stale count
  }, [count])  // Must include count, callback recreated every render

  return (
    <div>
      <span>{count}</span>
      <ExpensiveChild onIncrement={increment} />  {/* Re-renders on every count change */}
    </div>
  )
}
```

**Correct (no stale closure, stable callback):**

```tsx
function Counter() {
  const [count, setCount] = useState(0)

  const increment = useCallback(() => {
    setCount(c => c + 1)  // Always gets current value
  }, [])  // Never recreated

  return (
    <div>
      <span>{count}</span>
      <ExpensiveChild onIncrement={increment} />  {/* Doesn't re-render */}
    </div>
  )
}
```

**Batch multiple updates:**

```tsx
function Form() {
  const [formState, setFormState] = useState({ name: '', email: '', valid: false })

  const handleChange = (field: string, value: string) => {
    setFormState(prev => ({
      ...prev,
      [field]: value,
      valid: validateField(field, value) && prev.valid
    }))
  }

  return <input onChange={e => handleChange('name', e.target.value)} />
}
```

Reference: [useState](https://react.dev/reference/react/useState#updating-state-based-on-the-previous-state)

### 5.2 Use Lazy Initialization for Expensive Initial State

**Impact: MEDIUM (prevents expensive computation on every render)**

When initial state requires expensive computation, pass a function to useState. Otherwise, the computation runs on every render even though the result is only used once.

**Incorrect (expensive computation every render):**

```tsx
function EditorPage({ documentId }: { documentId: string }) {
  // parseDocument runs on EVERY render, result discarded after first
  const [content, setContent] = useState(parseDocument(documentId))  // 50ms wasted per render

  return <Editor content={content} onChange={setContent} />
}
```

**Correct (lazy initialization):**

```tsx
function EditorPage({ documentId }: { documentId: string }) {
  // parseDocument runs ONLY on initial render
  const [content, setContent] = useState(() => parseDocument(documentId))

  return <Editor content={content} onChange={setContent} />
}
```

**When to use lazy initialization:**
- Parsing large data structures
- Reading from localStorage/sessionStorage
- Creating complex initial objects
- Any computation taking >1ms

**With props dependency:**

```tsx
function FilteredList({ items, initialFilter }: Props) {
  // Expensive initial filter based on prop
  const [filtered, setFiltered] = useState(() =>
    items.filter(item => matchesFilter(item, initialFilter))
  )

  return <List items={filtered} />
}
```

**Note:** The initializer function receives no arguments. If you need props, reference them from the closure.

Reference: [useState Lazy Initialization](https://react.dev/reference/react/useState#avoiding-recreating-the-initial-state)

### 5.3 Use useDeferredValue for Non-Urgent Updates

**Impact: MEDIUM-HIGH (maintains <100ms input latency during expensive renders)**

The `useDeferredValue` hook lets you defer expensive re-renders while keeping the UI responsive. High-priority updates (like typing) happen immediately while heavy computations are deferred.

**Incorrect (typing feels sluggish):**

```tsx
function SearchPage() {
  const [query, setQuery] = useState('')

  // Heavy filtering blocks typing
  const filteredResults = products.filter(p =>
    p.name.toLowerCase().includes(query.toLowerCase())
  )  // 10,000 items = sluggish

  return (
    <div>
      <input
        value={query}
        onChange={e => setQuery(e.target.value)}
        placeholder="Search..."
      />
      <ProductGrid products={filteredResults} />
    </div>
  )
}
```

**Correct (typing stays responsive):**

```tsx
function SearchPage() {
  const [query, setQuery] = useState('')
  const deferredQuery = useDeferredValue(query)

  // Deferred filter doesn't block input
  const filteredResults = products.filter(p =>
    p.name.toLowerCase().includes(deferredQuery.toLowerCase())
  )

  const isStale = query !== deferredQuery

  return (
    <div>
      <input
        value={query}
        onChange={e => setQuery(e.target.value)}
        placeholder="Search..."
      />
      <div style={{ opacity: isStale ? 0.7 : 1 }}>
        <ProductGrid products={filteredResults} />
      </div>
    </div>
  )
}
```

**With memo for maximum benefit:**

```tsx
function SearchPage() {
  const [query, setQuery] = useState('')
  const deferredQuery = useDeferredValue(query)

  return (
    <div>
      <input value={query} onChange={e => setQuery(e.target.value)} />
      <MemoizedProductGrid query={deferredQuery} />
    </div>
  )
}

const MemoizedProductGrid = memo(function ProductGrid({ query }: { query: string }) {
  const filtered = products.filter(p =>
    p.name.toLowerCase().includes(query.toLowerCase())
  )
  return <Grid products={filtered} />
})
```

Reference: [useDeferredValue](https://react.dev/reference/react/useDeferredValue)

### 5.4 Use useOptimistic for Instant Feedback

**Impact: MEDIUM-HIGH (0ms perceived latency for mutations (instant feedback))**

The `useOptimistic` hook shows immediate UI changes while async operations complete. Users see instant feedback instead of waiting for server responses.

**Incorrect (user waits for response):**

```tsx
function TodoList({ todos, onAdd }: Props) {
  const [isPending, startTransition] = useTransition()

  const handleAdd = async (formData: FormData) => {
    const title = formData.get('title') as string
    startTransition(async () => {
      await addTodo(title)  // User waits 200-500ms
    })
  }

  return (
    <div>
      <form action={handleAdd}>
        <input name="title" />
        <button disabled={isPending}>
          {isPending ? 'Adding...' : 'Add'}
        </button>
      </form>
      <ul>
        {todos.map(todo => <TodoItem key={todo.id} todo={todo} />)}
      </ul>
    </div>
  )
}
```

**Correct (instant visual feedback):**

```tsx
function TodoList({ todos, onAdd }: Props) {
  const [optimisticTodos, addOptimisticTodo] = useOptimistic(
    todos,
    (currentTodos, newTitle: string) => [
      ...currentTodos,
      { id: crypto.randomUUID(), title: newTitle, pending: true }
    ]
  )

  const handleAdd = async (formData: FormData) => {
    const title = formData.get('title') as string
    addOptimisticTodo(title)  // Instantly shows in UI
    await addTodo(title)  // Server confirms in background
  }

  return (
    <div>
      <form action={handleAdd}>
        <input name="title" />
        <button>Add</button>
      </form>
      <ul>
        {optimisticTodos.map(todo => (
          <TodoItem
            key={todo.id}
            todo={todo}
            className={todo.pending ? 'opacity-50' : ''}
          />
        ))}
      </ul>
    </div>
  )
}
```

**Benefits:**
- Zero perceived latency for user actions
- Automatic rollback on failure
- Visual distinction for pending items

Reference: [useOptimistic](https://react.dev/reference/react/useOptimistic)

### 5.5 Use useTransition for Non-Blocking State Updates

**Impact: MEDIUM-HIGH (prevents UI freezing during expensive updates)**

The `useTransition` hook marks state updates as non-urgent, allowing React to interrupt them for higher-priority work. This prevents the UI from freezing during expensive operations.

**Incorrect (tab switch freezes UI):**

```tsx
function Dashboard() {
  const [tab, setTab] = useState('overview')

  const handleTabChange = (newTab: string) => {
    setTab(newTab)  // If PostsTab is slow, UI freezes
  }

  return (
    <div>
      <TabList>
        <Tab onClick={() => handleTabChange('overview')}>Overview</Tab>
        <Tab onClick={() => handleTabChange('posts')}>Posts</Tab>
        <Tab onClick={() => handleTabChange('analytics')}>Analytics</Tab>
      </TabList>

      {tab === 'overview' && <OverviewTab />}
      {tab === 'posts' && <PostsTab />}  {/* Slow component */}
      {tab === 'analytics' && <AnalyticsTab />}
    </div>
  )
}
```

**Correct (tab switch stays responsive):**

```tsx
function Dashboard() {
  const [tab, setTab] = useState('overview')
  const [isPending, startTransition] = useTransition()

  const handleTabChange = (newTab: string) => {
    startTransition(() => {
      setTab(newTab)  // Low priority, can be interrupted
    })
  }

  return (
    <div>
      <TabList>
        <Tab
          onClick={() => handleTabChange('overview')}
          className={tab === 'overview' && isPending ? 'loading' : ''}
        >
          Overview
        </Tab>
        <Tab onClick={() => handleTabChange('posts')}>Posts</Tab>
        <Tab onClick={() => handleTabChange('analytics')}>Analytics</Tab>
      </TabList>

      <div style={{ opacity: isPending ? 0.7 : 1 }}>
        {tab === 'overview' && <OverviewTab />}
        {tab === 'posts' && <PostsTab />}
        {tab === 'analytics' && <AnalyticsTab />}
      </div>
    </div>
  )
}
```

**With async actions:**

```tsx
const [isPending, startTransition] = useTransition()

const handleSubmit = () => {
  startTransition(async () => {
    await saveData(formData)
    // State updates after await need another startTransition
  })
}
```

Reference: [useTransition](https://react.dev/reference/react/useTransition)

---

## 6. Rendering Optimization

**Impact: MEDIUM**

Concurrent rendering, transitions, and streaming affect perceived performance. Blocking the main thread or improper transition boundaries degrades user experience.

### 6.1 Avoid Cascading State Updates in Effects

**Impact: MEDIUM (prevents double renders and layout thrashing)**

Setting state in effects that depend on other state causes cascading re-renders. Derive state during render or use event handlers instead.

**Incorrect (cascading updates, multiple renders):**

```tsx
function FilteredList({ items, filter }: Props) {
  const [filteredItems, setFilteredItems] = useState<Item[]>([])

  useEffect(() => {
    setFilteredItems(items.filter(i => matchesFilter(i, filter)))
  }, [items, filter])
  // Render 1: empty filteredItems
  // Effect runs, sets state
  // Render 2: with filtered items

  return <List items={filteredItems} />
}
```

**Correct (derive during render):**

```tsx
function FilteredList({ items, filter }: Props) {
  const filteredItems = items.filter(i => matchesFilter(i, filter))
  // Single render with correct data

  return <List items={filteredItems} />
}
```

**For expensive computations:**

```tsx
function FilteredList({ items, filter }: Props) {
  const filteredItems = useMemo(
    () => items.filter(i => matchesFilter(i, filter)),
    [items, filter]
  )

  return <List items={filteredItems} />
}
```

**When effects are appropriate:**
- Synchronizing with external systems
- Subscriptions and event listeners
- Data fetching (prefer Server Components or libraries)

Reference: [You Might Not Need an Effect](https://react.dev/learn/you-might-not-need-an-effect)

### 6.2 Enable Streaming SSR with Suspense

**Impact: MEDIUM (200-400ms faster TTFB, progressive content delivery)**

React 19 streams HTML progressively with Suspense. Content inside Suspense boundaries streams as it becomes available, reducing Time to First Byte and improving perceived performance.

**Incorrect (all-or-nothing SSR):**

```tsx
// Everything must complete before any HTML is sent
export default async function Page() {
  const user = await fetchUser()
  const posts = await fetchPosts()
  const recommendations = await fetchRecommendations()  // Slow!

  return (
    <div>
      <Header user={user} />
      <PostFeed posts={posts} />
      <Recommendations items={recommendations} />
    </div>
  )
}
// Client waits for slowest fetch before seeing anything
```

**Correct (progressive streaming):**

```tsx
export default function Page() {
  return (
    <div>
      <Suspense fallback={<HeaderSkeleton />}>
        <Header />
      </Suspense>

      <Suspense fallback={<FeedSkeleton />}>
        <PostFeed />
      </Suspense>

      <Suspense fallback={<RecommendationsSkeleton />}>
        <Recommendations />  {/* Streams when ready */}
      </Suspense>
    </div>
  )
}

async function Header() {
  const user = await fetchUser()
  return <header>{user.name}</header>
}

async function PostFeed() {
  const posts = await fetchPosts()
  return <div>{posts.map(p => <Post key={p.id} post={p} />)}</div>
}

async function Recommendations() {
  const items = await fetchRecommendations()
  return <aside>{items.map(i => <Rec key={i.id} item={i} />)}</aside>
}
// Fast sections appear immediately, slow sections stream in
```

**Benefits:**
- First content visible faster (lower TTFB)
- Progressive hydration as content arrives
- Slow data doesn't block fast content

Reference: [Streaming SSR](https://react.dev/reference/react-dom/server/renderToReadableStream)

### 6.3 Leverage Concurrent Rendering by Default

**Impact: MEDIUM (prevents UI freezing during complex updates)**

React 19 enables concurrent rendering by default. React can pause, interrupt, and resume rendering work. Write components that work with this model rather than against it.

**Incorrect (blocking synchronous pattern):**

```tsx
function DataTable({ data }: { data: Row[] }) {
  // Synchronous processing blocks the main thread
  const processedData = data.map(row => {
    return {
      ...row,
      computed: expensiveComputation(row),  // Blocks for each row
    }
  })

  return (
    <table>
      {processedData.map(row => <TableRow key={row.id} row={row} />)}
    </table>
  )
}
```

**Correct (works with concurrent rendering):**

```tsx
function DataTable({ data }: { data: Row[] }) {
  const deferredData = useDeferredValue(data)

  // Computation can be interrupted between renders
  const processedData = deferredData.map(row => ({
    ...row,
    computed: expensiveComputation(row),
  }))

  const isStale = data !== deferredData

  return (
    <div style={{ opacity: isStale ? 0.8 : 1 }}>
      <table>
        {processedData.map(row => <TableRow key={row.id} row={row} />)}
      </table>
    </div>
  )
}
```

**With virtualization for very large lists:**

```tsx
function VirtualizedDataTable({ data }: { data: Row[] }) {
  return (
    <VirtualizedList
      items={data}
      height={600}
      itemHeight={40}
      renderItem={(row) => <TableRow row={row} />}
    />
  )
}
// Only visible rows render, concurrent features work naturally
```

**Best practices:**
- Avoid synchronous loops that process thousands of items
- Use useDeferredValue for search/filter results
- Use virtualization for large lists
- Split expensive components with Suspense

Reference: [Concurrent React](https://react.dev/blog/2024/12/05/react-19#whats-new-in-react-19)

### 6.4 Memoize Expensive Child Components

**Impact: MEDIUM (prevents cascading re-renders in component trees)**

While React Compiler handles most memoization, wrapping expensive components with `memo()` can still help prevent re-renders when parent state changes don't affect the child.

**Incorrect (child re-renders on every parent update):**

```tsx
function Dashboard() {
  const [notifications, setNotifications] = useState(0)

  return (
    <div>
      <NotificationBell count={notifications} />
      <ExpensiveChart data={chartData} />  {/* Re-renders when notifications change */}
    </div>
  )
}

function ExpensiveChart({ data }: { data: ChartData }) {
  // 50ms render time
  return <canvas>{/* complex rendering */}</canvas>
}
```

**Correct (memo prevents unnecessary re-renders):**

```tsx
function Dashboard() {
  const [notifications, setNotifications] = useState(0)

  return (
    <div>
      <NotificationBell count={notifications} />
      <ExpensiveChart data={chartData} />  {/* Skips render if data unchanged */}
    </div>
  )
}

const ExpensiveChart = memo(function ExpensiveChart({ data }: { data: ChartData }) {
  // Only renders when data prop changes
  return <canvas>{/* complex rendering */}</canvas>
})
```

**With custom comparison:**

```tsx
const ExpensiveChart = memo(
  function ExpensiveChart({ data, options }: Props) {
    return <canvas>{/* complex rendering */}</canvas>
  },
  (prevProps, nextProps) => {
    // Only re-render if data length or options changed
    return (
      prevProps.data.length === nextProps.data.length &&
      prevProps.options.theme === nextProps.options.theme
    )
  }
)
```

**When memo helps:**
- Components with expensive render logic
- Components receiving stable props from frequently-updating parents
- List items rendered many times

Reference: [memo](https://react.dev/reference/react/memo)

### 6.5 Pass Children as Props to Avoid Re-renders

**Impact: MEDIUM (prevents re-renders of static children on parent state changes)**

When a component manages state, its entire subtree re-renders on state change. Passing children as props keeps static content outside the re-render boundary.

**Incorrect (static content re-renders):**

```tsx
function ExpandableSection({ title }: { title: string }) {
  const [isExpanded, setIsExpanded] = useState(false)

  return (
    <div>
      <button onClick={() => setIsExpanded(!isExpanded)}>{title}</button>
      {isExpanded && (
        <div>
          <ExpensiveContent />  {/* Re-created on every toggle */}
          <StaticFooter />
        </div>
      )}
    </div>
  )
}
```

**Correct (children stay outside state scope):**

```tsx
function ExpandableSection({
  title,
  children
}: {
  title: string
  children: React.ReactNode
}) {
  const [isExpanded, setIsExpanded] = useState(false)

  return (
    <div>
      <button onClick={() => setIsExpanded(!isExpanded)}>{title}</button>
      {isExpanded && children}  {/* Children don't re-render on toggle */}
    </div>
  )
}

// Usage
function Page() {
  return (
    <ExpandableSection title="Details">
      <ExpensiveContent />  {/* Created once in parent scope */}
      <StaticFooter />
    </ExpandableSection>
  )
}
```

**Alternative pattern (render props):**

```tsx
function ExpandableSection({
  title,
  renderContent
}: {
  title: string
  renderContent: () => React.ReactNode
}) {
  const [isExpanded, setIsExpanded] = useState(false)

  return (
    <div>
      <button onClick={() => setIsExpanded(!isExpanded)}>{title}</button>
      {isExpanded && renderContent()}
    </div>
  )
}
```

Reference: [Extracting State Logic](https://react.dev/learn/extracting-state-logic-into-a-reducer)

### 6.6 Use Stable Keys for List Rendering

**Impact: MEDIUM (prevents unnecessary DOM recreation and state loss)**

Keys help React identify which items changed. Unstable keys (like array indices or random values) cause unnecessary DOM recreation, lost component state, and poor performance.

**Incorrect (index as key):**

```tsx
function TodoList({ todos }: { todos: Todo[] }) {
  return (
    <ul>
      {todos.map((todo, index) => (
        <TodoItem key={index} todo={todo} />  // Key changes when items reorder
      ))}
    </ul>
  )
}
// Inserting item at index 0 recreates ALL items
// Input focus and local state is lost
```

**Incorrect (random key):**

```tsx
function TodoList({ todos }: { todos: Todo[] }) {
  return (
    <ul>
      {todos.map(todo => (
        <TodoItem key={Math.random()} todo={todo} />  // New key every render!
      ))}
    </ul>
  )
}
// Every render recreates ALL DOM nodes
```

**Correct (stable unique identifier):**

```tsx
function TodoList({ todos }: { todos: Todo[] }) {
  return (
    <ul>
      {todos.map(todo => (
        <TodoItem key={todo.id} todo={todo} />  // Stable across renders
      ))}
    </ul>
  )
}
// Only changed items update, state preserved
```

**When index keys are acceptable:**
- Static lists that never reorder
- Lists that never add/remove items
- Items have no local state or effects

Reference: [Rendering Lists](https://react.dev/learn/rendering-lists#keeping-list-items-in-order-with-key)

---

## 7. Component Patterns

**Impact: MEDIUM**

Ref as prop, metadata support, and directive patterns affect code organization. Legacy patterns like forwardRef add unnecessary complexity in React 19.

### 7.1 Apply use-server Directive for Server Actions Only

**Impact: MEDIUM (prevents confusion between Server Components and Server Actions)**

The 'use server' directive marks functions as Server Actions, not Server Components. Server Components are the default and need no directive.

**Incorrect (unnecessary use server):**

```tsx
// components/UserProfile.tsx
'use server'  // WRONG - this doesn't make it a Server Component

export async function UserProfile({ userId }: { userId: string }) {
  const user = await db.user.findUnique({ where: { id: userId } })
  return <div>{user.name}</div>
}
// This is incorrect usage - 'use server' is for Server Actions
```

**Correct (Server Component - no directive):**

```tsx
// components/UserProfile.tsx
// No directive needed - Server Components are default

export async function UserProfile({ userId }: { userId: string }) {
  const user = await db.user.findUnique({ where: { id: userId } })
  return <div>{user.name}</div>
}
```

**Correct (Server Action with use server):**

```tsx
// app/actions.ts
'use server'

export async function updateUserName(formData: FormData) {
  const name = formData.get('name') as string
  await db.user.update({ where: { id: userId }, data: { name } })
  revalidatePath('/profile')
}

// components/ProfileForm.tsx
import { updateUserName } from '@/app/actions'

export function ProfileForm() {
  return (
    <form action={updateUserName}>
      <input name="name" />
      <button>Save</button>
    </form>
  )
}
```

**Summary:**
- Server Components: No directive (default)
- Client Components: 'use client'
- Server Actions: 'use server' (functions, not components)

Reference: [use server](https://react.dev/reference/rsc/use-server)

### 7.2 Define Document Metadata in Components

**Impact: MEDIUM (eliminates third-party head management libraries)**

React 19 hoists `<title>`, `<meta>`, and `<link>` tags to the document head automatically. Define metadata where the content lives instead of using separate head management.

**Incorrect (external head management):**

```tsx
// Using a separate library or context
import { Helmet } from 'react-helmet'

function ProductPage({ product }: { product: Product }) {
  return (
    <>
      <Helmet>
        <title>{product.name} | Store</title>
        <meta name="description" content={product.description} />
      </Helmet>
      <ProductDetails product={product} />
    </>
  )
}
```

**Correct (native metadata support):**

```tsx
function ProductPage({ product }: { product: Product }) {
  return (
    <>
      <title>{product.name} | Store</title>
      <meta name="description" content={product.description} />
      <link rel="canonical" href={`https://store.com/products/${product.slug}`} />
      <ProductDetails product={product} />
    </>
  )
}
// React 19 automatically hoists to <head>
```

**In Server Components:**

```tsx
async function BlogPost({ slug }: { slug: string }) {
  const post = await getPost(slug)

  return (
    <article>
      <title>{post.title}</title>
      <meta name="description" content={post.excerpt} />
      <meta property="og:title" content={post.title} />
      <meta property="og:image" content={post.coverImage} />

      <h1>{post.title}</h1>
      <PostContent content={post.content} />
    </article>
  )
}
```

**Benefits:**
- Metadata lives with the content it describes
- Works with Server Components
- No third-party library needed
- Automatic deduplication of tags

Reference: [Document Metadata](https://react.dev/blog/2024/12/05/react-19#support-for-metadata-tags)

### 7.3 Place Context Providers Outside Client Boundaries

**Impact: MEDIUM (enables server rendering of provider trees)**

Context providers can be Server Components if they don't use hooks. Keep providers that only pass data as Server Components to avoid unnecessary client JavaScript.

**Incorrect (all providers are client components):**

```tsx
// providers/theme-provider.tsx
'use client'

export function ThemeProvider({ children }: { children: React.ReactNode }) {
  // No hooks, just passing a value
  return (
    <ThemeContext.Provider value={{ theme: 'light' }}>
      {children}
    </ThemeContext.Provider>
  )
}
// Unnecessary client component
```

**Correct (static provider as Server Component):**

```tsx
// providers/theme-provider.tsx
// No 'use client' - this can be a Server Component

import { ThemeContext } from './theme-context'

export function ThemeProvider({ children }: { children: React.ReactNode }) {
  const theme = getThemeFromCookie()  // Server-side

  return (
    <ThemeContext.Provider value={{ theme }}>
      {children}
    </ThemeContext.Provider>
  )
}
```

**When provider needs to be client:**

```tsx
// providers/auth-provider.tsx
'use client'  // Needed because of useState/useEffect

import { useState, useEffect } from 'react'

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null)

  useEffect(() => {
    // Subscribe to auth state
    return auth.onAuthStateChanged(setUser)
  }, [])

  return (
    <AuthContext.Provider value={{ user, setUser }}>
      {children}
    </AuthContext.Provider>
  )
}
```

**Pattern for hybrid providers:**

```tsx
// Server Component provides initial data
async function DataProvider({ children }: { children: React.ReactNode }) {
  const initialData = await fetchInitialData()

  return (
    <ClientDataProvider initialData={initialData}>
      {children}
    </ClientDataProvider>
  )
}

// Client Component manages dynamic state
'use client'
function ClientDataProvider({ initialData, children }) {
  const [data, setData] = useState(initialData)
  // ...
}
```

Reference: [Context with Server Components](https://react.dev/reference/react/useContext#passing-data-deeply-into-the-tree)

### 7.4 Place use client at Component Boundaries

**Impact: MEDIUM (minimizes client bundle, maximizes server rendering)**

The 'use client' directive marks the boundary where server rendering stops. Place it as deep in the tree as possible to maximize server-rendered content.

**Incorrect (directive too high in tree):**

```tsx
// app/dashboard/page.tsx
'use client'  // Entire page is client-rendered

import { useState } from 'react'

export default function DashboardPage() {
  const [filter, setFilter] = useState('')

  return (
    <div>
      <Header />          {/* Could be server-rendered */}
      <Sidebar />         {/* Could be server-rendered */}
      <FilterInput value={filter} onChange={setFilter} />
      <DataTable filter={filter} />
    </div>
  )
}
```

**Correct (directive at interaction boundary):**

```tsx
// app/dashboard/page.tsx - Server Component
import { FilterableDataTable } from './FilterableDataTable'

export default function DashboardPage() {
  return (
    <div>
      <Header />     {/* Server-rendered */}
      <Sidebar />    {/* Server-rendered */}
      <FilterableDataTable />
    </div>
  )
}

// app/dashboard/FilterableDataTable.tsx
'use client'  // Only interactive part

import { useState } from 'react'

export function FilterableDataTable() {
  const [filter, setFilter] = useState('')

  return (
    <div>
      <FilterInput value={filter} onChange={setFilter} />
      <DataTable filter={filter} />
    </div>
  )
}
```

**Guidelines:**
- Server Components are the default - no directive needed
- Add 'use client' only where you need hooks or browser APIs
- Think "islands of interactivity" in a sea of server content

Reference: [use client](https://react.dev/reference/rsc/use-client)

### 7.5 Use ref as a Prop Instead of forwardRef

**Impact: MEDIUM (eliminates forwardRef wrapper, reduces code by 30-50%)**

React 19 allows refs to be passed as regular props. The `forwardRef` wrapper is no longer necessary and adds unnecessary complexity.

**Incorrect (legacy forwardRef pattern):**

```tsx
import { forwardRef } from 'react'

const TextInput = forwardRef<HTMLInputElement, InputProps>(
  function TextInput({ label, ...props }, ref) {
    return (
      <div>
        <label>{label}</label>
        <input ref={ref} {...props} />
      </div>
    )
  }
)

// Usage
function Form() {
  const inputRef = useRef<HTMLInputElement>(null)
  return <TextInput ref={inputRef} label="Name" />
}
```

**Correct (ref as prop in React 19):**

```tsx
function TextInput({
  label,
  ref,
  ...props
}: InputProps & { ref?: React.Ref<HTMLInputElement> }) {
  return (
    <div>
      <label>{label}</label>
      <input ref={ref} {...props} />
    </div>
  )
}

// Usage - unchanged
function Form() {
  const inputRef = useRef<HTMLInputElement>(null)
  return <TextInput ref={inputRef} label="Name" />
}
```

**Benefits:**
- Cleaner component API
- No wrapper function needed
- TypeScript inference works naturally
- Easier to read and maintain

**Migration:** A codemod is available to automatically convert forwardRef components:

```bash
npx codemod@latest react/19/replace-forward-ref
```

Reference: [React 19 ref as prop](https://react.dev/blog/2024/12/05/react-19#ref-as-a-prop)

---

## 8. DOM & Hydration

**Impact: LOW-MEDIUM**

Hydration errors and DOM API improvements are incremental optimizations. Proper error handling prevents cryptic mismatches in SSR applications.

### 8.1 Handle Hydration Mismatches Properly

**Impact: LOW-MEDIUM (prevents cryptic errors, improves debugging experience)**

React 19 provides better hydration error messages, but mismatches still cause issues. Understand common causes and how to avoid them.

**Incorrect (hydration mismatch):**

```tsx
function Timestamp() {
  // Different value on server vs client
  return <span>{new Date().toLocaleTimeString()}</span>
}
// Server: "10:30:00 AM"
// Client: "10:30:01 AM"
// Hydration mismatch!
```

**Correct (suppress hydration for dynamic content):**

```tsx
function Timestamp() {
  const [time, setTime] = useState<string | null>(null)

  useEffect(() => {
    setTime(new Date().toLocaleTimeString())
    const interval = setInterval(() => {
      setTime(new Date().toLocaleTimeString())
    }, 1000)
    return () => clearInterval(interval)
  }, [])

  if (!time) return <span>--:--:--</span>  // Placeholder matches server

  return <span>{time}</span>
}
```

**Alternative (suppressHydrationWarning):**

```tsx
function Timestamp() {
  return (
    <span suppressHydrationWarning>
      {new Date().toLocaleTimeString()}
    </span>
  )
}
// Use sparingly - only for intentional mismatches
```

**Common hydration mismatch causes:**
- Time-based content
- Browser-specific APIs (window, localStorage)
- Random values
- User agent detection
- Third-party scripts modifying DOM

Reference: [Hydration Errors](https://react.dev/blog/2024/12/05/react-19#improvements-to-hydration-error-reporting)

### 8.2 Preload Critical Resources

**Impact: LOW-MEDIUM (faster resource loading, improved LCP)**

React 19 provides APIs to preload resources (scripts, stylesheets, fonts) before they're needed. Use these to improve loading performance for critical assets.

**Incorrect (resources load on demand):**

```tsx
function VideoPlayer({ videoId }: { videoId: string }) {
  return (
    <div>
      {/* Video player script loads only when component renders */}
      <script src="/video-player.js" />
      <div id="player" data-video={videoId} />
    </div>
  )
}
```

**Correct (preload critical resources):**

```tsx
import { preload, preconnect, prefetchDNS } from 'react-dom'

function VideoPlayer({ videoId }: { videoId: string }) {
  // Preload the video player script
  preload('/video-player.js', { as: 'script' })

  // Preconnect to video CDN
  preconnect('https://cdn.video-service.com')

  // Prefetch DNS for analytics
  prefetchDNS('https://analytics.example.com')

  return <div id="player" data-video={videoId} />
}
```

**Preload fonts:**

```tsx
import { preload } from 'react-dom'

function App() {
  preload('/fonts/inter.woff2', {
    as: 'font',
    type: 'font/woff2',
    crossOrigin: 'anonymous'
  })

  return <div className="font-inter">...</div>
}
```

**Preload stylesheets with precedence:**

```tsx
import { preinit } from 'react-dom'

function ThemeSwitcher({ theme }: { theme: 'light' | 'dark' }) {
  preinit(`/themes/${theme}.css`, {
    as: 'style',
    precedence: 'high'
  })

  return <div data-theme={theme}>...</div>
}
```

Reference: [Resource Preloading APIs](https://react.dev/blog/2024/12/05/react-19#support-for-preloading-resources)

### 8.3 Use Custom Elements with Full Prop Support

**Impact: LOW-MEDIUM (enables seamless web component integration)**

React 19 adds full support for custom elements, passing properties correctly instead of only attributes. Web components now work naturally with React.

**Incorrect (pre-React 19 workaround):**

```tsx
function MapWidget({ coordinates, onLocationSelect }: Props) {
  const mapRef = useRef<HTMLElement>(null)

  useEffect(() => {
    const map = mapRef.current
    if (map) {
      // Manual property setting
      (map as any).coordinates = coordinates;
      (map as any).addEventListener('locationselect', onLocationSelect)
    }
    return () => {
      (map as any)?.removeEventListener('locationselect', onLocationSelect)
    }
  }, [coordinates, onLocationSelect])

  return <custom-map ref={mapRef} />
}
```

**Correct (React 19 native support):**

```tsx
function MapWidget({ coordinates, onLocationSelect }: Props) {
  return (
    <custom-map
      coordinates={coordinates}           // Passed as property
      onlocationselect={onLocationSelect}  // Event handler attached
    />
  )
}
// React 19 automatically:
// - Passes complex objects as properties (not attributes)
// - Handles event listeners with on* naming
```

**With TypeScript:**

```tsx
// Declare custom element types
declare global {
  namespace JSX {
    interface IntrinsicElements {
      'custom-map': React.DetailedHTMLProps<
        React.HTMLAttributes<HTMLElement> & {
          coordinates: { lat: number; lng: number }
          onlocationselect?: (e: CustomEvent) => void
        },
        HTMLElement
      >
    }
  }
}

function MapWidget({ coordinates, onLocationSelect }: Props) {
  return (
    <custom-map
      coordinates={coordinates}
      onlocationselect={onLocationSelect}
    />
  )
}
```

Reference: [Custom Elements Support](https://react.dev/blog/2024/12/05/react-19#support-for-custom-elements)

### 8.4 Use Ref Cleanup Functions

**Impact: LOW-MEDIUM (prevents memory leaks, enables proper resource cleanup)**

React 19 supports cleanup functions in refs, similar to useEffect. Return a cleanup function from the ref callback to handle resource disposal.

**Incorrect (no cleanup, potential memory leak):**

```tsx
function VideoPlayer({ src }: { src: string }) {
  const videoRef = useRef<HTMLVideoElement>(null)

  useEffect(() => {
    const video = videoRef.current
    if (video) {
      video.addEventListener('ended', handleEnded)
    }
    return () => {
      video?.removeEventListener('ended', handleEnded)
    }
  }, [])

  return <video ref={videoRef} src={src} />
}
// Cleanup tied to effect, not to element lifecycle
```

**Correct (ref with cleanup function):**

```tsx
function VideoPlayer({ src }: { src: string }) {
  const handleRef = (video: HTMLVideoElement | null) => {
    if (!video) return

    video.addEventListener('ended', handleEnded)

    return () => {
      video.removeEventListener('ended', handleEnded)  // Cleanup on unmount
    }
  }

  return <video ref={handleRef} src={src} />
}
// Cleanup runs when element is removed from DOM
```

**With third-party libraries:**

```tsx
function ChartContainer({ data }: { data: ChartData }) {
  const handleRef = (element: HTMLDivElement | null) => {
    if (!element) return

    const chart = new ThirdPartyChart(element, data)

    return () => {
      chart.destroy()  // Proper cleanup
    }
  }

  return <div ref={handleRef} />
}
```

**Benefits:**
- Cleanup tied to DOM element lifecycle
- Simpler than useEffect for DOM operations
- Works naturally with conditional rendering

Reference: [Ref Callbacks](https://react.dev/blog/2024/12/05/react-19#ref-callbacks)

### 8.5 Use Stylesheet Precedence for CSS Loading

**Impact: LOW-MEDIUM (prevents FOUC, ensures correct style ordering)**

React 19 supports stylesheet loading with precedence control. Define loading order and React ensures styles are applied correctly, preventing flash of unstyled content.

**Incorrect (unpredictable style order):**

```tsx
function ComponentWithStyles() {
  return (
    <>
      <link rel="stylesheet" href="/component.css" />
      <link rel="stylesheet" href="/theme.css" />
      <div className="styled-component">...</div>
    </>
  )
}
// Order may vary, theme might not override component styles
```

**Correct (explicit precedence):**

```tsx
function ComponentWithStyles() {
  return (
    <>
      <link
        rel="stylesheet"
        href="/base.css"
        precedence="low"
      />
      <link
        rel="stylesheet"
        href="/component.css"
        precedence="medium"
      />
      <link
        rel="stylesheet"
        href="/theme.css"
        precedence="high"  // Always loads after component styles
      />
      <div className="styled-component">...</div>
    </>
  )
}
```

**With Suspense for style loading:**

```tsx
function StyledSection({ themeUrl }: { themeUrl: string }) {
  return (
    <Suspense fallback={<LoadingSpinner />}>
      <link
        rel="stylesheet"
        href={themeUrl}
        precedence="high"
      />
      <ThemedContent />
    </Suspense>
  )
}
// Component suspends until stylesheet is loaded
```

**Built-in precedence levels:**
- `"reset"` - Lowest priority
- `"low"` - Base styles
- `"medium"` - Component styles (default)
- `"high"` - Theme/override styles

Reference: [Stylesheet Precedence](https://react.dev/blog/2024/12/05/react-19#support-for-stylesheets)

---

## References

1. [https://react.dev](https://react.dev)
2. [https://react.dev/blog/2024/12/05/react-19](https://react.dev/blog/2024/12/05/react-19)
3. [https://react.dev/reference/react/use](https://react.dev/reference/react/use)
4. [https://react.dev/reference/react/useActionState](https://react.dev/reference/react/useActionState)
5. [https://react.dev/reference/react/useOptimistic](https://react.dev/reference/react/useOptimistic)
6. [https://react.dev/reference/rsc/server-components](https://react.dev/reference/rsc/server-components)
7. [https://react.dev/learn/react-compiler/introduction](https://react.dev/learn/react-compiler/introduction)
8. [https://vercel.com/blog/whats-new-in-react-19](https://vercel.com/blog/whats-new-in-react-19)