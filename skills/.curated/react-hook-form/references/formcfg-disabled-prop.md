---
title: Understand That register's disabled Prop Clears the Value
impact: MEDIUM
impactDescription: prevents lost field values and silently skipped validation
tags: formcfg, register, disabled, validation, footgun
---

## Understand That register's disabled Prop Clears the Value

Passing `disabled: true` to `register` (or to `useController`/`Controller`) makes the field's value become `undefined` in the form state and skips its validation. This is the documented behavior — RHF treats a disabled field as "not part of submission." It is **not** the same as `<input disabled>` for purely visual disabling. If you only want the input greyed out, use the plain HTML attribute. Use `register('name', { disabled: true })` only when you intentionally want the field excluded from submission and validation.

**Incorrect (using register's disabled option for visual disabling — the user's typed value disappears from form state):**

```typescript
function CheckoutForm() {
  const [usingGiftCard, setUsingGiftCard] = useState(false)
  const { register, handleSubmit } = useForm<CheckoutFormData>({
    defaultValues: { promoCode: '', giftCardCode: '' },
  })

  return (
    <form onSubmit={handleSubmit(submitCheckout)}>
      <label>
        <input type="checkbox" onChange={(e) => setUsingGiftCard(e.target.checked)} />
        Use a gift card
      </label>
      <input
        {...register('promoCode', { disabled: usingGiftCard })}
        // When usingGiftCard flips true, promoCode becomes undefined in form state.
        // Validation is skipped, and the user's typed value is gone if they toggle back.
      />
      <input {...register('giftCardCode', { disabled: !usingGiftCard })} />
    </form>
  )
}
```

**Correct (use HTML disabled for visual-only disable; use register's disabled only when intentionally excluding the field):**

```typescript
function CheckoutForm() {
  const [usingGiftCard, setUsingGiftCard] = useState(false)
  const { register, handleSubmit, watch } = useForm<CheckoutFormData & { useShippingForBilling: boolean }>({
    defaultValues: { promoCode: '', giftCardCode: '', useShippingForBilling: true, billingAddress: '' },
  })
  const useShippingForBilling = watch('useShippingForBilling')

  return (
    <form onSubmit={handleSubmit(submitCheckout)}>
      <label>
        <input type="checkbox" onChange={(e) => setUsingGiftCard(e.target.checked)} />
        Use a gift card
      </label>

      {/* Visual disable only: value stays in form state, validation still runs */}
      <input {...register('promoCode')} disabled={usingGiftCard} />
      <input {...register('giftCardCode')} disabled={!usingGiftCard} />

      {/* Intentional exclusion: when checked, billingAddress is omitted from submission */}
      <label>
        <input type="checkbox" {...register('useShippingForBilling')} />
        Billing same as shipping
      </label>
      <input
        {...register('billingAddress', {
          disabled: useShippingForBilling,
          required: !useShippingForBilling,
        })}
      />
    </form>
  )
}
```

**Rule of thumb:**
- Want the field greyed out but still submitted/validated → use the HTML `disabled` attribute directly on the input
- Want the field excluded from submission and validation → use `register('name', { disabled: true })`

Reference: [register - disabled](https://react-hook-form.com/docs/useform/register)
