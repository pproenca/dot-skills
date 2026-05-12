---
title: Destructive Actions Require a Typed Confirmation OR an Undo Window
impact: HIGH
impactDescription: Single-click destructive actions cause 5-10% accidental-loss rate; typed-name confirmation reduces accidental destruction by ~95%; undo windows resolve ~85% of mistakes
tags: ux, destructive, confirmation, typed-confirmation, undo, soft-delete
---

## Destructive Actions Require a Typed Confirmation OR an Undo Window

Destructive actions split into two categories with different patterns:

- **Recoverable** (delete a comment, archive a project, leave a channel): single-click action + toast with Undo (≥ 6 s) + soft-delete on the server
- **Irreversible** (delete a workspace, transfer ownership, drop a database): explicit typed confirmation that includes the entity's name

Never use a generic `confirm("Are you sure?")` browser dialog — it's accessibility-hostile, theme-broken, and unstyled.

**Incorrect (browser confirm; no typed confirmation for irreversible action; no undo for recoverable):**

```tsx
function DeleteWorkspaceButton({ workspace }: { workspace: Workspace }) {
  return (
    <button
      onClick={() => {
        if (confirm('Are you sure?')) deleteWorkspace(workspace.id) // gone forever, no recovery
      }}
    >
      Delete workspace
    </button>
  )
}
```

**Correct (typed confirmation for irreversible; undo for recoverable):**

```tsx
// IRREVERSIBLE — typed confirmation dialog
'use client'
import { useState } from 'react'

export function DeleteWorkspaceDialog({ workspace }: { workspace: Workspace }) {
  const [typed, setTyped] = useState('')
  const matches = typed === workspace.name

  return (
    <Dialog.Root>
      <Dialog.Trigger asChild>
        <Button variant="destructive">Delete workspace</Button>
      </Dialog.Trigger>
      <Dialog.Portal>
        <Dialog.Overlay className="fixed inset-0 bg-black/40" />
        <Dialog.Content className="fixed left-1/2 top-1/2 max-w-md -translate-x-1/2 -translate-y-1/2 rounded-lg bg-background p-6">
          <Dialog.Title className="text-lg font-semibold text-destructive">
            Delete "{workspace.name}"
          </Dialog.Title>
          <Dialog.Description className="mt-2 text-sm text-muted-foreground">
            This will permanently delete the workspace and all {workspace.projectCount} projects.
            This action cannot be undone.
          </Dialog.Description>
          <label className="mt-4 block">
            <span className="text-sm font-medium">
              Type <code className="rounded bg-muted px-1.5 py-0.5">{workspace.name}</code> to confirm
            </span>
            <input
              value={typed}
              onChange={(e) => setTyped(e.target.value)}
              className="mt-1 w-full rounded-md border px-3 h-11"
              autoComplete="off"
              autoCapitalize="off"
              aria-required
            />
          </label>
          <div className="mt-4 flex justify-end gap-2">
            <Dialog.Close asChild><Button variant="ghost">Cancel</Button></Dialog.Close>
            <form action={deleteWorkspaceAction.bind(null, workspace.id)}>
              <Button type="submit" variant="destructive" disabled={!matches}>
                Delete workspace
              </Button>
            </form>
          </div>
        </Dialog.Content>
      </Dialog.Portal>
    </Dialog.Root>
  )
}

// RECOVERABLE — single click + undo toast, soft-delete on the server
async function onDeleteComment(id: string) {
  await deleteCommentAction(id) // sets deletedAt; cron sweeps after 24h
  toast.success('Comment deleted', {
    action: { label: 'Undo', onClick: () => restoreCommentAction(id) },
    duration: 6000,
  })
}
```

**Rule:**
- Irreversible action → typed confirmation including the entity name; submit disabled until match
- Recoverable action → single click + toast-with-Undo (≥ 6 s) + soft-delete on the server (`deletedAt`)
- Destructive primary buttons use the `destructive` variant (red token, not raw red)
- Never use `window.confirm` — always a real Radix Dialog
- Pair the confirmation Title with the entity name so users have a "this is the thing I want to delete" moment

Reference: [Confirmation Dialogs — Apple HIG](https://developer.apple.com/design/human-interface-guidelines/alerts) · [GitHub's typed-confirmation pattern](https://github.blog/2023-01-26-why-we-redesigned-the-repository-deletion-confirmation/)
