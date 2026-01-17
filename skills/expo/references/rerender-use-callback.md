---
title: Stabilize Callbacks with useCallback
impact: MEDIUM
impactDescription: prevents child re-renders from callback recreation
tags: rerender, useCallback, callbacks, memoization
---

## Stabilize Callbacks with useCallback

Wrap event handlers in `useCallback` when passing them to memoized children. Without this, new function references on every render break `React.memo`.

**Incorrect (new callback breaks child memo):**

```typescript
const SearchResult = memo(function SearchResult({ item, onSelect }) {
  return (
    <Pressable onPress={() => onSelect(item.id)}>
      <Text>{item.title}</Text>
    </Pressable>
  )
})

function SearchScreen() {
  const [query, setQuery] = useState('')
  const [results, setResults] = useState([])
  const navigation = useNavigation()

  const handleSelect = (id) => {
    navigation.navigate('Detail', { id })
  }  // New function every render - breaks memo

  return (
    <View>
      <TextInput value={query} onChangeText={setQuery} />
      {results.map(item => (
        <SearchResult
          key={item.id}
          item={item}
          onSelect={handleSelect}  // Always new reference
        />
      ))}
    </View>
  )
}
```

**Correct (stable callback with useCallback):**

```typescript
const SearchResult = memo(function SearchResult({ item, onSelect }) {
  return (
    <Pressable onPress={() => onSelect(item.id)}>
      <Text>{item.title}</Text>
    </Pressable>
  )
})

function SearchScreen() {
  const [query, setQuery] = useState('')
  const [results, setResults] = useState([])
  const navigation = useNavigation()

  const handleSelect = useCallback((id) => {
    navigation.navigate('Detail', { id })
  }, [navigation])  // Stable reference

  return (
    <View>
      <TextInput value={query} onChangeText={setQuery} />
      {results.map(item => (
        <SearchResult
          key={item.id}
          item={item}
          onSelect={handleSelect}
        />
      ))}
    </View>
  )
}
```

**Functional updates avoid dependencies:**

```typescript
// Instead of depending on count
const increment = useCallback(() => {
  setCount(count + 1)
}, [count])  // Recreated when count changes

// Use functional update - no dependency
const increment = useCallback(() => {
  setCount(c => c + 1)
}, [])  // Never recreated
```

**When to use useCallback:**
- Passing callbacks to memoized children
- Callbacks used in useEffect dependencies
- Callbacks stored in refs

**When NOT to use useCallback:**
- Callbacks only used locally
- Components that aren't memoized
- Simple components where re-render is cheap

Reference: [React useCallback Documentation](https://react.dev/reference/react/useCallback)
