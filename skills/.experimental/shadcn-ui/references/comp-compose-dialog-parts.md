---
title: Compose Dialog with Semantic Parts
impact: CRITICAL
impactDescription: ensures accessibility and proper focus management
tags: comp, dialog, modal, composition, radix, accessibility
---

## Compose Dialog with Semantic Parts

Dialog components must use all semantic parts (Trigger, Content, Header, Title, Description) for proper accessibility. Missing parts break screen reader announcements and focus management.

**Incorrect (missing semantic structure):**

```tsx
import { Dialog, DialogContent } from "@/components/ui/dialog"

function DeleteConfirmation({ open, onClose }) {
  return (
    <Dialog open={open} onOpenChange={onClose}>
      <DialogContent>
        <h2>Delete Item?</h2>  {/* Not announced to screen readers */}
        <p>This cannot be undone.</p>
        <button onClick={onClose}>Cancel</button>
      </DialogContent>
    </Dialog>
  )
  // Missing: DialogHeader, DialogTitle, DialogDescription
  // Screen reader: Cannot identify dialog purpose
}
```

**Correct (full semantic structure):**

```tsx
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
  DialogFooter,
} from "@/components/ui/dialog"

function DeleteConfirmation() {
  return (
    <Dialog>
      <DialogTrigger asChild>
        <Button variant="destructive">Delete</Button>
      </DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Delete Item?</DialogTitle>
          <DialogDescription>
            This action cannot be undone. The item will be permanently removed.
          </DialogDescription>
        </DialogHeader>
        <DialogFooter>
          <Button variant="outline">Cancel</Button>
          <Button variant="destructive">Delete</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
```

**DialogTitle** is required - it sets `aria-labelledby` on the dialog.

Reference: [shadcn/ui Dialog](https://ui.shadcn.com/docs/components/dialog)
