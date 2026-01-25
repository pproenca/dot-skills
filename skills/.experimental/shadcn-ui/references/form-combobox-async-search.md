---
title: Implement Async Search with Combobox
impact: MEDIUM
impactDescription: enables searchable dropdowns for large datasets
tags: form, combobox, search, async, autocomplete
---

## Implement Async Search with Combobox

Use Combobox for searchable dropdowns with large datasets. Static Select components become unusable with hundreds of options.

**Incorrect (Select with many options):**

```tsx
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"

function UserSelect({ users }) {
  return (
    <Select>
      <SelectTrigger>
        <SelectValue placeholder="Select user" />
      </SelectTrigger>
      <SelectContent>
        {users.map((user) => (
          <SelectItem key={user.id} value={user.id}>
            {user.name}
          </SelectItem>
        ))}
      </SelectContent>
    </Select>
  )
  // With 1000+ users: slow render, no search capability
}
```

**Correct (Combobox with search):**

```tsx
import { useState } from "react"
import { Check, ChevronsUpDown } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Command, CommandEmpty, CommandGroup, CommandInput, CommandItem, CommandList } from "@/components/ui/command"
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover"

function UserCombobox({ users, value, onValueChange }) {
  const [open, setOpen] = useState(false)
  const [search, setSearch] = useState("")
  const filteredUsers = users.filter((u) => u.name.toLowerCase().includes(search.toLowerCase()))

  return (
    <Popover open={open} onOpenChange={setOpen}>
      <PopoverTrigger asChild>
        <Button variant="outline" role="combobox" aria-expanded={open}>
          {value ? users.find((u) => u.id === value)?.name : "Select user..."}
          <ChevronsUpDown className="ml-2 h-4 w-4 opacity-50" />
        </Button>
      </PopoverTrigger>
      <PopoverContent className="w-[300px] p-0">
        <Command>
          <CommandInput placeholder="Search..." value={search} onValueChange={setSearch} />
          <CommandList>
            <CommandEmpty>No user found.</CommandEmpty>
            <CommandGroup>
              {filteredUsers.slice(0, 50).map((user) => (
                <CommandItem key={user.id} value={user.id} onSelect={() => { onValueChange(user.id); setOpen(false) }}>
                  <Check className={cn("mr-2 h-4 w-4", value === user.id ? "opacity-100" : "opacity-0")} />
                  {user.name}
                </CommandItem>
              ))}
            </CommandGroup>
          </CommandList>
        </Command>
      </PopoverContent>
    </Popover>
  )
}
```

Reference: [shadcn/ui Combobox](https://ui.shadcn.com/docs/components/combobox)
