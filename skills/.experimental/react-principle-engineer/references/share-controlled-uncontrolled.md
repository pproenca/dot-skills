---
title: Choose between controlled and uncontrolled components
impact: HIGH
impactDescription: Controlled components are driven by props (maximum flexibility); uncontrolled use internal state (easier setup)
tags: [share, sharing, controlled, uncontrolled, patterns]
---

# Choose Between Controlled and Uncontrolled Components

A "controlled" component is driven by props. An "uncontrolled" component manages its own internal state. Choose based on how much control the parent needs.

## Why This Matters

Understanding this pattern:
- Determines how flexible your component is
- Affects how components integrate with forms
- Decides where state lives
- Impacts testability and reusability

## Uncontrolled Component

```tsx
// Uncontrolled: manages its own state
function SearchBox() {
  const [query, setQuery] = useState('');

  function handleSubmit() {
    console.log('Searching for:', query);
    // Do something with query
  }

  return (
    <div>
      <input
        value={query}
        onChange={e => setQuery(e.target.value)}
      />
      <button onClick={handleSubmit}>Search</button>
    </div>
  );
}

// Parent can't access or control the query value
function App() {
  return <SearchBox />;  // No control over internal state
}
```

## Controlled Component

```tsx
// Controlled: driven entirely by props
function SearchBox({
  query,
  onQueryChange,
  onSubmit,
}: {
  query: string;
  onQueryChange: (query: string) => void;
  onSubmit: () => void;
}) {
  return (
    <div>
      <input
        value={query}
        onChange={e => onQueryChange(e.target.value)}
      />
      <button onClick={onSubmit}>Search</button>
    </div>
  );
}

// Parent has full control
function App() {
  const [query, setQuery] = useState('');

  function handleSubmit() {
    // Parent controls what happens
    searchAPI(query);
    trackAnalytics(query);
  }

  return (
    <SearchBox
      query={query}
      onQueryChange={setQuery}
      onSubmit={handleSubmit}
    />
  );
}
```

## Comparison

| Aspect | Uncontrolled | Controlled |
|--------|--------------|------------|
| State location | Inside component | In parent |
| Parent access | Limited/none | Full access |
| Setup | Simpler | More props needed |
| Flexibility | Less | Maximum |
| Coordination | Harder | Easy |
| Testing | Harder | Easier |

## Panel Example

```tsx
// UNCONTROLLED: Panel manages its own expansion
function UncontrolledPanel({ title, children }: Props) {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <div>
      <button onClick={() => setIsOpen(!isOpen)}>{title}</button>
      {isOpen && <div>{children}</div>}
    </div>
  );
}

// Can't coordinate multiple panels:
<UncontrolledPanel title="A">Content A</UncontrolledPanel>
<UncontrolledPanel title="B">Content B</UncontrolledPanel>
// Both can be open at once - no way for parent to enforce "one at a time"
```

```tsx
// CONTROLLED: Parent decides expansion
function ControlledPanel({
  title,
  children,
  isOpen,
  onToggle,
}: Props) {
  return (
    <div>
      <button onClick={onToggle}>{title}</button>
      {isOpen && <div>{children}</div>}
    </div>
  );
}

// Parent can enforce accordion behavior:
function Accordion({ items }: { items: Item[] }) {
  const [openIndex, setOpenIndex] = useState(0);

  return (
    <>
      {items.map((item, index) => (
        <ControlledPanel
          key={item.id}
          title={item.title}
          isOpen={index === openIndex}
          onToggle={() => setOpenIndex(index)}
        >
          {item.content}
        </ControlledPanel>
      ))}
    </>
  );
}
```

## Hybrid: Support Both Modes

```tsx
// Component can be either controlled or uncontrolled
interface PanelProps {
  title: string;
  children: React.ReactNode;
  // If these are provided, controlled mode
  isOpen?: boolean;
  onToggle?: () => void;
  // If not provided, use default
  defaultOpen?: boolean;
}

function Panel({
  title,
  children,
  isOpen: controlledIsOpen,
  onToggle,
  defaultOpen = false,
}: PanelProps) {
  // Internal state for uncontrolled mode
  const [internalIsOpen, setInternalIsOpen] = useState(defaultOpen);

  // Determine which mode we're in
  const isControlled = controlledIsOpen !== undefined;
  const isOpen = isControlled ? controlledIsOpen : internalIsOpen;

  function handleToggle() {
    if (isControlled) {
      onToggle?.();
    } else {
      setInternalIsOpen(prev => !prev);
    }
  }

  return (
    <div>
      <button onClick={handleToggle}>{title}</button>
      {isOpen && <div>{children}</div>}
    </div>
  );
}

// Usage - uncontrolled:
<Panel title="FAQ" defaultOpen>Content</Panel>

// Usage - controlled:
<Panel title="FAQ" isOpen={isOpen} onToggle={toggle}>Content</Panel>
```

## When to Use Each

**Use Uncontrolled when:**
- Component works in isolation
- Parent doesn't need to know the state
- Simpler API is preferred
- One-off usage without coordination

**Use Controlled when:**
- Multiple components need to coordinate
- Parent needs to validate/transform values
- State needs to sync with other data
- Form libraries require it

## Key Principle

"Controlled" means the parent is in control via props. "Uncontrolled" means the component is in control via internal state. Design your components to support whichever makes sense for your use case - or both.
