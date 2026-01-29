---
title: Follow ref best practices
impact: MEDIUM
impactDescription: Treat refs as escape hatches - use them sparingly, avoid reading during render, prefer state for UI values
tags: [ref, best-practices, patterns, guidelines]
---

# Follow Ref Best Practices

Refs are powerful but should be used judiciously. They're escape hatches from React's declarative model.

## Core Principles

### 1. Treat Refs as Escape Hatches

```tsx
// Refs are for when React's model doesn't fit:
// - Imperative DOM APIs (focus, scroll, measure)
// - Timer IDs
// - Third-party library instances
// - Values that don't affect render

// If you find yourself using many refs, reconsider your approach
```

### 2. Don't Read/Write `ref.current` During Render

```tsx
// BAD
function Bad() {
  const ref = useRef(0);
  ref.current++;  // ❌ Mutation during render
  return <div>{ref.current}</div>;  // ❌ Reading during render
}

// GOOD
function Good() {
  const ref = useRef(0);

  useEffect(() => {
    ref.current++;  // ✅ In effect
  });

  function handleClick() {
    console.log(ref.current);  // ✅ In handler
  }

  return <button onClick={handleClick}>Click</button>;
}
```

### 3. Prefer State for UI Values

```tsx
// Problem: Ref for displayed value
function BadCounter() {
  const countRef = useRef(0);
  // UI won't update when countRef.current changes
}

// Solution: State for displayed value
function GoodCounter() {
  const [count, setCount] = useState(0);
  // UI updates when count changes
}
```

### 4. Use Refs for Non-UI Values

```tsx
function Timer() {
  // State: affects what's displayed
  const [time, setTime] = useState(0);

  // Ref: doesn't affect display (timer ID)
  const intervalRef = useRef<number | null>(null);

  function start() {
    intervalRef.current = setInterval(() => {
      setTime(t => t + 1);
    }, 1000);
  }

  function stop() {
    if (intervalRef.current) {
      clearInterval(intervalRef.current);
    }
  }

  return <div>{time}s</div>;
}
```

### 5. Don't Overuse Refs

```tsx
// Problem: Using refs to avoid re-renders everywhere
function Bad() {
  const dataRef = useRef([]);
  const filterRef = useRef('');
  const sortRef = useRef('asc');
  // Now nothing re-renders, UI is broken
}

// Solution: Use state, optimize with memo if needed
function Good() {
  const [data, setData] = useState([]);
  const [filter, setFilter] = useState('');
  const [sort, setSort] = useState('asc');
  // React can optimize re-renders
}
```

### 6. Avoid Ref Chains

```tsx
// Problem: Complex ref relationships
function Bad() {
  const ref1 = useRef(null);
  const ref2 = useRef(ref1);  // Ref to ref?
  const ref3 = useRef(() => ref2.current?.current);  // ??
}

// Solution: Simple, direct refs
function Good() {
  const elementRef = useRef<HTMLDivElement>(null);
  const timerRef = useRef<number | null>(null);
  // Each ref has one clear purpose
}
```

## When to Use Refs Checklist

✅ **Use ref when:**
- Storing timer/interval IDs
- Referencing DOM elements
- Holding third-party library instances
- Storing values that shouldn't trigger re-render
- Tracking previous values

❌ **Don't use ref when:**
- Value should be displayed in UI
- Change should trigger re-render
- You're trying to avoid re-renders (use memo instead)
- You're trying to share state between components

## Common Anti-Patterns

```tsx
// Anti-pattern 1: Ref to avoid passing prop
function Parent() {
  const valueRef = useRef('secret');
  return <Child valueRef={valueRef} />;  // Just pass the value!
}

// Anti-pattern 2: Ref to communicate between components
function Sibling1({ sharedRef }) {
  sharedRef.current = 'message';  // Unpredictable timing!
}

// Anti-pattern 3: Ref instead of state for form
function Form() {
  const inputRef = useRef('');
  // Uncontrolled input - harder to validate, no re-render on change
}
```

## Key Principle

Refs exist for cases where React's declarative model doesn't apply. Use them for imperative operations and non-UI values. For everything else, prefer state and props.
