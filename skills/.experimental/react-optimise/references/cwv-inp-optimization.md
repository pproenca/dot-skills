---
title: Optimize Interaction to Next Paint with Yielding
impact: HIGH
impactDescription: reduces INP from 500ms+ to under 200ms
tags: cwv, inp, yielding, main-thread, responsiveness
---

## Optimize Interaction to Next Paint with Yielding

Long tasks that exceed 50ms block the main thread, preventing the browser from processing user input and painting visual feedback. High INP scores indicate users experience sluggish interactions. Yielding breaks expensive work into smaller chunks, letting the browser paint between them.

**Incorrect (synchronous processing blocks paint for 500ms+):**

```tsx
function OrderConfirmation({ orderId }: { orderId: string }) {
  const handleConfirm = () => {
    validateInventory(orderId)     // 150ms
    calculateShipping(orderId)     // 100ms
    applyDiscountRules(orderId)    // 80ms
    generateInvoice(orderId)       // 120ms
    updateAnalytics(orderId)       // 70ms
    // total: 520ms blocking — browser cannot paint "Processing..." until done
    navigateToReceipt(orderId)
  }

  return (
    <button onClick={handleConfirm}>
      Confirm Order
    </button>
  )
}
```

**Correct (yielding lets browser paint between chunks):**

```tsx
function OrderConfirmation({ orderId }: { orderId: string }) {
  const [processing, setProcessing] = useState(false)

  const handleConfirm = async () => {
    setProcessing(true) // browser paints "Processing..." immediately

    validateInventory(orderId)
    await yieldToMain()

    calculateShipping(orderId)
    await yieldToMain()

    applyDiscountRules(orderId)
    await yieldToMain()

    generateInvoice(orderId)
    await yieldToMain()

    updateAnalytics(orderId)
    navigateToReceipt(orderId)
  }

  return (
    <button onClick={handleConfirm} disabled={processing}>
      {processing ? "Processing..." : "Confirm Order"}
    </button>
  )
}

function yieldToMain(): Promise<void> {
  if ("scheduler" in globalThis && "yield" in scheduler) {
    return scheduler.yield() // preferred: preserves task priority
  }
  return new Promise((resolve) => setTimeout(resolve, 0))
}
```

Reference: [web.dev — Optimize INP](https://web.dev/articles/optimize-inp)
