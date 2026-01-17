---
title: Introduce Special Case Object
impact: HIGH
impactDescription: eliminates repeated null checks throughout codebase
tags: cond, special-case, null-object, null-checks
---

## Introduce Special Case Object

When many places check for a special case (often null) and do the same thing, create a special case object that encapsulates that behavior.

**Incorrect (repeated null checks):**

```typescript
interface Customer {
  name: string
  billingPlan: BillingPlan
  paymentHistory: Payment[]
}

function getCustomerName(customer: Customer | null): string {
  return customer !== null ? customer.name : 'Occupant'
}

function getBillingPlan(customer: Customer | null): BillingPlan {
  return customer !== null ? customer.billingPlan : BillingPlan.BASIC
}

function getPaymentHistory(customer: Customer | null): Payment[] {
  return customer !== null ? customer.paymentHistory : []
}

// Every function that uses Customer needs null checks
function sendInvoice(customer: Customer | null): void {
  const name = customer !== null ? customer.name : 'Occupant'
  const plan = customer !== null ? customer.billingPlan : BillingPlan.BASIC
  // ...more null checks
}
```

**Correct (special case object handles the behavior):**

```typescript
interface Customer {
  name: string
  billingPlan: BillingPlan
  paymentHistory: Payment[]
  isUnknown: boolean
}

class RealCustomer implements Customer {
  constructor(
    public name: string,
    public billingPlan: BillingPlan,
    public paymentHistory: Payment[]
  ) {}

  get isUnknown(): boolean {
    return false
  }
}

class UnknownCustomer implements Customer {
  name = 'Occupant'
  billingPlan = BillingPlan.BASIC
  paymentHistory: Payment[] = []

  get isUnknown(): boolean {
    return true
  }
}

// Factory function returns special case instead of null
function getCustomer(id: string): Customer {
  const customer = database.find(id)
  return customer ?? new UnknownCustomer()
}

// No more null checks needed
function sendInvoice(customer: Customer): void {
  const name = customer.name  // Works for both real and unknown
  const plan = customer.billingPlan  // No null check needed
}
```

**Benefits:**
- Null checks eliminated throughout codebase
- Default behavior centralized in one place
- New special cases can add different default behaviors

Reference: [Introduce Special Case](https://refactoring.com/catalog/introduceSpecialCase.html)
