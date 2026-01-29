---
title: Each effect should represent one synchronization concern
impact: HIGH
impactDescription: Don't combine unrelated logic in one effect; split effects by what they synchronize, not by timing
tags: [effect, separation, concerns, single-responsibility]
---

# Each Effect Should Represent One Synchronization Concern

If your Effect does two unrelated things, split it into two Effects. The question isn't "when does this run?" but "what am I synchronizing?"

## Why This Matters

Separate Effects:
- Can be reasoned about independently
- Have focused cleanup functions
- Won't re-run when unrelated dependencies change
- Are easier to test and maintain

## Incorrect: Combined Unrelated Logic

```tsx
// Problem: Two unrelated concerns in one effect
function ChatRoom({ roomId }: { roomId: string }) {
  useEffect(() => {
    // Concern 1: Connection
    const connection = createConnection(roomId);
    connection.connect();

    // Concern 2: Analytics
    logVisit(roomId);

    return () => {
      connection.disconnect();
    };
  }, [roomId]);

  // Problem: If we add a dependency for connection
  // (like serverUrl), the analytics would also re-log
}
```

## Correct: Separate Effects

```tsx
// Solution: Each effect handles one concern
function ChatRoom({ roomId }: { roomId: string }) {
  // Effect 1: Chat connection
  useEffect(() => {
    const connection = createConnection(roomId);
    connection.connect();
    return () => connection.disconnect();
  }, [roomId]);

  // Effect 2: Analytics
  useEffect(() => {
    logVisit(roomId);
  }, [roomId]);

  // Now if we add serverUrl to connection:
  // - Connection effect re-syncs on serverUrl change
  // - Analytics effect is unaffected
}
```

## The Test: Can You Delete One?

```tsx
// If deleting one effect would break the other, they belong together
// If they're independent, they should be separate

// These are INDEPENDENT:
useEffect(() => {
  const connection = createConnection(roomId);
  connection.connect();
  return () => connection.disconnect();
}, [roomId]);

useEffect(() => {
  if (isAnimated) {
    playAnimation();
  }
}, [isAnimated]);

// Deleting the animation effect doesn't break chat
// Deleting the chat effect doesn't break animation
// They should be separate ✅
```

## Incorrect: Chained Effects

```tsx
// Problem: Effect chain to avoid dependency
function Bad() {
  const [data, setData] = useState(null);
  const [processed, setProcessed] = useState(null);
  const [rendered, setRendered] = useState(null);

  useEffect(() => {
    fetchData().then(setData);
  }, []);

  useEffect(() => {
    if (data) {
      setProcessed(processData(data));
    }
  }, [data]);

  useEffect(() => {
    if (processed) {
      setRendered(renderData(processed));
    }
  }, [processed]);

  // Three effects for what should be one operation!
}

// Solution: One effect for the complete sync
function Good() {
  const [rendered, setRendered] = useState(null);

  useEffect(() => {
    async function fetchAndProcess() {
      const data = await fetchData();
      const processed = processData(data);
      const rendered = renderData(processed);
      setRendered(rendered);
    }
    fetchAndProcess();
  }, []);

  // Or better: just derive processed/rendered during render
}
```

## The "Unrelated Dependencies" Smell

```tsx
// When you see unrelated things in dependencies, consider splitting

// SMELL: roomId and theme are unrelated
useEffect(() => {
  // roomId is for connection
  const connection = createConnection(roomId);
  connection.connect();

  // theme is for document
  document.body.className = theme;

  return () => connection.disconnect();
}, [roomId, theme]);

// When theme changes, connection is re-established unnecessarily!

// Solution: Split into separate effects
useEffect(() => {
  const connection = createConnection(roomId);
  connection.connect();
  return () => connection.disconnect();
}, [roomId]);

useEffect(() => {
  document.body.className = theme;
}, [theme]);
```

## When Effects DO Belong Together

```tsx
// These are related - they're both about the same external sync
useEffect(() => {
  const map = new MapLibrary(containerRef.current);

  map.setCenter(center);  // Same external system
  map.setZoom(zoom);      // Same external system

  return () => map.destroy();
}, [center, zoom]);

// Splitting these would require passing the map instance
// between effects - they're fundamentally coupled
```

## Thinking in Synchronization

```tsx
// Ask: "What external system am I keeping in sync?"

// External system: WebSocket connection
useEffect(() => {
  const ws = new WebSocket(url);
  return () => ws.close();
}, [url]);

// External system: Browser title
useEffect(() => {
  document.title = title;
}, [title]);

// External system: Scroll position
useEffect(() => {
  window.scrollTo(0, 0);
}, [pathname]);

// Each is a separate sync, each is a separate effect
```

## Key Principle

Don't think "these things happen at the same time." Think "these things sync with the same external system." Different systems = different Effects.
