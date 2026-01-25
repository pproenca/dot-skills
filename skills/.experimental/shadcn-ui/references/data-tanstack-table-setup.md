---
title: Configure TanStack Table with Required Row Models
impact: MEDIUM
impactDescription: enables pagination, sorting, and filtering features
tags: data, tanstack-table, configuration, row-models, setup
---

## Configure TanStack Table with Required Row Models

Include all row model functions you need in useReactTable. Missing row models cause features to silently not work.

**Incorrect (missing row models):**

```tsx
import { useReactTable, getCoreRowModel } from "@tanstack/react-table"

function DataTable({ data, columns }) {
  const table = useReactTable({
    data,
    columns,
    getCoreRowModel: getCoreRowModel(),
    // Pagination, sorting, filtering won't work
  })

  return (
    <>
      {/* Table renders but buttons do nothing */}
      <Button onClick={() => table.nextPage()}>Next</Button>
    </>
  )
}
```

**Correct (all required row models):**

```tsx
import {
  useReactTable,
  getCoreRowModel,
  getPaginationRowModel,
  getSortedRowModel,
  getFilteredRowModel,
  type SortingState,
  type ColumnFiltersState,
} from "@tanstack/react-table"

function DataTable({ data, columns }) {
  const [sorting, setSorting] = useState<SortingState>([])
  const [columnFilters, setColumnFilters] = useState<ColumnFiltersState>([])

  const table = useReactTable({
    data,
    columns,
    getCoreRowModel: getCoreRowModel(),
    getPaginationRowModel: getPaginationRowModel(),  // Enables pagination
    getSortedRowModel: getSortedRowModel(),          // Enables sorting
    getFilteredRowModel: getFilteredRowModel(),      // Enables filtering
    onSortingChange: setSorting,
    onColumnFiltersChange: setColumnFilters,
    state: {
      sorting,
      columnFilters,
    },
  })

  return (/* Table with working features */)
}
```

**Row model functions:**
| Function | Enables |
|----------|---------|
| `getCoreRowModel` | Basic table rendering (required) |
| `getPaginationRowModel` | Page navigation |
| `getSortedRowModel` | Column sorting |
| `getFilteredRowModel` | Column filtering |

Reference: [shadcn/ui Data Table](https://ui.shadcn.com/docs/components/data-table)
