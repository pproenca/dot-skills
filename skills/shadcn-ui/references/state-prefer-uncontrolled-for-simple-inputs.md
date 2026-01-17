---
title: Prefer Uncontrolled Components for Simple Inputs
impact: LOW-MEDIUM
impactDescription: reduces state management overhead for simple cases
tags: state, uncontrolled, controlled, forms, simplicity
---

## Prefer Uncontrolled Components for Simple Inputs

For inputs that don't need real-time value access (search forms, quick filters), use uncontrolled components with refs or form data to reduce state overhead.

**Incorrect (controlled state for simple search):**

```tsx
function SimpleSearch({ onSearch }: { onSearch: (query: string) => void }) {
  const [query, setQuery] = useState("")

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    onSearch(query)
  }

  return (
    <form onSubmit={handleSubmit}>
      <Input
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        placeholder="Search..."
      />
      {/* Re-renders component on every keystroke */}
      <Button type="submit">Search</Button>
    </form>
  )
}
```

**Correct (uncontrolled with form data):**

```tsx
function SimpleSearch({ onSearch }: { onSearch: (query: string) => void }) {
  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    const formData = new FormData(e.currentTarget)
    const query = formData.get("query") as string
    onSearch(query)
  }

  return (
    <form onSubmit={handleSubmit}>
      <Input name="query" placeholder="Search..." />
      {/* No re-renders during typing */}
      <Button type="submit">Search</Button>
    </form>
  )
}
```

**Alternative (useRef for imperative access):**

```tsx
function QuickFilter({ onFilter }: { onFilter: (value: string) => void }) {
  const inputRef = useRef<HTMLInputElement>(null)

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === "Enter") {
      onFilter(inputRef.current?.value ?? "")
    }
  }

  return (
    <Input
      ref={inputRef}
      placeholder="Filter..."
      onKeyDown={handleKeyDown}
    />
  )
}
```

**Use controlled state when:**
- You need real-time validation feedback
- The value is used elsewhere in the UI (character count, preview)
- You need to programmatically change the value
- Using React Hook Form (which handles this efficiently)

**Use uncontrolled when:**
- Value only needed on submit
- Simple forms with no real-time requirements
- Performance is critical in large forms

Reference: [React Uncontrolled Components](https://react.dev/learn/sharing-state-between-components#controlled-and-uncontrolled-components)
