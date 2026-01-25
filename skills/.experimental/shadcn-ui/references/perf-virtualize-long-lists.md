---
title: Virtualize Long Lists in Select and Command
impact: LOW-MEDIUM
impactDescription: prevents UI freeze with 1000+ items
tags: perf, virtualization, select, command, tanstack-virtual
---

## Virtualize Long Lists in Select and Command

Use virtualization for Select or Command components with many items. Rendering 1000+ DOM nodes causes visible lag and high memory usage.

**Incorrect (rendering all items):**

```tsx
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"

function CountrySelect({ countries }) {  // 200+ countries
  return (
    <Select>
      <SelectTrigger>
        <SelectValue placeholder="Select country" />
      </SelectTrigger>
      <SelectContent>
        {countries.map((country) => (
          <SelectItem key={country.code} value={country.code}>
            {country.name}
          </SelectItem>
        ))}
      </SelectContent>
    </Select>
  )
  // All 200 items render immediately, causing delay
}
```

**Correct (virtualized with Command):**

```tsx
import { useVirtualizer } from "@tanstack/react-virtual"
import { Command, CommandEmpty, CommandGroup, CommandInput, CommandItem, CommandList } from "@/components/ui/command"

function CountrySelect({ countries, value, onValueChange }) {
  const [search, setSearch] = useState("")
  const parentRef = useRef<HTMLDivElement>(null)
  const filtered = countries.filter((c) => c.name.toLowerCase().includes(search.toLowerCase()))
  const virtualizer = useVirtualizer({
    count: filtered.length, getScrollElement: () => parentRef.current, estimateSize: () => 32, overscan: 5,
  })

  return (
    <Popover>
      <PopoverTrigger asChild>
        <Button variant="outline">
          {value ? countries.find((c) => c.code === value)?.name : "Select country"}
        </Button>
      </PopoverTrigger>
      <PopoverContent className="p-0">
        <Command>
          <CommandInput value={search} onValueChange={setSearch} placeholder="Search..." />
          <CommandList ref={parentRef} className="max-h-[300px] overflow-auto">
            <CommandEmpty>No country found.</CommandEmpty>
            <CommandGroup style={{ height: `${virtualizer.getTotalSize()}px`, position: "relative" }}>
              {virtualizer.getVirtualItems().map((virtualItem) => {
                const country = filtered[virtualItem.index]
                return (
                  <CommandItem
                    key={country.code} value={country.code} onSelect={() => onValueChange(country.code)}
                    style={{ position: "absolute", top: 0, left: 0, width: "100%", transform: `translateY(${virtualItem.start}px)` }}>
                    {country.name}
                  </CommandItem>
                )
              })}
            </CommandGroup>
          </CommandList>
        </Command>
      </PopoverContent>
    </Popover>
  )
}
```

Reference: [TanStack Virtual](https://tanstack.com/virtual/latest)
