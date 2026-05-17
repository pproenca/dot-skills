---
title: Keep Default reValidateMode Unless Validation Is Expensive
impact: MEDIUM
impactDescription: maintains immediate corrective feedback after first submit
tags: formcfg, revalidate-mode, validation, useForm
---

## Keep Default reValidateMode Unless Validation Is Expensive

After the first submit, `reValidateMode` controls when fields re-validate. The default is `onChange`, which gives users immediate positive feedback the moment they fix an error — this is the recommended UX in most cases ("don't eagerly scold, but eagerly reward"). Only switch to `onBlur` or `onSubmit` when validation is genuinely expensive (async checks, large schemas, heavy regex on long inputs).

**Incorrect (switching reValidateMode to onBlur for a cheap synchronous schema):**

```typescript
function CheckoutForm() {
  const { register, handleSubmit } = useForm<CheckoutFormData>({
    mode: 'onSubmit',
    reValidateMode: 'onBlur',  // Hurts UX: user fixes a wrong CVV and gets no feedback until blur
    resolver: zodResolver(cheapSyncSchema),
  })

  return (
    <form onSubmit={handleSubmit(placeOrder)}>
      <input {...register('cardNumber')} />
      <input {...register('cvv')} />
    </form>
  )
}
```

**Correct (default onChange revalidation; switch only when validation is genuinely expensive):**

```typescript
function CheckoutForm() {
  const { register, handleSubmit } = useForm<CheckoutFormData>({
    mode: 'onSubmit',
    // reValidateMode: 'onChange' is the default — leave it for immediate feedback on correction.
    // Switch to 'onBlur' only if you have an async check or >16ms-per-keystroke validation cost.
    resolver: zodResolver(cheapSyncSchema),
  })

  return (
    <form onSubmit={handleSubmit(placeOrder)}>
      <input {...register('cardNumber')} />
      <input {...register('cvv')} />
    </form>
  )
}
```

**When to deviate from the default:**
- Validation involves a network call or expensive computation (>16ms per keystroke)
- The form has dozens of fields and post-submit re-render cost is measurable in profiling
- The error message is purely informational, not correctable in real time

Otherwise keep `onChange` — users who just fixed an error get instant validation success, which is the UX the RHF defaults are tuned for.

Reference: [useForm - reValidateMode](https://react-hook-form.com/docs/useform)
