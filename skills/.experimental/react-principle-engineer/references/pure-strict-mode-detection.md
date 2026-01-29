---
title: Use StrictMode to detect impure components
impact: HIGH
impactDescription: StrictMode double-renders to expose hidden bugs before they reach production
tags: [pure, debugging, strictmode, development]
---

# Use StrictMode to Detect Impure Components

React's StrictMode intentionally renders components twice in development to help you find impure components that produce different results on re-render.

## Why This Matters

StrictMode catches bugs that would otherwise be invisible:
- External mutations during render
- Missing cleanup in effects
- Deprecated lifecycle usage
- Side effects in render that should be in useEffect

## Correct Setup

```tsx
// index.tsx or main.tsx
import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import App from './App';

const root = createRoot(document.getElementById('root')!);
root.render(
  <StrictMode>
    <App />
  </StrictMode>
);
```

## Bug StrictMode Catches

```tsx
// This bug is INVISIBLE without StrictMode
let counter = 0;

function BuggyCounter() {
  counter++;
  return <div>Count: {counter}</div>;
}

function App() {
  return (
    <>
      <BuggyCounter />  {/* Shows 2 in StrictMode, 1 in production */}
      <BuggyCounter />  {/* Shows 4 in StrictMode, 2 in production */}
    </>
  );
}

// In development with StrictMode:
// - First BuggyCounter renders twice: counter becomes 2
// - Second BuggyCounter renders twice: counter becomes 4
//
// This makes the bug OBVIOUS during development
```

## The Fix StrictMode Guides You To

```tsx
// Solution: Pure component, works correctly with StrictMode
function PureCounter({ value }: { value: number }) {
  return <div>Count: {value}</div>;
}

function App() {
  const [count, setCount] = useState(0);

  return (
    <>
      <PureCounter value={count} />
      <button onClick={() => setCount(c => c + 1)}>
        Increment
      </button>
    </>
  );
}
```

## Effect Cleanup Detection

```tsx
// StrictMode also tests effect cleanup
function ChatRoom({ roomId }: { roomId: string }) {
  useEffect(() => {
    const connection = createConnection(roomId);
    connection.connect();

    // In StrictMode:
    // 1. Connect to room
    // 2. Disconnect (cleanup)
    // 3. Connect again
    // This verifies cleanup works correctly!

    return () => {
      connection.disconnect();
    };
  }, [roomId]);

  return <h1>Welcome to {roomId}</h1>;
}
```

## What StrictMode Does

| Behavior | Purpose |
|----------|---------|
| Double render | Detect impure rendering |
| Double effect | Verify cleanup functions |
| Deprecation warnings | Identify outdated patterns |
| Legacy context check | Find unsafe lifecycle usage |

## Common StrictMode "False Positives"

```tsx
// This LOOKS broken in StrictMode but is actually fine
function Logger({ message }: { message: string }) {
  console.log('Rendering:', message);  // Logs twice in dev
  return <div>{message}</div>;
}

// The double log is expected in StrictMode
// Production will only log once
// Don't disable StrictMode just to avoid double logs!
```

## Key Principle

If your component behaves differently when rendered twice, you have a bug. StrictMode makes this obvious. Pure components produce identical results whether rendered once or a hundred times.
