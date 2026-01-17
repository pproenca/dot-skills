---
title: Always Clean Up Effects on Unmount
impact: HIGH
impactDescription: prevents memory leaks and orphaned timers
tags: tuistate, useeffect, cleanup, memory, timers
---

## Always Clean Up Effects on Unmount

Return cleanup functions from `useEffect` to cancel timers, close connections, and release resources when components unmount.

**Incorrect (no cleanup):**

```typescript
function Spinner() {
  const [frame, setFrame] = useState(0)
  const frames = ['|', '/', '-', '\\']

  useEffect(() => {
    setInterval(() => {
      setFrame(f => (f + 1) % frames.length)
    }, 100)
    // No cleanup - timer runs forever after unmount
  }, [])

  return <Text>{frames[frame]}</Text>
}
// Memory leak, state updates on unmounted component
```

**Correct (cleanup function):**

```typescript
function Spinner() {
  const [frame, setFrame] = useState(0)
  const frames = ['|', '/', '-', '\\']

  useEffect(() => {
    const timer = setInterval(() => {
      setFrame(f => (f + 1) % frames.length)
    }, 100)

    return () => clearInterval(timer)  // Cleanup on unmount
  }, [])

  return <Text>{frames[frame]}</Text>
}
```

**Common cleanup patterns:**

```typescript
// Event listeners
useEffect(() => {
  const handler = () => handleResize()
  process.stdout.on('resize', handler)
  return () => process.stdout.off('resize', handler)
}, [])

// Abort controller for fetch
useEffect(() => {
  const controller = new AbortController()

  fetch(url, { signal: controller.signal })
    .then(setData)
    .catch(err => {
      if (err.name !== 'AbortError') setError(err)
    })

  return () => controller.abort()
}, [url])

// Subscriptions
useEffect(() => {
  const unsubscribe = eventEmitter.subscribe(handler)
  return unsubscribe
}, [])
```

Reference: [React Documentation - useEffect Cleanup](https://react.dev/reference/react/useEffect#connecting-to-an-external-system)
