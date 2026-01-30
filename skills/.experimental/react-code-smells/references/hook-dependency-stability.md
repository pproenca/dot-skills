---
title: Ensure Hook Dependencies are Stable
impact: MEDIUM-HIGH
impactDescription: prevents infinite loops and unnecessary effect runs
tags: hook, dependencies, stability, useCallback, useMemo
---

## Ensure Hook Dependencies are Stable

Unstable dependencies cause hooks to run every render. Stabilize references with useCallback/useMemo or restructure to avoid the dependency.

**Code Smell Indicators:**
- useEffect runs on every render
- Infinite re-render loops
- Console warnings about rapidly changing dependencies
- "Maximum update depth exceeded" errors

**Incorrect (unstable dependencies):**

```tsx
function SearchResults({ query }) {
  const [results, setResults] = useState([])

  // This object is recreated every render
  const options = {
    limit: 10,
    sort: 'relevance',
  }

  // This function is recreated every render
  const fetchResults = async () => {
    const data = await search(query, options)
    setResults(data)
  }

  // Effect runs every render because options and fetchResults change
  useEffect(() => {
    fetchResults()
  }, [fetchResults, options]) // Both unstable!

  return <ResultList results={results} />
}
```

**Correct (stable dependencies):**

```tsx
function SearchResults({ query }) {
  const [results, setResults] = useState([])

  // Option 1: Move static values outside component or use useMemo
  const options = useMemo(() => ({
    limit: 10,
    sort: 'relevance',
  }), []) // Empty deps = never changes

  // Option 2: Define function inside effect if only used there
  useEffect(() => {
    async function fetchResults() {
      const data = await search(query, options)
      setResults(data)
    }
    fetchResults()
  }, [query, options]) // query changes, options is stable

  return <ResultList results={results} />
}
```

**Alternative: Remove dependency entirely:**

```tsx
function SearchResults({ query }) {
  const [results, setResults] = useState([])

  // Static config doesn't need to be in deps
  useEffect(() => {
    const options = { limit: 10, sort: 'relevance' }
    search(query, options).then(setResults)
  }, [query]) // Only real dependency

  return <ResultList results={results} />
}
```

**For callbacks passed to children:**

```tsx
function ParentComponent() {
  const [items, setItems] = useState([])

  // Unstable: recreated every render
  const handleDelete = (id) => {
    setItems(items.filter(i => i.id !== id))
  }

  // Stable: uses functional update, no deps
  const handleDeleteStable = useCallback((id) => {
    setItems(prev => prev.filter(i => i.id !== id))
  }, [])

  // Child won't re-render unnecessarily
  return <ItemList items={items} onDelete={handleDeleteStable} />
}
```

**Dependency audit checklist:**
```
For each dependency, ask:
├── Is it a primitive (string, number, boolean)? → Stable
├── Is it a function? → Wrap in useCallback or move inside effect
├── Is it an object/array? → useMemo or move outside component
├── Is it a ref? → Exclude from deps (refs are stable)
└── Is it from props? → Consider if parent passes stable reference
```

Reference: [Removing Effect Dependencies](https://react.dev/learn/removing-effect-dependencies)
