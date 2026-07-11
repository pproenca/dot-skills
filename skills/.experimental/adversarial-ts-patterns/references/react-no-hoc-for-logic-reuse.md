---
title: Reuse stateful logic with a custom hook, not a new higher-order component
tags: react, hoc, custom-hooks, decorator
---

## Reuse stateful logic with a custom hook, not a new higher-order component

The wrong default is writing a new `withX` higher-order component to share stateful logic — the pre-hooks idiom (and a Decorator-pattern port) that survives in training data. An HOC that only injects props costs a wrapper component per use (deeper trees, wrapper hell in DevTools), collides prop names invisibly, erases prop types unless generics are threaded carefully, and hides which values come from where. A custom hook returns the same values as plain named bindings in the consuming component — no extra tree nodes, no prop collision, full inference.

**Evidence of violation:** a newly written function that takes a component and returns a component (`withCurrentUser(Component)` shape) whose wrapper only computes values and passes them as extra props — it renders no JSX structure of its own beyond the wrapped component. The carve-out is an HOC required by a library's API you consume, or a wrapper that genuinely alters the tree around the child (an error boundary, a provider bundle, a portal) — those add structure, which hooks cannot.

**Incorrect (wrapper component per consumer, props appear from nowhere):**

```tsx
function withCurrentUser<P extends { user: User }>(Wrapped: React.ComponentType<P>) {
  return function WithCurrentUser(props: Omit<P, "user">) {
    const user = useSyncExternalStore(userStore.subscribe, userStore.get)
    return <Wrapped {...(props as P)} user={user} />
  }
}
const ProfileMenuWithUser = withCurrentUser(ProfileMenu)
```

**Correct (hook returns the value where it is used):**

```tsx
function useCurrentUser(): User {
  return useSyncExternalStore(userStore.subscribe, userStore.get)
}

function ProfileMenu() {
  const user = useCurrentUser()
  return <MenuTrigger label={user.displayName} />
}
```

Reference: [react.dev — Reusing Logic with Custom Hooks](https://react.dev/learn/reusing-logic-with-custom-hooks)
