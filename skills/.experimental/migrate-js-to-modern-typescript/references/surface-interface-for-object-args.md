---
title: Convert Loose Object Arguments to Named Interfaces
impact: HIGH
impactDescription: enables reuse and clearer error messages
tags: surface, interfaces, object-parameters
---

## Convert Loose Object Arguments to Named Interfaces

A function that takes an ad-hoc inline object gives callers no guidance and produces giant single-line structural error messages on any mismatch. A named interface documents every field, can be exported and reused by callers, and makes the compiler report `CreateInvoiceInput` instead of an unreadable inline shape.

**Incorrect (inline structural type — unreadable, unreusable):**

```typescript
function createInvoice(arg: {
  customerId: string
  lines: { sku: string; qty: number }[]
  dueInDays: number
}): Invoice {
  return persistInvoice(arg)
}
```

**Correct (named interfaces — reusable, readable errors):**

```typescript
interface InvoiceLine {
  sku: string
  qty: number
}

interface CreateInvoiceInput {
  customerId: string
  lines: InvoiceLine[]
  dueInDays: number
}

function createInvoice(input: CreateInvoiceInput): Invoice {
  return persistInvoice(input)
}
```

Reference: [Google TypeScript Style Guide](https://google.github.io/styleguide/tsguide.html)
