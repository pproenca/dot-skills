---
title: Use the Render-Prop Components to Isolate Re-renders Without a Child Component
impact: HIGH
impactDescription: confines a subscription to one subtree without authoring a wrapper component
tags: sub, Watch, FormStateSubscribe, FieldArray, isolation, render-prop
---

## Use the Render-Prop Components to Isolate Re-renders Without a Child Component

Re-render isolation comes from putting the subscription somewhere other than the form component. The usual advice — extract a child component — works but costs a component and a prop-drilled `control` for every watched value. React Hook Form ships render-prop wrappers that do the same thing inline: `<Watch>` wraps `useWatch`, `<FormStateSubscribe>` wraps `useFormState`, and `<FieldArray>` (7.81+) wraps `useFieldArray`. Each is a one-line component that calls the hook and hands the result to `render`, so the subscription lives in that element and only that subtree re-renders.

**Incorrect (hooks in the form component — every keystroke re-renders the whole form):**

```typescript
function InvoiceForm() {
  const { control, register, handleSubmit } = useForm<Invoice>({ defaultValues: emptyInvoice })
  const { fields, append } = useFieldArray({ control, name: 'lineItems' })
  const [quantity, unitPrice] = useWatch({ control, name: ['quantity', 'unitPrice'] })
  const { isDirty, isSubmitting } = useFormState({ control })

  return (
    <form onSubmit={handleSubmit(saveInvoice)}>
      {fields.map((field, index) => (
        <input key={field.id} {...register(`lineItems.${index}.description`)} />
      ))}
      <button type="button" onClick={() => append({ description: '' })}>Add line</button>
      <p>Total: {quantity * unitPrice}</p>
      <button type="submit" disabled={!isDirty || isSubmitting}>Save</button>
    </form>
  )
}
```

**Correct (each subscription confined to its own element):**

```typescript
function InvoiceForm() {
  const { control, register, handleSubmit } = useForm<Invoice>({ defaultValues: emptyInvoice })

  return (
    <form onSubmit={handleSubmit(saveInvoice)}>
      <FieldArray
        control={control}
        name="lineItems"
        render={({ fields, append }) => (
          <>
            {fields.map((field, index) => (
              <input key={field.id} {...register(`lineItems.${index}.description`)} />
            ))}
            <button type="button" onClick={() => append({ description: '' })}>Add line</button>
          </>
        )}
      />
      <Watch
        control={control}
        name={['quantity', 'unitPrice']}
        render={([quantity, unitPrice]) => <p>Total: {quantity * unitPrice}</p>}
      />
      <FormStateSubscribe
        control={control}
        render={({ isDirty, isSubmitting }) => (
          <button type="submit" disabled={!isDirty || isSubmitting}>Save</button>
        )}
      />
    </form>
  )
}
```

**Two traps in the current typings:**
- `<Watch>` accepts both `name` and `names`. `names` is marked `@deprecated` in 7.82 and is renamed away in v8 — write `name`, even though the shipped JSDoc example still shows `names`.
- `FieldArrayProps.render` is typed to return `React.ReactElement`, not `ReactNode[]`. Returning `fields.map(...)` directly fails to typecheck despite appearing that way in the shipped JSDoc — wrap the output in a fragment.

Prefer an extracted child component when the subtree needs its own logic, handlers, or memoization; prefer the render-prop component when it is purely "read this value, render this markup".

Reference: [useWatch](https://react-hook-form.com/docs/usewatch) · [useFieldArray](https://react-hook-form.com/docs/usefieldarray)
