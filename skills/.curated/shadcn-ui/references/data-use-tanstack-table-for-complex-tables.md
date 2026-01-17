---
title: Use TanStack Table for Complex Data Tables
impact: MEDIUM-HIGH
impactDescription: eliminates 200-500 lines of manual table logic
tags: data, tanstack-table, sorting, filtering, pagination
---

## Use TanStack Table for Complex Data Tables

For tables requiring sorting, filtering, or pagination, use TanStack Table with shadcn/ui's Table component. Manual implementations are error-prone and lack features.

**Incorrect (manual sorting implementation):**

```tsx
function UserTable({ users }: { users: User[] }) {
  const [sortField, setSortField] = useState<keyof User>("name")
  const [sortDirection, setSortDirection] = useState<"asc" | "desc">("asc")

  const sortedUsers = [...users].sort((a, b) => {
    // Manual sorting - breaks for nested fields, dates, null values
    const aVal = a[sortField]
    const bVal = b[sortField]
    return sortDirection === "asc"
      ? aVal > bVal ? 1 : -1
      : aVal < bVal ? 1 : -1
  })

  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead onClick={() => setSortField("name")}>Name</TableHead>
          {/* Missing sort indicators, accessibility */}
        </TableRow>
      </TableHeader>
      {/* ... */}
    </Table>
  )
}
```

**Correct (TanStack Table integration):**

```tsx
import {
  useReactTable,
  getCoreRowModel,
  getSortedRowModel,
  getFilteredRowModel,
  getPaginationRowModel,
  flexRender,
  type ColumnDef,
  type SortingState,
} from "@tanstack/react-table"

const columns: ColumnDef<User>[] = [
  {
    accessorKey: "name",
    header: ({ column }) => (
      <Button
        variant="ghost"
        onClick={() => column.toggleSorting(column.getIsSorted() === "asc")}
      >
        Name
        <ArrowUpDown className="ml-2 h-4 w-4" />
      </Button>
    ),
  },
  {
    accessorKey: "email",
    header: "Email",
  },
  {
    accessorKey: "status",
    header: "Status",
    cell: ({ row }) => <Badge>{row.getValue("status")}</Badge>,
  },
]

function UserTable({ users }: { users: User[] }) {
  const [sorting, setSorting] = useState<SortingState>([])

  const table = useReactTable({
    data: users,
    columns,
    getCoreRowModel: getCoreRowModel(),
    getSortedRowModel: getSortedRowModel(),
    onSortingChange: setSorting,
    state: { sorting },
  })

  return (
    <Table>
      <TableHeader>
        {table.getHeaderGroups().map((headerGroup) => (
          <TableRow key={headerGroup.id}>
            {headerGroup.headers.map((header) => (
              <TableHead key={header.id}>
                {flexRender(header.column.columnDef.header, header.getContext())}
              </TableHead>
            ))}
          </TableRow>
        ))}
      </TableHeader>
      <TableBody>
        {table.getRowModel().rows.map((row) => (
          <TableRow key={row.id}>
            {row.getVisibleCells().map((cell) => (
              <TableCell key={cell.id}>
                {flexRender(cell.column.columnDef.cell, cell.getContext())}
              </TableCell>
            ))}
          </TableRow>
        ))}
      </TableBody>
    </Table>
  )
}
```

Reference: [shadcn/ui Data Table](https://ui.shadcn.com/docs/components/data-table)
