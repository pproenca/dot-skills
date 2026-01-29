---
title: Lift state up to the nearest common ancestor
impact: HIGH
impactDescription: When multiple components need to reflect the same changing data, move state to their common parent
tags: [share, sharing, lifting, parent, coordination]
---

# Lift State Up to the Nearest Common Ancestor

When two or more components need to share state and update together, move the state to their closest common parent component. The parent becomes the "source of truth."

## Why This Matters

Lifting state up:
- Creates a single source of truth
- Ensures components stay in sync
- Makes data flow explicit and traceable
- Enables coordination between siblings

**Incorrect (the problem):** Independent State

```tsx
// Problem: Each Panel has its own state - can't coordinate
function Panel({ title, children }: PanelProps) {
  const [isExpanded, setIsExpanded] = useState(false);

  return (
    <section>
      <h3>{title}</h3>
      {isExpanded ? (
        <div>{children}</div>
      ) : (
        <button onClick={() => setIsExpanded(true)}>Show</button>
      )}
    </section>
  );
}

function Accordion() {
  return (
    <>
      {/* Both can be expanded at once - no coordination */}
      <Panel title="About">About content...</Panel>
      <Panel title="History">History content...</Panel>
    </>
  );
}
```

**Correct (the solution):** Lift State Up

```tsx
// Step 1: Remove state from child, accept via props
function Panel({
  title,
  children,
  isExpanded,
  onToggle,
}: PanelProps) {
  return (
    <section>
      <h3>{title}</h3>
      {isExpanded ? (
        <div>{children}</div>
      ) : (
        <button onClick={onToggle}>Show</button>
      )}
    </section>
  );
}

// Step 2: Add state to common parent
function Accordion() {
  const [activeIndex, setActiveIndex] = useState(0);

  return (
    <>
      <Panel
        title="About"
        isExpanded={activeIndex === 0}
        onToggle={() => setActiveIndex(0)}
      >
        About content...
      </Panel>
      <Panel
        title="History"
        isExpanded={activeIndex === 1}
        onToggle={() => setActiveIndex(1)}
      >
        History content...
      </Panel>
    </>
  );
}
// Now only one panel can be expanded at a time
```

## The Three Steps

```tsx
// 1. REMOVE state from child component
//    Before: const [value, setValue] = useState(initial);
//    After:  Accept value and onChange as props

// 2. PASS hardcoded data from parent first (to verify it works)
<Child value="test" onChange={() => {}} />

// 3. ADD state to parent and wire it up
function Parent() {
  const [value, setValue] = useState(initial);
  return <Child value={value} onChange={setValue} />;
}
```

## Real Example: Synced Inputs

```tsx
// Two inputs that should always show the same value

// Problem: Each input has own state
function UnsyncedInputs() {
  return (
    <>
      <Input label="First" />   {/* Own state */}
      <Input label="Second" />  {/* Own state, not synced */}
    </>
  );
}

// Solution: State lifted to parent
function SyncedInputs() {
  const [value, setValue] = useState('');

  return (
    <>
      <Input label="First" value={value} onChange={setValue} />
      <Input label="Second" value={value} onChange={setValue} />
    </>
  );
}

function Input({
  label,
  value,
  onChange,
}: {
  label: string;
  value: string;
  onChange: (value: string) => void;
}) {
  return (
    <label>
      {label}:
      <input
        value={value}
        onChange={e => onChange(e.target.value)}
      />
    </label>
  );
}
```

## Finding the Common Ancestor

```tsx
// Component tree:
// App
// ├── Sidebar
// │   └── FilterPanel  ← needs filters
// └── Main
//     └── ProductList  ← needs filters

// Both FilterPanel and ProductList need filter state
// Common ancestor is App

function App() {
  const [filters, setFilters] = useState<Filters>(defaultFilters);

  return (
    <>
      <Sidebar>
        <FilterPanel filters={filters} onChange={setFilters} />
      </Sidebar>
      <Main>
        <ProductList filters={filters} />
      </Main>
    </>
  );
}
```

## When Lifting Gets Cumbersome

```tsx
// If you're passing props through many levels, consider:
// 1. Component composition
// 2. Context for truly global state
// 3. State management libraries

// Too many props drilling through:
<Grandparent value={value} onChange={onChange}>
  <Parent value={value} onChange={onChange}>
    <Child value={value} onChange={onChange} />
  </Parent>
</Grandparent>

// Consider Context for deep trees:
const ValueContext = createContext<ValueState | null>(null);

function Grandparent() {
  const [value, setValue] = useState(initial);
  return (
    <ValueContext value={{ value, setValue }}>
      <Parent>
        <Child />
      </Parent>
    </ValueContext>
  );
}
```

## Key Principle

If component A and component B both need to change together, ask: "Who is their nearest common parent?" Move the state there, and pass it down. The state lives in one place, changes propagate everywhere automatically.
