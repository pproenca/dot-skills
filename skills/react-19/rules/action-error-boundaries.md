---
title: Wrap Actions with Error Boundaries
impact: CRITICAL
impactDescription: prevents unhandled rejections from crashing the app
tags: action, error-boundaries, error-handling, resilience
---

## Wrap Actions with Error Boundaries

Actions that throw errors will propagate to the nearest Error Boundary. Without proper boundaries, a single failed action can crash your entire application.

**Incorrect (no error boundary, crash on failure):**

```tsx
function CheckoutPage() {
  const [state, submitOrder] = useActionState(async (prev, formData) => {
    const result = await processPayment(formData)  // Throws on failure
    return result
  }, null)

  return (
    <form action={submitOrder}>
      <CardInput />
      <button>Pay Now</button>
    </form>
  )
}

// If processPayment throws, the entire page crashes
```

**Correct (error boundary catches failures):**

```tsx
function CheckoutPage() {
  return (
    <ErrorBoundary fallback={<PaymentErrorFallback />}>
      <PaymentForm />
    </ErrorBoundary>
  )
}

function PaymentForm() {
  const [state, submitOrder] = useActionState(async (prev, formData) => {
    const result = await processPayment(formData)
    if (result.error) {
      return { error: result.error }  // Handled errors stay in state
    }
    redirect('/confirmation')
    return { error: null }
  }, { error: null })

  return (
    <form action={submitOrder}>
      <CardInput />
      <button>Pay Now</button>
      {state.error && <p className="error">{state.error}</p>}
    </form>
  )
}

function PaymentErrorFallback() {
  return (
    <div>
      <h2>Payment failed</h2>
      <button onClick={() => window.location.reload()}>Try again</button>
    </div>
  )
}
```

**Best practices:**
- Return errors in state for recoverable failures
- Let Error Boundaries catch unexpected exceptions
- Provide meaningful fallback UI with recovery options

Reference: [Error Boundaries with Actions](https://react.dev/reference/react/useActionState#displaying-errors-with-an-error-boundary)
