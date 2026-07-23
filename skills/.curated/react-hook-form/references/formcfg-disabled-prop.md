---
title: Use the HTML disabled Attribute for Visual Disabling, Not register's disabled Option
impact: MEDIUM
impactDescription: prevents fields silently missing from submission and skipped validation
tags: formcfg, register, disabled, validation, footgun
---

## Use the HTML disabled Attribute for Visual Disabling, Not register's disabled Option

Passing `disabled: true` to `register` (or to `useController`/`Controller`) tells RHF the field is "not part of submission": `handleSubmit` deletes the field from the values object it hands your handler, and validation for that field is skipped. It is **not** the same as `<input disabled>` for purely visual disabling. If you only want the input greyed out, use the plain HTML attribute.

The value itself is **not** destroyed — `handleSubmit` unsets disabled names from a *clone* of the form values, so `getValues('promoCode')` still returns what the user typed and re-enabling the field brings it back into the payload. The bug this causes is a field that quietly vanishes from your submit handler while the UI still shows a value in it.

**Incorrect (using register's disabled option for visual disabling — promoCode silently disappears from the submitted payload):**

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
        // When usingGiftCard flips true, submitCheckout receives no promoCode key at all
        // and its validation is skipped — while the input still shows the typed value.
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

If a value is disappearing from your submit handler, check for this option before suspecting `getValues()` — the two disagree by design.

Reference: [register - disabled](https://react-hook-form.com/docs/useform/register)
