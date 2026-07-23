---
title: Read Every formState Property You Depend On During Render
impact: MEDIUM
impactDescription: prevents a component that never re-renders when the state it shows changes
tags: formstate, formState, proxy, subscription, conditional
---

## Read Every formState Property You Depend On During Render

`formState` is a Proxy: each property has a getter that marks it subscribed the first time it is read. Subscription is established by the *read*, not by how you write it — `formState.isValid`, `const { isValid } = formState`, and destructuring in the `useForm` call are all equivalent, and all three subscribe to exactly `isValid`. (The common claim that touching the whole object "disables the optimization" is not true; the getters are per-property.)

The real trap is a property that is never read during render. Read it only inside a callback, or only in a branch that doesn't run on the first render, and the getter never fires — so RHF never re-renders the component when that property changes, and the UI silently stops updating.

**Incorrect (isSubmitting is only read inside the handler — the button label never updates):**

```typescript
function SaveButton() {
  const { handleSubmit, formState } = useForm<ArticleDraft>({ defaultValues: emptyDraft })

  const onClick = handleSubmit(async (values) => {
    if (formState.isSubmitting) return  // First read happens in a callback, after render
    await saveDraft(values)
  })

  return <button onClick={onClick}>Save</button>
}
```

**Correct (read it in the render body, so the subscription exists):**

```typescript
function SaveButton() {
  const { handleSubmit, formState: { isSubmitting } } = useForm<ArticleDraft>({ defaultValues: emptyDraft })

  const onClick = handleSubmit(async (values) => {
    await saveDraft(values)
  })

  return (
    <button onClick={onClick} disabled={isSubmitting}>
      {isSubmitting ? 'Saving…' : 'Save'}
    </button>
  )
}
```

The same applies to a conditional read: `{step === 2 && errors.email && …}` does not subscribe to `errors` until `step` reaches 2. Destructuring at the top of the component is the habit that makes this a non-issue, which is the real reason to do it.

Reference: [formState](https://react-hook-form.com/docs/useform/formstate) · [useFormState](https://react-hook-form.com/docs/useformstate)
