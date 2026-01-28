---
title: Clean Up Resources in useEffect
impact: MEDIUM
impactDescription: prevents memory leaks from subscriptions and timers
tags: mem, useEffect, cleanup, memory-leak, subscriptions
---

## Clean Up Resources in useEffect

Effects that create subscriptions, timers, or listeners must clean them up on unmount to prevent memory leaks.

**Incorrect (no cleanup):**

```tsx
function LivePriceDisplay({ symbol }) {
  const [price, setPrice] = useState(null)

  useEffect(() => {
    // WebSocket connection never closed
    const ws = new WebSocket(`wss://prices.example.com/${symbol}`)
    ws.onmessage = (event) => {
      setPrice(JSON.parse(event.data).price)
    }
    // No cleanup! WebSocket stays open after unmount
  }, [symbol])

  useEffect(() => {
    // Timer never cleared
    const interval = setInterval(() => {
      fetchPrice(symbol).then(setPrice)
    }, 5000)
    // No cleanup! Timer keeps running after unmount
  }, [symbol])

  return <Text>${price}</Text>
}
// Memory leaks accumulate with each mount/unmount
```

**Correct (proper cleanup):**

```tsx
function LivePriceDisplay({ symbol }) {
  const [price, setPrice] = useState(null)

  useEffect(() => {
    const ws = new WebSocket(`wss://prices.example.com/${symbol}`)

    ws.onmessage = (event) => {
      setPrice(JSON.parse(event.data).price)
    }

    // Cleanup: close WebSocket on unmount or symbol change
    return () => {
      ws.close()
    }
  }, [symbol])

  useEffect(() => {
    const interval = setInterval(() => {
      fetchPrice(symbol).then(setPrice)
    }, 5000)

    // Cleanup: clear interval on unmount or symbol change
    return () => {
      clearInterval(interval)
    }
  }, [symbol])

  return <Text>${price}</Text>
}
```

**Common cleanup patterns:**

```tsx
// Event listeners
useEffect(() => {
  const subscription = AppState.addEventListener('change', handleAppState)
  return () => subscription.remove()
}, [])

// Keyboard listeners
useEffect(() => {
  const showSub = Keyboard.addListener('keyboardDidShow', handleShow)
  const hideSub = Keyboard.addListener('keyboardDidHide', handleHide)
  return () => {
    showSub.remove()
    hideSub.remove()
  }
}, [])

// Dimensions listener
useEffect(() => {
  const subscription = Dimensions.addEventListener('change', handleChange)
  return () => subscription.remove()
}, [])

// Async operations with mounted check
useEffect(() => {
  let isMounted = true

  fetchData().then(data => {
    if (isMounted) {
      setData(data)
    }
  })

  return () => {
    isMounted = false
  }
}, [])

// Animation cleanup
useEffect(() => {
  const animation = Animated.loop(
    Animated.sequence([
      Animated.timing(opacity, { toValue: 1, duration: 1000 }),
      Animated.timing(opacity, { toValue: 0, duration: 1000 }),
    ])
  )
  animation.start()

  return () => animation.stop()
}, [])
```

**Reanimated shared values don't need cleanup:**

```tsx
// Shared values are automatically cleaned up
useEffect(() => {
  opacity.value = withTiming(1)
  // No cleanup needed for shared values
}, [])
```

**Cleanup checklist:**
- [ ] WebSocket connections → `ws.close()`
- [ ] setInterval/setTimeout → `clearInterval()`/`clearTimeout()`
- [ ] Event listeners → `subscription.remove()`
- [ ] Animated.loop → `animation.stop()`
- [ ] AbortController → `controller.abort()`
- [ ] Third-party subscriptions → check library docs

Reference: [React useEffect Cleanup](https://react.dev/learn/synchronizing-with-effects#how-to-handle-the-effect-firing-twice-in-development)
