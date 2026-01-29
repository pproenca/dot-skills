---
title: Don't mirror props in state
impact: HIGH
impactDescription: Initializing state from props creates a copy that won't update when the prop changes
tags: [state, props, mirroring, initialization, sync]
---

# Don't Mirror Props in State

When you initialize state from a prop, you create a copy. The state won't update when the prop changes, leading to stale data.

## Why This Matters

Mirrored props:
- Create a disconnected copy of the data
- Won't reflect parent updates
- Lead to confusing "out of sync" bugs
- Make the data flow unclear

**Incorrect (anti-pattern):**

```tsx
// Problem: Copying prop into state
function Clock({ color }: { color: string }) {
  // This only reads the INITIAL value of color
  const [currentColor, setCurrentColor] = useState(color);

  // When parent changes color prop, currentColor is STALE

  return (
    <h1 style={{ color: currentColor }}>
      {new Date().toLocaleTimeString()}
    </h1>
  );
}

function App() {
  const [color, setColor] = useState('blue');

  return (
    <div>
      <select value={color} onChange={e => setColor(e.target.value)}>
        <option value="blue">Blue</option>
        <option value="red">Red</option>
      </select>
      {/* Clock won't update when color changes! */}
      <Clock color={color} />
    </div>
  );
}
```

**Correct (recommended):**

```tsx
// Solution: Use the prop directly
function Clock({ color }: { color: string }) {
  // Just use the prop - always current
  return (
    <h1 style={{ color }}>
      {new Date().toLocaleTimeString()}
    </h1>
  );
}
```

**Incorrect (anti-pattern):**

```tsx
// Problem: Mirroring prop for "local editing"
function Message({ message }: { message: string }) {
  // Trying to make an "editable copy"
  const [text, setText] = useState(message);

  // BUG: If parent updates message, we don't see it

  return (
    <div>
      <input value={text} onChange={e => setText(e.target.value)} />
      <p>Original: {message}</p>
      <p>Current: {text}</p>
    </div>
  );
}
```

**Correct (recommended):**

```tsx
// Solution: Parent owns the state, passes it down
function Message({ message, onChange }: {
  message: string;
  onChange: (text: string) => void;
}) {
  return (
    <input value={message} onChange={e => onChange(e.target.value)} />
  );
}

function App() {
  const [message, setMessage] = useState('Hello');
  return <Message message={message} onChange={setMessage} />;
}
```

## When Mirroring IS Intentional

```tsx
// If you WANT to ignore future updates, use clear naming
function EditableTitle({ initialTitle }: { initialTitle: string }) {
  // The "initial" prefix makes intent clear
  const [title, setTitle] = useState(initialTitle);

  // This component owns its own copy
  // Parent changes to initialTitle are ignored (intentionally)
  return (
    <input value={title} onChange={e => setTitle(e.target.value)} />
  );
}

// Or use "default" prefix
function ColorPicker({ defaultColor }: { defaultColor: string }) {
  const [color, setColor] = useState(defaultColor);
  // ...
}
```

## The Key Pattern

```tsx
// If you want updates from parent: DON'T use state
function Controlled({ value }: { value: string }) {
  return <span>{value}</span>;  // Always current
}

// If you want to ignore updates: name prop clearly
function Uncontrolled({ defaultValue }: { defaultValue: string }) {
  const [value, setValue] = useState(defaultValue);
  return <span>{value}</span>;  // Internal copy
}
```

## Incorrect Pattern with useEffect

```tsx
// Problem: Trying to "sync" state with prop via effect
function Clock({ color }: { color: string }) {
  const [currentColor, setCurrentColor] = useState(color);

  // This is a code smell - unnecessary complexity
  useEffect(() => {
    setCurrentColor(color);
  }, [color]);

  return <h1 style={{ color: currentColor }}>...</h1>;
}
```

**Correct (recommended):**

```tsx
// Solution: Just use the prop! No state needed
function Clock({ color }: { color: string }) {
  return <h1 style={{ color }}>...</h1>;
}
```

## Decision Guide

| Scenario | Solution |
|----------|----------|
| Display prop value | Use prop directly |
| Transform prop for display | Calculate during render |
| Edit but parent controls | Controlled component (value + onChange) |
| Edit with initial value, ignore updates | State with `initialX` or `defaultX` prop |

## Key Principle

Props and state are separate concepts. Props are data from the parent. State is data the component owns. Don't blur the line by copying props into state - it creates two sources of truth for the same data.
