---
title: Use Standard Hover, Click, and Long-Press Patterns; Never Invent New Ones
impact: CRITICAL
impactDescription: Non-standard interaction patterns cause 60-80% task failure on first attempt (NN/g); users discover hidden interactions through hover-only affordances at less than 20% rate
tags: inter, hover, click, context-menu, long-press, affordance
---

## Use Standard Hover, Click, and Long-Press Patterns; Never Invent New Ones

Click = primary action. Right-click (or long-press on touch) = context menu. Hover = reveal secondary details or actions on desktop, never hide primary functionality. Double-click is reserved for `<input>` text editing and the OS-level "open" gesture in file managers — never invent custom double-click handlers. Long-press is the touch equivalent of right-click; pair them in a single component.

**Incorrect (primary action only on hover, custom double-tap, no touch equivalent):**

```tsx
function Row({ item }: { item: Item }) {
  const [hovered, setHovered] = useState(false)
  return (
    <div
      onMouseEnter={() => setHovered(true)}
      onMouseLeave={() => setHovered(false)}
      onDoubleClick={() => openItem(item.id)} // discoverable to ~0% of users
    >
      {item.name}
      {hovered && <button onClick={() => deleteItem(item.id)}>Delete</button>}
    </div>
  )
}
```

**Correct (click opens, right-click and long-press both open context menu, hover shows actions but they are reachable by keyboard too):**

```tsx
import * as ContextMenu from '@radix-ui/react-context-menu'

function Row({ item }: { item: Item }) {
  return (
    <ContextMenu.Root>
      <ContextMenu.Trigger asChild>
        <Link
          href={`/items/${item.id}`}
          className="group flex items-center justify-between px-3 py-2 hover:bg-accent focus-visible:outline-2 focus-visible:outline-ring"
        >
          <span>{item.name}</span>
          {/* Hover-reveal actions, but also keyboard-focusable */}
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <button
                aria-label={`Actions for ${item.name}`}
                className="invisible group-hover:visible group-focus-within:visible size-8 flex items-center justify-center"
              >
                <MoreHorizontal className="size-4" />
              </button>
            </DropdownMenuTrigger>
            <DropdownMenuContent>
              <DropdownMenuItem onSelect={() => openItem(item.id)}>Open</DropdownMenuItem>
              <DropdownMenuItem onSelect={() => deleteItem(item.id)} className="text-destructive">
                Delete
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </Link>
      </ContextMenu.Trigger>
      <ContextMenu.Portal>
        <ContextMenu.Content className="min-w-40 rounded-md border bg-popover p-1 shadow-md">
          <ContextMenu.Item onSelect={() => openItem(item.id)}>Open</ContextMenu.Item>
          <ContextMenu.Item onSelect={() => deleteItem(item.id)}>Delete</ContextMenu.Item>
        </ContextMenu.Content>
      </ContextMenu.Portal>
    </ContextMenu.Root>
  )
}
```

**Rule:**
- Primary action is always reachable in one click — never require hover or double-click to discover
- Right-click and long-press open the same context menu (Radix `ContextMenu` handles both)
- Hover-revealed UI must also appear on `:focus-within` so keyboard users see the same affordances
- Use `group` + `group-hover:` + `group-focus-within:` (Tailwind) for hover/focus reveal patterns
- Reserve double-click for rename-in-place text inputs only

Reference: [Discoverable Functionality — Nielsen Norman Group](https://www.nngroup.com/articles/discoverable-functionality/)
