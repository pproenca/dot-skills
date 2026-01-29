---
title: Dependencies must match the code
impact: HIGH
impactDescription: Every reactive value used in an effect must be in the dependency array; don't lie about dependencies
tags: [effect, dependencies, linter, reactive, sync]
---

# Dependencies Must Match the Code

The dependency array tells React when to re-run the Effect. Include every reactive value (props, state, context, or values derived from them) that the Effect reads.

## Why This Matters

Correct dependencies:
- Keep Effects synchronized with current state
- Prevent stale closure bugs
- Enable proper cleanup timing
- Are required - React's linter enforces this

## The Core Rule

```tsx
function ChatRoom({ roomId }: { roomId: string }) {
  const [serverUrl, setServerUrl] = useState('https://localhost:1234');

  useEffect(() => {
    // Effect reads roomId and serverUrl
    const connection = createConnection(serverUrl, roomId);
    connection.connect();
    return () => connection.disconnect();
  }, [serverUrl, roomId]);  // Must list both!

  // roomId is a prop (reactive)
  // serverUrl is state (reactive)
  // Both can change, both must be in deps
}
```

## What's Reactive?

```tsx
function Component({ propValue }: { propValue: string }) {
  const [stateValue, setStateValue] = useState('');
  const contextValue = useContext(MyContext);

  // Reactive (can change between renders):
  // - propValue (prop)
  // - stateValue (state)
  // - contextValue (context)
  // - derivedValue (calculated from reactive values)
  const derivedValue = propValue + stateValue;

  useEffect(() => {
    doSomething(propValue, stateValue, contextValue, derivedValue);
  }, [propValue, stateValue, contextValue, derivedValue]);

  // NOT reactive (stable between renders):
  // - refs (ref.current is mutable but ref is stable)
  // - setState functions (guaranteed stable)
  // - module-level constants
}

const CONSTANT = 'https://api.example.com';

function Example() {
  useEffect(() => {
    fetch(CONSTANT);  // Not in deps - it never changes
  }, []);
}
```

## Don't Lie About Dependencies

```tsx
// Problem: Missing dependency
function SearchResults({ query }: { query: string }) {
  const [results, setResults] = useState([]);

  useEffect(() => {
    fetchResults(query).then(setResults);
  }, []);  // 🔴 Missing 'query' - STALE!

  // Bug: Shows results for first query forever
  // Even when query prop changes, effect doesn't re-run
}

// Solution: Include all dependencies
useEffect(() => {
  fetchResults(query).then(setResults);
}, [query]);  // ✅ Re-fetches when query changes
```

## The Linter Is Right

```tsx
// Problem: Suppressing the linter
useEffect(() => {
  const connection = createConnection(roomId);
  connection.connect();
  return () => connection.disconnect();
  // eslint-disable-next-line react-hooks/exhaustive-deps
}, []);  // 🔴 Ignoring roomId!

// This creates bugs:
// - Won't reconnect when roomId changes
// - Shows wrong room's messages
// - StrictMode will expose the bug

// Solution: Trust the linter
useEffect(() => {
  const connection = createConnection(roomId);
  connection.connect();
  return () => connection.disconnect();
}, [roomId]);  // ✅ Reconnects when room changes
```

## Objects and Functions as Dependencies

```tsx
// PROBLEM: Object/function recreated every render
function Chat({ roomId }: { roomId: string }) {
  const options = { roomId, serverUrl };  // New object every render

  useEffect(() => {
    const connection = createConnection(options);
    connection.connect();
    return () => connection.disconnect();
  }, [options]);  // Runs on EVERY render! options is new each time
}

// SOLUTION 1: Move inside effect
function Chat({ roomId }: { roomId: string }) {
  useEffect(() => {
    const options = { roomId, serverUrl };  // Created inside effect
    const connection = createConnection(options);
    connection.connect();
    return () => connection.disconnect();
  }, [roomId]);  // Now depends on primitive
}

// SOLUTION 2: Use primitives
function Chat({ roomId, serverUrl }: Props) {
  useEffect(() => {
    const connection = createConnection(serverUrl, roomId);
    connection.connect();
    return () => connection.disconnect();
  }, [roomId, serverUrl]);  // Primitives are safe
}
```

## Empty Dependency Array

```tsx
// Empty array = run once on mount, cleanup on unmount
useEffect(() => {
  const handleKeyDown = (e: KeyboardEvent) => {
    if (e.key === 'Escape') closeModal();
  };

  document.addEventListener('keydown', handleKeyDown);
  return () => document.removeEventListener('keydown', handleKeyDown);
}, []);  // ✅ Only if effect truly has no reactive dependencies

// But wait - closeModal might be reactive!
// If it uses state, this is a bug
```

## To Remove a Dependency, Change the Code

```tsx
// If you want fewer dependencies, restructure the code

// Problem: Want to remove onMessage from deps
useEffect(() => {
  connection.on('message', onMessage);
  return () => connection.off('message', onMessage);
}, [onMessage]);  // Runs when onMessage changes (often!)

// Solution: Use useEffectEvent for non-reactive logic (React 18.3+)
const onMessageEvent = useEffectEvent(onMessage);

useEffect(() => {
  connection.on('message', onMessageEvent);
  return () => connection.off('message', onMessageEvent);
}, []);  // onMessageEvent is stable, not in deps
```

## Key Principle

Dependencies aren't what you "want" the Effect to depend on - they're what the Effect actually reads. The linter tells you what's true; work with it, not against it.
