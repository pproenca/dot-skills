---
title: Use Ref Cleanup Functions
impact: LOW-MEDIUM
impactDescription: prevents memory leaks, enables proper resource cleanup
tags: dom, ref, cleanup, lifecycle
---

## Use Ref Cleanup Functions

React 19 supports cleanup functions in refs, similar to useEffect. Return a cleanup function from the ref callback to handle resource disposal.

**Incorrect (no cleanup, potential memory leak):**

```tsx
function VideoPlayer({ src }: { src: string }) {
  const videoRef = useRef<HTMLVideoElement>(null)

  useEffect(() => {
    const video = videoRef.current
    if (video) {
      video.addEventListener('ended', handleEnded)
    }
    return () => {
      video?.removeEventListener('ended', handleEnded)
    }
  }, [])

  return <video ref={videoRef} src={src} />
}
// Cleanup tied to effect, not to element lifecycle
```

**Correct (ref with cleanup function):**

```tsx
function VideoPlayer({ src }: { src: string }) {
  const handleRef = (video: HTMLVideoElement | null) => {
    if (!video) return

    video.addEventListener('ended', handleEnded)

    return () => {
      video.removeEventListener('ended', handleEnded)  // Cleanup on unmount
    }
  }

  return <video ref={handleRef} src={src} />
}
// Cleanup runs when element is removed from DOM
```

**With third-party libraries:**

```tsx
function ChartContainer({ data }: { data: ChartData }) {
  const handleRef = (element: HTMLDivElement | null) => {
    if (!element) return

    const chart = new ThirdPartyChart(element, data)

    return () => {
      chart.destroy()  // Proper cleanup
    }
  }

  return <div ref={handleRef} />
}
```

**Benefits:**
- Cleanup tied to DOM element lifecycle
- Simpler than useEffect for DOM operations
- Works naturally with conditional rendering

Reference: [Ref Callbacks](https://react.dev/blog/2024/12/05/react-19#ref-callbacks)
