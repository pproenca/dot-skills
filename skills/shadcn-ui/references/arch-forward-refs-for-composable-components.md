---
title: Forward Refs for Composable Components
impact: CRITICAL
impactDescription: enables integration with form libraries and focus management
tags: arch, forwardRef, refs, composition, forms
---

## Forward Refs for Composable Components

Custom components wrapping shadcn/ui primitives must forward refs to enable form library integration, focus management, and imperative handles.

**Incorrect (ref not forwarded):**

```tsx
interface SearchInputProps {
  onSearch: (query: string) => void
}

function SearchInput({ onSearch }: SearchInputProps) {
  const [query, setQuery] = useState("")

  return (
    <Input
      value={query}
      onChange={(e) => setQuery(e.target.value)}
      onKeyDown={(e) => e.key === "Enter" && onSearch(query)}
    />
  )
}

// Parent cannot focus the input
function SearchForm() {
  const inputRef = useRef<HTMLInputElement>(null)

  useEffect(() => {
    inputRef.current?.focus() // null - ref not forwarded
  }, [])

  return <SearchInput ref={inputRef} onSearch={handleSearch} />
}
```

**Correct (ref forwarded to underlying element):**

```tsx
interface SearchInputProps {
  onSearch: (query: string) => void
}

const SearchInput = forwardRef<HTMLInputElement, SearchInputProps>(
  ({ onSearch }, ref) => {
    const [query, setQuery] = useState("")

    return (
      <Input
        ref={ref}
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        onKeyDown={(e) => e.key === "Enter" && onSearch(query)}
      />
    )
  }
)
SearchInput.displayName = "SearchInput"

// Parent can now focus the input
function SearchForm() {
  const inputRef = useRef<HTMLInputElement>(null)

  useEffect(() => {
    inputRef.current?.focus() // Works - ref forwarded to Input
  }, [])

  return <SearchInput ref={inputRef} onSearch={handleSearch} />
}
```

**Always forward refs when:**
- Wrapping form inputs (Input, Select, Textarea)
- Creating trigger components for modals/popovers
- Building components used with React Hook Form

Reference: [React forwardRef](https://react.dev/reference/react/forwardRef)
