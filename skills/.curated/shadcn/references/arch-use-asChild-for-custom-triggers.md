---
title: Use asChild for Custom Trigger Elements
impact: CRITICAL
impactDescription: preserves accessibility and event handling
tags: arch, asChild, radix, composition, triggers
---

## Use asChild for Custom Trigger Elements

When using custom elements as triggers for Radix-based components, use the `asChild` prop to merge behavior onto your custom element instead of wrapping it.

**Incorrect (nested button elements, broken a11y):**

```tsx
function UserMenu() {
  return (
    <DropdownMenu>
      <DropdownMenuTrigger>
        <Button variant="ghost">
          <UserIcon className="h-4 w-4" />
          Account
        </Button>
      </DropdownMenuTrigger>
      {/* Creates <button><button>...</button></button> - invalid HTML */}
      <DropdownMenuContent>
        <DropdownMenuItem>Profile</DropdownMenuItem>
        <DropdownMenuItem>Settings</DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  )
}
```

**Correct (single button element with merged props):**

```tsx
function UserMenu() {
  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button variant="ghost">
          <UserIcon className="h-4 w-4" />
          Account
        </Button>
      </DropdownMenuTrigger>
      {/* Renders single <button> with all Radix props merged */}
      <DropdownMenuContent>
        <DropdownMenuItem>Profile</DropdownMenuItem>
        <DropdownMenuItem>Settings</DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  )
}
```

**When to use asChild:**
- Trigger components (DialogTrigger, PopoverTrigger, DropdownMenuTrigger)
- When your custom component already renders a focusable element
- When you need to preserve your component's styling and props

Reference: [Radix UI Composition](https://www.radix-ui.com/primitives/docs/guides/composition)
