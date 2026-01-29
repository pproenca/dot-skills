---
title: Use refs to track mutable values across renders
impact: MEDIUM
impactDescription: Refs persist values between renders without causing re-renders, useful for previous values, timers, and callbacks
tags: [ref, mutable, persistence, callbacks, timers]
---

# Use Refs to Track Mutable Values Across Renders

Refs can store any mutable value that needs to persist across renders but doesn't affect the UI. This is useful for tracking previous values, holding timer IDs, or keeping stable callback references.

## Why This Matters

Mutable refs enable:
- Tracking previous props/state
- Storing interval/timeout IDs
- Keeping latest callback for effects
- Avoiding stale closures

## Tracking Previous Values

```tsx
function useChange(value: unknown) {
  const prevRef = useRef(value);
  const prev = prevRef.current;

  useEffect(() => {
    prevRef.current = value;
  });

  return { prev, current: value };
}

function PriceDisplay({ price }: { price: number }) {
  const { prev, current } = useChange(price);

  return (
    <div>
      <span>${current}</span>
      {prev !== undefined && current > prev && <span>↑</span>}
      {prev !== undefined && current < prev && <span>↓</span>}
    </div>
  );
}
```

## Holding Timer IDs

```tsx
function Debounced({ value, delay }: { value: string; delay: number }) {
  const [debouncedValue, setDebouncedValue] = useState(value);
  const timeoutRef = useRef<number>();

  useEffect(() => {
    // Clear previous timeout
    clearTimeout(timeoutRef.current);

    // Set new timeout
    timeoutRef.current = setTimeout(() => {
      setDebouncedValue(value);
    }, delay);

    return () => {
      clearTimeout(timeoutRef.current);
    };
  }, [value, delay]);

  return <span>{debouncedValue}</span>;
}
```

## Latest Callback Pattern

```tsx
// Keep latest callback without re-running effect
function useInterval(callback: () => void, delay: number) {
  const savedCallback = useRef(callback);

  // Update ref to latest callback
  useEffect(() => {
    savedCallback.current = callback;
  });

  // Set up interval with stable ref
  useEffect(() => {
    function tick() {
      savedCallback.current();  // Always calls latest callback
    }

    const id = setInterval(tick, delay);
    return () => clearInterval(id);
  }, [delay]);  // Only re-runs when delay changes
}

// Usage
function Counter() {
  const [count, setCount] = useState(0);

  // Callback can use latest state without being in deps
  useInterval(() => {
    setCount(count + 1);  // Uses current count
  }, 1000);

  return <div>{count}</div>;
}
```

## Avoiding Stale Closures in Async

```tsx
function Search({ onResults }: { onResults: (r: Result[]) => void }) {
  const [query, setQuery] = useState('');
  const latestQuery = useRef(query);

  // Keep ref updated
  useEffect(() => {
    latestQuery.current = query;
  }, [query]);

  async function handleSearch() {
    const currentQuery = query;
    const results = await fetchResults(currentQuery);

    // Only update if this is still the latest search
    if (latestQuery.current === currentQuery) {
      onResults(results);
    }
  }

  return (
    <div>
      <input value={query} onChange={e => setQuery(e.target.value)} />
      <button onClick={handleSearch}>Search</button>
    </div>
  );
}
```

## Instance Count / Render Tracking (Debug Only)

```tsx
function useRenderCount() {
  const renderCount = useRef(0);

  // Update in effect, not during render
  useEffect(() => {
    renderCount.current += 1;
  });

  return renderCount.current;
}

function Component() {
  const renderCount = useRenderCount();

  console.log(`Rendered ${renderCount} times`);
  return <div>...</div>;
}
```

## Third-Party Instance Storage

```tsx
function Chart({ data }: { data: ChartData }) {
  const containerRef = useRef<HTMLDivElement>(null);
  const chartRef = useRef<ChartJS | null>(null);

  useEffect(() => {
    if (!containerRef.current) return;

    // Create chart instance
    chartRef.current = new ChartJS(containerRef.current, {
      type: 'line',
      data,
    });

    return () => {
      chartRef.current?.destroy();
    };
  }, []);  // Create once

  // Update chart when data changes
  useEffect(() => {
    if (chartRef.current) {
      chartRef.current.data = data;
      chartRef.current.update();
    }
  }, [data]);

  return <div ref={containerRef} />;
}
```

## Key Principle

Use refs for mutable values that need to persist across renders but don't influence what gets rendered. They're like instance variables in class components - private storage that React doesn't monitor.
