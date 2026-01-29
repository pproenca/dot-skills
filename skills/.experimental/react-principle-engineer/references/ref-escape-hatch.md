---
title: Refs are escape hatches for non-rendering values
impact: MEDIUM
impactDescription: Use refs to store values that shouldn't trigger re-renders, like timer IDs, DOM elements, or external objects
tags: [ref, escape-hatch, rendering, state, dom]
---

# Refs Are Escape Hatches for Non-Rendering Values

When you need to remember a value but don't want changes to trigger a re-render, use a ref. Refs are "outside" React's rendering system.

## Why This Matters

Understanding refs:
- Clarifies ref vs state decisions
- Prevents unnecessary re-renders
- Enables imperative DOM access
- Stores values across renders without triggering updates

## Ref vs State

```tsx
// STATE: Value affects what's displayed
function Counter() {
  const [count, setCount] = useState(0);  // Changes → re-render

  return (
    <button onClick={() => setCount(c => c + 1)}>
      Count: {count}  {/* Displayed, so use state */}
    </button>
  );
}

// REF: Value doesn't affect display
function Stopwatch() {
  const intervalRef = useRef<number | null>(null);  // Not displayed
  const [time, setTime] = useState(0);

  function start() {
    intervalRef.current = setInterval(() => {
      setTime(t => t + 1);
    }, 1000);
    // No re-render when setting intervalRef
  }

  function stop() {
    clearInterval(intervalRef.current!);
  }

  return (
    <div>
      <p>{time} seconds</p>
      <button onClick={start}>Start</button>
      <button onClick={stop}>Stop</button>
    </div>
  );
}
```

## Common Ref Use Cases

```tsx
// 1. Timer IDs
const intervalId = useRef<number | null>(null);

// 2. Previous value tracking
const prevValue = useRef(value);
useEffect(() => {
  prevValue.current = value;
});

// 3. DOM element access
const inputRef = useRef<HTMLInputElement>(null);

// 4. Instance of external library
const mapInstance = useRef<google.maps.Map | null>(null);

// 5. Mutable values in callbacks
const latestCallback = useRef(callback);
latestCallback.current = callback;
```

## DOM Access with Refs

```tsx
function TextInputWithFocusButton() {
  const inputRef = useRef<HTMLInputElement>(null);

  function handleClick() {
    inputRef.current?.focus();  // Imperative DOM access
  }

  return (
    <>
      <input ref={inputRef} />
      <button onClick={handleClick}>Focus Input</button>
    </>
  );
}
```

## Difference from State

| Aspect | useRef | useState |
|--------|--------|----------|
| Changes trigger re-render | No | Yes |
| Value available | Immediately | Next render |
| Mutable | Yes (.current) | No (use setter) |
| Safe in render | Read only, don't write | Read freely |

## Incorrect: Ref for Displayed Value

```tsx
// Problem: Using ref for displayed value
function Counter() {
  const countRef = useRef(0);

  function increment() {
    countRef.current += 1;
    // UI doesn't update! No re-render triggered
  }

  return (
    <button onClick={increment}>
      Count: {countRef.current}  {/* Shows stale value! */}
    </button>
  );
}
```

## Correct: State for Displayed Value

```tsx
// Solution: Use state for displayed values
function Counter() {
  const [count, setCount] = useState(0);

  function increment() {
    setCount(c => c + 1);  // Triggers re-render
  }

  return (
    <button onClick={increment}>
      Count: {count}  {/* Always current */}
    </button>
  );
}
```

## Key Principle

Ask: "Does this value affect what the component renders?" If yes, use state. If no (like a timer ID or DOM reference), use a ref.
