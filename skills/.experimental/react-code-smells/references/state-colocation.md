---
title: Colocate State with Components That Use It
impact: CRITICAL
impactDescription: reduces prop passing by 60%, improves component isolation
tags: state, colocation, locality, refactoring, maintainability
---

## Colocate State with Components That Use It

State lifted too high causes unnecessary re-renders and prop drilling. Push state down to the lowest component that needs it.

**Code Smell Indicators:**
- Parent component re-renders when only child state changes
- Props passed to siblings that don't use them
- Global state for component-local concerns
- State in a provider that only one component reads

**Incorrect (state too high, causes cascading re-renders):**

```tsx
function App() {
  const [searchTerm, setSearchTerm] = useState('') // Only SearchBox uses this
  const [selectedId, setSelectedId] = useState(null) // Only List uses this
  const [isModalOpen, setIsModalOpen] = useState(false) // Only Modal uses this

  return (
    <div>
      <SearchBox value={searchTerm} onChange={setSearchTerm} />
      <List selectedId={selectedId} onSelect={setSelectedId} />
      <Modal isOpen={isModalOpen} onClose={() => setIsModalOpen(false)} />
    </div>
  )
}
// Every state change re-renders App and all children
```

**Correct (state colocated with consumers):**

```tsx
function App() {
  return (
    <div>
      <SearchBox /> {/* owns its own searchTerm state */}
      <List />       {/* owns its own selectedId state */}
      <Modal />      {/* owns its own isOpen state */}
    </div>
  )
}

function SearchBox() {
  const [searchTerm, setSearchTerm] = useState('')
  // Only SearchBox re-renders when typing
  return <input value={searchTerm} onChange={e => setSearchTerm(e.target.value)} />
}

function List() {
  const [selectedId, setSelectedId] = useState(null)
  // Only List re-renders when selection changes
  return items.map(item => (
    <Item
      key={item.id}
      selected={item.id === selectedId}
      onSelect={() => setSelectedId(item.id)}
    />
  ))
}
```

**When to lift state:**
- Multiple components need to read the same state
- Sibling components need to coordinate
- State needs to persist across component unmounts

**Decision framework:**
```
Is this state used by:
├── Only this component? → Keep it here
├── This component and children? → Keep it here, pass as props
├── This component and siblings? → Lift to parent
└── Many distant components? → Consider context
```

**Safe transformation steps:**
1. Find state that's only used by one subtree
2. Move useState to the root of that subtree
3. Remove the prop from parent components
4. Verify the parent no longer re-renders on state change

Reference: [State: A Component's Memory](https://react.dev/learn/state-a-components-memory)
