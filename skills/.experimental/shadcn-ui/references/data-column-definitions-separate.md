---
title: Define Columns in Separate File for Reusability
impact: MEDIUM
impactDescription: enables column reuse and cleaner component code
tags: data, columns, tanstack-table, organization, reusability
---

## Define Columns in Separate File for Reusability

Extract column definitions to a separate file. Inline definitions clutter components and prevent reuse across different views.

**Incorrect (inline column definitions):**

```tsx
// pages/users.tsx - 200+ lines
function UsersPage() {
  const columns = [
    {
      accessorKey: "name",
      header: "Name",
      cell: ({ row }) => <div>{row.getValue("name")}</div>,
    },
    {
      accessorKey: "email",
      header: ({ column }) => (
        <Button variant="ghost" onClick={() => column.toggleSorting()}>
          Email <ArrowUpDown className="ml-2 h-4 w-4" />
        </Button>
      ),
      cell: ({ row }) => <div className="lowercase">{row.getValue("email")}</div>,
    },
    // 10 more column definitions...
  ]

  // Rest of component buried below column definitions
}
```

**Correct (separate columns file):**

```tsx
// columns/user-columns.tsx
"use client"

import { ColumnDef } from "@tanstack/react-table"
import { ArrowUpDown } from "lucide-react"
import { Button } from "@/components/ui/button"

export type User = {
  id: string
  name: string
  email: string
  role: "admin" | "user"
}

export const userColumns: ColumnDef<User>[] = [
  {
    accessorKey: "name",
    header: "Name",
  },
  {
    accessorKey: "email",
    header: ({ column }) => (
      <Button variant="ghost" onClick={() => column.toggleSorting(column.getIsSorted() === "asc")}>
        Email
        <ArrowUpDown className="ml-2 h-4 w-4" />
      </Button>
    ),
  },
  {
    accessorKey: "role",
    header: "Role",
    cell: ({ row }) => <span className="capitalize">{row.getValue("role")}</span>,
  },
]
```

```tsx
// pages/users.tsx - Clean and focused
import { userColumns } from "@/columns/user-columns"
import { DataTable } from "@/components/ui/data-table"

function UsersPage() {
  const users = await fetchUsers()
  return <DataTable columns={userColumns} data={users} />
}
```

Reference: [TanStack Table Column Defs](https://tanstack.com/table/v8/docs/guide/column-defs)
