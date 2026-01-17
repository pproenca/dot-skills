---
title: Use Controlled State for Dialogs Triggered Externally
impact: LOW-MEDIUM
impactDescription: enables programmatic dialog control from parent components
tags: state, controlled, dialog, modal, programmatic
---

## Use Controlled State for Dialogs Triggered Externally

When dialogs need to be opened from parent components or through programmatic events, use controlled state (`open`/`onOpenChange` props) instead of relying on the internal trigger.

**Incorrect (uncontrolled dialog, hard to open programmatically):**

```tsx
function UserRow({ user }: { user: User }) {
  return (
    <TableRow>
      <TableCell>{user.name}</TableCell>
      <TableCell>
        <Dialog>
          <DialogTrigger asChild>
            <Button size="sm">Edit</Button>
          </DialogTrigger>
          <DialogContent>
            <EditUserForm user={user} />
          </DialogContent>
        </Dialog>
        {/* Cannot open this dialog from parent table component */}
      </TableCell>
    </TableRow>
  )
}

function UsersTable() {
  const handleBulkEdit = () => {
    // No way to programmatically open edit dialog for selected users
  }
}
```

**Correct (controlled dialog state):**

```tsx
function UserRow({
  user,
  editOpen,
  onEditOpenChange,
}: {
  user: User
  editOpen: boolean
  onEditOpenChange: (open: boolean) => void
}) {
  return (
    <TableRow>
      <TableCell>{user.name}</TableCell>
      <TableCell>
        <Button size="sm" onClick={() => onEditOpenChange(true)}>
          Edit
        </Button>
        <Dialog open={editOpen} onOpenChange={onEditOpenChange}>
          <DialogContent>
            <EditUserForm user={user} onSuccess={() => onEditOpenChange(false)} />
          </DialogContent>
        </Dialog>
      </TableCell>
    </TableRow>
  )
}

function UsersTable({ users }: { users: User[] }) {
  const [editingUserId, setEditingUserId] = useState<string | null>(null)

  const handleBulkEdit = (userId: string) => {
    setEditingUserId(userId) // Programmatically open dialog
  }

  return (
    <Table>
      <TableBody>
        {users.map((user) => (
          <UserRow
            key={user.id}
            user={user}
            editOpen={editingUserId === user.id}
            onEditOpenChange={(open) => setEditingUserId(open ? user.id : null)}
          />
        ))}
      </TableBody>
    </Table>
  )
}
```

**Alternative (dialog state in parent, dialog content separate):**

```tsx
function UsersTable({ users }: { users: User[] }) {
  const [editingUser, setEditingUser] = useState<User | null>(null)

  return (
    <>
      <Table>
        <TableBody>
          {users.map((user) => (
            <TableRow key={user.id}>
              <TableCell>{user.name}</TableCell>
              <TableCell>
                <Button size="sm" onClick={() => setEditingUser(user)}>
                  Edit
                </Button>
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>

      <Dialog open={!!editingUser} onOpenChange={(open) => !open && setEditingUser(null)}>
        <DialogContent>
          {editingUser && <EditUserForm user={editingUser} />}
        </DialogContent>
      </Dialog>
    </>
  )
}
```

Reference: [Radix Dialog Controlled](https://www.radix-ui.com/primitives/docs/components/dialog#api-reference)
