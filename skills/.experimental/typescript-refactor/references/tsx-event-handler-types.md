---
title: Type Event Handlers with React Synthetic Event Types
impact: MEDIUM-HIGH
impactDescription: types event.target/currentTarget and replaces any
tags: tsx, events, handlers, dom
---

## Type Event Handlers with React Synthetic Event Types

React dispatches its own `SyntheticEvent`, not the DOM `Event`. Typing a handler parameter as `any` (or the wrong DOM event) loses the typed `target`/`currentTarget` and lets typos through. Use the element-parameterized React event types for handlers defined separately; write the handler inline when you want the event type inferred from the JSX attribute.

**Incorrect (any erases the event shape):**

```tsx
function handleChange(event: any) {
  setQuery(event.target.value) // value is any; typos go uncaught
}

return <input onChange={handleChange} />
```

**Correct (parameterized synthetic events; inline handlers infer):**

```tsx
function handleChange(event: React.ChangeEvent<HTMLInputElement>) {
  setQuery(event.target.value) // value: string
}

function handleSubmit(event: React.FormEvent<HTMLFormElement>) {
  event.preventDefault()
}

return (
  <form onSubmit={handleSubmit}>
    <input onChange={handleChange} />
    <button onClick={(event) => console.log(event.currentTarget.name)}>Go</button>
  </form>
)
```

Reference: [React TypeScript Cheatsheet — Forms and Events](https://react-typescript-cheatsheet.netlify.app/docs/basic/getting-started/forms_and_events/)
