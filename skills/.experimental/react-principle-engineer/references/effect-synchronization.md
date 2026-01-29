---
title: Effects synchronize with external systems
impact: HIGH
impactDescription: Use effects to keep React components synchronized with things outside React like APIs, DOM, timers
tags: [effect, synchronization, external, lifecycle]
---

# Effects Synchronize with External Systems

Effects let you run code after rendering to synchronize your component with some system outside of React: network, browser APIs, third-party widgets, etc.

## Why This Matters

Understanding effects:
- Clarifies when to use them (and when not to)
- Prevents misuse for derived state or event handling
- Explains the cleanup mechanism
- Guides proper dependency management

## What Counts as "External"

```tsx
// External systems that need Effects:
// - Network requests/WebSockets
// - Browser APIs (localStorage, timers, observers)
// - Third-party libraries (D3, charts, maps)
// - DOM measurements after paint
// - Analytics tracking

// NOT external (don't use Effects):
// - Transforming data for rendering
// - Responding to user events
// - Updating other state based on state changes
```

## Basic Synchronization

```tsx
function ChatRoom({ roomId }: { roomId: string }) {
  useEffect(() => {
    // START synchronization: connect to the external system
    const connection = createConnection(roomId);
    connection.connect();

    // STOP synchronization: disconnect when done
    return () => {
      connection.disconnect();
    };
  }, [roomId]);  // Re-sync when roomId changes

  return <Chat />;
}

// When roomId changes:
// 1. Disconnect from old room (cleanup)
// 2. Connect to new room (effect)
```

## The Synchronization Lifecycle

```tsx
function VideoPlayer({ src, isPlaying }: Props) {
  const videoRef = useRef<HTMLVideoElement>(null);

  // Sync video element with isPlaying state
  useEffect(() => {
    const video = videoRef.current;
    if (!video) return;

    // Synchronize: make video match isPlaying
    if (isPlaying) {
      video.play();
    } else {
      video.pause();
    }

    // No cleanup needed - play/pause doesn't need to be "undone"
  }, [isPlaying]);

  return <video ref={videoRef} src={src} />;
}
```

## DOM Measurements

```tsx
function Tooltip({ children, targetRef }: Props) {
  const [position, setPosition] = useState({ x: 0, y: 0 });
  const tooltipRef = useRef<HTMLDivElement>(null);

  // Need to measure after render to position correctly
  useEffect(() => {
    const target = targetRef.current;
    const tooltip = tooltipRef.current;
    if (!target || !tooltip) return;

    const targetRect = target.getBoundingClientRect();
    const tooltipRect = tooltip.getBoundingClientRect();

    setPosition({
      x: targetRect.left + (targetRect.width - tooltipRect.width) / 2,
      y: targetRect.top - tooltipRect.height - 8,
    });
  });  // Run after every render to stay positioned

  return (
    <div ref={tooltipRef} style={{ left: position.x, top: position.y }}>
      {children}
    </div>
  );
}
```

## Third-Party Library Integration

```tsx
function Map({ center, zoom }: MapProps) {
  const containerRef = useRef<HTMLDivElement>(null);
  const mapRef = useRef<google.maps.Map | null>(null);

  // Create map instance once
  useEffect(() => {
    if (!containerRef.current) return;

    const map = new google.maps.Map(containerRef.current, {
      center,
      zoom,
    });
    mapRef.current = map;

    return () => {
      // Cleanup: destroy map instance
      // (Google Maps doesn't have explicit destroy, but concept applies)
    };
  }, []);  // Empty deps: only on mount

  // Sync center with React state
  useEffect(() => {
    mapRef.current?.setCenter(center);
  }, [center]);

  // Sync zoom with React state
  useEffect(() => {
    mapRef.current?.setZoom(zoom);
  }, [zoom]);

  return <div ref={containerRef} style={{ height: 400, width: '100%' }} />;
}
```

## Browser API Synchronization

```tsx
function DocumentTitle({ title }: { title: string }) {
  useEffect(() => {
    const previousTitle = document.title;
    document.title = title;

    return () => {
      document.title = previousTitle;  // Restore on unmount
    };
  }, [title]);

  return null;  // Just a side effect, no UI
}

function OnlineStatus() {
  const [isOnline, setIsOnline] = useState(navigator.onLine);

  useEffect(() => {
    function handleOnline() { setIsOnline(true); }
    function handleOffline() { setIsOnline(false); }

    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);

    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
    };
  }, []);

  return isOnline ? 'Online' : 'Offline';
}
```

## Not Synchronization (Don't Use Effect)

```tsx
// Problem: Transforming data in effect
function FilteredList({ items, filter }: Props) {
  const [filteredItems, setFilteredItems] = useState<Item[]>([]);

  useEffect(() => {
    setFilteredItems(items.filter(matchesFilter));
  }, [items, filter]);  // Unnecessary effect!

  return <List items={filteredItems} />;
}

// Solution: Calculate during render
function FilteredList({ items, filter }: Props) {
  const filteredItems = items.filter(matchesFilter);
  return <List items={filteredItems} />;
}
```

## Key Principle

An Effect answers the question: "After rendering, what external system needs to be synchronized with my current state?" If nothing external needs syncing, you probably don't need an Effect.
