---
title: Treat props as read-only
impact: HIGH
impactDescription: Mutating props breaks React's data flow and causes bugs that are hard to track across components
tags: [pure, props, immutability, data-flow]
---

# Treat Props as Read-Only

Props are owned by the parent component. Never mutate them - this breaks React's one-way data flow and creates bugs that are extremely difficult to debug.

## Why This Matters

Props are React's way of passing data down:
- Parent owns the data, child reads it
- Mutations bypass React's re-render detection
- Other components may share the same reference
- TypeScript readonly types exist for a reason

**Incorrect (anti-pattern):**

```tsx
// Problem: Mutating a prop object
interface User {
  name: string;
  email: string;
  displayName?: string;
}

function UserCard({ user }: { user: User }) {
  // WRONG - mutating the prop
  user.displayName = user.name.toUpperCase();

  return (
    <div>
      <h2>{user.displayName}</h2>
      <p>{user.email}</p>
    </div>
  );
}

// Bug: the parent's user object is now mutated too!
function UserList({ users }: { users: User[] }) {
  return (
    <div>
      {users.map(user => (
        <UserCard key={user.email} user={user} />
      ))}
      {/* After rendering, all users have displayName mutated */}
    </div>
  );
}
```

**Correct (recommended):**

```tsx
// Solution: Compute derived values without mutation
function UserCard({ user }: { user: User }) {
  // Calculate during render, don't store
  const displayName = user.name.toUpperCase();

  return (
    <div>
      <h2>{displayName}</h2>
      <p>{user.email}</p>
    </div>
  );
}
```

**Incorrect (anti-pattern):**

```tsx
// Problem: Mutating a prop array
function SortedList({ items }: { items: string[] }) {
  // WRONG - .sort() mutates the original array
  items.sort();

  return (
    <ul>
      {items.map(item => <li key={item}>{item}</li>)}
    </ul>
  );
}
```

**Correct (recommended):**

```tsx
// Solution: Create a sorted copy
function SortedList({ items }: { items: string[] }) {
  // .slice() or spread creates a copy, then sort that
  const sortedItems = [...items].sort();

  return (
    <ul>
      {sortedItems.map(item => <li key={item}>{item}</li>)}
    </ul>
  );
}
```

**Incorrect (anti-pattern):**

```tsx
// Problem: Adding properties to prop objects
function EnhancedItem({ item }: { item: Item }) {
  // WRONG - modifying the prop
  item.processedAt = new Date();
  item.isEnhanced = true;

  return <div>{item.name} - {item.processedAt.toISOString()}</div>;
}
```

**Correct (recommended):**

```tsx
// Solution: Create enhanced object without mutation
function EnhancedItem({ item }: { item: Item }) {
  const enhanced = {
    ...item,
    processedAt: new Date(),
    isEnhanced: true,
  };

  return <div>{enhanced.name} - {enhanced.processedAt.toISOString()}</div>;
}
```

## TypeScript Enforcement

```tsx
// Use Readonly to catch mutations at compile time
interface User {
  readonly name: string;
  readonly email: string;
}

// Or use utility type
type Props = {
  user: Readonly<User>;
  items: ReadonlyArray<Item>;
};

function Component({ user, items }: Props) {
  // TypeScript error: Cannot assign to 'name' because it is read-only
  user.name = 'New Name';

  // TypeScript error: Property 'push' does not exist on type 'readonly Item[]'
  items.push(newItem);
}
```

## Key Principle

Props flow down like a river - the parent controls the source, children just observe. If a child needs to change something, it should tell the parent (via callback props), not mutate the data directly.
