---
title: Never Use Nested Ternary Operators
impact: HIGH
impactDescription: Nested ternaries are 3-5x harder to parse than equivalent if/else, with error rates in code review increasing by 200%
tags: flow, ternary, readability, conditionals, anti-pattern
---

## Never Use Nested Ternary Operators

Nested ternary operators create write-only code. The human brain processes branching logic linearly, but nested ternaries force simultaneous evaluation of multiple conditions. Even with formatting, the precedence and flow become ambiguous. One nested ternary can make an entire function unreadable.

**Incorrect (nested ternaries):**

```typescript
function getStatusBadge(user: User): string {
  return user.isAdmin
    ? user.isActive
      ? 'admin-active'
      : 'admin-inactive'
    : user.isPremium
      ? user.isActive
        ? 'premium-active'
        : 'premium-inactive'
      : user.isActive
        ? 'basic-active'
        : 'basic-inactive';
}
```

**Correct (explicit conditionals):**

```typescript
function getStatusBadge(user: User): string {
  const status = user.isActive ? 'active' : 'inactive';

  if (user.isAdmin) {
    return `admin-${status}`;
  }
  if (user.isPremium) {
    return `premium-${status}`;
  }
  return `basic-${status}`;
}
```

**Incorrect (ternary chain for value selection):**

```typescript
const priority = task.isUrgent
  ? task.isImportant
    ? 1
    : 2
  : task.isImportant
    ? 3
    : 4;
```

**Correct (lookup object or switch):**

```typescript
const priorityMatrix = {
  'urgent-important': 1,
  'urgent-normal': 2,
  'normal-important': 3,
  'normal-normal': 4,
};

const urgency = task.isUrgent ? 'urgent' : 'normal';
const importance = task.isImportant ? 'important' : 'normal';
const priority = priorityMatrix[`${urgency}-${importance}`];
```

**Incorrect (inline nested ternary in JSX):**

```tsx
function UserAvatar({ user }: Props) {
  return (
    <div className={
      user.status === 'online'
        ? user.isPremium
          ? 'avatar-premium-online'
          : 'avatar-online'
        : user.status === 'away'
          ? 'avatar-away'
          : 'avatar-offline'
    }>
      {user.name}
    </div>
  );
}
```

**Correct (helper function with clear logic):**

```tsx
function getAvatarClass(user: User): string {
  if (user.status === 'online') {
    return user.isPremium ? 'avatar-premium-online' : 'avatar-online';
  }
  if (user.status === 'away') {
    return 'avatar-away';
  }
  return 'avatar-offline';
}

function UserAvatar({ user }: Props) {
  return (
    <div className={getAvatarClass(user)}>
      {user.name}
    </div>
  );
}
```

### Acceptable Single-Level Ternary

```typescript
// OK: Single ternary for simple binary choice
const label = isLoading ? 'Loading...' : 'Submit';

// OK: Nullish coalescing or optional chaining
const name = user?.name ?? 'Anonymous';

// NOT OK: Even two levels is too much
const label = isLoading ? 'Loading...' : isDisabled ? 'Disabled' : 'Submit';
```

### Benefits

- Code flow is immediately apparent
- Debugging is possible (can set breakpoints)
- Modifications don't require understanding entire expression
- Code review can focus on logic, not parsing

### When NOT to Apply

- Single-level ternaries for simple binary choices are acceptable
- Ternaries inside template literals for simple value selection
