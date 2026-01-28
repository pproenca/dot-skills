---
title: Always Include DialogTitle for Screen Readers
impact: HIGH
impactDescription: required for ARIA labeling and screen reader announcements
tags: ally, dialog, aria, screen-reader, title
---

## Always Include DialogTitle for Screen Readers

Every Dialog must have a DialogTitle. This sets the `aria-labelledby` attribute that screen readers use to announce the dialog's purpose when it opens.

**Incorrect (missing DialogTitle):**

```tsx
import { Dialog, DialogContent } from "@/components/ui/dialog"

function ConfirmDialog({ open, onClose }) {
  return (
    <Dialog open={open} onOpenChange={onClose}>
      <DialogContent>
        <p>Are you sure you want to delete this item?</p>
        <Button onClick={onClose}>Cancel</Button>
        <Button variant="destructive">Delete</Button>
      </DialogContent>
    </Dialog>
  )
  // Screen reader: "Dialog" (no context about purpose)
}
```

**Correct (with DialogTitle):**

```tsx
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"

function ConfirmDialog({ open, onClose }) {
  return (
    <Dialog open={open} onOpenChange={onClose}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Delete Item</DialogTitle>
          <DialogDescription>
            This action cannot be undone.
          </DialogDescription>
        </DialogHeader>
        <p>Are you sure you want to delete this item?</p>
        <Button onClick={onClose}>Cancel</Button>
        <Button variant="destructive">Delete</Button>
      </DialogContent>
    </Dialog>
  )
  // Screen reader: "Delete Item dialog"
}
```

**For visually hidden titles:**

```tsx
<DialogTitle className="sr-only">Search</DialogTitle>
```

Reference: [WAI-ARIA Dialog Pattern](https://www.w3.org/WAI/ARIA/apg/patterns/dialog-modal/)
