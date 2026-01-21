---
title: Cancelable Event Pattern
impact: CRITICAL
impactDescription: allows consumers to prevent default behavior based on custom logic
tags: err, events, cancelable, pattern
---

## Cancelable Event Pattern

Event handlers should receive a details object with a `cancel()` method that prevents the default behavior. This allows consumers to conditionally prevent state changes.

**Incorrect (no cancellation):**

```typescript
interface DialogProps {
  onOpenChange?: (open: boolean) => void
}

function DialogRoot(props: DialogProps) {
  const handleClose = () => {
    // No way for consumer to prevent close
    setOpen(false)
    props.onOpenChange?.(false)
  }
}
```

**Correct (with cancelable details):**

```typescript
interface ChangeEventDetails {
  reason: string
  cancel: () => void
  isCanceled: boolean
}

function createChangeEventDetails(reason: string): ChangeEventDetails {
  let canceled = false
  return {
    reason,
    cancel: () => { canceled = true },
    get isCanceled() { return canceled },
  }
}

interface DialogRootProps {
  onOpenChange?: (open: boolean, details: ChangeEventDetails) => void
}

function DialogRoot(props: DialogRootProps) {
  const handleClose = (reason: string) => {
    const details = createChangeEventDetails(reason)
    props.onOpenChange?.(false, details)

    // Consumer can prevent close
    if (details.isCanceled) {
      return
    }

    setOpen(false)
  }
}

// Consumer usage
<Dialog.Root
  onOpenChange={(open, details) => {
    if (!open && hasUnsavedChanges) {
      details.cancel() // Prevent close
      showConfirmation()
    }
  }}
/>
```

**When to use:**
- All state change callbacks
- Especially for close/dismiss events in dialogs, modals, popovers
