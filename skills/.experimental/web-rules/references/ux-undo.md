---
title: Prefer Undo Over Confirmation for Everyday Actions
impact: HIGH
impactDescription: Confirmation dialogs add ~2 s and one click to every action; undo windows resolve ~85% of real mistakes while keeping the happy path one-click
tags: ux, undo, soft-delete, toast-undo, recoverable, confirmation
---

## Prefer Undo Over Confirmation for Everyday Actions

For frequent, recoverable actions (archive, delete a comment, mark read, dismiss notification, leave channel), let the user act in one click and offer Undo via a toast that persists for at least 6 seconds. The server soft-deletes (`deletedAt` column) and a scheduled job sweeps after 24 hours. Reserve confirmation dialogs for irreversible actions (see [ux-destructive-confirmation](ux-destructive-confirmation.md)) and for actions that affect other people.

**Incorrect (every action prompts a confirmation, no undo path, hard delete):**

```tsx
function CommentRow({ comment }: { comment: Comment }) {
  return (
    <li>
      <p>{comment.body}</p>
      <button
        onClick={() => {
          if (confirm('Delete this comment?')) {
            deleteCommentAction(comment.id) // hard delete; gone forever
          }
        }}
      >
        Delete
      </button>
    </li>
  )
}
```

**Correct (one-click action, optimistic update, undo toast, soft-delete on server):**

```tsx
'use client'
import { useOptimistic, useTransition } from 'react'
import { toast } from 'sonner'
import { deleteCommentAction, restoreCommentAction } from './actions'

export function CommentRow({ comment }: { comment: Comment }) {
  const [optimisticDeleted, setOptimisticDeleted] = useOptimistic(false)
  const [, startTransition] = useTransition()

  function onDelete() {
    startTransition(async () => {
      setOptimisticDeleted(true)
      const result = await deleteCommentAction(comment.id)
      if (!result.ok) {
        setOptimisticDeleted(false)
        toast.error(`Couldn't delete comment`)
        return
      }
      toast.success('Comment deleted', {
        action: { label: 'Undo', onClick: () => restoreCommentAction(comment.id) },
        duration: 6000,
      })
    })
  }

  if (optimisticDeleted) return null

  return (
    <li className="group flex gap-2 p-3">
      <p className="flex-1">{comment.body}</p>
      <Button
        variant="ghost"
        size="icon"
        onClick={onDelete}
        aria-label="Delete comment"
        className="opacity-0 group-hover:opacity-100 group-focus-within:opacity-100 size-11"
      >
        <Trash2 className="size-4" />
      </Button>
    </li>
  )
}
```

**Server side: soft-delete + sweep job:**

```ts
// app/comments/actions.ts
'use server'
export async function deleteCommentAction(id: string) {
  await db.comment.update({ where: { id }, data: { deletedAt: new Date() } })
  revalidateTag(`comments-${id}`)
  return { ok: true }
}

export async function restoreCommentAction(id: string) {
  await db.comment.update({ where: { id }, data: { deletedAt: null } })
  revalidateTag(`comments-${id}`)
  return { ok: true }
}

// scheduled job, e.g. cron / Inngest
export async function sweepDeletedComments() {
  await db.comment.deleteMany({
    where: { deletedAt: { lt: new Date(Date.now() - 24 * 60 * 60 * 1000) } },
  })
}
```

**Rule:**
- Recoverable everyday actions: one-click + toast-with-Undo (≥ 6 s) + soft-delete on the server
- Soft-delete columns (`deletedAt`) sweep after 24 hours via a scheduled job
- Reserve confirmation dialogs for: irreversible actions, actions affecting other people, actions that move significant money
- Pair Undo with optimistic UI — the row disappears immediately, restored if the user clicks Undo
- Server Action returns `{ ok, error }` — never throw; client decides how to react

Reference: [Aza Raskin: Never use a warning when you mean undo](https://www.azarask.in/blog/post/never-use-a-warning-when-you-mean-undo/)
