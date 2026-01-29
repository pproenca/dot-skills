---
title: Use subscribe for Non-React Consumers
impact: MEDIUM
impactDescription: enables direct DOM updates without React re-render
tags: render, subscribe, external, vanilla
---

## Use subscribe for Non-React Consumers

For non-React code or when you need to update the DOM directly without triggering React re-renders, use the store's `subscribe` method. This is useful for animations, canvas updates, or integrating with third-party libraries.

**Incorrect (React re-render for every frame):**

```typescript
function AnimatedCounter() {
  const progress = useProgressStore((s) => s.progress)
  // Re-renders 60 times per second during animation
  return (
    <div
      className="progress-bar"
      style={{ width: `${progress}%` }}
    />
  )
}
```

**Correct (direct DOM update via subscribe):**

```typescript
function AnimatedCounter() {
  const progressRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    // Subscribe directly to store updates
    const unsubscribe = useProgressStore.subscribe(
      (state) => state.progress,
      (progress) => {
        // Update DOM directly, no React re-render
        if (progressRef.current) {
          progressRef.current.style.width = `${progress}%`
        }
      }
    )
    return unsubscribe
  }, [])

  return <div ref={progressRef} className="progress-bar" />
}
```

**Alternative (subscribeWithSelector middleware):**

```typescript
import { subscribeWithSelector } from 'zustand/middleware'

const useProgressStore = create<ProgressState>()(
  subscribeWithSelector((set) => ({
    progress: 0,
    setProgress: (progress) => set({ progress }),
  }))
)

// Subscribe with fireImmediately option
useProgressStore.subscribe(
  (state) => state.progress,
  (progress, previousProgress) => {
    console.log('Progress changed from', previousProgress, 'to', progress)
  },
  { fireImmediately: true }
)
```

**When to use:**
- High-frequency updates (animations, real-time data)
- Canvas or WebGL rendering
- Third-party library integration
- Analytics or logging

Reference: [Zustand - subscribeWithSelector](https://zustand.docs.pmnd.rs/middlewares/subscribe-with-selector)
