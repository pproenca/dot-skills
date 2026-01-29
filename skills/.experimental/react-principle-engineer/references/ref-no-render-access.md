---
title: Don't read or write refs during render
impact: HIGH
impactDescription: Accessing ref.current during render makes component behavior unpredictable and breaks React's model
tags: [ref, rendering, purity, predictability]
---

# Don't Read or Write Refs During Render

Reading or writing `ref.current` during rendering breaks component purity. React doesn't track ref changes, so render output becomes unpredictable.

## Why This Matters

Refs during render cause:
- Unpredictable render output
- Different results in development vs production
- StrictMode revealing bugs
- Concurrent rendering issues

## Incorrect: Writing Ref During Render

```tsx
// Problem: Setting ref during render
function Counter() {
  const countRef = useRef(0);

  // WRONG: Writing ref during render
  countRef.current++;

  return <div>{countRef.current}</div>;
}
// In StrictMode, shows 2, 4, 6 instead of 1, 2, 3
// The mutation happens during render, which runs twice in dev
```

## Incorrect: Reading Ref During Render

```tsx
// Problem: Reading ref to determine render output
function DisplayValue() {
  const valueRef = useRef('initial');

  // WRONG: Render depends on mutable ref
  return <div>{valueRef.current}</div>;
}
// React doesn't know when valueRef.current changes
// Component might show stale value
```

## Correct: Access Refs in Event Handlers

```tsx
// Solution: Write ref in event handler
function StopWatch() {
  const startTimeRef = useRef<number | null>(null);
  const [elapsed, setElapsed] = useState(0);

  function handleStart() {
    startTimeRef.current = Date.now();  // Write in handler
    requestAnimationFrame(tick);
  }

  function tick() {
    if (startTimeRef.current) {
      setElapsed(Date.now() - startTimeRef.current);  // Read in handler
      requestAnimationFrame(tick);
    }
  }

  return (
    <div>
      <p>{elapsed}ms</p>
      <button onClick={handleStart}>Start</button>
    </div>
  );
}
```

## Correct: Access Refs in Effects

```tsx
// Solution: Write ref in effect
function MeasureSize() {
  const divRef = useRef<HTMLDivElement>(null);
  const [size, setSize] = useState({ width: 0, height: 0 });

  useEffect(() => {
    if (divRef.current) {
      const rect = divRef.current.getBoundingClientRect();  // Read in effect
      setSize({ width: rect.width, height: rect.height });
    }
  }, []);

  return <div ref={divRef}>Measure me</div>;
}
```

## The One Exception: Lazy Initialization

```tsx
// EXCEPTION: One-time initialization during render is OK
function Video({ src }: { src: string }) {
  const playerRef = useRef<VideoPlayer | null>(null);

  // OK: Only initializes once, never changes after
  if (playerRef.current === null) {
    playerRef.current = new VideoPlayer();
  }

  return <VideoPlayerView player={playerRef.current} />;
}

// This pattern is safe because:
// 1. Only sets once (check for null)
// 2. Always sets to the same thing
// 3. Result is deterministic
```

## Incorrect Pattern: Render Counter

```tsx
// Problem: Tracking renders with ref
function BadComponent() {
  const renderCount = useRef(0);
  renderCount.current++;  // Mutation during render!

  console.log(`Render #${renderCount.current}`);
  return <div>...</div>;
}
// Shows wrong counts in StrictMode
// Behavior differs dev vs prod
```

## Key Locations for Ref Access

```tsx
function Component() {
  const ref = useRef(null);

  // ❌ DON'T: During render (function body)
  // ref.current = something;
  // const x = ref.current;

  // ✅ DO: In event handlers
  function handleClick() {
    ref.current = something;
  }

  // ✅ DO: In effects
  useEffect(() => {
    ref.current = something;
  }, []);

  // ✅ DO: In callbacks passed to child
  return <Child onMount={node => { ref.current = node; }} />;
}
```

## Key Principle

Refs are for values that live "outside" the render. Keep them outside - access them in effects and event handlers, not during render itself.
