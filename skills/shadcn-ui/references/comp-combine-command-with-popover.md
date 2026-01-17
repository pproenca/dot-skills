---
title: Combine Command with Popover for Searchable Selects
impact: MEDIUM
impactDescription: reduces selection time by 3-5× for long lists
tags: comp, command, popover, combobox, search
---

## Combine Command with Popover for Searchable Selects

For searchable dropdown selection (combobox pattern), combine Command with Popover. Command provides search and keyboard navigation; Popover provides positioning.

**Incorrect (native select with no search):**

```tsx
function CountrySelect({ value, onChange }: CountrySelectProps) {
  return (
    <Select value={value} onValueChange={onChange}>
      <SelectTrigger>
        <SelectValue placeholder="Select country" />
      </SelectTrigger>
      <SelectContent>
        {countries.map((country) => (
          <SelectItem key={country.code} value={country.code}>
            {country.name}
          </SelectItem>
        ))}
        {/* 200+ countries with no way to search - poor UX */}
      </SelectContent>
    </Select>
  )
}
```

**Correct (Command + Popover combobox):**

```tsx
import { Check, ChevronsUpDown } from "lucide-react"
import { cn } from "@/lib/utils"
import {
  Command,
  CommandEmpty,
  CommandGroup,
  CommandInput,
  CommandItem,
  CommandList,
} from "@/components/ui/command"
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover"

function CountrySelect({ value, onChange }: CountrySelectProps) {
  const [open, setOpen] = useState(false)
  const selectedCountry = countries.find((c) => c.code === value)

  return (
    <Popover open={open} onOpenChange={setOpen}>
      <PopoverTrigger asChild>
        <Button
          variant="outline"
          role="combobox"
          aria-expanded={open}
          className="w-full justify-between"
        >
          {selectedCountry?.name ?? "Select country..."}
          <ChevronsUpDown className="ml-2 h-4 w-4 shrink-0 opacity-50" />
        </Button>
      </PopoverTrigger>
      <PopoverContent className="w-full p-0">
        <Command>
          <CommandInput placeholder="Search countries..." />
          <CommandList>
            <CommandEmpty>No country found.</CommandEmpty>
            <CommandGroup>
              {countries.map((country) => (
                <CommandItem
                  key={country.code}
                  value={country.name}
                  onSelect={() => {
                    onChange(country.code)
                    setOpen(false)
                  }}
                >
                  <Check
                    className={cn(
                      "mr-2 h-4 w-4",
                      value === country.code ? "opacity-100" : "opacity-0"
                    )}
                  />
                  {country.name}
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

**Combobox features:**
- Type to filter (CommandInput)
- Arrow keys to navigate
- Enter to select
- Escape to close
- Accessible role="combobox" with aria-expanded

Reference: [shadcn/ui Combobox](https://ui.shadcn.com/docs/components/combobox)
