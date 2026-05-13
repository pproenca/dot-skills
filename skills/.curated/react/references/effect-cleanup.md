---
title: Every effect that subscribes, schedules, or connects must return a cleanup that tears it down
impact: MEDIUM
impactDescription: prevents memory leaks, double-firing event handlers, and stale callbacks holding closures over unmounted components
tags: effect, cleanup-return, subscription-teardown, abort-guard
---

## Every effect that subscribes, schedules, or connects must return a cleanup that tears it down

**Pattern intent:** any effect that opens a resource (subscription, interval, listener, socket, fetch) must close it in its cleanup. Cleanup runs on unmount *and* between renders when deps change — both cases need teardown to be idempotent.

### Shapes to recognize

- `useEffect(() => { setInterval(...) }, [])` with no `return () => clearInterval(...)`.
- An `addEventListener` inside an effect with no matching `removeEventListener` in the return.
- A `fetch(...).then(setData)` with an `AbortController` *created* but not consulted on resolve — abort fires, but the resolved-then-aborted path still calls `setData` on an unmounted component (see "Race guard" below).
- A WebSocket / EventSource opened in an effect with no `.close()` in cleanup.
- A subscription to a third-party store (Mobx, Apollo, RxJS) with no `subscription.unsubscribe()` on unmount.
- A timer registered via `setTimeout` for a deferred-effect pattern with no `clearTimeout` — fires after unmount, errors on stale state setter.

### Race guard for cancellable async

A common subtle bug: aborting a fetch *doesn't* prevent its already-resolved `.then(setData)` from running. Guard the post-resolve state write:

```typescript
useEffect(() => {
  const controller = new AbortController()
  fetch('/api/data', { signal: controller.signal })
    .then(res => res.json())
    .then(data => {
      if (!controller.signal.aborted) setData(data)
    })
    .catch(err => {
      if (!controller.signal.aborted) setError(err)
    })
  return () => controller.abort()
}, [])
```

Without the `if (!aborted)` guard, an abort that lands *after* `.then(res.json())` resolves still triggers `setData` against an unmounted (or re-keyed) component. The cleaner alternative is to migrate the read to `use(promise)` + Suspense, which handles the lifecycle structurally.

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

// Abort fetch on unmount — with race guard against post-resolve state writes
useEffect(() => {
  const controller = new AbortController()

  fetch('/api/data', { signal: controller.signal })
    .then(res => res.json())
    .then(data => {
      if (!controller.signal.aborted) setData(data)
    })

  return () => controller.abort()
}, [])

// WebSocket connection
useEffect(() => {
  const ws = new WebSocket(url)
  ws.onmessage = handleMessage
  return () => ws.close()
}, [url])
```
