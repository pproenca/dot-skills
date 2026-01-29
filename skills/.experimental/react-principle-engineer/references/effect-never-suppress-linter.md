---
title: Never suppress the dependency linter
impact: HIGH
impactDescription: Suppressing exhaustive-deps hides bugs; fix the code instead of silencing the warning
tags: [effect, linter, dependencies, bugs, warnings]
---

# Never Suppress the Dependency Linter

When the linter warns about missing dependencies, the correct response is to change your code, not suppress the warning. Suppression hides real bugs.

## Why This Matters

The linter catches:
- Stale closures reading old values
- Effects that should re-run but don't
- Missing cleanup timing
- Bugs that are very hard to find otherwise

## The Temptation

```tsx
// The linter complains about missing 'count'
useEffect(() => {
  const id = setInterval(() => {
    console.log(count);  // Using count
  }, 1000);
  return () => clearInterval(id);
}, []);  // ⚠️ Missing dependency: 'count'

// Developer thinks: "I only want this to run once"
// So they add:
// eslint-disable-next-line react-hooks/exhaustive-deps

// THIS IS A BUG, not a linter mistake!
```

## The Bug It Catches

```tsx
function Counter() {
  const [count, setCount] = useState(0);

  useEffect(() => {
    const id = setInterval(() => {
      setCount(count + 1);  // Always adds 1 to INITIAL count (0)
    }, 1000);
    return () => clearInterval(id);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);  // SUPPRESSED - BUG!

  return <div>{count}</div>;
  // Shows: 1, 1, 1, 1... (stuck at 1!)
}
```

## The Fix: Change the Code

```tsx
// Solution 1: Use updater function
function Counter() {
  const [count, setCount] = useState(0);

  useEffect(() => {
    const id = setInterval(() => {
      setCount(c => c + 1);  // Updater doesn't need count in scope
    }, 1000);
    return () => clearInterval(id);
  }, []);  // ✅ Now correctly has no dependencies

  return <div>{count}</div>;
  // Shows: 1, 2, 3, 4...
}

// Solution 2: Include the dependency (if appropriate)
useEffect(() => {
  const id = setInterval(() => {
    console.log(count);
  }, 1000);
  return () => clearInterval(id);
}, [count]);  // ✅ Re-runs when count changes
```

## Common "Fix" That's Wrong

```tsx
// "I'll add the dependency but it runs too often!"
function Chat({ roomId, onMessage }: Props) {
  useEffect(() => {
    const conn = connect(roomId);
    conn.on('message', onMessage);
    return () => conn.disconnect();
  }, [roomId, onMessage]);  // onMessage changes every render!

  // Wrong "fix": suppress linter
  // ❌ // eslint-disable-next-line react-hooks/exhaustive-deps
  // }, [roomId]);
}

// Correct fix: stabilize the callback
function Chat({ roomId, onMessage }: Props) {
  // If parent doesn't memoize, wrap it
  const stableOnMessage = useCallback(onMessage, []);
  // Or use useEffectEvent (React 18.3+)

  useEffect(() => {
    const conn = connect(roomId);
    conn.on('message', stableOnMessage);
    return () => conn.disconnect();
  }, [roomId, stableOnMessage]);  // ✅ Now stable
}
```

## When You Think You Need to Suppress

| Symptom | Real Fix |
|---------|----------|
| "Effect runs too often" | Remove the reactive value from effect, or stabilize it |
| "I only want mount" | Ensure deps are truly empty (no reactive values read) |
| "Callback changes every render" | useCallback in parent, or useEffectEvent |
| "Object reference changes" | Move object creation inside effect, or useMemo |

## Moving Values Inside the Effect

```tsx
// Problem: Object created outside, changes every render
function Chat({ roomId }: { roomId: string }) {
  const options = { roomId, serverUrl: 'https://...' };

  useEffect(() => {
    const conn = connect(options);
    return () => conn.disconnect();
  }, [options]);  // ⚠️ options is new every render!
}

// Solution: Create inside effect
function Chat({ roomId }: { roomId: string }) {
  useEffect(() => {
    const options = { roomId, serverUrl: 'https://...' };
    const conn = connect(options);
    return () => conn.disconnect();
  }, [roomId]);  // ✅ Depends only on primitive
}
```

## The Principle

```tsx
// The dependency array is a DESCRIPTION of your code, not a WISH

// If your code reads 'count', you depend on 'count'
// The linter knows this from analyzing your code
// Suppressing it doesn't change reality - it hides the bug

// RULE: Treat linter warnings as compile errors
// If the linter says you need a dependency, you do
// Change your code to not need it, or include it
```

## Key Principle

The linter is smarter than your intuition about closures. When it says you're missing a dependency, it's right. Find a way to fix the code structure, not silence the warning.
