---
title: useFieldArray's disabled Option Makes Every Mutation a Silent No-op
impact: MEDIUM-HIGH
impactDescription: prevents append/remove calls that vanish with no error or warning
tags: array, useFieldArray, disabled, read-only, no-op
---

## useFieldArray's disabled Option Makes Every Mutation a Silent No-op

`useFieldArray({ disabled })` (RHF 7.79+) is not a UI hint. When `disabled` is truthy, `append`, `prepend`, `insert`, `remove`, `swap`, `move`, `update`, and `replace` each return immediately — no mutation, no error, no console warning. Reaching for it as "grey the rows out while saving" produces a form where clicking Add does nothing and there is nothing in the console to explain why.

**Incorrect (`disabled` tied to submit state — the append silently disappears):**

```typescript
function TeamMembersFields({ control }: { control: Control<TeamForm> }) {
  const { isSubmitting } = useFormState({ control })
  const { fields, append, remove } = useFieldArray({
    control,
    name: 'members',
    disabled: isSubmitting,  // Also kills append/remove, not just the visuals
  })

  return (
    <>
      {fields.map((field, index) => (
        <MemberRow key={field.id} index={index} onRemove={() => remove(index)} />
      ))}
      <button type="button" onClick={() => append({ email: '' })}>Add member</button>
    </>
  )
}
```

**Correct (disable the controls; reserve the option for genuinely read-only arrays):**

```typescript
function TeamMembersFields({ control }: { control: Control<TeamForm> }) {
  const { isSubmitting } = useFormState({ control })
  const { fields, append, remove } = useFieldArray({ control, name: 'members' })

  return (
    <>
      {fields.map((field, index) => (
        <MemberRow key={field.id} index={index} onRemove={() => remove(index)} disabled={isSubmitting} />
      ))}
      <button type="button" onClick={() => append({ email: '' })} disabled={isSubmitting}>
        Add member
      </button>
    </>
  )
}
```

Use `disabled: true` when the array is structurally immutable for this user — a locked invoice, a plan the current role may not edit — where a mutation slipping through would be a bug. In that case `fields[index].disabled` (7.80+) carries the flag down to each row so the inputs can render disabled from the same source of truth.

Reference: [useFieldArray](https://react-hook-form.com/docs/usefieldarray)
