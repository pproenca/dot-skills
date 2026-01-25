---
title: Use Dropdown Menu for Row Actions
impact: MEDIUM
impactDescription: consistent action pattern across all data tables
tags: data, table, actions, dropdown-menu, row
---

## Use Dropdown Menu for Row Actions

Place row actions in a DropdownMenu. Multiple inline buttons create visual clutter and inconsistent spacing.

**Incorrect (inline action buttons):**

```tsx
const columns: ColumnDef<User>[] = [
  // ...other columns
  {
    id: "actions",
    cell: ({ row }) => (
      <div className="flex gap-2">
        <Button size="sm" variant="ghost">Edit</Button>
        <Button size="sm" variant="ghost">View</Button>
        <Button size="sm" variant="destructive">Delete</Button>
      </div>
    ),
  },
]
// Cluttered, takes too much horizontal space
```

**Correct (dropdown menu):**

```tsx
import { MoreHorizontal } from "lucide-react"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"

const columns: ColumnDef<User>[] = [
  // ...other columns
  {
    id: "actions",
    enableHiding: false,
    cell: ({ row }) => {
      const user = row.original

      return (
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <Button variant="ghost" className="h-8 w-8 p-0">
              <span className="sr-only">Open menu</span>
              <MoreHorizontal className="h-4 w-4" />
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end">
            <DropdownMenuLabel>Actions</DropdownMenuLabel>
            <DropdownMenuItem onClick={() => navigator.clipboard.writeText(user.id)}>
              Copy ID
            </DropdownMenuItem>
            <DropdownMenuSeparator />
            <DropdownMenuItem>Edit user</DropdownMenuItem>
            <DropdownMenuItem>View details</DropdownMenuItem>
            <DropdownMenuSeparator />
            <DropdownMenuItem className="text-destructive">Delete user</DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      )
    },
  },
]
```

Reference: [shadcn/ui Data Table](https://ui.shadcn.com/docs/components/data-table)
