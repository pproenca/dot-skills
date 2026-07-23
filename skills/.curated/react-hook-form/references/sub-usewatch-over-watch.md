---
title: Use useWatch Instead of watch for Isolated Re-renders
impact: CRITICAL
impactDescription: confines value-change re-renders to the subscribing component
tags: sub, useWatch, watch, re-renders, subscription
---

## Use useWatch Instead of watch for Isolated Re-renders

The `watch()` method triggers re-renders at the useForm hook level, affecting the entire form component. Use `useWatch()` in child components to isolate re-renders to only the components that need the watched value.

**Incorrect (watch at root causes entire form to re-render):**

```typescript
function CheckoutForm() {
  const { register, watch, handleSubmit } = useForm()
  const shippingMethod = watch('shippingMethod')  // Every change re-renders entire form

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <select {...register('shippingMethod')}>
        <option value="standard">Standard</option>
        <option value="express">Express</option>
      </select>
      <ShippingCost method={shippingMethod} />
      <input {...register('address')} />
      <input {...register('city')} />
    </form>
  )
}
```

**Correct (useWatch isolates re-render to child component):**

```typescript
function CheckoutForm() {
  const { register, handleSubmit, control } = useForm()

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <select {...register('shippingMethod')}>
        <option value="standard">Standard</option>
        <option value="express">Express</option>
      </select>
      <ShippingCostDisplay control={control} />  {/* Only this re-renders */}
      <input {...register('address')} />
      <input {...register('city')} />
    </form>
  )
}

function ShippingCostDisplay({ control }: { control: Control<CheckoutFormData> }) {
  const shippingMethod = useWatch({ control, name: 'shippingMethod' })
  return <ShippingCost method={shippingMethod} />
}
```

**Push the subscription as deep as it will go.** The win is not `useWatch` over `watch` in itself — it is *where the subscription lives*. A `useWatch` at the top of the form re-renders the whole form exactly like `watch` does. Put it in the leaf that renders the value, and pass `control` down rather than the watched value; the sibling sections then never re-render. If you don't want to author a component for it, `<Watch>` does the same inline — see `sub-render-prop-components`.

Reference: [useWatch](https://react-hook-form.com/docs/usewatch)
