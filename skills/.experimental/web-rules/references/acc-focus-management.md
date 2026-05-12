---
title: Render a Visible Focus Ring and Trap Focus Inside Modals
impact: CRITICAL
impactDescription: 'Removing outline:none without a replacement causes keyboard users to lose their position — measured ~80% navigation failure (Deque); WCAG 2.4.7 requires a visible focus indicator'
tags: acc, focus, focus-visible, focus-trap, focus-restore, wcag-2-4-7
---

## Render a Visible Focus Ring and Trap Focus Inside Modals

A focus ring must always be visible when keyboard navigation moves focus. Tailwind's `focus-visible:` variant shows the ring only for keyboard users (not pointer clicks). Modals must trap focus: Tab cycles only within the dialog and Shift+Tab wraps. When the modal closes, focus restores to the element that opened it. Use Radix Dialog / Popover — they implement all three behaviors correctly.

**Incorrect (focus ring removed for all users, no focus trap, focus is lost on dialog close):**

```css
/* global.css */
*:focus { outline: none; }  /* nukes accessibility for every keyboard user */
```

```tsx
function CustomDialog({ children, onClose }: { children: React.ReactNode; onClose: () => void }) {
  return (
    <div className="fixed inset-0 bg-black/50">
      <div className="bg-white p-6 rounded">
        {children}
        <button onClick={onClose}>Close</button>
        {/* No focus trap. Tab can leave the dialog and reach the page behind. */}
      </div>
    </div>
  )
}
```

**Correct (visible focus ring on keyboard, focus trap + restore via Radix):**

```css
/* app/globals.css */
:focus-visible {
  outline: 2px solid hsl(var(--ring));
  outline-offset: 2px;
  border-radius: 4px;
}
```

```tsx
import * as Dialog from '@radix-ui/react-dialog'

function EditDialog({ children }: { children: React.ReactNode }) {
  return (
    <Dialog.Root>
      <Dialog.Trigger asChild>
        <Button>Edit</Button>
      </Dialog.Trigger>
      <Dialog.Portal>
        <Dialog.Overlay className="fixed inset-0 bg-black/40" />
        <Dialog.Content
          className="fixed left-1/2 top-1/2 max-w-md -translate-x-1/2 -translate-y-1/2 rounded-lg bg-background p-6 shadow-xl"
          onOpenAutoFocus={(e) => {
            // Default: focus first focusable element inside. Override only if necessary.
          }}
        >
          {/* Radix Dialog:
              - Traps focus inside Content while open
              - Restores focus to the Trigger on close
              - Adds aria-modal="true"
              - Listens for Escape to close
          */}
          <Dialog.Title className="text-lg font-semibold">Edit profile</Dialog.Title>
          <form className="mt-4 space-y-3">
            <label className="block">
              <span className="text-sm font-medium">Name</span>
              <input className="mt-1 w-full rounded-md border px-3 h-11 focus-visible:outline-2 focus-visible:outline-ring" />
            </label>
            <div className="flex justify-end gap-2">
              <Dialog.Close asChild>
                <Button variant="ghost">Cancel</Button>
              </Dialog.Close>
              <Button type="submit">Save</Button>
            </div>
          </form>
        </Dialog.Content>
      </Dialog.Portal>
    </Dialog.Root>
  )
}
```

**Routing-level focus restoration (App Router):**

```tsx
// app/template.tsx — fires on every navigation, unlike layout.tsx
'use client'
import { useEffect, useRef } from 'react'

export default function RouteFocus({ children }: { children: React.ReactNode }) {
  const headingRef = useRef<HTMLDivElement>(null)
  useEffect(() => {
    headingRef.current?.focus()
  }, [])
  return (
    <div ref={headingRef} tabIndex={-1} className="focus:outline-none">
      {children}
    </div>
  )
}
```

**Rule:**
- Never set `outline: none` without immediately providing a `:focus-visible` replacement
- Use `focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-ring` (Tailwind) — the ring renders only on keyboard focus
- Modals trap focus and restore it on close (use Radix Dialog / Popover / DropdownMenu — never roll your own)
- On route change, move focus to the new page's `<h1>` (use `tabIndex={-1}` + `.focus()` in `template.tsx`)
- Verify by Tab-walking the entire UI with the mouse unplugged

Reference: [WCAG 2.4.7 Focus Visible](https://www.w3.org/WAI/WCAG22/Understanding/focus-visible.html) · [Radix Dialog focus management](https://www.radix-ui.com/primitives/docs/components/dialog#accessibility)
