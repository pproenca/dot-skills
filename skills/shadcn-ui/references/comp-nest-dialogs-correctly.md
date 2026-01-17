---
title: Nest Dialogs with Proper Focus Management
impact: MEDIUM
impactDescription: maintains focus trap hierarchy in nested modals
tags: comp, dialog, nesting, focus, modals
---

## Nest Dialogs with Proper Focus Management

When opening a dialog from within another dialog (e.g., confirmation from settings), manage focus correctly to prevent trapping issues.

**Incorrect (nested Dialog loses focus context):**

```tsx
function SettingsDialog() {
  return (
    <Dialog>
      <DialogTrigger asChild>
        <Button>Settings</Button>
      </DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Settings</DialogTitle>
        </DialogHeader>
        <div className="space-y-4">
          {/* Settings content */}
          <Dialog>
            <DialogTrigger asChild>
              <Button variant="destructive">Delete Account</Button>
            </DialogTrigger>
            <DialogContent>
              {/* Inner dialog - focus management may break */}
              <DialogTitle>Confirm Delete</DialogTitle>
            </DialogContent>
          </Dialog>
        </div>
      </DialogContent>
    </Dialog>
  )
}
```

**Correct (AlertDialog for confirmations):**

```tsx
function SettingsDialog() {
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false)

  return (
    <>
      <Dialog>
        <DialogTrigger asChild>
          <Button>Settings</Button>
        </DialogTrigger>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Settings</DialogTitle>
          </DialogHeader>
          <div className="space-y-4">
            {/* Settings content */}
            <Button variant="destructive" onClick={() => setShowDeleteConfirm(true)}>
              Delete Account
            </Button>
          </div>
        </DialogContent>
      </Dialog>

      <AlertDialog open={showDeleteConfirm} onOpenChange={setShowDeleteConfirm}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Delete Account?</AlertDialogTitle>
            <AlertDialogDescription>
              This action cannot be undone. Your data will be permanently deleted.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction onClick={handleDelete}>Delete</AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </>
  )
}
```

**Alternative (DropdownMenu with modal={false}):**

```tsx
<DropdownMenu modal={false}>
  {/* When modal={false}, dropdown won't steal focus from parent dialog */}
  <DropdownMenuTrigger asChild>
    <Button variant="outline">Options</Button>
  </DropdownMenuTrigger>
  <DropdownMenuContent>
    <DropdownMenuItem onSelect={() => setShowDeleteConfirm(true)}>
      Delete
    </DropdownMenuItem>
  </DropdownMenuContent>
</DropdownMenu>
```

**Guidelines:**
- Use AlertDialog for confirmations (designed for this pattern)
- Set `modal={false}` on DropdownMenu inside Dialogs
- Manage nested dialog state in parent component

Reference: [shadcn/ui AlertDialog](https://ui.shadcn.com/docs/components/alert-dialog)
