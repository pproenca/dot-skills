---
title: Parameterize Two Functions That Differ by a Literal
impact: HIGH
impactDescription: eliminates a copy-paste twin function and the diff-rot bug class
tags: dup, parameterize, functions
---

## Parameterize Two Functions That Differ by a Literal

When you see two functions named almost the same — `sendEmailToCustomer` / `sendEmailToVendor`, `getActiveUsers` / `getInactiveUsers`, `formatUSD` / `formatEUR` — and their bodies are character-for-character identical except a single literal, you have one function masquerading as two. Each twin must be kept in sync forever, and they always drift. The judgment skill is identifying the *axis* that varies (a recipient role, a flag, a currency code) and lifting it out.

**Incorrect (two functions, one diff each):**

```typescript
async function notifyCustomerOfPriceChange(customerId: string): Promise<void> {
  const customer = await db.customers.find(customerId);
  await mailer.send({
    to: customer.email,
    template: 'price-change',
    subject: 'Important: Your price has changed',
    cc: 'customer-success@acme.com',
  });
  await audit.log('price_change_notified', { recipientId: customerId, role: 'customer' });
}

async function notifyVendorOfPriceChange(vendorId: string): Promise<void> {
  const vendor = await db.vendors.find(vendorId);
  await mailer.send({
    to: vendor.email,
    template: 'price-change',
    subject: 'Important: Your price has changed',
    cc: 'vendor-relations@acme.com',
  });
  await audit.log('price_change_notified', { recipientId: vendorId, role: 'vendor' });
}
// One axis varies (role: customer vs vendor → different table, different cc).
// Everything else is duplicated. Add a header to the email and you edit both.
```

**Correct (lift the varying axis to a parameter):**

```typescript
type Role = 'customer' | 'vendor';

const CONFIG: Record<Role, { table: 'customers' | 'vendors'; cc: string }> = {
  customer: { table: 'customers', cc: 'customer-success@acme.com' },
  vendor:   { table: 'vendors',   cc: 'vendor-relations@acme.com' },
};

async function notifyOfPriceChange(role: Role, id: string): Promise<void> {
  const { table, cc } = CONFIG[role];
  const recipient = await db[table].find(id);
  await mailer.send({
    to: recipient.email,
    template: 'price-change',
    subject: 'Important: Your price has changed',
    cc,
  });
  await audit.log('price_change_notified', { recipientId: id, role });
}
// One function. Adding a "partner" role is one new line in CONFIG.
```

**Distinguishing real differences from cosmetic ones:**

Look at the *body line by line*. If every difference between the two functions is:
- A literal value (string, number, currency code), or
- A different table/collection name, or
- A different audit category

...then the function is one function. If the differences include *different control flow, different error handling, different validation rules*, then they may genuinely be two functions — and you should split that distinction into shared and divergent parts, not collapse them.

**When NOT to use this pattern:**

- Two functions that look similar today but are being held apart deliberately because they evolve independently (e.g. compliance rules for one role about to change). Premature unification re-couples them. Note this with a comment if so.

Reference: [Refactoring — Parameterize Function](https://refactoring.com/catalog/parameterizeFunction.html) (Martin Fowler)
