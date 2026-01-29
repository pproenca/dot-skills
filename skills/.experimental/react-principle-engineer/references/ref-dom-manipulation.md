---
title: Use refs for imperative DOM operations
impact: MEDIUM
impactDescription: When you need to call DOM methods like focus(), scrollIntoView(), or measure elements, use refs
tags: [ref, dom, imperative, focus, scroll]
---

# Use Refs for Imperative DOM Operations

Some DOM operations can't be expressed declaratively. When you need to call methods like `focus()`, `scrollIntoView()`, or measure dimensions, use refs.

## Why This Matters

DOM refs enable:
- Focus management
- Scroll control
- Animations
- Measurements
- Third-party library integration

## Basic DOM Ref

```tsx
function SearchInput() {
  const inputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    // Focus on mount
    inputRef.current?.focus();
  }, []);

  return <input ref={inputRef} placeholder="Search..." />;
}
```

## Focus Management

```tsx
function Form() {
  const emailRef = useRef<HTMLInputElement>(null);
  const passwordRef = useRef<HTMLInputElement>(null);

  function handleEmailKeyDown(e: KeyboardEvent) {
    if (e.key === 'Enter') {
      passwordRef.current?.focus();  // Move to next field
    }
  }

  return (
    <form>
      <input
        ref={emailRef}
        type="email"
        onKeyDown={handleEmailKeyDown}
      />
      <input
        ref={passwordRef}
        type="password"
      />
    </form>
  );
}
```

## Scroll Control

```tsx
function Chat({ messages }: { messages: Message[] }) {
  const endRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    // Scroll to bottom when new messages arrive
    endRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  return (
    <div className="chat">
      {messages.map(msg => (
        <Message key={msg.id} message={msg} />
      ))}
      <div ref={endRef} />  {/* Scroll anchor */}
    </div>
  );
}
```

## Measuring Elements

```tsx
function Tooltip({ targetRef, children }: Props) {
  const tooltipRef = useRef<HTMLDivElement>(null);
  const [position, setPosition] = useState({ x: 0, y: 0 });

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
  });

  return (
    <div
      ref={tooltipRef}
      style={{ position: 'fixed', left: position.x, top: position.y }}
    >
      {children}
    </div>
  );
}
```

## Video/Audio Control

```tsx
function VideoPlayer({ src }: { src: string }) {
  const videoRef = useRef<HTMLVideoElement>(null);
  const [isPlaying, setIsPlaying] = useState(false);

  function togglePlay() {
    if (isPlaying) {
      videoRef.current?.pause();
    } else {
      videoRef.current?.play();
    }
    setIsPlaying(!isPlaying);
  }

  return (
    <div>
      <video ref={videoRef} src={src} />
      <button onClick={togglePlay}>
        {isPlaying ? 'Pause' : 'Play'}
      </button>
    </div>
  );
}
```

## Forwarding Refs to Child Components

```tsx
// When a child component needs to expose its DOM node
const FancyInput = forwardRef<HTMLInputElement, Props>(
  function FancyInput(props, ref) {
    return (
      <input
        ref={ref}
        className="fancy"
        {...props}
      />
    );
  }
);

function Parent() {
  const inputRef = useRef<HTMLInputElement>(null);

  function handleClick() {
    inputRef.current?.focus();
  }

  return (
    <>
      <FancyInput ref={inputRef} />
      <button onClick={handleClick}>Focus</button>
    </>
  );
}
```

## Canvas and WebGL

```tsx
function Canvas() {
  const canvasRef = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    // Imperative drawing
    ctx.fillStyle = 'blue';
    ctx.fillRect(0, 0, 100, 100);
  }, []);

  return <canvas ref={canvasRef} width={400} height={300} />;
}
```

## Key Principle

React's declarative model handles most UI updates. For the cases where you need imperative access (focus, scroll, measure, animate), refs give you direct access to the DOM.
