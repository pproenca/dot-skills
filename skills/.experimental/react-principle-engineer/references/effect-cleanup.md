---
title: Always provide cleanup functions for effects
impact: HIGH
impactDescription: Effects that start something must stop it; cleanup runs before re-running and on unmount
tags: [effect, cleanup, memory-leaks, subscriptions]
---

# Always Provide Cleanup Functions for Effects

When your Effect starts something that needs to be stopped or cleaned up, return a cleanup function. React will call it before re-running the Effect and when the component unmounts.

## Why This Matters

Cleanup prevents:
- Memory leaks from subscriptions
- Stale callbacks running
- Multiple concurrent connections
- Resource exhaustion

## Basic Cleanup Pattern

```tsx
useEffect(() => {
  // START: Set up something
  const subscription = subscribe(channel);

  // STOP: Clean it up
  return () => {
    subscription.unsubscribe();
  };
}, [channel]);
```

## When Cleanup Runs

```tsx
function ChatRoom({ roomId }: { roomId: string }) {
  useEffect(() => {
    const connection = createConnection(roomId);
    connection.connect();
    console.log(`Connected to ${roomId}`);

    return () => {
      connection.disconnect();
      console.log(`Disconnected from ${roomId}`);
    };
  }, [roomId]);
}

// Timeline when roomId changes from "general" to "travel":
// 1. Component renders with roomId="travel"
// 2. "Disconnected from general" (cleanup of old effect)
// 3. "Connected to travel" (new effect runs)

// On unmount:
// 4. "Disconnected from travel" (final cleanup)
```

## Common Cleanup Scenarios

### Event Listeners

```tsx
useEffect(() => {
  function handleResize() {
    setSize({ width: window.innerWidth, height: window.innerHeight });
  }

  window.addEventListener('resize', handleResize);

  return () => {
    window.removeEventListener('resize', handleResize);
  };
}, []);
```

### Timers

```tsx
useEffect(() => {
  const intervalId = setInterval(() => {
    setCount(c => c + 1);
  }, 1000);

  return () => {
    clearInterval(intervalId);
  };
}, []);
```

### Subscriptions

```tsx
useEffect(() => {
  const unsubscribe = store.subscribe(() => {
    setStoreState(store.getState());
  });

  return unsubscribe;  // Clean function returned directly
}, [store]);
```

### Fetch Requests (Abort)

```tsx
useEffect(() => {
  const controller = new AbortController();

  async function fetchData() {
    try {
      const response = await fetch(url, { signal: controller.signal });
      const data = await response.json();
      setData(data);
    } catch (error) {
      if (error.name !== 'AbortError') {
        setError(error);
      }
    }
  }

  fetchData();

  return () => {
    controller.abort();  // Cancel in-flight request
  };
}, [url]);
```

### Race Condition Prevention

```tsx
useEffect(() => {
  let cancelled = false;

  async function fetchData() {
    const data = await fetchUserData(userId);

    // Only update if this effect is still current
    if (!cancelled) {
      setUser(data);
    }
  }

  fetchData();

  return () => {
    cancelled = true;
  };
}, [userId]);
```

## No Cleanup Needed

```tsx
// Analytics - fire and forget
useEffect(() => {
  logPageView(page);
  // No cleanup: logging doesn't need to be "undone"
}, [page]);

// Syncing video with state
useEffect(() => {
  if (isPlaying) {
    videoRef.current?.play();
  } else {
    videoRef.current?.pause();
  }
  // No cleanup: pause/play doesn't accumulate
}, [isPlaying]);
```

## StrictMode and Cleanup

```tsx
// In development with StrictMode, React:
// 1. Mounts component
// 2. Runs effect
// 3. Runs cleanup (!)
// 4. Runs effect again

// This verifies your cleanup works correctly!

useEffect(() => {
  const connection = createConnection(roomId);
  connection.connect();
  // Without proper cleanup, you'd see TWO connections

  return () => {
    connection.disconnect();
  };
}, [roomId]);

// With proper cleanup: connect, disconnect, connect
// Final state: one connection (correct!)
```

## Incorrect: Missing Cleanup

```tsx
// Problem: No cleanup for subscription
useEffect(() => {
  socket.on('message', handleMessage);
  // Memory leak! Old handlers accumulate
}, [handleMessage]);

// Solution: Clean up subscription
useEffect(() => {
  socket.on('message', handleMessage);
  return () => {
    socket.off('message', handleMessage);
  };
}, [handleMessage]);
```

## Cleanup for DOM Modifications

```tsx
useEffect(() => {
  const tooltip = document.createElement('div');
  tooltip.className = 'tooltip';
  document.body.appendChild(tooltip);

  return () => {
    document.body.removeChild(tooltip);
  };
}, []);
```

## Key Principle

Ask: "What would happen if this Effect ran twice?" or "What's left behind if the component disappears?" If the answer involves leaks, stale state, or duplicate resources, you need cleanup.
