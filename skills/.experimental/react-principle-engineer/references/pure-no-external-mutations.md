---
title: Never mutate external variables during render
impact: HIGH
impactDescription: Mutations during render cause unpredictable behavior, race conditions, and bugs that are nearly impossible to track down
tags: [purity, rendering, mutations, bugs]
---

# Never Mutate External Variables During Render

Components must not change variables or objects that existed before rendering. This includes module-level variables, props, and any objects passed in from outside.

## Why This Matters

React assumes components are pure functions. When you mutate external variables:
- Multiple renders produce different results
- Other components reading the same variable get corrupted data
- Concurrent features (Suspense, transitions) break completely
- StrictMode will expose bugs by double-rendering

## Incorrect

```tsx
// BAD: Mutating a module-level variable during render
let guestNumber = 0;

function GuestGreeting() {
  // This mutation happens during render - WRONG!
  guestNumber = guestNumber + 1;
  return <h2>Welcome, Guest #{guestNumber}</h2>;
}

function GuestList() {
  return (
    <>
      <GuestGreeting />  {/* Shows #2 in StrictMode (double render) */}
      <GuestGreeting />  {/* Shows #4 in StrictMode */}
      <GuestGreeting />  {/* Shows #6 in StrictMode */}
    </>
  );
}
```

## Correct

```tsx
// GOOD: Use props to pass unique values
function GuestGreeting({ guestNumber }: { guestNumber: number }) {
  return <h2>Welcome, Guest #{guestNumber}</h2>;
}

function GuestList() {
  return (
    <>
      <GuestGreeting guestNumber={1} />
      <GuestGreeting guestNumber={2} />
      <GuestGreeting guestNumber={3} />
    </>
  );
}
```

## Also Incorrect

```tsx
// BAD: Mutating a prop object
function UserCard({ user }: { user: User }) {
  // WRONG - mutating the prop object
  user.displayName = user.firstName + ' ' + user.lastName;
  return <div>{user.displayName}</div>;
}
```

## Correct Alternative

```tsx
// GOOD: Calculate during render without mutation
function UserCard({ user }: { user: User }) {
  const displayName = user.firstName + ' ' + user.lastName;
  return <div>{displayName}</div>;
}
```

## Key Principle

Think of rendering like a math formula: `y = 2x`. No matter how many times you calculate it, `x = 3` always gives `y = 6`. Your components should work the same way - given the same props, they return the same JSX, every time.
