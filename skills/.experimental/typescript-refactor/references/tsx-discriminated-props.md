---
title: Model Mutually-Exclusive Props as Discriminated Unions
impact: HIGH
impactDescription: makes impossible prop combinations a compile error
tags: tsx, props, discriminated-unions, state
---

## Model Mutually-Exclusive Props as Discriminated Unions

When a component renders different shapes for different states, all-optional props let callers build impossible combinations (`status="error"` with no `error`, or with stale `data`). A discriminated union on a literal field ties each state to exactly the props it needs, so illegal combinations fail to type-check and narrowing removes non-null assertions.

**Incorrect (all-optional; impossible states compile):**

```tsx
interface UserPanelProps {
  status: "loading" | "error" | "success"
  data?: User
  error?: Error
}

function UserPanel({ status, data }: UserPanelProps) {
  if (status === "success") return <Profile user={data!} /> // data could be undefined
  // <UserPanel status="error" /> compiles with no error object
  return null
}
```

**Correct (each state carries its own props):**

```tsx
type UserPanelProps =
  | { status: "loading" }
  | { status: "error"; error: Error }
  | { status: "success"; data: User }

function UserPanel(props: UserPanelProps) {
  switch (props.status) {
    case "loading": return <Spinner />
    case "error":   return <Alert message={props.error.message} />
    case "success": return <Profile user={props.data} /> // narrowed, no `!`
  }
}
```

The same shape types `useReducer` actions — see [`arch-discriminated-unions`](arch-discriminated-unions.md).

Reference: [React — Using TypeScript: useReducer](https://react.dev/learn/typescript#typing-usereducer)
