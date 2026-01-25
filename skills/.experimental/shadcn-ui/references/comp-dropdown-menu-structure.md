---
title: Structure Dropdown Menus with Required Parts
impact: HIGH
impactDescription: ensures keyboard navigation and screen reader support
tags: comp, dropdown-menu, radix, composition, navigation
---

## Structure Dropdown Menus with Required Parts

Dropdown menus require Trigger, Content, and Item parts for proper keyboard navigation and accessibility. Missing parts break arrow key navigation and focus management.

**Incorrect (minimal structure):**

```tsx
import { DropdownMenu, DropdownMenuContent } from "@/components/ui/dropdown-menu"

function UserMenu() {
  return (
    <DropdownMenu>
      <button>Menu</button>  {/* Not connected as trigger */}
      <DropdownMenuContent>
        <button>Profile</button>  {/* Not a DropdownMenuItem */}
        <button>Settings</button>
      </DropdownMenuContent>
    </DropdownMenu>
  )
  // Keyboard navigation broken, no arrow key support
}
```

**Correct (full structure):**

```tsx
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"

function UserMenu() {
  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button variant="ghost">Menu</Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end">
        <DropdownMenuLabel>My Account</DropdownMenuLabel>
        <DropdownMenuSeparator />
        <DropdownMenuItem>Profile</DropdownMenuItem>
        <DropdownMenuItem>Settings</DropdownMenuItem>
        <DropdownMenuSeparator />
        <DropdownMenuItem>Log out</DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  )
}
```

**Keyboard behavior with correct structure:**
- `Enter`/`Space` opens menu
- Arrow keys navigate items
- `Escape` closes menu
- Type-ahead search works

Reference: [shadcn/ui Dropdown Menu](https://ui.shadcn.com/docs/components/dropdown-menu)
