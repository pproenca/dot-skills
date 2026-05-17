---
title: Wrap Async Submit Handlers in try/catch and Reset on isSubmitSuccessful
impact: HIGH
impactDescription: prevents stuck isSubmitting state and missing post-success reset
tags: formstate, isSubmitting, isSubmitSuccessful, async, submit, reset
---

## Wrap Async Submit Handlers in try/catch and Reset on isSubmitSuccessful

`isSubmitting` is the canonical way to disable the submit button while a request is in flight, but it has a well-known footgun: if your submit handler **throws**, `isSubmitting` stays `true` and the form becomes unrecoverable. Always `try/catch` inside the async handler. Pair this with `isSubmitSuccessful` + `useEffect(reset)` to clear the form after a successful submit (resetting inside the handler races with the success state transition).

**Incorrect (throw leaves isSubmitting stuck; manual reset races):**

```typescript
function CreatePostForm() {
  const { register, handleSubmit, reset, formState: { isSubmitting } } = useForm<PostFormData>()

  const onSubmit = async (data: PostFormData) => {
    const res = await fetch('/api/posts', { method: 'POST', body: JSON.stringify(data) })
    if (!res.ok) throw new Error('Save failed')  // isSubmitting will stay true forever
    reset()  // Races with the form's success state
  }

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('title')} />
      <textarea {...register('body')} />
      <button disabled={isSubmitting}>{isSubmitting ? 'Saving…' : 'Save'}</button>
    </form>
  )
}
```

**Correct (try/catch keeps form recoverable; useEffect resets after success):**

```typescript
function CreatePostForm() {
  const {
    register,
    handleSubmit,
    reset,
    setError,
    formState: { isSubmitting, isSubmitSuccessful, errors },
  } = useForm<PostFormData>()

  const onSubmit = async (data: PostFormData) => {
    try {
      const res = await fetch('/api/posts', { method: 'POST', body: JSON.stringify(data) })
      if (!res.ok) {
        setError('root.serverError', { type: 'server', message: 'Save failed' })
      }
    } catch {
      setError('root.serverError', { type: 'network', message: 'Network error — please retry' })
    }
  }

  // Reset after a successful submit completes — runs once per success transition
  useEffect(() => {
    if (isSubmitSuccessful) reset()
  }, [isSubmitSuccessful, reset])

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      {errors.root?.serverError && <div role="alert">{errors.root.serverError.message}</div>}
      <input {...register('title')} />
      <textarea {...register('body')} />
      <button disabled={isSubmitting}>{isSubmitting ? 'Saving…' : 'Save'}</button>
    </form>
  )
}
```

**Key details:**
- `isSubmitting` resets only when the handler **returns** (resolves). A throw leaves it `true` and the form unrecoverable
- `isSubmitSuccessful` becomes `true` when the handler completes without throwing and without calling `setError`. Use it to gate the post-success reset
- Calling `reset()` inside the submit handler races with React's commit of `isSubmitSuccessful`; the `useEffect` form is the documented pattern
- If you want to preserve specific fields across reset, pass them: `reset(undefined, { keepDirtyValues: true })` or `reset({ defaultValue: lastSaved })`

Reference: [formState](https://react-hook-form.com/docs/useform/formstate) · [reset](https://react-hook-form.com/docs/useform/reset) · [Discussion #10103 — isSubmitting does not recover when submit handler throws](https://github.com/orgs/react-hook-form/discussions/10103)
