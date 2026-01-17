---
title: Maintain Focus Management in Modals
impact: CRITICAL
impactDescription: prevents 100% keyboard user navigation failure
tags: ally, focus, modals, keyboard, dialog
---

## Maintain Focus Management in Modals

Radix Dialog/Sheet components trap focus within the modal and return focus on close. Custom modal implementations must replicate this behavior for keyboard accessibility.

**Incorrect (focus escapes modal):**

```tsx
function CustomModal({
  open,
  onClose,
  children,
}: {
  open: boolean
  onClose: () => void
  children: React.ReactNode
}) {
  if (!open) return null

  return (
    <div className="fixed inset-0 bg-black/50" onClick={onClose}>
      <div className="fixed left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 bg-white p-6 rounded-lg">
        <button onClick={onClose}>Close</button>
        {children}
        {/* Tab key can focus elements behind modal */}
        {/* Escape key doesn't close modal */}
        {/* Focus not moved to modal on open */}
      </div>
    </div>
  )
}
```

**Correct (using shadcn/ui Dialog):**

```tsx
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogClose,
} from "@/components/ui/dialog"

function CustomModal({
  open,
  onOpenChange,
  title,
  children,
}: {
  open: boolean
  onOpenChange: (open: boolean) => void
  title: string
  children: React.ReactNode
}) {
  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>{title}</DialogTitle>
        </DialogHeader>
        {children}
        {/* Focus trapped within DialogContent */}
        {/* Escape key closes modal automatically */}
        {/* Focus returns to trigger on close */}
      </DialogContent>
    </Dialog>
  )
}
```

**Focus management behaviors:**
- Focus moves to first focusable element on open
- Tab cycles through modal content only
- Shift+Tab cycles backwards
- Escape closes and returns focus to trigger

Reference: [WAI-ARIA Dialog Pattern](https://www.w3.org/WAI/ARIA/apg/patterns/dialog-modal/)
