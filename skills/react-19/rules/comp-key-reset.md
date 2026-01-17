---
title: Use Key to Reset Component State
impact: LOW-MEDIUM
impactDescription: correct state isolation, proper resets
tags: comp, key, reset, state
---

## Use Key to Reset Component State

When you need to fully reset a component's internal state, change its key. This unmounts the old instance and mounts a fresh one.

**Incorrect (state persists between items):**

```typescript
function UserEditor({ user }: { user: User }) {
  const [draft, setDraft] = useState(user.bio)

  // When user changes, draft keeps old value!
  return (
    <textarea value={draft} onChange={e => setDraft(e.target.value)} />
  )
}

function App() {
  const [selectedUser, setSelectedUser] = useState(users[0])

  return (
    <div>
      <UserList onSelect={setSelectedUser} />
      <UserEditor user={selectedUser} />
    </div>
  )
}
// Switching users shows stale draft text
```

**Correct (key forces fresh instance):**

```typescript
function App() {
  const [selectedUser, setSelectedUser] = useState(users[0])

  return (
    <div>
      <UserList onSelect={setSelectedUser} />
      <UserEditor key={selectedUser.id} user={selectedUser} />
    </div>
  )
}
// Each user gets fresh editor state
```

**Alternative (controlled reset with effect):**

```typescript
function UserEditor({ user }: { user: User }) {
  const [draft, setDraft] = useState(user.bio)

  // Sync when user changes
  useEffect(() => {
    setDraft(user.bio)
  }, [user.id])

  return (
    <textarea value={draft} onChange={e => setDraft(e.target.value)} />
  )
}
// Works but key approach is cleaner
```

**Use key reset for:**
- Form editors switching between items
- Chat components switching rooms
- Any stateful component that should reset on prop change
