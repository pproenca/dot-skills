---
title: Choose Controlled vs Uncontrolled Deliberately
impact: HIGH
impactDescription: prevents state sync bugs, clarifies component API contracts
tags: comp, controlled, uncontrolled, state-ownership, api-design
---

## Choose Controlled vs Uncontrolled Deliberately

Mixing controlled and uncontrolled patterns creates confusing APIs. Design components with clear state ownership.

**Code Smell Indicators:**
- Component accepts both `value` and `defaultValue`
- Internal state sometimes syncs with props, sometimes doesn't
- Unclear who "owns" the state
- `useEffect` syncing internal state with props

**Incorrect (confused ownership):**

```tsx
function SearchInput({ value, defaultValue, onChange }) {
  // Who owns the state? Both caller and component?
  const [internalValue, setInternalValue] = useState(defaultValue ?? '')

  // This effect creates sync bugs
  useEffect(() => {
    if (value !== undefined) {
      setInternalValue(value)
    }
  }, [value])

  function handleChange(e) {
    setInternalValue(e.target.value)
    onChange?.(e.target.value)
  }

  // Sometimes uses prop, sometimes uses state
  const displayValue = value ?? internalValue

  return <input value={displayValue} onChange={handleChange} />
}
```

**Correct (controlled pattern - caller owns state):**

```tsx
interface ControlledSearchInputProps {
  value: string
  onChange: (value: string) => void
}

function SearchInput({ value, onChange }: ControlledSearchInputProps) {
  // No internal state - caller owns it completely
  return (
    <input
      value={value}
      onChange={e => onChange(e.target.value)}
    />
  )
}

// Usage
function SearchPage() {
  const [search, setSearch] = useState('')
  return <SearchInput value={search} onChange={setSearch} />
}
```

**Correct (uncontrolled pattern - component owns state):**

```tsx
interface UncontrolledSearchInputProps {
  defaultValue?: string
  onSearch?: (value: string) => void
}

function SearchInput({ defaultValue = '', onSearch }: UncontrolledSearchInputProps) {
  // Component owns the state completely
  const [value, setValue] = useState(defaultValue)

  function handleSubmit() {
    onSearch?.(value)
  }

  return (
    <div>
      <input value={value} onChange={e => setValue(e.target.value)} />
      <button onClick={handleSubmit}>Search</button>
    </div>
  )
}
```

**Supporting both patterns cleanly:**

```tsx
type SearchInputProps =
  | { value: string; onChange: (value: string) => void; defaultValue?: never }
  | { defaultValue?: string; value?: never; onChange?: never }

function SearchInput(props: SearchInputProps) {
  const isControlled = 'value' in props && props.value !== undefined

  // Separate implementations
  if (isControlled) {
    return <input value={props.value} onChange={e => props.onChange(e.target.value)} />
  }

  return <UncontrolledSearchInput defaultValue={props.defaultValue} />
}

function UncontrolledSearchInput({ defaultValue = '' }) {
  const [value, setValue] = useState(defaultValue)
  return <input value={value} onChange={e => setValue(e.target.value)} />
}
```

**Decision framework:**
```
Who should own the state?
├── Caller needs to read/set value programmatically → Controlled
├── Component can manage state independently → Uncontrolled
├── Sometimes caller, sometimes component → Support both explicitly
└── Unclear → Default to controlled (more flexible)
```

Reference: [Sharing State Between Components](https://react.dev/learn/sharing-state-between-components#controlled-and-uncontrolled-components)
