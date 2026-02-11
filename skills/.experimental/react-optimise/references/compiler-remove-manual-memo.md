---
title: Remove Manual Memoization After Compiler Adoption
impact: CRITICAL
impactDescription: 20-40% code reduction in component files
tags: compiler, cleanup, memoization, migration
---

## Remove Manual Memoization After Compiler Adoption

Once React Compiler is enabled and validated, manual `useMemo`, `useCallback`, and `React.memo` wrappers become redundant. The compiler inserts equivalent (or better) memoization automatically. Leaving manual memo in place adds maintenance burden, obscures intent, and produces double-memoization that the compiler must work around.

**Incorrect (manual memoization with compiler already enabled):**

```tsx
"use memo"

const UserProfile = memo(function UserProfile({
  user,
  onFollow,
}: UserProfileProps) {
  const fullName = useMemo(
    () => `${user.firstName} ${user.lastName}`,
    [user.firstName, user.lastName]
  )

  const handleFollow = useCallback(
    () => onFollow(user.id),
    [user.id, onFollow]
  )

  const joinDate = useMemo(
    () => new Intl.DateTimeFormat("en-GB").format(user.createdAt),
    [user.createdAt]
  )

  return (
    <div>
      <h1>{fullName}</h1>
      <span>Joined {joinDate}</span>
      <button onClick={handleFollow}>Follow</button>
    </div>
  )
})
```

**Correct (clean code, compiler handles memoization):**

```tsx
"use memo"

function UserProfile({ user, onFollow }: UserProfileProps) {
  const fullName = `${user.firstName} ${user.lastName}`
  const handleFollow = () => onFollow(user.id)
  const joinDate = new Intl.DateTimeFormat("en-GB").format(user.createdAt)

  return (
    <div>
      <h1>{fullName}</h1>
      <span>Joined {joinDate}</span>
      <button onClick={handleFollow}>Follow</button>
    </div>
  )
}
```

Reference: [React Compiler — Removing Manual Memoization](https://react.dev/learn/react-compiler#removing-existing-memoization)
