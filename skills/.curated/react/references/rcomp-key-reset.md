---
title: Tie a stateful child's identity to the entity it edits by setting `key={entity.id}` — let React tear down stale state for you
impact: LOW-MEDIUM
impactDescription: forces full unmount/remount on identity change; eliminates a class of stale-state bugs without `useEffect`-based resets
tags: rcomp, key-reset, identity-key, prop-driven-reset
---

## Tie a stateful child's identity to the entity it edits by setting `key={entity.id}` — let React tear down stale state for you

**Pattern intent:** when a stateful child component represents a specific entity (a user being edited, a chat room currently open, a draft in progress), its React identity should track the entity's identity. Setting `key={entity.id}` on the child makes "show a different entity" mean "unmount, remount fresh" — no manual reset code needed.

### Shapes to recognize

- A `<UserEditor user={user}>` with internal `useState(user.bio)` that doesn't reset when `user` changes — stale draft text on user switch.
- A `<ChatRoom roomId={id}>` with subscription state that lingers between rooms.
- A `useEffect(() => { setX(prop.initial) }, [prop.id])` *purely* to reset state on prop-id change — the same anti-pattern as derived-state-via-effect ([`effect-avoid-unnecessary.md`](effect-avoid-unnecessary.md)). The right fix is usually `key`, not the effect.
- A "reset" button somewhere in UI that does manual `setX(initial), setY(initial), setZ(initial)` calls — could be a key bump (`setResetCounter(c => c + 1)` on a wrapper) that remounts the subtree.
- Modal/dialog components that retain their internal state between unrelated openings — using `key` on the inner content forces fresh state per opening.

The canonical resolution: pass `key={entity.id}` to the stateful child. React unmounts the previous instance and mounts a fresh one with default-initialized state. No reset effect, no manual setter cascade.

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

**Anti-pattern (effect-based reset — for reference, do not use):**

```typescript
function UserEditor({ user }: { user: User }) {
  const [draft, setDraft] = useState(user.bio)

  // ❌ Reset via effect — this is the exact anti-pattern in effect-avoid-unnecessary.md.
  // It causes an extra render pass and is brittle if multiple props can change.
  useEffect(() => {
    setDraft(user.bio)
  }, [user.id])

  return (
    <textarea value={draft} onChange={e => setDraft(e.target.value)} />
  )
}
```

This shape appears in older React codebases and is functionally equivalent to the key-reset approach, but it pays an extra render pass and breaks when you have multiple reset triggers. Prefer `key={user.id}` on the parent.

**Use key reset for:**
- Form editors switching between items
- Chat components switching rooms
- Any stateful component that should reset on prop change
