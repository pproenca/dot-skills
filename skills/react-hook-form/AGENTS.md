# React Hook Form

**Version 0.1.0**  
  
January 2026

> **Note:**
> This document is mainly for agents and LLMs to follow when maintaining,
> generating, or refactoring React Hook Form codebases. Humans may also find it useful,
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive performance optimization guide for React Hook Form applications, designed for AI agents and LLMs. Contains 41 rules across 8 categories, prioritized by impact from critical (form configuration, field subscriptions) to incremental (advanced patterns). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated refactoring and code generation.

---

## Table of Contents

1. [Form Configuration](#1-form-configuration) — **CRITICAL**
   - 1.1 [Always Provide defaultValues for Form Initialization](#11-always-provide-defaultvalues-for-form-initialization)
   - 1.2 [Avoid useForm Return Object in useEffect Dependencies](#12-avoid-useform-return-object-in-useeffect-dependencies)
   - 1.3 [Enable shouldUnregister for Dynamic Form Memory Efficiency](#13-enable-shouldunregister-for-dynamic-form-memory-efficiency)
   - 1.4 [Set reValidateMode to onBlur for Post-Submit Performance](#14-set-revalidatemode-to-onblur-for-post-submit-performance)
   - 1.5 [Use Async defaultValues for Server Data](#15-use-async-defaultvalues-for-server-data)
   - 1.6 [Use onSubmit Mode for Optimal Performance](#16-use-onsubmit-mode-for-optimal-performance)
2. [Field Subscription](#2-field-subscription) — **CRITICAL**
   - 2.1 [Avoid Calling watch() in Render for One-Time Reads](#21-avoid-calling-watch-in-render-for-one-time-reads)
   - 2.2 [Combine useWatch with getValues for Timing Safety](#22-combine-usewatch-with-getvalues-for-timing-safety)
   - 2.3 [Provide defaultValue to useWatch for Initial Render](#23-provide-defaultvalue-to-usewatch-for-initial-render)
   - 2.4 [Subscribe Deep in Component Tree Where Data Is Needed](#24-subscribe-deep-in-component-tree-where-data-is-needed)
   - 2.5 [Use useFormContext Sparingly for Deep Nesting](#25-use-useformcontext-sparingly-for-deep-nesting)
   - 2.6 [Use useWatch Instead of watch for Isolated Re-renders](#26-use-usewatch-instead-of-watch-for-isolated-re-renders)
   - 2.7 [Watch Specific Fields Instead of Entire Form](#27-watch-specific-fields-instead-of-entire-form)
3. [Controlled Components](#3-controlled-components) — **HIGH**
   - 3.1 [Avoid Double Registration with useController](#31-avoid-double-registration-with-usecontroller)
   - 3.2 [Combine Local State with useController for UI-Only State](#32-combine-local-state-with-usecontroller-for-ui-only-state)
   - 3.3 [Use Single useController Per Component](#33-use-single-usecontroller-per-component)
   - 3.4 [Use useController for Re-render Isolation in Controlled Components](#34-use-usecontroller-for-re-render-isolation-in-controlled-components)
   - 3.5 [Wire Controller Field Props Correctly for UI Libraries](#35-wire-controller-field-props-correctly-for-ui-libraries)
4. [Validation Patterns](#4-validation-patterns) — **HIGH**
   - 4.1 [Access Errors via Optional Chaining or Lodash Get](#41-access-errors-via-optional-chaining-or-lodash-get)
   - 4.2 [Consider Native Validation for Simple Forms](#42-consider-native-validation-for-simple-forms)
   - 4.3 [Define Schema Outside Component for Resolver Caching](#43-define-schema-outside-component-for-resolver-caching)
   - 4.4 [Prefer Resolver Over Inline Validation for Complex Rules](#44-prefer-resolver-over-inline-validation-for-complex-rules)
   - 4.5 [Use delayError to Debounce Rapid Error Display](#45-use-delayerror-to-debounce-rapid-error-display)
   - 4.6 [Use Schema Factory for Dynamic Validation](#46-use-schema-factory-for-dynamic-validation)
5. [Field Arrays](#5-field-arrays) — **MEDIUM-HIGH**
   - 5.1 [Provide Complete Default Objects for Field Array Operations](#51-provide-complete-default-objects-for-field-array-operations)
   - 5.2 [Separate Sequential Field Array Operations](#52-separate-sequential-field-array-operations)
   - 5.3 [Use field.id as Key in useFieldArray Maps](#53-use-fieldid-as-key-in-usefieldarray-maps)
   - 5.4 [Use FormProvider for Virtualized Field Arrays](#54-use-formprovider-for-virtualized-field-arrays)
   - 5.5 [Use Single useFieldArray Instance Per Field Name](#55-use-single-usefieldarray-instance-per-field-name)
6. [State Management](#6-state-management) — **MEDIUM**
   - 6.1 [Avoid isValid with onSubmit Mode for Button State](#61-avoid-isvalid-with-onsubmit-mode-for-button-state)
   - 6.2 [Destructure formState Properties Before Render](#62-destructure-formstate-properties-before-render)
   - 6.3 [Subscribe to Specific Field Names in useFormState](#63-subscribe-to-specific-field-names-in-useformstate)
   - 6.4 [Use getFieldState for Single Field State Access](#64-use-getfieldstate-for-single-field-state-access)
   - 6.5 [Use useFormState for Isolated State Subscriptions](#65-use-useformstate-for-isolated-state-subscriptions)
7. [Integration Patterns](#7-integration-patterns) — **MEDIUM**
   - 7.1 [Transform Values at Controller Level for Type Coercion](#71-transform-values-at-controller-level-for-type-coercion)
   - 7.2 [Use Controller for Material-UI Components](#72-use-controller-for-material-ui-components)
   - 7.3 [Verify shadcn Form Component Import Source](#73-verify-shadcn-form-component-import-source)
   - 7.4 [Wire shadcn Select with onValueChange Instead of Spread](#74-wire-shadcn-select-with-onvaluechange-instead-of-spread)
8. [Advanced Patterns](#8-advanced-patterns) — **LOW**
   - 8.1 [Create Test Wrapper with QueryClient and AuthProvider](#81-create-test-wrapper-with-queryclient-and-authprovider)
   - 8.2 [Disable DevTools in Production and During Performance Testing](#82-disable-devtools-in-production-and-during-performance-testing)
   - 8.3 [Wrap FormProvider Children with React.memo](#83-wrap-formprovider-children-with-reactmemo)

---

## 1. Form Configuration

**Impact: CRITICAL**

Initial useForm setup determines validation timing, re-render boundaries, and default value caching. Incorrect mode selection causes re-renders on every keystroke.

### 1.1 Always Provide defaultValues for Form Initialization

**Impact: CRITICAL (prevents undefined state bugs and enables reset() functionality)**

Omitting `defaultValues` causes undefined state conflicts with controlled components and breaks `reset()` functionality. Always provide explicit defaults, using empty strings instead of undefined.

**Incorrect (no defaultValues, breaks reset and controlled components):**

```typescript
const { register, reset, handleSubmit } = useForm()

function ProfileForm({ user }: { user: User }) {
  useEffect(() => {
    reset(user)  // reset() won't restore to "initial" state without defaultValues
  }, [user, reset])

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('firstName')} />  {/* undefined initial value */}
      <input {...register('lastName')} />
    </form>
  )
}
```

**Correct (explicit defaultValues enable proper reset):**

```typescript
const { register, reset, handleSubmit } = useForm({
  defaultValues: {
    firstName: '',
    lastName: '',
  },
})

function ProfileForm({ user }: { user: User }) {
  useEffect(() => {
    reset(user)  // reset() properly restores to defaultValues when called without args
  }, [user, reset])

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('firstName')} />
      <input {...register('lastName')} />
    </form>
  )
}
```

**Note:** Avoid using custom objects with prototype methods (Moment, Luxon) as defaultValues. Use plain objects or primitives.

Reference: [useForm - defaultValues](https://react-hook-form.com/docs/useform)

### 1.2 Avoid useForm Return Object in useEffect Dependencies

**Impact: CRITICAL (prevents infinite render loops)**

Adding the entire useForm return object to a useEffect dependency array causes infinite loops. Destructure only the specific methods you need.

**Incorrect (entire form object causes infinite loop):**

```typescript
function ContactForm({ defaultEmail }: { defaultEmail: string }) {
  const form = useForm({
    defaultValues: { email: '' },
  })

  useEffect(() => {
    form.reset({ email: defaultEmail })
  }, [form, defaultEmail])  // form reference changes on every render = infinite loop

  return (
    <form onSubmit={form.handleSubmit(onSubmit)}>
      <input {...form.register('email')} />
    </form>
  )
}
```

**Correct (destructure specific stable methods):**

```typescript
function ContactForm({ defaultEmail }: { defaultEmail: string }) {
  const { register, handleSubmit, reset } = useForm({
    defaultValues: { email: '' },
  })

  useEffect(() => {
    reset({ email: defaultEmail })
  }, [reset, defaultEmail])  // reset is stable, no infinite loop

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('email')} />
    </form>
  )
}
```

**Note:** In a future major release, useForm return will be memoized. Until then, always destructure.

Reference: [useForm](https://react-hook-form.com/docs/useform)

### 1.3 Enable shouldUnregister for Dynamic Form Memory Efficiency

**Impact: HIGH (reduces memory usage for forms with frequently mounted/unmounted fields)**

By default, unmounted fields retain their values and validation state. For forms with frequently added/removed fields, enable `shouldUnregister` to automatically clean up unmounted fields.

**Incorrect (unmounted fields persist in memory):**

```typescript
const { register, handleSubmit } = useForm({
  shouldUnregister: false,  // Default: unmounted fields stay in form state
})

function MultiStepForm() {
  const [step, setStep] = useState(1)

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      {step === 1 && (
        <input {...register('personalInfo.name')} />
      )}
      {step === 2 && (
        <input {...register('companyInfo.company')} />  {/* Step 1 fields still in memory */}
      )}
    </form>
  )
}
```

**Correct (unmounted fields cleaned up automatically):**

```typescript
const { register, handleSubmit } = useForm({
  shouldUnregister: true,  // Unmounted fields removed from form state
})

function MultiStepForm() {
  const [step, setStep] = useState(1)

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      {step === 1 && (
        <input {...register('personalInfo.name')} />
      )}
      {step === 2 && (
        <input {...register('companyInfo.company')} />  {/* Step 1 fields cleaned up */}
      )}
    </form>
  )
}
```

**When NOT to use:**
- Multi-step wizards where you need to preserve values across steps
- Conditional fields that should retain values when hidden

Reference: [useForm - shouldUnregister](https://react-hook-form.com/docs/useform)

### 1.4 Set reValidateMode to onBlur for Post-Submit Performance

**Impact: CRITICAL (reduces re-renders after initial submission by 80%+)**

After form submission, `reValidateMode` controls when fields re-validate. The default `onChange` causes validation on every keystroke after first submit. Use `onBlur` or `onSubmit` for better post-submission performance.

**Incorrect (re-validates on every keystroke after submit):**

```typescript
const { register, handleSubmit } = useForm({
  mode: 'onSubmit',
  reValidateMode: 'onChange',  // Default: after first submit, validates on EVERY keystroke
})

function PaymentForm() {
  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('cardNumber', { required: true })} />
      <input {...register('cvv', { required: true, maxLength: 4 })} />
    </form>
  )
}
```

**Correct (re-validates only when leaving field):**

```typescript
const { register, handleSubmit } = useForm({
  mode: 'onSubmit',
  reValidateMode: 'onBlur',  // After first submit, validates only on blur
})

function PaymentForm() {
  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('cardNumber', { required: true })} />
      <input {...register('cvv', { required: true, maxLength: 4 })} />
    </form>
  )
}
```

Reference: [useForm - reValidateMode](https://react-hook-form.com/docs/useform)

### 1.5 Use Async defaultValues for Server Data

**Impact: CRITICAL (eliminates manual useEffect reset patterns)**

React Hook Form supports async functions for `defaultValues`, eliminating the need for manual useEffect + reset() patterns when loading initial data from an API.

**Incorrect (manual useEffect reset pattern):**

```typescript
function EditUserForm({ userId }: { userId: string }) {
  const { register, reset, handleSubmit, formState: { isLoading } } = useForm({
    defaultValues: {
      email: '',
      name: '',
    },
  })

  useEffect(() => {
    async function loadUser() {
      const user = await fetchUser(userId)
      reset(user)  // Manual reset required
    }
    loadUser()
  }, [userId, reset])

  if (isLoading) return <Spinner />

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('email')} />
      <input {...register('name')} />
    </form>
  )
}
```

**Correct (async defaultValues handles loading automatically):**

```typescript
function EditUserForm({ userId }: { userId: string }) {
  const { register, handleSubmit, formState: { isLoading } } = useForm({
    defaultValues: async () => {
      const user = await fetchUser(userId)
      return {
        email: user.email,
        name: user.name,
      }
    },
  })

  if (isLoading) return <Spinner />

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('email')} />
      <input {...register('name')} />
    </form>
  )
}
```

**Note:** defaultValues are cached after initial load. Use `reset()` with new values if you need to refresh data.

Reference: [useForm - defaultValues](https://react-hook-form.com/docs/useform)

### 1.6 Use onSubmit Mode for Optimal Performance

**Impact: CRITICAL (prevents re-renders on every keystroke)**

The `mode` option in useForm determines when validation runs. Using `onChange` mode triggers validation on every keystroke, causing significant re-renders. Default to `onSubmit` unless real-time feedback is essential.

**Incorrect (validates on every keystroke):**

```typescript
const { register, handleSubmit, formState: { errors } } = useForm({
  mode: 'onChange',  // Triggers validation + re-render on EVERY input change
})

function RegistrationForm() {
  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('email', { required: true, pattern: /^\S+@\S+$/i })} />
      {errors.email && <span>{errors.email.message}</span>}
    </form>
  )
}
```

**Correct (validates only on submit):**

```typescript
const { register, handleSubmit, formState: { errors } } = useForm({
  mode: 'onSubmit',  // Default: validates only when form is submitted
})

function RegistrationForm() {
  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('email', { required: true, pattern: /^\S+@\S+$/i })} />
      {errors.email && <span>{errors.email.message}</span>}
    </form>
  )
}
```

**When to use other modes:**
- `onBlur`: Validate when user leaves a field (good balance of UX and performance)
- `onTouched`: Like `onBlur` but only after first interaction
- `onChange`: Only when real-time validation feedback is critical (use sparingly)

Reference: [useForm - mode](https://react-hook-form.com/docs/useform)

---

## 2. Field Subscription

**Impact: CRITICAL**

Isolating field subscriptions prevents cascade re-renders across the form tree. Using watch() at root vs useWatch() in children is the #1 performance differentiator.

### 2.1 Avoid Calling watch() in Render for One-Time Reads

**Impact: HIGH (prevents unnecessary subscriptions and re-renders)**

If you only need to read a value once (not subscribe to changes), use `getValues()` instead of `watch()`. Calling watch() creates a subscription that triggers re-renders on every change.

**Incorrect (watch creates subscription for one-time read):**

```typescript
function SubmitButton() {
  const { watch, handleSubmit, formState: { isValid } } = useForm()

  const handleClick = () => {
    const email = watch('email')  // Creates subscription, but we only need current value
    analytics.track('form_submit_attempt', { email })
    handleSubmit(onSubmit)()
  }

  return <button onClick={handleClick} disabled={!isValid}>Submit</button>
}
```

**Correct (getValues for one-time read):**

```typescript
function SubmitButton() {
  const { getValues, handleSubmit, formState: { isValid } } = useForm()

  const handleClick = () => {
    const email = getValues('email')  // No subscription, just current value
    analytics.track('form_submit_attempt', { email })
    handleSubmit(onSubmit)()
  }

  return <button onClick={handleClick} disabled={!isValid}>Submit</button>
}
```

**When to use each:**
- `watch()`: Need to react to value changes (display, conditional rendering)
- `getValues()`: Need current value at a point in time (event handlers, submit)

Reference: [useForm - getValues](https://react-hook-form.com/docs/useform/getvalues)

### 2.2 Combine useWatch with getValues for Timing Safety

**Impact: HIGH (prevents missed updates due to subscription timing)**

If `setValue()` is called before useWatch establishes its subscription, the update is missed. Combine useWatch with getValues to guarantee no updates are lost.

**Incorrect (setValue before subscription misses update):**

```typescript
function PrefillableForm() {
  const { setValue, control } = useForm()
  const couponCode = useWatch({ control, name: 'couponCode' })

  useEffect(() => {
    const savedCoupon = localStorage.getItem('savedCoupon')
    if (savedCoupon) {
      setValue('couponCode', savedCoupon)  // May fire before useWatch subscription
    }
  }, [setValue])

  return <div>Applied coupon: {couponCode}</div>  {/* May show stale value */}
}
```

**Correct (merge subscription with current values):**

```typescript
function PrefillableForm() {
  const { setValue, control, getValues } = useForm()

  const useFormValues = () => ({
    ...useWatch({ control }),
    ...getValues(),  // Fallback ensures no missed values
  })

  const { couponCode } = useFormValues()

  useEffect(() => {
    const savedCoupon = localStorage.getItem('savedCoupon')
    if (savedCoupon) {
      setValue('couponCode', savedCoupon)
    }
  }, [setValue])

  return <div>Applied coupon: {couponCode}</div>  {/* Always shows current value */}
}
```

Reference: [useWatch](https://react-hook-form.com/docs/usewatch)

### 2.3 Provide defaultValue to useWatch for Initial Render

**Impact: MEDIUM-HIGH (prevents undefined flash on initial render)**

useWatch returns undefined on the first render before the subscription is established. Provide a defaultValue to prevent undefined checks and potential UI flicker.

**Incorrect (undefined on first render):**

```typescript
function PriceDisplay({ control }: { control: Control<OrderForm> }) {
  const quantity = useWatch({ control, name: 'quantity' })

  return (
    <div>
      {quantity !== undefined ? (  // Undefined check required
        <span>Quantity: {quantity}</span>
      ) : (
        <span>Loading...</span>  // Flash of loading state
      )}
    </div>
  )
}
```

**Correct (defaultValue prevents undefined):**

```typescript
function PriceDisplay({ control }: { control: Control<OrderForm> }) {
  const quantity = useWatch({
    control,
    name: 'quantity',
    defaultValue: 1,  // Immediate value, no undefined check needed
  })

  return (
    <div>
      <span>Quantity: {quantity}</span>
    </div>
  )
}
```

**Note:** defaultValue should match the type expected by your form schema to maintain type safety.

Reference: [useWatch](https://react-hook-form.com/docs/usewatch)

### 2.4 Subscribe Deep in Component Tree Where Data Is Needed

**Impact: CRITICAL (prevents parent re-renders from propagating to unrelated children)**

Subscribe to form values as deep in the component tree as possible, where the data is actually used. This isolates re-renders to the specific component that needs the value.

**Incorrect (subscription at parent re-renders all children):**

```typescript
function CheckoutPage() {
  const { control, register, handleSubmit } = useForm()
  const paymentMethod = useWatch({ control, name: 'paymentMethod' })  // Parent subscribes

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <ShippingSection register={register} />  {/* Re-renders on paymentMethod change */}
      <BillingSection register={register} />  {/* Re-renders on paymentMethod change */}
      <PaymentSection
        register={register}
        paymentMethod={paymentMethod}  {/* Prop drilling */}
      />
    </form>
  )
}
```

**Correct (subscription at leaf component isolates re-renders):**

```typescript
function CheckoutPage() {
  const { control, register, handleSubmit } = useForm()

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <ShippingSection register={register} />  {/* Never re-renders for payment */}
      <BillingSection register={register} />  {/* Never re-renders for payment */}
      <PaymentSection register={register} control={control} />
    </form>
  )
}

function PaymentSection({ register, control }: PaymentSectionProps) {
  const paymentMethod = useWatch({ control, name: 'paymentMethod' })  // Only this re-renders

  return (
    <div>
      <select {...register('paymentMethod')}>
        <option value="card">Credit Card</option>
        <option value="paypal">PayPal</option>
      </select>
      {paymentMethod === 'card' && <CardFields register={register} />}
    </div>
  )
}
```

Reference: [useWatch](https://react-hook-form.com/docs/usewatch)

### 2.5 Use useFormContext Sparingly for Deep Nesting

**Impact: MEDIUM (reduces prop drilling but increases implicit dependencies)**

useFormContext eliminates prop drilling by accessing form methods via context, but creates implicit dependencies that are harder to track. Use it for deeply nested components; prefer explicit props for shallow nesting.

**Incorrect (useFormContext for shallow nesting):**

```typescript
function ContactForm() {
  const methods = useForm()

  return (
    <FormProvider {...methods}>
      <form onSubmit={methods.handleSubmit(onSubmit)}>
        <NameInput />  {/* One level deep, context overhead not needed */}
        <EmailInput />
      </form>
    </FormProvider>
  )
}

function NameInput() {
  const { register } = useFormContext()  // Implicit dependency
  return <input {...register('name')} />
}
```

**Correct (explicit props for shallow nesting):**

```typescript
function ContactForm() {
  const { register, handleSubmit } = useForm()

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <NameInput register={register} />  {/* Explicit dependency */}
      <EmailInput register={register} />
    </form>
  )
}

function NameInput({ register }: { register: UseFormRegister<ContactFormData> }) {
  return <input {...register('name')} />
}
```

**When to use useFormContext:**
- Components nested 3+ levels deep
- Shared components used across multiple forms
- Complex form sections with many fields

Reference: [useFormContext](https://react-hook-form.com/docs/useformcontext)

### 2.6 Use useWatch Instead of watch for Isolated Re-renders

**Impact: CRITICAL (reduces re-renders by 10-50× in complex forms with multiple watchers)**

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

Reference: [useWatch](https://react-hook-form.com/docs/usewatch)

### 2.7 Watch Specific Fields Instead of Entire Form

**Impact: CRITICAL (reduces re-renders from N fields to 1 field change)**

Calling `watch()` without arguments subscribes to ALL form fields, causing re-renders on any field change. Always specify the field names you need.

**Incorrect (watches all fields, re-renders on any change):**

```typescript
function OrderForm() {
  const { register, watch, handleSubmit } = useForm()
  const formValues = watch()  // Re-renders when ANY field changes

  const total = calculateTotal(formValues.quantity, formValues.price)

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('customerName')} />  {/* Changes here trigger total recalc */}
      <input {...register('email')} />  {/* Changes here trigger total recalc */}
      <input {...register('quantity', { valueAsNumber: true })} />
      <input {...register('price', { valueAsNumber: true })} />
      <div>Total: ${total}</div>
    </form>
  )
}
```

**Correct (watches only needed fields):**

```typescript
function OrderForm() {
  const { register, watch, handleSubmit } = useForm()
  const [quantity, price] = watch(['quantity', 'price'])  // Only re-renders when these change

  const total = calculateTotal(quantity, price)

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('customerName')} />  {/* No re-render on change */}
      <input {...register('email')} />  {/* No re-render on change */}
      <input {...register('quantity', { valueAsNumber: true })} />
      <input {...register('price', { valueAsNumber: true })} />
      <div>Total: ${total}</div>
    </form>
  )
}
```

Reference: [useForm - watch](https://react-hook-form.com/docs/useform/watch)

---

## 3. Controlled Components

**Impact: HIGH**

Proper Controller/useController usage isolates re-renders to individual fields. Incorrect patterns cause N×M re-renders with controlled UI libraries.

### 3.1 Avoid Double Registration with useController

**Impact: HIGH (prevents duplicate state management and validation bugs)**

useController handles field registration automatically. Calling `register()` on a field already managed by useController creates duplicate state tracking and validation conflicts.

**Incorrect (double registration causes state conflicts):**

```typescript
function CustomInput({ control, name }: CustomInputProps) {
  const { register } = useFormContext()
  const { field, fieldState } = useController({ name, control })

  return (
    <div>
      <input
        {...field}
        {...register(name)}  // Double registration!
      />
      {fieldState.error && <span>{fieldState.error.message}</span>}
    </div>
  )
}
```

**Correct (useController handles registration):**

```typescript
function CustomInput({ control, name }: CustomInputProps) {
  const { field, fieldState } = useController({ name, control })

  return (
    <div>
      <input {...field} />  {/* useController provides all needed props */}
      {fieldState.error && <span>{fieldState.error.message}</span>}
    </div>
  )
}
```

Reference: [useController](https://react-hook-form.com/docs/usecontroller)

### 3.2 Combine Local State with useController for UI-Only State

**Impact: MEDIUM (reduces form re-renders by 50%+ when UI state changes don't affect form data)**

It's valid to combine useController with local useState for UI-only state (like dropdown open/closed, formatting preview). Keep form data in useController and UI state separate.

**Incorrect (mixing UI state into form state):**

```typescript
function PhoneInput({ control }: { control: Control<FormData> }) {
  const { field } = useController({
    name: 'phone',
    control,
    defaultValue: { number: '', showFormatted: false },  // UI state in form
  })

  return (
    <div>
      <input
        value={field.value.number}
        onChange={(e) => field.onChange({ ...field.value, number: e.target.value })}
      />
      <label>
        <input
          type="checkbox"
          checked={field.value.showFormatted}  // UI state pollutes form data
          onChange={(e) => field.onChange({ ...field.value, showFormatted: e.target.checked })}
        />
        Show formatted
      </label>
    </div>
  )
}
```

**Correct (separate UI state from form state):**

```typescript
function PhoneInput({ control }: { control: Control<FormData> }) {
  const { field } = useController({ name: 'phone', control })
  const [showFormatted, setShowFormatted] = useState(false)  // UI-only state

  const displayValue = showFormatted ? formatPhone(field.value) : field.value

  return (
    <div>
      <input
        value={displayValue}
        onChange={(e) => field.onChange(e.target.value)}  // Only phone number in form
      />
      <label>
        <input
          type="checkbox"
          checked={showFormatted}
          onChange={(e) => setShowFormatted(e.target.checked)}  // Local state only
        />
        Show formatted
      </label>
    </div>
  )
}
```

Reference: [useController](https://react-hook-form.com/docs/usecontroller)

### 3.3 Use Single useController Per Component

**Impact: MEDIUM-HIGH (prevents prop name collisions and simplifies component logic)**

Each component should use at most one useController. Multiple useControllers in a single component cause prop name collisions and complex state management. Split into separate components instead.

**Incorrect (multiple useControllers cause collisions):**

```typescript
function DateRangeInput({ control }: { control: Control<FormData> }) {
  const startField = useController({ name: 'startDate', control })
  const endField = useController({ name: 'endDate', control })  // Prop names collide

  return (
    <div>
      <DatePicker
        value={startField.field.value}
        onChange={startField.field.onChange}
        error={startField.fieldState.error?.message}
      />
      <DatePicker
        value={endField.field.value}
        onChange={endField.field.onChange}
        error={endField.fieldState.error?.message}
      />
    </div>
  )
}
```

**Correct (separate components for each controlled field):**

```typescript
function DateRangeInput({ control }: { control: Control<FormData> }) {
  return (
    <div>
      <DateInput control={control} name="startDate" label="Start Date" />
      <DateInput control={control} name="endDate" label="End Date" />
    </div>
  )
}

function DateInput({ control, name, label }: DateInputProps) {
  const { field, fieldState } = useController({ name, control })

  return (
    <DatePicker
      label={label}
      value={field.value}
      onChange={field.onChange}
      error={fieldState.error?.message}
    />
  )
}
```

Reference: [useController](https://react-hook-form.com/docs/usecontroller)

### 3.4 Use useController for Re-render Isolation in Controlled Components

**Impact: HIGH (reduces re-renders from O(n) to O(1) per field change)**

useController creates a controlled input that only re-renders when its specific field value changes. This is essential for integrating with UI libraries like MUI, Ant Design, or custom components.

**Incorrect (inline Controller causes parent re-renders):**

```typescript
function PaymentForm() {
  const { control, handleSubmit } = useForm()

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <Controller
        name="amount"
        control={control}
        render={({ field }) => (
          <CurrencyInput {...field} />  // Parent re-renders affect this
        )}
      />
      <Controller
        name="currency"
        control={control}
        render={({ field }) => (
          <CurrencySelect {...field} />
        )}
      />
    </form>
  )
}
```

**Correct (useController in dedicated component isolates re-renders):**

```typescript
function PaymentForm() {
  const { control, handleSubmit } = useForm()

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <AmountInput control={control} />  {/* Only re-renders on amount change */}
      <CurrencySelectField control={control} />  {/* Only re-renders on currency change */}
    </form>
  )
}

function AmountInput({ control }: { control: Control<PaymentFormData> }) {
  const { field } = useController({ name: 'amount', control })
  return <CurrencyInput {...field} />
}

function CurrencySelectField({ control }: { control: Control<PaymentFormData> }) {
  const { field } = useController({ name: 'currency', control })
  return <CurrencySelect {...field} />
}
```

Reference: [useController](https://react-hook-form.com/docs/usecontroller)

### 3.5 Wire Controller Field Props Correctly for UI Libraries

**Impact: HIGH (prevents form binding bugs and eliminates silent failures in 100% of UI library integrations)**

Different UI libraries expect different prop names. Map Controller's field props correctly: `onChange` sends data back, `onBlur` reports interaction, `value` sets the display, `ref` enables focus on error.

**Incorrect (spreading field on incompatible component):**

```typescript
function FormWithSelect({ control }: { control: Control<FormData> }) {
  return (
    <Controller
      name="country"
      control={control}
      render={({ field }) => (
        <Select {...field} />  // Select may not accept all field props directly
      )}
    />
  )
}
```

**Correct (manually wire required props):**

```typescript
function FormWithSelect({ control }: { control: Control<FormData> }) {
  return (
    <Controller
      name="country"
      control={control}
      render={({ field }) => (
        <Select
          value={field.value}
          onValueChange={field.onChange}  // Map to component's change handler
          onBlur={field.onBlur}
        >
          <SelectItem value="us">United States</SelectItem>
          <SelectItem value="uk">United Kingdom</SelectItem>
        </Select>
      )}
    />
  )
}
```

**Common mappings by library:**
- MUI Select: `value`, `onChange` (receives event)
- Radix/shadcn Select: `value`, `onValueChange` (receives value directly)
- React Select: `value`, `onChange` (receives option object)

Reference: [useController](https://react-hook-form.com/docs/usecontroller)

---

## 4. Validation Patterns

**Impact: HIGH**

Schema resolver caching, validation mode selection, and error handling patterns affect validation cost per keystroke.

### 4.1 Access Errors via Optional Chaining or Lodash Get

**Impact: MEDIUM-HIGH (prevents runtime errors from undefined nested properties)**

Error objects can have deeply nested paths for nested fields. Use optional chaining or lodash `get()` to safely access error messages without runtime errors.

**Incorrect (direct access throws on undefined):**

```typescript
function AddressForm() {
  const { register, formState: { errors } } = useForm()

  return (
    <form>
      <input {...register('address.street', { required: true })} />
      <span>{errors.address.street.message}</span>  {/* Throws if address undefined */}

      <input {...register('address.city', { required: true })} />
      <span>{errors.address.city.message}</span>  {/* Throws if address undefined */}
    </form>
  )
}
```

**Correct (optional chaining for safe access):**

```typescript
function AddressForm() {
  const { register, formState: { errors } } = useForm()

  return (
    <form>
      <input {...register('address.street', { required: true })} />
      <span>{errors.address?.street?.message}</span>  {/* Safe access */}

      <input {...register('address.city', { required: true })} />
      <span>{errors.address?.city?.message}</span>  {/* Safe access */}
    </form>
  )
}
```

**Alternative (lodash get for complex paths):**

```typescript
import { get } from 'lodash'

function AddressForm() {
  const { register, formState: { errors } } = useForm()

  return (
    <form>
      <input {...register('address.street', { required: true })} />
      <span>{get(errors, 'address.street.message')}</span>
    </form>
  )
}
```

Reference: [React Hook Form - Advanced Usage](https://react-hook-form.com/advanced-usage)

### 4.2 Consider Native Validation for Simple Forms

**Impact: MEDIUM (reduces JavaScript validation overhead for basic constraints)**

For simple forms with basic constraints (required, minLength, pattern), browser-native validation eliminates JavaScript validation overhead. Enable with `shouldUseNativeValidation`.

**Incorrect (JavaScript validates simple constraints):**

```typescript
function NewsletterForm() {
  const { register, handleSubmit, formState: { errors } } = useForm()

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input
        {...register('email', {
          required: 'Email required',
          pattern: { value: /^\S+@\S+$/i, message: 'Invalid email' },
        })}
        type="email"
      />
      {errors.email && <span>{errors.email.message}</span>}
      <button type="submit">Subscribe</button>
    </form>
  )
}
```

**Correct (browser handles validation natively):**

```typescript
function NewsletterForm() {
  const { register, handleSubmit } = useForm({
    shouldUseNativeValidation: true,
  })

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input
        {...register('email', { required: true })}
        type="email"  // Browser validates email format
        required  // Browser shows native required message
      />
      <button type="submit">Subscribe</button>
    </form>
  )
}
```

**When NOT to use:**
- Custom error message styling required
- Complex cross-field validation
- Need consistent UX across browsers

Reference: [useForm - shouldUseNativeValidation](https://react-hook-form.com/docs/useform)

### 4.3 Define Schema Outside Component for Resolver Caching

**Impact: HIGH (prevents schema recreation on every render)**

Define validation schemas outside the component to enable resolver caching. Schemas defined inside components are recreated on every render, bypassing optimization.

**Incorrect (schema recreated on every render):**

```typescript
function RegistrationForm() {
  const schema = z.object({  // Created fresh on every render
    email: z.string().email(),
    password: z.string().min(8),
  })

  const { register, handleSubmit } = useForm({
    resolver: zodResolver(schema),  // New resolver instance each render
  })

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('email')} />
      <input {...register('password')} type="password" />
    </form>
  )
}
```

**Correct (schema defined once, resolver cached):**

```typescript
const registrationSchema = z.object({  // Created once at module load
  email: z.string().email(),
  password: z.string().min(8),
})

type RegistrationFormData = z.infer<typeof registrationSchema>

function RegistrationForm() {
  const { register, handleSubmit } = useForm<RegistrationFormData>({
    resolver: zodResolver(registrationSchema),  // Stable resolver reference
  })

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('email')} />
      <input {...register('password')} type="password" />
    </form>
  )
}
```

Reference: [React Hook Form Resolvers](https://github.com/react-hook-form/resolvers)

### 4.4 Prefer Resolver Over Inline Validation for Complex Rules

**Impact: HIGH (centralizes validation logic and enables type inference)**

Inline validation rules in `register()` are convenient for simple cases, but resolvers (Zod, Yup) provide better type safety, centralized logic, and cross-field validation capabilities.

**Incorrect (complex inline validation scattered across inputs):**

```typescript
function CheckoutForm() {
  const { register, handleSubmit, watch } = useForm()
  const billingAddressSame = watch('billingAddressSame')

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('email', {
        required: 'Email required',
        pattern: { value: /^\S+@\S+$/i, message: 'Invalid email' },
      })} />
      <input {...register('billingAddressSame')} type="checkbox" />
      <input {...register('billingStreet', {
        required: !billingAddressSame && 'Street required',  // Cross-field logic inline
      })} />
    </form>
  )
}
```

**Correct (resolver centralizes all validation):**

```typescript
const checkoutSchema = z.object({
  email: z.string().email('Invalid email'),
  billingAddressSame: z.boolean(),
  billingStreet: z.string().optional(),
}).refine(
  (data) => data.billingAddressSame || data.billingStreet,
  { message: 'Street required', path: ['billingStreet'] }
)

type CheckoutFormData = z.infer<typeof checkoutSchema>

function CheckoutForm() {
  const { register, handleSubmit } = useForm<CheckoutFormData>({
    resolver: zodResolver(checkoutSchema),
  })

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('email')} />
      <input {...register('billingAddressSame')} type="checkbox" />
      <input {...register('billingStreet')} />
    </form>
  )
}
```

Reference: [React Hook Form Resolvers](https://github.com/react-hook-form/resolvers)

### 4.5 Use delayError to Debounce Rapid Error Display

**Impact: MEDIUM (reduces UI flicker during fast typing validation)**

When using `onChange` mode, errors appear and disappear rapidly as users type. Use `delayError` to add a small delay, preventing UI flicker while still providing timely feedback.

**Incorrect (errors flash rapidly during typing):**

```typescript
function SearchForm() {
  const { register, formState: { errors } } = useForm({
    mode: 'onChange',
  })

  return (
    <form>
      <input {...register('query', { minLength: 3 })} />
      {errors.query && <span>Min 3 characters</span>}  {/* Flashes on/off rapidly */}
    </form>
  )
}
```

**Correct (error display debounced):**

```typescript
function SearchForm() {
  const { register, formState: { errors } } = useForm({
    mode: 'onChange',
    delayError: 300,  // 300ms delay before showing errors
  })

  return (
    <form>
      <input {...register('query', { minLength: 3 })} />
      {errors.query && <span>Min 3 characters</span>}  {/* Appears after 300ms delay */}
    </form>
  )
}
```

**When to use:**
- Real-time validation with `onChange` mode
- Fields with character count requirements
- Search inputs with minimum length

Reference: [useForm - delayError](https://react-hook-form.com/docs/useform)

### 4.6 Use Schema Factory for Dynamic Validation

**Impact: HIGH (enables context-dependent validation without render-time schema creation)**

When validation rules depend on runtime context (user role, feature flags), use a factory function to create schemas. This keeps schema creation outside the render cycle while allowing dynamic rules.

**Incorrect (schema recreated in component based on props):**

```typescript
function OrderForm({ maxQuantity }: { maxQuantity: number }) {
  const { register, handleSubmit } = useForm({
    resolver: zodResolver(
      z.object({
        quantity: z.number().max(maxQuantity),  // Recreated when maxQuantity changes
        notes: z.string().optional(),
      })
    ),
  })

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('quantity', { valueAsNumber: true })} />
    </form>
  )
}
```

**Correct (factory function creates schema outside render):**

```typescript
const createOrderSchema = (maxQuantity: number) =>
  z.object({
    quantity: z.number().max(maxQuantity, `Maximum ${maxQuantity} items`),
    notes: z.string().optional(),
  })

function OrderForm({ maxQuantity }: { maxQuantity: number }) {
  const schema = useMemo(() => createOrderSchema(maxQuantity), [maxQuantity])

  const { register, handleSubmit } = useForm({
    resolver: zodResolver(schema),
  })

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('quantity', { valueAsNumber: true })} />
    </form>
  )
}
```

Reference: [React Hook Form Resolvers](https://github.com/react-hook-form/resolvers)

---

## 5. Field Arrays

**Impact: MEDIUM-HIGH**

Dynamic field management requires proper key handling and state isolation to prevent stale data and excess re-renders during CRUD operations.

### 5.1 Provide Complete Default Objects for Field Array Operations

**Impact: HIGH (prevents partial data and validation failures)**

When using `append()`, `prepend()`, `insert()`, or `update()`, always provide complete field objects with all required properties. Empty or partial objects cause validation and data inconsistencies.

**Incorrect (empty object causes undefined fields):**

```typescript
function TasksForm() {
  const { control, register } = useForm<{ tasks: Task[] }>()
  const { fields, append } = useFieldArray({ control, name: 'tasks' })

  return (
    <div>
      {fields.map((field, index) => (
        <div key={field.id}>
          <input {...register(`tasks.${index}.title`)} />  {/* undefined initially */}
          <input {...register(`tasks.${index}.priority`)} />  {/* undefined initially */}
        </div>
      ))}
      <button type="button" onClick={() => append({})}>Add Task</button>  {/* Empty object */}
    </div>
  )
}
```

**Correct (complete object with all fields):**

```typescript
function TasksForm() {
  const { control, register } = useForm<{ tasks: Task[] }>()
  const { fields, append } = useFieldArray({ control, name: 'tasks' })

  const addTask = () => {
    append({
      title: '',
      priority: 'medium',
      dueDate: null,
    })
  }

  return (
    <div>
      {fields.map((field, index) => (
        <div key={field.id}>
          <input {...register(`tasks.${index}.title`)} />
          <select {...register(`tasks.${index}.priority`)}>
            <option value="low">Low</option>
            <option value="medium">Medium</option>
            <option value="high">High</option>
          </select>
        </div>
      ))}
      <button type="button" onClick={addTask}>Add Task</button>
    </div>
  )
}
```

Reference: [useFieldArray](https://react-hook-form.com/docs/usefieldarray)

### 5.2 Separate Sequential Field Array Operations

**Impact: MEDIUM-HIGH (prevents state corruption from batched mutations)**

Chaining `append()` and `remove()` in the same handler can cause state corruption. Defer removals to a useEffect or separate user action to allow React to process renders between operations.

**Incorrect (stacked operations cause state issues):**

```typescript
function ReplaceItemForm() {
  const { control } = useForm()
  const { fields, append, remove } = useFieldArray({ control, name: 'items' })

  const replaceItem = (indexToReplace: number, newItem: Item) => {
    remove(indexToReplace)  // Remove old item
    append(newItem)  // Immediately add new - state may be stale
  }

  return (
    <div>
      {fields.map((field, index) => (
        <ItemRow
          key={field.id}
          index={index}
          onReplace={(newItem) => replaceItem(index, newItem)}
        />
      ))}
    </div>
  )
}
```

**Correct (use update for replacements, or defer operations):**

```typescript
function ReplaceItemForm() {
  const { control } = useForm()
  const { fields, update } = useFieldArray({ control, name: 'items' })

  const replaceItem = (indexToReplace: number, newItem: Item) => {
    update(indexToReplace, newItem)  // Single atomic operation
  }

  return (
    <div>
      {fields.map((field, index) => (
        <ItemRow
          key={field.id}
          index={index}
          onReplace={(newItem) => replaceItem(index, newItem)}
        />
      ))}
    </div>
  )
}
```

**Alternative (defer removal with useEffect):**

```typescript
const [pendingRemoval, setPendingRemoval] = useState<number | null>(null)

useEffect(() => {
  if (pendingRemoval !== null) {
    remove(pendingRemoval)
    setPendingRemoval(null)
  }
}, [pendingRemoval, remove])
```

Reference: [useFieldArray](https://react-hook-form.com/docs/usefieldarray)

### 5.3 Use field.id as Key in useFieldArray Maps

**Impact: MEDIUM-HIGH (prevents state corruption and unnecessary re-renders)**

useFieldArray generates a unique `id` for each field. Using array index as key causes React to lose track of component identity when items are reordered, removed, or inserted.

**Incorrect (index as key causes state corruption):**

```typescript
function IngredientsForm() {
  const { control, register } = useForm()
  const { fields, append, remove } = useFieldArray({ control, name: 'ingredients' })

  return (
    <div>
      {fields.map((field, index) => (
        <div key={index}>  {/* Index key causes re-render issues */}
          <input {...register(`ingredients.${index}.name`)} />
          <button type="button" onClick={() => remove(index)}>Remove</button>
        </div>
      ))}
      <button type="button" onClick={() => append({ name: '' })}>Add</button>
    </div>
  )
}
```

**Correct (field.id ensures stable identity):**

```typescript
function IngredientsForm() {
  const { control, register } = useForm()
  const { fields, append, remove } = useFieldArray({ control, name: 'ingredients' })

  return (
    <div>
      {fields.map((field, index) => (
        <div key={field.id}>  {/* Stable identity across operations */}
          <input {...register(`ingredients.${index}.name`)} />
          <button type="button" onClick={() => remove(index)}>Remove</button>
        </div>
      ))}
      <button type="button" onClick={() => append({ name: '' })}>Add</button>
    </div>
  )
}
```

Reference: [useFieldArray](https://react-hook-form.com/docs/usefieldarray)

### 5.4 Use FormProvider for Virtualized Field Arrays

**Impact: MEDIUM (maintains field state when rows exit/enter viewport)**

When using virtualization libraries (react-window, react-virtuoso) with field arrays, fields exiting the viewport lose their DOM reference. Use FormProvider with useFormContext to maintain state across virtualization boundaries.

**Incorrect (direct props break with virtualization):**

```typescript
function VirtualizedList() {
  const { control, register } = useForm()
  const { fields } = useFieldArray({ control, name: 'rows' })

  return (
    <VirtualList
      itemCount={fields.length}
      itemSize={50}
      renderItem={({ index }) => (
        <input {...register(`rows.${index}.value`)} />  // Loses state when scrolled out
      )}
    />
  )
}
```

**Correct (FormProvider preserves context across virtualization):**

```typescript
function VirtualizedList() {
  const methods = useForm()
  const { fields } = useFieldArray({ control: methods.control, name: 'rows' })

  return (
    <FormProvider {...methods}>
      <VirtualList
        itemCount={fields.length}
        itemSize={50}
        renderItem={({ index }) => (
          <VirtualizedRow index={index} fieldId={fields[index].id} />
        )}
      />
    </FormProvider>
  )
}

function VirtualizedRow({ index, fieldId }: { index: number; fieldId: string }) {
  const { register, getValues } = useFormContext()

  return (
    <input
      key={fieldId}
      defaultValue={getValues(`rows.${index}.value`)}  // Restore from form state
      {...register(`rows.${index}.value`)}
    />
  )
}
```

Reference: [React Hook Form - Advanced Usage](https://react-hook-form.com/advanced-usage)

### 5.5 Use Single useFieldArray Instance Per Field Name

**Impact: MEDIUM-HIGH (prevents state conflicts from duplicate subscriptions)**

Each field name should have only one useFieldArray instance. Multiple instances managing the same field name cause state conflicts and unpredictable behavior.

**Incorrect (multiple instances for same field):**

```typescript
function OrderForm() {
  const { control } = useForm()

  return (
    <div>
      <ItemsList control={control} />
      <ItemsSummary control={control} />
    </div>
  )
}

function ItemsList({ control }: { control: Control }) {
  const { fields, append } = useFieldArray({ control, name: 'items' })  // Instance 1
  return <div>{/* render items */}</div>
}

function ItemsSummary({ control }: { control: Control }) {
  const { fields } = useFieldArray({ control, name: 'items' })  // Instance 2 - conflicts!
  return <div>Total items: {fields.length}</div>
}
```

**Correct (single instance, pass fields down or use useWatch):**

```typescript
function OrderForm() {
  const { control } = useForm()
  const { fields, append, remove } = useFieldArray({ control, name: 'items' })

  return (
    <div>
      <ItemsList fields={fields} append={append} remove={remove} />
      <ItemsSummary control={control} />  {/* Uses useWatch, not useFieldArray */}
    </div>
  )
}

function ItemsSummary({ control }: { control: Control }) {
  const items = useWatch({ control, name: 'items' })  // Read-only subscription
  return <div>Total items: {items?.length ?? 0}</div>
}
```

Reference: [useFieldArray](https://react-hook-form.com/docs/usefieldarray)

---

## 6. State Management

**Impact: MEDIUM**

FormState access via Proxy subscription optimization requires explicit destructuring. Accessing entire formState object disables optimization.

### 6.1 Avoid isValid with onSubmit Mode for Button State

**Impact: MEDIUM (prevents validation on every render for button disabled state)**

When using `mode: 'onSubmit'`, accessing `isValid` forces validation on every render to determine the current validity state. This defeats the purpose of deferred validation.

**Incorrect (isValid triggers validation despite onSubmit mode):**

```typescript
function RegistrationForm() {
  const { register, handleSubmit, formState: { isValid } } = useForm({
    mode: 'onSubmit',  // Expects validation only on submit
  })

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('email', { required: true })} />
      <input {...register('password', { required: true })} />
      <button disabled={!isValid}>Register</button>  {/* Forces validation on every render */}
    </form>
  )
}
```

**Correct (use isSubmitting or allow submit attempt):**

```typescript
function RegistrationForm() {
  const { register, handleSubmit, formState: { isSubmitting } } = useForm({
    mode: 'onSubmit',
  })

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('email', { required: true })} />
      <input {...register('password', { required: true })} />
      <button disabled={isSubmitting}>
        {isSubmitting ? 'Registering...' : 'Register'}
      </button>
    </form>
  )
}
```

**Alternative (use onChange mode if real-time validation needed):**

```typescript
const { formState: { isValid } } = useForm({
  mode: 'onChange',  // Explicit: validation runs on every change
})
```

Reference: [useForm - mode](https://react-hook-form.com/docs/useform)

### 6.2 Destructure formState Properties Before Render

**Impact: MEDIUM (enables Proxy subscription optimization)**

formState is wrapped in a Proxy that tracks which properties you access. Destructure the specific properties you need before render to enable the subscription optimization. Assigning the entire object disables it.

**Incorrect (entire object assignment disables Proxy):**

```typescript
function SubmitButton() {
  const { handleSubmit, formState } = useForm()

  return (
    <button
      disabled={!formState.isValid}  // Proxy optimization disabled
      onClick={handleSubmit(onSubmit)}
    >
      {formState.isSubmitting ? 'Saving...' : 'Save'}
    </button>
  )
}
```

**Correct (destructure enables selective subscription):**

```typescript
function SubmitButton() {
  const { handleSubmit, formState: { isValid, isSubmitting } } = useForm()

  return (
    <button
      disabled={!isValid}  // Only subscribes to isValid changes
      onClick={handleSubmit(onSubmit)}
    >
      {isSubmitting ? 'Saving...' : 'Save'}
    </button>
  )
}
```

**Note:** This also applies to useFormState hook - always destructure the properties you need.

Reference: [useFormState](https://react-hook-form.com/docs/useformstate)

### 6.3 Subscribe to Specific Field Names in useFormState

**Impact: MEDIUM (reduces re-renders to only relevant field changes)**

useFormState accepts a `name` option to subscribe only to specific field state changes. Without it, the component re-renders on any field's state change.

**Incorrect (subscribes to all field state changes):**

```typescript
function PasswordStrengthIndicator({ control }: { control: Control }) {
  const { errors, dirtyFields } = useFormState({ control })  // All fields

  const passwordError = errors.password
  const isPasswordDirty = dirtyFields.password

  return isPasswordDirty && !passwordError ? (
    <span>Password looks good!</span>
  ) : null
}
```

**Correct (subscribes only to password field):**

```typescript
function PasswordStrengthIndicator({ control }: { control: Control }) {
  const { errors, dirtyFields } = useFormState({
    control,
    name: 'password',  // Only re-renders on password state changes
  })

  const passwordError = errors.password
  const isPasswordDirty = dirtyFields.password

  return isPasswordDirty && !passwordError ? (
    <span>Password looks good!</span>
  ) : null
}
```

**Multiple fields:**

```typescript
const { errors } = useFormState({
  control,
  name: ['email', 'password'],  // Subscribe to multiple specific fields
})
```

Reference: [useFormState](https://react-hook-form.com/docs/useformstate)

### 6.4 Use getFieldState for Single Field State Access

**Impact: MEDIUM (avoids subscription overhead for one-time state reads)**

When you need to check a single field's state (dirty, touched, error) without subscribing to updates, use `getFieldState()`. It returns current state without creating a subscription.

**Incorrect (useFormState creates subscription for one-time check):**

```typescript
function FieldHelpText({ control, name }: { control: Control; name: string }) {
  const { touchedFields } = useFormState({ control })  // Subscribes to all touched changes

  const wasTouched = touchedFields[name]

  return wasTouched ? null : <span>Please fill out this field</span>
}
```

**Correct (getFieldState for non-reactive read):**

```typescript
function FieldHelpText({ formState, name }: { formState: FormState; name: string }) {
  const { isTouched } = getFieldState(name, formState)  // No subscription created

  return isTouched ? null : <span>Please fill out this field</span>
}

function MyForm() {
  const { register, formState } = useForm()

  return (
    <form>
      <input {...register('email')} />
      <FieldHelpText formState={formState} name="email" />
    </form>
  )
}
```

**When to use each:**
- `useFormState`: Need to react to state changes (display updates)
- `getFieldState`: Need current state at a point in time (conditional logic)

Reference: [useForm - getFieldState](https://react-hook-form.com/docs/useform/getfieldstate)

### 6.5 Use useFormState for Isolated State Subscriptions

**Impact: MEDIUM (prevents parent re-renders from state access in children)**

useFormState allows subscribing to form state in child components without causing parent re-renders. Each useFormState instance is isolated and doesn't affect other subscribers.

**Incorrect (formState at root re-renders entire form):**

```typescript
function ContactForm() {
  const { register, handleSubmit, formState: { errors, isDirty } } = useForm()

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('email', { required: true })} />
      {errors.email && <span>Email required</span>}  {/* Re-renders all on any state change */}
      <input {...register('message')} />
      <SaveIndicator isDirty={isDirty} />  {/* Prop drilling */}
    </form>
  )
}
```

**Correct (useFormState isolates subscriptions):**

```typescript
function ContactForm() {
  const { register, handleSubmit, control } = useForm()

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <EmailField register={register} control={control} />
      <input {...register('message')} />
      <SaveIndicator control={control} />  {/* Isolated subscription */}
    </form>
  )
}

function EmailField({ register, control }: EmailFieldProps) {
  const { errors } = useFormState({ control, name: 'email' })

  return (
    <div>
      <input {...register('email', { required: true })} />
      {errors.email && <span>Email required</span>}
    </div>
  )
}

function SaveIndicator({ control }: { control: Control }) {
  const { isDirty } = useFormState({ control })

  return isDirty ? <span>Unsaved changes</span> : null
}
```

Reference: [useFormState](https://react-hook-form.com/docs/useformstate)

---

## 7. Integration Patterns

**Impact: MEDIUM**

Third-party UI library integration (MUI, shadcn, Ant Design) requires specific wiring patterns to maintain uncontrolled component benefits.

### 7.1 Transform Values at Controller Level for Type Coercion

**Impact: MEDIUM (prevents type coercion bugs in 100% of numeric/date form fields)**

Native inputs return strings. When your form needs numbers, dates, or other types, transform values in the Controller render function rather than relying solely on `valueAsNumber` or `valueAsDate`.

**Incorrect (valueAsNumber has edge cases):**

```typescript
function QuantityInput() {
  const { register } = useForm()

  return (
    <input
      {...register('quantity', { valueAsNumber: true })}  // Returns NaN for empty string
      type="number"
    />
  )
}
```

**Correct (explicit transformation in Controller):**

```typescript
function QuantityInput({ control }: { control: Control }) {
  return (
    <Controller
      name="quantity"
      control={control}
      render={({ field }) => (
        <input
          type="number"
          value={field.value ?? ''}
          onChange={(e) => {
            const value = e.target.value
            field.onChange(value === '' ? null : parseInt(value, 10))
          }}
          onBlur={field.onBlur}
        />
      )}
    />
  )
}
```

**Alternative (Zod transform at schema level):**

```typescript
const schema = z.object({
  quantity: z.string().transform((val) => (val === '' ? null : parseInt(val, 10))),
})
```

Reference: [React Hook Form - Advanced Usage](https://react-hook-form.com/advanced-usage)

### 7.2 Use Controller for Material-UI Components

**Impact: MEDIUM (maintains controlled component behavior with proper event handling)**

Material-UI components are controlled by design. Use Controller to wrap them, handling the onChange event object correctly (MUI passes the event, not the value directly).

**Incorrect (register doesn't work with MUI controlled components):**

```typescript
import { TextField } from '@mui/material'

function MuiForm() {
  const { register, handleSubmit } = useForm()

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <TextField
        {...register('email')}  // MUI TextField is controlled, register won't work
        label="Email"
      />
    </form>
  )
}
```

**Correct (Controller handles MUI's event-based onChange):**

```typescript
import { TextField } from '@mui/material'
import { Controller } from 'react-hook-form'

function MuiForm() {
  const { control, handleSubmit } = useForm()

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <Controller
        name="email"
        control={control}
        render={({ field, fieldState }) => (
          <TextField
            {...field}  // MUI TextField accepts onChange with event
            label="Email"
            error={!!fieldState.error}
            helperText={fieldState.error?.message}
          />
        )}
      />
    </form>
  )
}
```

Reference: [React Hook Form - UI Libraries](https://react-hook-form.com/get-started#IntegratingwithUIlibraries)

### 7.3 Verify shadcn Form Component Import Source

**Impact: MEDIUM (prevents silent component mismatch bugs)**

React Hook Form exports its own `<Form>` component. When using shadcn/ui, ensure you import the shadcn Form wrapper, not RHF's Form. Auto-imports often get this wrong.

**Incorrect (imports RHF Form instead of shadcn):**

```typescript
import { useForm, Form } from 'react-hook-form'  // Wrong Form!
import { FormField, FormItem, FormLabel } from '@/components/ui/form'

function LoginForm() {
  const form = useForm()

  return (
    <Form {...form}>  {/* RHF Form doesn't work with shadcn FormField */}
      <FormField
        control={form.control}
        name="email"
        render={({ field }) => (
          <FormItem>
            <FormLabel>Email</FormLabel>
            <Input {...field} />
          </FormItem>
        )}
      />
    </Form>
  )
}
```

**Correct (separate imports for each library):**

```typescript
import { useForm } from 'react-hook-form'
import { Form, FormField, FormItem, FormLabel } from '@/components/ui/form'

function LoginForm() {
  const form = useForm()

  return (
    <Form {...form}>  {/* shadcn Form wraps FormProvider correctly */}
      <FormField
        control={form.control}
        name="email"
        render={({ field }) => (
          <FormItem>
            <FormLabel>Email</FormLabel>
            <Input {...field} />
          </FormItem>
        )}
      />
    </Form>
  )
}
```

Reference: [shadcn Form](https://ui.shadcn.com/docs/components/form)

### 7.4 Wire shadcn Select with onValueChange Instead of Spread

**Impact: MEDIUM (prevents 100% of silent select binding failures with Radix-based components)**

shadcn's Select (built on Radix) uses `onValueChange` instead of `onChange`. Spreading field props directly doesn't work. Manually wire the value change handler.

**Incorrect (spread doesn't work with Radix Select):**

```typescript
function CountrySelect({ control }: { control: Control }) {
  return (
    <FormField
      control={control}
      name="country"
      render={({ field }) => (
        <Select {...field}>  {/* field.onChange expects event, Radix passes value */}
          <SelectTrigger>
            <SelectValue placeholder="Select country" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="us">United States</SelectItem>
            <SelectItem value="uk">United Kingdom</SelectItem>
          </SelectContent>
        </Select>
      )}
    />
  )
}
```

**Correct (wire props individually):**

```typescript
function CountrySelect({ control }: { control: Control }) {
  return (
    <FormField
      control={control}
      name="country"
      render={({ field }) => (
        <Select
          value={field.value}
          onValueChange={field.onChange}  // Radix passes value directly
          onOpenChange={() => field.onBlur()}  // Trigger blur on close
        >
          <SelectTrigger>
            <SelectValue placeholder="Select country" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="us">United States</SelectItem>
            <SelectItem value="uk">United Kingdom</SelectItem>
          </SelectContent>
        </Select>
      )}
    />
  )
}
```

Reference: [shadcn Select](https://ui.shadcn.com/docs/components/select)

---

## 8. Advanced Patterns

**Impact: LOW**

FormProvider optimization with React.memo, DevTools performance impact awareness, and testing patterns for hook-based forms.

### 8.1 Create Test Wrapper with QueryClient and AuthProvider

**Impact: LOW (enables proper hook testing with required context providers)**

Hook tests require proper context providers. Create a reusable wrapper function that provides QueryClient, AuthProvider, and any other required context for your forms.

**Incorrect (missing providers causes hook errors):**

```typescript
import { renderHook } from '@testing-library/react'
import { useForm } from 'react-hook-form'

test('form submits correctly', () => {
  const { result } = renderHook(() => useForm())  // May fail if form uses context

  act(() => {
    result.current.setValue('email', 'test@example.com')
  })

  expect(result.current.getValues('email')).toBe('test@example.com')
})
```

**Correct (wrapper provides all required context):**

```typescript
import { renderHook, act } from '@testing-library/react'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { useForm } from 'react-hook-form'

const createWrapper = () => {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  })

  return function Wrapper({ children }: { children: React.ReactNode }) {
    return (
      <QueryClientProvider client={queryClient}>
        {children}
      </QueryClientProvider>
    )
  }
}

test('form submits correctly', () => {
  const { result } = renderHook(() => useForm(), {
    wrapper: createWrapper(),
  })

  act(() => {
    result.current.setValue('email', 'test@example.com')
  })

  expect(result.current.getValues('email')).toBe('test@example.com')
})
```

Reference: [React Hook Form - Testing](https://react-hook-form.com/advanced-usage#TestingForm)

### 8.2 Disable DevTools in Production and During Performance Testing

**Impact: LOW (eliminates DevTools overhead during profiling)**

React Hook Form DevTools can cause performance issues, especially with FormProvider. Always disable in production and temporarily remove when profiling performance.

**Incorrect (DevTools enabled regardless of environment):**

```typescript
import { DevTool } from '@hookform/devtools'

function ProfileForm() {
  const { control, register, handleSubmit } = useForm()

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('email')} />
      <DevTool control={control} />  {/* Always renders, even in production */}
    </form>
  )
}
```

**Correct (conditionally render DevTools):**

```typescript
import { DevTool } from '@hookform/devtools'

function ProfileForm() {
  const { control, register, handleSubmit } = useForm()

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('email')} />
      {process.env.NODE_ENV === 'development' && <DevTool control={control} />}
    </form>
  )
}
```

**Alternative (dynamic import to avoid bundle impact):**

```typescript
const DevTool = lazy(() =>
  import('@hookform/devtools').then((mod) => ({ default: mod.DevTool }))
)

function ProfileForm() {
  const { control, register, handleSubmit } = useForm()

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('email')} />
      {process.env.NODE_ENV === 'development' && (
        <Suspense fallback={null}>
          <DevTool control={control} />
        </Suspense>
      )}
    </form>
  )
}
```

Reference: [React Hook Form DevTools](https://react-hook-form.com/dev-tools)

### 8.3 Wrap FormProvider Children with React.memo

**Impact: LOW (prevents cascade re-renders from FormProvider state updates)**

FormProvider triggers re-renders on form state updates. Wrap expensive child components with `React.memo` to prevent unnecessary re-renders when their props haven't changed.

**Incorrect (children re-render on any form state change):**

```typescript
function LargeForm() {
  const methods = useForm()

  return (
    <FormProvider {...methods}>
      <form onSubmit={methods.handleSubmit(onSubmit)}>
        <PersonalInfoSection />  {/* Re-renders on ANY form state change */}
        <AddressSection />  {/* Re-renders on ANY form state change */}
        <PaymentSection />  {/* Re-renders on ANY form state change */}
      </form>
    </FormProvider>
  )
}

function PersonalInfoSection() {
  const { register } = useFormContext()
  return (
    <div>
      <input {...register('firstName')} />
      <input {...register('lastName')} />
    </div>
  )
}
```

**Correct (memo prevents unnecessary child re-renders):**

```typescript
function LargeForm() {
  const methods = useForm()

  return (
    <FormProvider {...methods}>
      <form onSubmit={methods.handleSubmit(onSubmit)}>
        <PersonalInfoSection />
        <AddressSection />
        <PaymentSection />
      </form>
    </FormProvider>
  )
}

const PersonalInfoSection = memo(function PersonalInfoSection() {
  const { register } = useFormContext()
  return (
    <div>
      <input {...register('firstName')} />
      <input {...register('lastName')} />
    </div>
  )
})

const AddressSection = memo(function AddressSection() {
  const { register } = useFormContext()
  return (
    <div>
      <input {...register('address.street')} />
      <input {...register('address.city')} />
    </div>
  )
})
```

Reference: [React Hook Form - Advanced Usage](https://react-hook-form.com/advanced-usage)

---

## References

1. [https://react-hook-form.com/docs](https://react-hook-form.com/docs)
2. [https://react-hook-form.com/advanced-usage](https://react-hook-form.com/advanced-usage)
3. [https://react-hook-form.com/docs/useform](https://react-hook-form.com/docs/useform)
4. [https://react-hook-form.com/docs/usewatch](https://react-hook-form.com/docs/usewatch)
5. [https://react-hook-form.com/docs/usecontroller](https://react-hook-form.com/docs/usecontroller)
6. [https://react-hook-form.com/docs/usefieldarray](https://react-hook-form.com/docs/usefieldarray)
7. [https://react-hook-form.com/docs/useformstate](https://react-hook-form.com/docs/useformstate)
8. [https://github.com/react-hook-form/resolvers](https://github.com/react-hook-form/resolvers)
9. [https://ui.shadcn.com/docs/components/form](https://ui.shadcn.com/docs/components/form)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |