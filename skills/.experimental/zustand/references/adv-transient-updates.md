---
title: Use subscribe for Transient Updates
impact: LOW
impactDescription: enables non-React integrations without re-renders
tags: adv, subscribe, transient, external
---

## Use subscribe for Transient Updates

For high-frequency updates or non-React integrations (animations, WebGL, analytics), use `subscribe` to react to state changes without triggering React re-renders.

**Incorrect (React re-renders for every update):**

```typescript
function CursorTracker() {
  const position = useCursorStore((s) => s.position)
  // Re-renders 60+ times per second during mouse movement

  useEffect(() => {
    // Expensive analytics on every re-render
    analytics.track('cursor_position', position)
  }, [position])

  return <Cursor x={position.x} y={position.y} />
}
```

**Correct (transient subscription for analytics):**

```typescript
function CursorTracker() {
  const cursorRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    // Subscribe outside React render cycle
    const unsubscribe = useCursorStore.subscribe(
      (state, prevState) => {
        // Update DOM directly (no re-render)
        if (cursorRef.current) {
          cursorRef.current.style.transform =
            `translate(${state.position.x}px, ${state.position.y}px)`
        }

        // Throttled analytics (doesn't cause re-render)
        if (Math.abs(state.position.x - prevState.position.x) > 50) {
          analytics.track('cursor_moved', state.position)
        }
      }
    )
    return unsubscribe
  }, [])

  return <div ref={cursorRef} className="cursor" />
}
```

**Alternative (selective subscription with subscribeWithSelector):**

```typescript
import { subscribeWithSelector } from 'zustand/middleware'

const useGameStore = create<GameState>()(
  subscribeWithSelector((set) => ({
    score: 0,
    health: 100,
    position: { x: 0, y: 0 },
    // ...
  }))
)

// Subscribe only to score changes
useGameStore.subscribe(
  (state) => state.score,
  (score, prevScore) => {
    if (score > prevScore) {
      playSound('point')
      showFloatingText(`+${score - prevScore}`)
    }
  }
)

// Subscribe to health with custom equality
useGameStore.subscribe(
  (state) => state.health,
  (health) => {
    if (health <= 0) {
      triggerGameOver()
    }
  },
  { equalityFn: (a, b) => Math.floor(a / 10) === Math.floor(b / 10) }
)
```

**Use cases:**
- Canvas/WebGL rendering
- Audio engine updates
- Analytics/logging
- Third-party library sync

Reference: [Zustand - subscribeWithSelector](https://zustand.docs.pmnd.rs/middlewares/subscribe-with-selector)
