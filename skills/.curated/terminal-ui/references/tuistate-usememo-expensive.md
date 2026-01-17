---
title: Memoize Expensive Computations with useMemo
impact: MEDIUM
impactDescription: avoids recalculating on every render
tags: tuistate, usememo, memoization, performance, computation
---

## Memoize Expensive Computations with useMemo

Use `useMemo` to cache expensive calculations that depend on specific values. This prevents recalculating derived data on every render.

**Incorrect (recalculates on every render):**

```typescript
function FileTree({ files }: { files: FileNode[] }) {
  const [filter, setFilter] = useState('')
  const [selected, setSelected] = useState<string | null>(null)

  // Runs on EVERY render, even when only selected changes
  const filteredFiles = files
    .filter(f => f.name.includes(filter))
    .sort((a, b) => a.name.localeCompare(b.name))

  return (
    <Box flexDirection="column">
      {filteredFiles.map(file => (
        <Text key={file.path} inverse={file.path === selected}>
          {file.name}
        </Text>
      ))}
    </Box>
  )
}
```

**Correct (memoized computation):**

```typescript
function FileTree({ files }: { files: FileNode[] }) {
  const [filter, setFilter] = useState('')
  const [selected, setSelected] = useState<string | null>(null)

  // Only recalculates when files or filter changes
  const filteredFiles = useMemo(() => {
    return files
      .filter(f => f.name.includes(filter))
      .sort((a, b) => a.name.localeCompare(b.name))
  }, [files, filter])

  return (
    <Box flexDirection="column">
      {filteredFiles.map(file => (
        <Text key={file.path} inverse={file.path === selected}>
          {file.name}
        </Text>
      ))}
    </Box>
  )
}
```

**Common memoization candidates:**

```typescript
// Formatting expensive data
const tableRows = useMemo(() =>
  data.map(row => formatRow(row, columns)),
  [data, columns]
)

// Aggregating statistics
const stats = useMemo(() => ({
  total: items.length,
  completed: items.filter(i => i.done).length,
  avgDuration: items.reduce((sum, i) => sum + i.duration, 0) / items.length
}), [items])

// Searching/filtering large datasets
const searchResults = useMemo(() =>
  haystack.filter(item =>
    item.toLowerCase().includes(needle.toLowerCase())
  ),
  [haystack, needle]
)
```

**When NOT to use this pattern:**
- For trivial computations (the overhead of memoization exceeds savings)
- When values change on every render anyway

Reference: [React Documentation - useMemo](https://react.dev/reference/react/useMemo)
