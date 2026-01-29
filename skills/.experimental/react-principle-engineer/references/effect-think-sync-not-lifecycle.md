---
title: Think start/stop synchronization, not component lifecycle
impact: HIGH
impactDescription: Effects have their own lifecycle; don't think in mount/unmount but in how to sync and unsync
tags: [effect, lifecycle, synchronization, mental-model]
---

# Think Start/Stop Synchronization, Not Component Lifecycle

Effects don't run "on mount" or "on update." They start synchronizing with something external, and later stop. This mental model makes Effects much easier to understand.

## Why This Matters

The sync mental model:
- Makes cleanup logic obvious
- Explains why StrictMode double-runs effects
- Clarifies dependency behavior
- Matches how Effects actually work

## The Wrong Mental Model

```tsx
// WRONG: Thinking in lifecycle
useEffect(() => {
  // "This runs on mount"
  doSomething();

  return () => {
    // "This runs on unmount"
    cleanup();
  };
}, []);

// Problems with this thinking:
// - StrictMode runs cleanup between mounts
// - Effects with deps run multiple times
// - You start asking "when" instead of "what"
```

## The Right Mental Model

```tsx
// RIGHT: Thinking in synchronization
useEffect(() => {
  // "How to START syncing with roomId"
  const connection = createConnection(roomId);
  connection.connect();

  return () => {
    // "How to STOP syncing with roomId"
    connection.disconnect();
  };
}, [roomId]);

// This Effect knows how to:
// 1. Start syncing (connect to roomId)
// 2. Stop syncing (disconnect from roomId)
//
// React calls these at the right times:
// - Mount: start syncing
// - roomId changes: stop old sync, start new sync
// - Unmount: stop syncing
```

## Example Timeline

```tsx
function ChatRoom({ roomId }: { roomId: string }) {
  useEffect(() => {
    const connection = createConnection(roomId);
    connection.connect();
    return () => connection.disconnect();
  }, [roomId]);
}

// User opens chat with roomId="general":
// → Start: Connect to "general"

// User switches to roomId="travel":
// → Stop: Disconnect from "general"
// → Start: Connect to "travel"

// User switches to roomId="music":
// → Stop: Disconnect from "travel"
// → Start: Connect to "music"

// User closes chat (unmount):
// → Stop: Disconnect from "music"

// Notice: We never said "mount" or "unmount"
// We only described how to start and stop syncing
```

## Why StrictMode Double-Fires

```tsx
// StrictMode tests that your sync/unsync works:

useEffect(() => {
  console.log('Sync start');
  return () => console.log('Sync stop');
}, []);

// In StrictMode (dev only):
// 1. "Sync start"
// 2. "Sync stop"    ← React tests your cleanup
// 3. "Sync start"

// If your Effect is pure (proper sync/unsync),
// the final state is the same as running once
```

## Describing Sync, Not Timing

```tsx
// WRONG: Describing when it runs
useEffect(() => {
  // "After first render, fetch user"
  fetchUser(id).then(setUser);
}, [id]);
// What about when id changes? Sounds like it "runs again"?

// RIGHT: Describing what it syncs
useEffect(() => {
  // "Keep React state in sync with server's user data"
  let cancelled = false;

  fetchUser(id).then(user => {
    if (!cancelled) setUser(user);
  });

  return () => {
    cancelled = true;  // Stop syncing with old id
  };
}, [id]);
// Clear: sync with current id, stop syncing when id changes
```

## The Sync Contract

```tsx
// Your Effect makes a contract with React:

useEffect(() => {
  // "Here's how to sync with [dependencies]"
  const cleanup = startSync(dependencies);

  return () => {
    // "Here's how to stop syncing"
    cleanup();
  };
}, [dependencies]);

// React promises:
// - Call start when deps change
// - Call stop before calling start again
// - Call stop when component goes away
```

## Empty Dependencies ≠ "Run Once"

```tsx
// WRONG thinking:
useEffect(() => {
  setup();
}, []);  // "Run once on mount"

// RIGHT thinking:
useEffect(() => {
  setup();
}, []);  // "Sync with nothing reactive - sync once"

// The difference matters:
// - "Run once" suggests it's about timing
// - "Sync with nothing" explains WHY it only runs once
```

## Practical Difference

```tsx
// If you think lifecycle:
// "This effect runs on mount to set up analytics"
// "Why is it firing twice in dev??"

// If you think synchronization:
// "This effect syncs with the analytics service"
// "StrictMode verified my sync/unsync works correctly"

useEffect(() => {
  analytics.init();
  analytics.pageView();
  return () => analytics.cleanup();
}, []);
```

## Key Principle

Don't ask "when does this effect run?" Ask "what does this effect synchronize with, and how do I start and stop that synchronization?" This makes cleanup obvious and handles all timing cases.
