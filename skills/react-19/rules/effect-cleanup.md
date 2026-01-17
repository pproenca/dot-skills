---
title: Always Clean Up Effect Side Effects
impact: MEDIUM
impactDescription: prevents memory leaks, stale callbacks
tags: effect, cleanup, memory-leak, subscription
---

## Always Clean Up Effect Side Effects

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
