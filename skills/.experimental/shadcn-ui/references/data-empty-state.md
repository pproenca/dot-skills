---
title: Handle Empty Table State Gracefully
impact: MEDIUM
impactDescription: improves UX when no data matches filters or exists
tags: data, table, empty-state, ux, feedback
---

## Handle Empty Table State Gracefully

Display a meaningful message when tables have no rows. Empty tables without feedback leave users confused.

**Incorrect (silent empty state):**

```tsx
function DataTable({ data, columns }) {
  return (
    <Table>
      <TableHeader>{/* ... */}</TableHeader>
      <TableBody>
        {table.getRowModel().rows.map((row) => (
          <TableRow key={row.id}>{/* ... */}</TableRow>
        ))}
      </TableBody>
    </Table>
  )
  // When empty: just shows headers with blank space below
}
```

**Correct (explicit empty state):**

```tsx
import { Empty } from "@/components/ui/empty"

function DataTable({ data, columns }) {
  return (
    <Table>
      <TableHeader>{/* ... */}</TableHeader>
      <TableBody>
        {table.getRowModel().rows.length ? (
          table.getRowModel().rows.map((row) => (
            <TableRow key={row.id}>{/* ... */}</TableRow>
          ))
        ) : (
          <TableRow>
            <TableCell colSpan={columns.length} className="h-24 text-center">
              No results found.
            </TableCell>
          </TableRow>
        )}
      </TableBody>
    </Table>
  )
}
```

**With Empty component (richer feedback):**

```tsx
<TableBody>
  {table.getRowModel().rows.length ? (
    /* rows */
  ) : (
    <TableRow>
      <TableCell colSpan={columns.length}>
        <Empty
          icon={<SearchX className="h-10 w-10" />}
          title="No users found"
          description="Try adjusting your search or filter criteria."
        >
          <Button variant="outline" onClick={clearFilters}>
            Clear filters
          </Button>
        </Empty>
      </TableCell>
    </TableRow>
  )}
</TableBody>
```

Reference: [shadcn/ui Empty](https://ui.shadcn.com/docs/components/empty)
