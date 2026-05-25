---
title: Type useState and useRef for Nullable and Mutable State
impact: MEDIUM
impactDescription: prevents null-unsafe state assignments and ref access
tags: tsx, hooks, usestate, useref
---

## Type useState and useRef for Nullable and Mutable State

`useState` infers from its initial value, which is right when the value is concrete but wrong when state starts empty: `useState(null)` infers the type `null` and rejects every later assignment. Give the explicit union when state will hold more than its initial value. In React 19 `useRef` requires an initial argument, so DOM refs are `useRef<T>(null)`.

**Incorrect (inferred null; ref with no argument):**

```tsx
const [user, setUser] = useState(null)
setUser(fetchedUser) // Error: User is not assignable to null

const inputRef = useRef<HTMLInputElement>() // Error in React 19: expected 1 argument
```

**Correct (explicit union; ref initialized):**

```tsx
const [user, setUser] = useState<User | null>(null)
setUser(fetchedUser) // OK

const inputRef = useRef<HTMLInputElement>(null)
inputRef.current?.focus()
```

Let component return types infer; when you must annotate one, use `React.JSX.Element` — the global `JSX` namespace was removed from `@types/react` 19.

Reference: [React — Using TypeScript: Hooks](https://react.dev/learn/typescript#typing-usestate)
