---
title: Confirm Every Destructive or Irreversible Action With Explicit Visible Feedback
impact: HIGH
impactDescription: Silent destructive actions cause 15-25% support-ticket rate "did this work?"; explicit confirmation reduces error reports by 60-80%
tags: feed, success-confirmation, undo, optimistic, destructive
---

## Confirm Every Destructive or Irreversible Action With Explicit Visible Feedback

After any destructive or hard-to-undo action (delete, archive, send, pay), confirm completion with visible feedback that names the action. For everyday actions, prefer optimistic UI + toast-with-undo. For high-stakes irreversible actions (purchase, public publish), show a confirmation screen or banner that persists until the user dismisses it. Never assume "no error = obvious success."

**Incorrect (silent action — user wonders if anything happened):**

```tsx
function ArchiveButton({ id }: { id: string }) {
  return (
    <button onClick={() => archiveAction(id)}>
      Archive
    </button>
  )
  // Action succeeds, page reloads silently. User: "did I actually archive it?"
}
```

**Correct (optimistic update + named toast + undo for everyday actions):**

```tsx
'use client'
import { useOptimistic, useTransition } from 'react'
import { toast } from 'sonner'
import { archiveAction, unarchiveAction } from './actions'

export function ProjectRow({ project }: { project: Project }) {
  const [optimisticArchived, setOptimisticArchived] = useOptimistic(project.archived)
  const [, startTransition] = useTransition()

  function onArchive() {
    startTransition(async () => {
      setOptimisticArchived(true)
      const result = await archiveAction(project.id)
      if (!result.ok) {
        setOptimisticArchived(false)
        toast.error(`Couldn't archive "${project.name}"`)
        return
      }
      toast.success(`Archived "${project.name}"`, {
        action: { label: 'Undo', onClick: () => unarchiveAction(project.id) },
        duration: 6000,
      })
    })
  }

  return (
    <li className="flex items-center justify-between p-3">
      <span className={optimisticArchived ? 'text-muted-foreground line-through' : ''}>
        {project.name}
      </span>
      <Button variant="ghost" size="sm" onClick={onArchive} disabled={optimisticArchived}>
        Archive
      </Button>
    </li>
  )
}
```

**High-stakes confirmation (purchase / publish / send) — persistent banner or screen:**

```tsx
// After successful checkout — render a confirmation screen, not just a toast
export default async function ConfirmationPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params
  const order = await getOrder(id)
  return (
    <div className="mx-auto max-w-md text-center p-8 space-y-4">
      <CheckCircle2 className="mx-auto size-12 text-success" aria-hidden="true" />
      <h1 className="text-xl font-semibold">Order confirmed</h1>
      <p className="text-sm text-muted-foreground">
        Order #{order.number} for {formatMoney(order.total)} is on its way.
        We sent the receipt to {order.email}.
      </p>
      <div className="flex justify-center gap-2 pt-2">
        <Button variant="ghost" asChild><Link href="/orders">View orders</Link></Button>
        <Button asChild><Link href="/">Back to shop</Link></Button>
      </div>
    </div>
  )
}
```

**Rule:**
- Every destructive action triggers a named confirmation (toast or screen) — the message includes the entity name ("Archived 'Atlas project'", not "Archived")
- Everyday actions (archive, delete, mute): toast + Undo, 6 s duration
- Irreversible high-stakes actions (purchase, send, publish): confirmation screen or banner that persists until dismissed
- Pair confirmation with `aria-live="polite"` regions so screen-reader users hear it (`sonner` handles this)
- Never rely on the absence of an error to imply success

Reference: [Affordances and signifiers — NN/g](https://www.nngroup.com/articles/feedback/)
