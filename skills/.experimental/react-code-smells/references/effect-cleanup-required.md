---
title: Always Clean Up Effect Side Effects
impact: HIGH
impactDescription: prevents memory leaks, stale callbacks, and race conditions
tags: effect, cleanup, memory-leaks, subscriptions, refactoring
---

## Always Clean Up Effect Side Effects

Effects that create subscriptions, timers, or async operations without cleanup cause memory leaks and bugs. Always return a cleanup function.

**Code Smell Indicators:**
- Subscriptions without unsubscribe
- setInterval without clearInterval
- Async operations that set state after unmount
- "Can't perform state update on unmounted component" warnings

**Incorrect (no cleanup):**

```tsx
function LivePrice({ symbol }) {
  const [price, setPrice] = useState(null)

  useEffect(() => {
    // Subscription without cleanup - memory leak
    const ws = new WebSocket(`wss://prices.api/${symbol}`)
    ws.onmessage = (e) => setPrice(JSON.parse(e.data).price)
    // No cleanup - connection stays open forever
  }, [symbol])

  useEffect(() => {
    // Timer without cleanup - runs forever
    const interval = setInterval(() => {
      fetch(`/api/prices/${symbol}`).then(r => r.json()).then(setPrice)
    }, 5000)
    // No cleanup
  }, [symbol])

  useEffect(() => {
    // Async without abort - race condition
    fetch(`/api/prices/${symbol}`)
      .then(r => r.json())
      .then(data => setPrice(data.price))
    // If symbol changes quickly, old responses may arrive after new ones
  }, [symbol])

  return <span>{price}</span>
}
```

**Correct (proper cleanup):**

```tsx
function LivePrice({ symbol }) {
  const [price, setPrice] = useState(null)

  // WebSocket with cleanup
  useEffect(() => {
    const ws = new WebSocket(`wss://prices.api/${symbol}`)
    ws.onmessage = (e) => setPrice(JSON.parse(e.data).price)

    return () => ws.close()  // Cleanup: close connection
  }, [symbol])

  // Timer with cleanup
  useEffect(() => {
    const interval = setInterval(() => {
      fetch(`/api/prices/${symbol}`).then(r => r.json()).then(setPrice)
    }, 5000)

    return () => clearInterval(interval)  // Cleanup: stop timer
  }, [symbol])

  // Async with abort controller
  useEffect(() => {
    const controller = new AbortController()

    fetch(`/api/prices/${symbol}`, { signal: controller.signal })
      .then(r => r.json())
      .then(data => setPrice(data.price))
      .catch(e => {
        if (e.name !== 'AbortError') throw e  // Ignore abort errors
      })

    return () => controller.abort()  // Cleanup: cancel fetch
  }, [symbol])

  return <span>{price}</span>
}
```

**Cleanup patterns by side effect type:**

| Side Effect | Cleanup Pattern |
|-------------|-----------------|
| WebSocket | `ws.close()` |
| EventListener | `element.removeEventListener()` |
| setInterval | `clearInterval(id)` |
| setTimeout | `clearTimeout(id)` |
| fetch | `AbortController.abort()` |
| Third-party subscription | `subscription.unsubscribe()` |
| DOM mutation | Restore original state |

**Boolean flag pattern for non-abortable async:**

```tsx
useEffect(() => {
  let cancelled = false

  async function fetchData() {
    const data = await someAsyncOperation()
    if (!cancelled) {
      setData(data)  // Only set if not cancelled
    }
  }

  fetchData()

  return () => {
    cancelled = true  // Mark as cancelled on cleanup
  }
}, [dependency])
```

**Cleanup timing:**
```
Component renders with deps = [A]
├── Effect runs (setup)
├── deps change to [B]
│   ├── Cleanup runs for [A]
│   └── Effect runs for [B]
├── Component unmounts
│   └── Cleanup runs for [B]
```

Reference: [Synchronizing with Effects](https://react.dev/learn/synchronizing-with-effects#how-to-handle-the-effect-firing-twice-in-development)
