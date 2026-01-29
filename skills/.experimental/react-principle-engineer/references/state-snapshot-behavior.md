---
title: State behaves like a snapshot
impact: HIGH
impactDescription: State value is fixed for each render; updates schedule new renders rather than changing current values
tags: [state, snapshot, rendering, async, batching]
---

# State Behaves Like a Snapshot

Each render has its own fixed state value. When you call `setState`, you're scheduling a new render with a new value - you're not changing the current value.

## Why This Matters

Understanding snapshots:
- Explains why state "doesn't update immediately"
- Prevents bugs with async operations
- Clarifies event handler behavior
- Helps understand React's rendering model

## The Snapshot Mental Model

```tsx
function Counter() {
  const [count, setCount] = useState(0);

  function handleClick() {
    // In THIS render, count is 0
    setCount(count + 1);  // Schedules render with 1
    setCount(count + 1);  // Still reading count=0, schedules render with 1
    setCount(count + 1);  // Still count=0, schedules render with 1

    console.log(count);   // Logs 0, not 3!
  }

  return <button onClick={handleClick}>{count}</button>;
}
// After click: shows 1, not 3
```

## Why Multiple setStates Don't Stack

```tsx
// Each render is a "snapshot" with fixed values
function Counter() {
  const [count, setCount] = useState(0);

  function handleClick() {
    // Imagine React "takes a photo" of this render
    // In that photo, count = 0

    setCount(count + 1);  // "Set count to 0 + 1"
    setCount(count + 1);  // "Set count to 0 + 1" (same!)
    setCount(count + 1);  // "Set count to 0 + 1" (same!)

    // All three schedule count = 1
    // React batches and only renders once
  }
}
```

## Correct: Use Updater Functions

```tsx
function Counter() {
  const [count, setCount] = useState(0);

  function handleClick() {
    // Updater functions receive the PENDING state
    setCount(c => c + 1);  // 0 + 1 = 1
    setCount(c => c + 1);  // 1 + 1 = 2
    setCount(c => c + 1);  // 2 + 1 = 3

    console.log(count);  // Still logs 0 (snapshot!)
  }

  return <button onClick={handleClick}>{count}</button>;
}
// After click: shows 3
```

## Async Code and Snapshots

```tsx
// Problem: Using stale snapshot value
function MessageForm() {
  const [message, setMessage] = useState('');

  async function handleSubmit() {
    const currentMessage = message;  // Capture from snapshot

    await sendMessage(message);

    // Even after await, using the OLD snapshot value
    console.log('Sent:', message);  // Could be stale!
  }

  // If user types more while sending, message has changed
  // but our console.log shows the old value
}
```

**Correct (recommended):**

```tsx
// Solution: Capture what you need before async operations
function MessageForm() {
  const [message, setMessage] = useState('');

  async function handleSubmit() {
    const messageToSend = message;  // Capture from current snapshot

    // Use the captured value
    await sendMessage(messageToSend);
    console.log('Sent:', messageToSend);  // Correct value

    // Can still check current state after
    // (but it might have changed during await)
  }
}
```

## Timeouts and Closures

```tsx
function DelayedCounter() {
  const [count, setCount] = useState(0);

  function handleClick() {
    // The timeout captures the CURRENT snapshot's count
    setTimeout(() => {
      setCount(count + 1);  // Uses count from when click happened
    }, 3000);
  }

  // If count is 0 and you click 5 times quickly:
  // - 5 timeouts scheduled, each with count=0
  // - After 3 seconds, all 5 run: setCount(0+1) five times
  // - Result: 1, not 5

  return <button onClick={handleClick}>{count}</button>;
}
```

## Correct: Updater for Delayed Updates

```tsx
function DelayedCounter() {
  const [count, setCount] = useState(0);

  function handleClick() {
    setTimeout(() => {
      // Updater receives latest pending state
      setCount(c => c + 1);
    }, 3000);
  }

  // 5 quick clicks → result is 5 after 3 seconds

  return <button onClick={handleClick}>{count}</button>;
}
```

## Visualizing the Snapshot

```tsx
function Messenger() {
  const [message, setMessage] = useState('Hello');

  function handleSendClick() {
    setTimeout(() => {
      // Which message gets shown?
      alert(message);
    }, 5000);
  }

  return (
    <>
      <input
        value={message}
        onChange={e => setMessage(e.target.value)}
      />
      <button onClick={handleSendClick}>Send</button>
    </>
  );
}

// Click Send when message = "Hello"
// Then change input to "Goodbye"
// 5 seconds later, alert shows "Hello" (the snapshot!)
```

## Key Principle

Think of each render as a freeze-frame photo. State, props, and event handlers in that render all see the same frozen values. `setState` doesn't change the photo - it tells React to take a new photo with different values.
