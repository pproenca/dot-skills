---
title: One Level of Abstraction Per Function
impact: CRITICAL
impactDescription: prevents the reader from context-switching between strategy and mechanics
tags: func, abstraction, levels, cohesion
---

## One Level of Abstraction Per Function

A function that calls `repository.save(invoice)` (high-level orchestration) and also computes `invoice.items.reduce((s, i) => s + i.qty * i.price * (1 - i.discount), 0)` (low-level arithmetic) forces the reader to constantly shift gears. Keep one level per function: either orchestrate the *what*, or compute the *how*, never both in the same body.

**Incorrect (high-level call mixed with low-level conditional and arithmetic):**

```ts
// Reader's eye jumps: "save invoice" → low-level boolean trio → "send email".
async function finalizeInvoice(invoice: Invoice): Promise<void> {
  if (
    invoice.items.length > 0 &&
    invoice.total > 0 &&
    !invoice.archived &&
    invoice.dueDate.getTime() > Date.now()
  ) {
    await invoiceRepository.save(invoice);
    await mailer.send(invoice.customerEmail, `Invoice ${invoice.id} ready`);
  }
}
```

**Correct (low-level predicate extracted; outer function reads as policy at one level):**

```ts
// Outer function now reads as a single sentence at the policy level.
async function finalizeInvoice(invoice: Invoice): Promise<void> {
  if (!isInvoiceShippable(invoice)) return;
  await invoiceRepository.save(invoice);
  await mailer.send(invoice.customerEmail, `Invoice ${invoice.id} ready`);
}

function isInvoiceShippable(invoice: Invoice): boolean {
  return (
    invoice.items.length > 0 &&
    invoice.total > 0 &&
    !invoice.archived &&
    invoice.dueDate.getTime() > Date.now()
  );
}
```

**When NOT to apply this pattern:**
- Leaf functions where there is no higher level — `isInvoiceShippable` itself contains only low-level checks because that is its job. Don't recursively extract the `&&` chain.
- React event handlers that have a single trivial line of detail before the callback (`onClick={() => setOpen(false)}`) — extracting `handleClose` for one `setState` call is often noisier than the inline version.
- Performance-critical hot paths where extracting a predicate adds a function call per iteration of a tight loop; sometimes the mixed-level body is the right trade.

**Why this matters:** Single-level functions read top-down like prose; mixed-level functions force the reader to re-tune their abstraction every line.

Reference: [Clean Code, Chapter 3: Functions — Stepdown Rule](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
