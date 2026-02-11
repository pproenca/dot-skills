---
title: Avoid Closure-Based Memory Leaks in Event Handlers
impact: LOW-MEDIUM
impactDescription: prevents MB-scale memory retention in event-heavy UIs
tags: mem, closure, event-handler, garbage-collection
---

## Avoid Closure-Based Memory Leaks in Event Handlers

Event handlers that capture large arrays, datasets, or DOM references in their closure retain that data for the lifetime of the handler registration. When handlers are attached to long-lived elements like `window` or `document` without cleanup, the closed-over data is never garbage collected.

**Incorrect (handler closure retains entire analytics dataset):**

```tsx
function AnalyticsOverlay({ events }: { events: AnalyticsEvent[] }) {
  const [hoverPosition, setHoverPosition] = useState<{ x: number; y: number } | null>(null)

  useEffect(() => {
    const handleMouseMove = (e: MouseEvent) => {
      // Closure captures the entire events array (50,000+ objects retained)
      const nearbyEvent = events.find(
        (event) =>
          Math.abs(event.x - e.clientX) < 10 &&
          Math.abs(event.y - e.clientY) < 10
      )
      if (nearbyEvent) {
        setHoverPosition({ x: e.clientX, y: e.clientY })
      }
    }

    window.addEventListener("mousemove", handleMouseMove)
    // Missing cleanup — handler retains events array after unmount
  }, [events])

  return hoverPosition ? (
    <div style={{ position: "fixed", left: hoverPosition.x, top: hoverPosition.y }}>
      <EventTooltip />
    </div>
  ) : null
}
```

**Correct (minimal closure with spatial index, proper cleanup):**

```tsx
function AnalyticsOverlay({ events }: { events: AnalyticsEvent[] }) {
  const [hoverPosition, setHoverPosition] = useState<{ x: number; y: number } | null>(null)
  const spatialIndexRef = useRef<Map<string, AnalyticsEvent>>(new Map())

  useEffect(() => {
    // Build lightweight lookup — closure captures only the ref
    const index = new Map<string, AnalyticsEvent>()
    for (const event of events) {
      const key = `${Math.round(event.x / 10)},${Math.round(event.y / 10)}`
      index.set(key, event)
    }
    spatialIndexRef.current = index
  }, [events])

  useEffect(() => {
    const handleMouseMove = (e: MouseEvent) => {
      const key = `${Math.round(e.clientX / 10)},${Math.round(e.clientY / 10)}`
      if (spatialIndexRef.current.has(key)) {
        setHoverPosition({ x: e.clientX, y: e.clientY })
      } else {
        setHoverPosition(null)
      }
    }

    window.addEventListener("mousemove", handleMouseMove)
    return () => {
      window.removeEventListener("mousemove", handleMouseMove)
    }
  }, [])

  return hoverPosition ? (
    <div style={{ position: "fixed", left: hoverPosition.x, top: hoverPosition.y }}>
      <EventTooltip />
    </div>
  ) : null
}
```

Reference: [Chrome DevTools — Fix Memory Problems](https://developer.chrome.com/docs/devtools/memory-problems)
