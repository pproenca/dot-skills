---
title: Use useSyncExternalStore for External Subscriptions
impact: MEDIUM
impactDescription: correct subscription handling, SSR compatible
tags: effect, useSyncExternalStore, subscription, external
---

## Use useSyncExternalStore for External Subscriptions

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
