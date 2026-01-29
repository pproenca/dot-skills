---
title: Understand when React preserves vs resets state
impact: MEDIUM
impactDescription: React preserves state when a component stays at the same position in the tree; changing position or type resets it
tags: [share, sharing, identity, position, preservation]
---

# Understand When React Preserves vs Resets State

React keeps state for a component as long as it's rendered at the same position in the UI tree. When the component's position or type changes, React destroys its state.

## Why This Matters

Understanding preservation:
- Explains unexpected state behavior
- Helps intentionally reset state when needed
- Guides component structure decisions
- Prevents subtle bugs with conditional rendering

## Same Position = State Preserved

```tsx
function App() {
  const [isFancy, setIsFancy] = useState(false);

  return (
    <div>
      {isFancy ? (
        <Counter isFancy={true} />  // Position 1
      ) : (
        <Counter isFancy={false} /> // Position 1 (same!)
      )}
      <button onClick={() => setIsFancy(!isFancy)}>
        Toggle Fancy
      </button>
    </div>
  );
}

function Counter({ isFancy }: { isFancy: boolean }) {
  const [count, setCount] = useState(0);

  return (
    <div className={isFancy ? 'fancy' : ''}>
      <h1>{count}</h1>
      <button onClick={() => setCount(c => c + 1)}>+1</button>
    </div>
  );
}

// Clicking "Toggle Fancy" does NOT reset the counter!
// It's the same <Counter> at the same position
// Only the isFancy prop changes
```

## Different Position = State Reset

```tsx
function App() {
  const [showFirst, setShowFirst] = useState(true);

  return (
    <div>
      {showFirst && <Counter />}  {/* Position 1 when shown */}
      {!showFirst && <Counter />} {/* Position 2 when shown */}
      <button onClick={() => setShowFirst(!showFirst)}>
        Toggle
      </button>
    </div>
  );
}

// Toggling resets the counter!
// When showFirst=true: Counter is at position 1
// When showFirst=false: Counter is at position 2
// Different position = fresh state
```

## Different Component Type = State Reset

```tsx
function App() {
  const [isPaused, setIsPaused] = useState(false);

  return (
    <div>
      {isPaused ? (
        <p>Game paused</p>  // <p> element
      ) : (
        <Counter />          // <Counter> component
      )}
    </div>
  );
}

// Switching between <p> and <Counter> resets Counter's state
// They're different types at the same position
```

## Wrapper Elements Affect Position

```tsx
function App() {
  const [showInSection, setShowInSection] = useState(false);

  return (
    <div>
      {showInSection ? (
        <section>
          <Counter />  {/* Child of <section> */}
        </section>
      ) : (
        <Counter />    {/* Direct child of <div> */}
      )}
    </div>
  );
}

// Counter state is RESET when toggling!
// Position 1: <div> → <section> → <Counter>
// Position 2: <div> → <Counter>
// Different positions in the tree
```

## Using Keys to Force Reset

```tsx
function Chat({ contactId }: { contactId: string }) {
  const [draft, setDraft] = useState('');

  // Without key: draft is preserved when switching contacts
  // That's a bug - you don't want old message in new chat!

  return (
    <div>
      <h2>Chat with {contactId}</h2>
      <input
        value={draft}
        onChange={e => setDraft(e.target.value)}
      />
    </div>
  );
}

// Solution: Use key to reset when contact changes
function App() {
  const [contactId, setContactId] = useState('alice');

  return (
    <Chat
      key={contactId}  // Different key = new instance = fresh state
      contactId={contactId}
    />
  );
}
```

## Using Keys to Preserve Across Position Changes

```tsx
// Without keys: reordering resets state
function Scoreboard() {
  const [isPlayerOneFirst, setIsPlayerOneFirst] = useState(true);

  // These positions swap, but they're different players
  const players = isPlayerOneFirst
    ? [<Score name="Alice" />, <Score name="Bob" />]
    : [<Score name="Bob" />, <Score name="Alice" />];

  return <>{players}</>;  // State follows position, not player!
}

// Solution: With keys, state follows identity
function Scoreboard() {
  const [isPlayerOneFirst, setIsPlayerOneFirst] = useState(true);

  const players = isPlayerOneFirst
    ? [<Score key="alice" name="Alice" />, <Score key="bob" name="Bob" />]
    : [<Score key="bob" name="Bob" />, <Score key="alice" name="Alice" />];

  return <>{players}</>;  // State follows the key, not position
}
```

## Summary of Rules

| Situation | State Behavior |
|-----------|----------------|
| Same component, same position | Preserved |
| Same component, different position | Reset |
| Different component type, same position | Reset |
| Same position but different key | Reset |
| Same key but different position | Preserved |

## Key Principle

React sees your UI as a tree. A component's "identity" is determined by its type and position in that tree (or its key if provided). State lives as long as that identity stays the same.
