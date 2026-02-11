---
title: Stabilize Hook Dependencies with Refs and Callbacks
impact: HIGH
impactDescription: prevents infinite loops, eliminates unnecessary re-executions
tags: hook, dependencies, useRef, stability, infinite-loops
---

## Stabilize Hook Dependencies with Refs and Callbacks

Unstable dependencies — callback props that are recreated every render — cause useEffect to re-execute infinitely. The effect fires, triggers a state change in the parent, the parent re-renders with a new callback reference, and the effect fires again. Storing the latest callback in a ref breaks the cycle while always calling the most recent version.

**Incorrect (callback prop in dependency array — infinite loop):**

```tsx
function useInterval(callback: () => void, delayMs: number) {
  useEffect(() => {
    const id = setInterval(callback, delayMs);
    return () => clearInterval(id);
  }, [callback, delayMs]); // callback changes every render — effect restarts infinitely
}

function PollDashboard({ refreshRate }: { refreshRate: number }) {
  const [metrics, setMetrics] = useState<Metrics | null>(null);

  // New function reference every render
  useInterval(() => {
    fetchMetrics().then(setMetrics); // setMetrics triggers re-render, new callback, repeat
  }, refreshRate);

  return <MetricsDisplay metrics={metrics} />;
}
```

**Correct (ref stabilizes the callback — effect runs once):**

```tsx
function useInterval(callback: () => void, delayMs: number) {
  const savedCallback = useRef(callback);

  // Update ref on every render — always points to latest closure
  useEffect(() => {
    savedCallback.current = callback;
  });

  useEffect(() => {
    const id = setInterval(() => savedCallback.current(), delayMs);
    return () => clearInterval(id);
  }, [delayMs]); // Only re-runs when delay changes
}

function PollDashboard({ refreshRate }: { refreshRate: number }) {
  const [metrics, setMetrics] = useState<Metrics | null>(null);

  useInterval(() => {
    fetchMetrics().then(setMetrics);
  }, refreshRate);

  return <MetricsDisplay metrics={metrics} />;
}
```

**Modern alternative (useEffectEvent — React 19.2+):**

`useEffectEvent` wraps a callback so it can be used inside effects without declaring it as a dependency, achieving the same stability with less boilerplate:

```tsx
function useInterval(callback: () => void, delayMs: number) {
  const onTick = useEffectEvent(callback);

  useEffect(() => {
    const id = setInterval(onTick, delayMs);
    return () => clearInterval(id);
  }, [delayMs]);
}
```

For codebases on React 19.2+, prefer `useEffectEvent` over the ref pattern. See the `react` skill for detailed API usage.

Reference: [React Docs - useEffectEvent](https://react.dev/learn/separating-events-from-effects)
