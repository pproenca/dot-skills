---
title: Justify Any mode Other Than the Default onSubmit
impact: CRITICAL
impactDescription: prevents a full validation pass and re-render on every keystroke
tags: formcfg, validation-mode, re-renders, useForm
---

## Justify Any mode Other Than the Default onSubmit

`mode` decides when RHF validates. The default is `'onSubmit'`, and you should have to argue your way off it: `'onChange'` runs the field's validation — the whole resolver schema, if you use one — and re-renders on every keystroke. It gets reached for reflexively because "validate as they type" sounds like better UX, when in practice it means showing someone an "invalid email" error while they are still on the third character.

**Incorrect (onChange chosen by default — errors fire mid-word, every keystroke re-validates):**

```typescript
function RegistrationForm() {
  const { register, handleSubmit, formState: { errors } } = useForm<RegistrationData>({
    mode: 'onChange',
    defaultValues: { email: '' },
  })

  return (
    <form onSubmit={handleSubmit(createAccount)}>
      <input {...register('email', { pattern: { value: /^\S+@\S+$/, message: 'Enter a valid email' } })} />
      {errors.email && <span>{errors.email.message}</span>}
    </form>
  )
}
```

**Correct (leave the default; escalate only where it earns its keep):**

```typescript
function RegistrationForm() {
  const { register, handleSubmit, formState: { errors } } = useForm<RegistrationData>({
    defaultValues: { email: '' },
  })

  return (
    <form onSubmit={handleSubmit(createAccount)}>
      <input {...register('email', { pattern: { value: /^\S+@\S+$/, message: 'Enter a valid email' } })} />
      {errors.email && <span>{errors.email.message}</span>}
    </form>
  )
}
```

`reValidateMode` already defaults to `'onChange'`, so a field that has *failed* validation does give immediate feedback as the user corrects it — which is what people usually think they need `mode: 'onChange'` for.

**Modes worth the escalation:**
- `onTouched` — validate after the first blur, then on change. The usual right answer when submit-time errors feel too late.
- `onBlur` — validate on blur only; quieter than `onTouched` while correcting.
- `onChange` — password-strength meters, "username is available" checks, live-computed totals. Add a comment saying which.
- `all` — `onBlur` and `onChange` together; rarely justified.

Reference: [useForm - mode](https://react-hook-form.com/docs/useform)
