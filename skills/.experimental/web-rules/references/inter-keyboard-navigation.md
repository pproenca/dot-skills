---
title: Every Interactive Element Is Reachable and Operable by Keyboard
impact: CRITICAL
impactDescription: 8-15% of users navigate primarily by keyboard (motor disabilities, power users, screen-reader users); a single unreachable control blocks the entire flow
tags: inter, keyboard, focus, tab-order, escape, enter
---

## Every Interactive Element Is Reachable and Operable by Keyboard

Tab moves focus forward through interactive elements in DOM order; Shift+Tab moves back. Enter activates buttons and submits forms; Space activates buttons and toggles checkboxes; Escape closes dialogs, popovers, and dropdowns. Arrow keys navigate within composite widgets (lists, menus, tabs, radio groups). Never use `<div onClick>` for actions — it is invisible to keyboards and assistive tech.

**Incorrect (`<div>` actions, no Escape handler, focus stuck inside dialog):**

```tsx
function FilterPanel({ open, onClose }: { open: boolean; onClose: () => void }) {
  if (!open) return null
  return (
    <div className="fixed inset-0 bg-background p-6">
      <div onClick={onClose}>×</div> {/* unreachable by Tab, no Enter handler */}
      <div onClick={applyFilter}>Apply</div> {/* same problem */}
    </div>
  )
}
```

**Correct (semantic elements, Escape closes, Radix dialog manages focus + trap + restore):**

```tsx
import * as Dialog from '@radix-ui/react-dialog'

function FilterPanel({ open, onOpenChange }: { open: boolean; onOpenChange: (open: boolean) => void }) {
  return (
    <Dialog.Root open={open} onOpenChange={onOpenChange}>
      <Dialog.Portal>
        <Dialog.Overlay className="fixed inset-0 bg-black/40 data-[state=open]:animate-in" />
        <Dialog.Content
          className="fixed inset-x-4 top-1/2 -translate-y-1/2 max-w-md rounded-lg bg-background p-6 shadow-lg"
          // Radix handles: focus trap, Escape to close, restore focus on close, aria-modal
        >
          <Dialog.Title className="text-lg font-semibold">Filters</Dialog.Title>
          <fieldset className="mt-4 space-y-2">
            {/* ... form controls — every one is focusable */}
          </fieldset>
          <div className="mt-6 flex justify-end gap-2">
            <Dialog.Close asChild>
              <Button variant="ghost">Cancel</Button>
            </Dialog.Close>
            <Button onClick={applyFilter}>Apply</Button>
          </div>
        </Dialog.Content>
      </Dialog.Portal>
    </Dialog.Root>
  )
}
```

**Composite widget keyboard contract:**

```tsx
// Tabs — Radix handles ArrowLeft/ArrowRight, Home, End
<Tabs.Root defaultValue="account">
  <Tabs.List>
    <Tabs.Trigger value="account">Account</Tabs.Trigger>
    <Tabs.Trigger value="security">Security</Tabs.Trigger>
  </Tabs.List>
  <Tabs.Content value="account">...</Tabs.Content>
  <Tabs.Content value="security">...</Tabs.Content>
</Tabs.Root>
```

**Rule:**
- Use semantic elements (`<button>`, `<a>`, `<input>`, `<select>`) — never `<div onClick>`
- Tab order matches visual order — never reorder with positive `tabindex` (only `tabindex="-1"` and `tabindex="0"` are allowed)
- Escape closes every dismissable surface (dialog, popover, dropdown, menu)
- Use Radix or shadcn/ui primitives for composite widgets — they implement the full ARIA APG patterns
- Verify by tabbing through every screen with the mouse unplugged

Reference: [WCAG 2.1.1 Keyboard](https://www.w3.org/WAI/WCAG22/Understanding/keyboard.html) · [ARIA Authoring Practices Guide](https://www.w3.org/WAI/ARIA/apg/)
