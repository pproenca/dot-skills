---
title: Subscribe to external mutable state through `useSyncExternalStore`, not `useEffect` + `useState`
impact: MEDIUM
impactDescription: prevents tearing under concurrent rendering, provides correct SSR semantics, removes manual cleanup boilerplate
tags: effect, external-subscription, sync-external-store, tearing-safe
---

## Subscribe to external mutable state through `useSyncExternalStore`, not `useEffect` + `useState`

**Pattern intent:** mutable state that lives outside React (browser APIs like `online`/`localStorage`, Redux stores, Mobx, Apollo, RxJS) must be read through the dedicated subscription hook. `useEffect` + `useState` works in non-concurrent rendering but tears under concurrent rendering and has no SSR snapshot story.

### Shapes to recognize

- `useEffect(() => { window.addEventListener('online', () => setOnline(navigator.onLine)) ... }, [])` and a paired `useState(true)` mirror.
- A custom hook `useNetworkStatus()` whose body is the above shape.
- Hand-written subscription to a third-party store with `useEffect` and `useState`, returning the mirrored value.
- A reading from `localStorage` inside a `useEffect` to populate `useState` — works for one-time read; for live values that change in another tab, `useSyncExternalStore` plus the `storage` event is correct.
- A "global counter" or "user session" piece of mutable state held in a module variable, accessed by a component via `useEffect` to copy into `useState` — same anti-shape.

The canonical resolution: write a `subscribe(callback)` that registers listeners and returns an unsubscribe; write a `getSnapshot()` that returns the current value; call `useSyncExternalStore(subscribe, getSnapshot, getServerSnapshot)`. The result reads tearing-free in concurrent mode and produces correct SSR markup.

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
