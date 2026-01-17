---
title: Memoize Expensive Component Renders
impact: MEDIUM
impactDescription: prevents unnecessary re-renders in lists and data displays
tags: perf, memo, useMemo, useCallback, re-renders
---

## Memoize Expensive Component Renders

Use `React.memo` for list items and expensive components to prevent re-renders when parent state changes but props remain the same.

**Incorrect (re-renders all rows on any change):**

```tsx
function DataTable({ data, onRowSelect }: DataTableProps) {
  const [selectedId, setSelectedId] = useState<string | null>(null)

  return (
    <Table>
      <TableBody>
        {data.map((row) => (
          <TableRow key={row.id} onClick={() => onRowSelect(row.id)}>
            {/* All 100 rows re-render when selectedId changes */}
            <TableCell>{row.name}</TableCell>
            <TableCell>{row.email}</TableCell>
            <TableCell>
              <Badge variant={row.status === "active" ? "default" : "secondary"}>
                {row.status}
              </Badge>
            </TableCell>
          </TableRow>
        ))}
      </TableBody>
    </Table>
  )
}
```

**Correct (memoized row component):**

```tsx
const DataTableRow = memo(function DataTableRow({
  row,
  onSelect,
}: {
  row: DataRow
  onSelect: (id: string) => void
}) {
  return (
    <TableRow onClick={() => onSelect(row.id)}>
      <TableCell>{row.name}</TableCell>
      <TableCell>{row.email}</TableCell>
      <TableCell>
        <Badge variant={row.status === "active" ? "default" : "secondary"}>
          {row.status}
        </Badge>
      </TableCell>
    </TableRow>
  )
})

function DataTable({ data, onRowSelect }: DataTableProps) {
  const [selectedId, setSelectedId] = useState<string | null>(null)

  // Stable callback reference
  const handleSelect = useCallback((id: string) => {
    setSelectedId(id)
    onRowSelect(id)
  }, [onRowSelect])

  return (
    <Table>
      <TableBody>
        {data.map((row) => (
          <DataTableRow key={row.id} row={row} onSelect={handleSelect} />
          // Only rows with changed props re-render
        ))}
      </TableBody>
    </Table>
  )
}
```

**Memoization guidelines:**
- Use `memo` for list items rendered 10+ times
- Use `useCallback` for handlers passed to memoized children
- Use `useMemo` for expensive computations
- Don't memoize everything - measure first

Reference: [React memo](https://react.dev/reference/react/memo)
