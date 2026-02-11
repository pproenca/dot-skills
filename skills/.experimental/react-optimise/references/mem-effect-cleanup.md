---
title: Clean Up Effects to Prevent Subscription Memory Leaks
impact: LOW-MEDIUM
impactDescription: prevents linear memory growth in long-lived SPAs
tags: mem, cleanup, subscription, useEffect
---

## Clean Up Effects to Prevent Subscription Memory Leaks

Subscriptions created in useEffect without a cleanup function accumulate listeners every time the component re-mounts. In SPAs with client-side routing, a user navigating back and forth creates duplicate subscriptions that consume memory and trigger stale callbacks.

**Incorrect (new listener added on each mount, never removed):**

```tsx
function StockTicker({ symbol }: { symbol: string }) {
  const [price, setPrice] = useState<number | null>(null)

  useEffect(() => {
    const socket = new WebSocket(`wss://market-feed.example.com/ws/${symbol}`)

    socket.onmessage = (event) => {
      const update = JSON.parse(event.data) as { price: number }
      setPrice(update.price) // stale callback fires after unmount
    }

    // No cleanup — socket stays open after unmount
    // Navigating away and back creates a second socket
    // 10 navigations = 10 open sockets consuming memory and bandwidth
  }, [symbol])

  return <span className="ticker">{price ? `$${price.toFixed(2)}` : "Loading..."}</span>
}
```

**Correct (cleanup closes connection on unmount or symbol change):**

```tsx
function StockTicker({ symbol }: { symbol: string }) {
  const [price, setPrice] = useState<number | null>(null)

  useEffect(() => {
    const socket = new WebSocket(`wss://market-feed.example.com/ws/${symbol}`)

    socket.onmessage = (event) => {
      const update = JSON.parse(event.data) as { price: number }
      setPrice(update.price)
    }

    return () => {
      socket.close() // closes connection on unmount or symbol change
    }
  }, [symbol])

  return <span className="ticker">{price ? `$${price.toFixed(2)}` : "Loading..."}</span>
}
```

Reference: [React Docs — Synchronizing with Effects](https://react.dev/learn/synchronizing-with-effects#how-to-handle-the-effect-firing-twice-in-development)
