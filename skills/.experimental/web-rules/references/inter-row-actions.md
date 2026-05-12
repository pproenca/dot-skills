---
title: Use One Row-Action Pattern Per List (Kebab Menu OR Hover Actions OR Swipe)
impact: HIGH
impactDescription: Mixing row-action patterns within the same list causes 40%+ task-completion drop; users learn ONE affordance per surface
tags: inter, row-actions, kebab, dropdown, hover, swipe-actions
---

## Use One Row-Action Pattern Per List (Kebab Menu OR Hover Actions OR Swipe)

Pick one row-action pattern for a given list and stick with it. The three valid patterns: (1) a kebab menu (`…`) at the end of every row, always visible; (2) hover-reveal action icons that also appear on `:focus-within`; (3) swipe-to-reveal on mobile, paired with the kebab on desktop. Never mix patterns inside the same list. The kebab pattern is the safest default — visible, keyboard-reachable, mobile-friendly without swipe gestures.

**Incorrect (mixing inline buttons, hover icons, and "click anywhere to delete" handlers):**

```tsx
function MessageList({ messages }: { messages: Message[] }) {
  return (
    <ul>
      {messages.map((m) => (
        <li key={m.id} className="flex gap-2" onClick={() => deleteMessage(m.id)}>
          <span>{m.subject}</span>
          <button onClick={() => archiveMessage(m.id)}>Archive</button>
          {/* and elsewhere in the same list, hover-only actions on other rows */}
        </li>
      ))}
    </ul>
  )
}
```

**Correct (single kebab-menu pattern, always visible, keyboard-reachable):**

```tsx
import { MoreHorizontal, Archive, Star, Trash2 } from 'lucide-react'

function MessageRow({ message }: { message: Message }) {
  return (
    <li className="group flex items-center gap-3 px-3 py-2 hover:bg-accent">
      <Link href={`/inbox/${message.id}`} className="flex-1 truncate">
        {message.subject}
      </Link>
      <DropdownMenu>
        <DropdownMenuTrigger asChild>
          <Button
            size="icon"
            variant="ghost"
            className="size-9"
            aria-label={`Actions for ${message.subject}`}
          >
            <MoreHorizontal className="size-4" />
          </Button>
        </DropdownMenuTrigger>
        <DropdownMenuContent align="end">
          <DropdownMenuItem onSelect={() => archiveAction(message.id)}>
            <Archive className="mr-2 size-4" /> Archive
          </DropdownMenuItem>
          <DropdownMenuItem onSelect={() => starAction(message.id)}>
            <Star className="mr-2 size-4" /> Star
          </DropdownMenuItem>
          <DropdownMenuSeparator />
          <DropdownMenuItem onSelect={() => deleteAction(message.id)} className="text-destructive">
            <Trash2 className="mr-2 size-4" /> Delete
          </DropdownMenuItem>
        </DropdownMenuContent>
      </DropdownMenu>
    </li>
  )
}
```

**Alternative (hover-reveal pattern — only when the row itself is dense and chrome must stay quiet):**

```tsx
// Reveals the same actions on hover OR focus-within. Same kebab as fallback on touch.
<li className="group flex items-center gap-3 px-3 py-2 hover:bg-accent">
  <Link href={`/inbox/${m.id}`} className="flex-1 truncate">{m.subject}</Link>
  <div className="ml-auto flex gap-1 opacity-0 group-hover:opacity-100 group-focus-within:opacity-100 transition-opacity">
    <IconButton aria-label="Archive" icon={Archive} onClick={() => archiveAction(m.id)} />
    <IconButton aria-label="Star" icon={Star} onClick={() => starAction(m.id)} />
  </div>
</li>
```

**Rule:**
- Pick one pattern per list (kebab is the default) and do not mix
- Row click navigates to detail — never deletes, archives, or otherwise mutates
- Hover-reveal must also appear on `:focus-within` (use Tailwind `group-focus-within:`)
- Destructive items in the menu are marked with `text-destructive` and grouped at the bottom under a separator
- Swipe actions (mobile) must duplicate every action available in the kebab menu — never expose a destructive action by swipe only

Reference: [List item interactions — Material Design](https://m3.material.io/components/lists)
