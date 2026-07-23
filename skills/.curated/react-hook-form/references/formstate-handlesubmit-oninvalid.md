---
title: Use handleSubmit's Second Argument to Handle a Rejected Submit
impact: MEDIUM
impactDescription: gives a failed submit somewhere to go instead of silently doing nothing
tags: formstate, handleSubmit, onInvalid, errors, accessibility
---

## Use handleSubmit's Second Argument to Handle a Rejected Submit

`handleSubmit(onValid, onInvalid)` takes two callbacks. Almost all code passes only the first, so when validation fails the click does nothing observable: no navigation, no request, and — on a long form — an error message somewhere below the fold that the user never scrolls to. They press the button again, harder.

`onInvalid` receives the same `FieldErrors` object as `formState.errors` and is the natural place to move focus to the first bad field, scroll it into view, announce it, or record that submission is failing.

**Incorrect (invalid submit is a no-op from the user's point of view):**

```typescript
function ApplicationForm() {
  const { register, handleSubmit } = useForm<ApplicationValues>({
    defaultValues: emptyApplication,
  })

  return (
    <form onSubmit={handleSubmit(submitApplication)}>
      {/* 40 fields; the invalid one may be far off-screen */}
      <button type="submit">Submit application</button>
    </form>
  )
}
```

**Correct (failed validation moves the user to the problem):**

```typescript
function ApplicationForm() {
  const { register, handleSubmit, setFocus } = useForm<ApplicationValues>({
    defaultValues: emptyApplication,
  })

  const onInvalid = (errors: FieldErrors<ApplicationValues>) => {
    const firstField = Object.keys(errors)[0] as FieldPath<ApplicationValues> | undefined
    if (firstField) setFocus(firstField, { shouldSelect: true })
    trackEvent('application_submit_rejected', { fieldCount: Object.keys(errors).length })
  }

  return (
    <form onSubmit={handleSubmit(submitApplication, onInvalid)}>
      <button type="submit">Submit application</button>
    </form>
  )
}
```

Note the two callbacks are typed differently: `onValid` receives the schema's **output** type (see `formcfg-transformed-values-generic`), while `onInvalid` receives errors keyed on the form's input type.

RHF also focuses the first errored field itself when the field was registered with a ref — `onInvalid` is what you need when the control is custom, virtualized, or on another wizard step, where there is no ref to focus.

Reference: [handleSubmit](https://react-hook-form.com/docs/useform/handlesubmit)
