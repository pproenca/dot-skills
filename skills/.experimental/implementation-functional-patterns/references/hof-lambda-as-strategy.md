---
title: Pass a lambda instead of defining a Strategy class when variation is one function
tags: hof, strategy-alternative, comparator, predicate, transformer
---

## Pass a lambda instead of defining a Strategy class when variation is one function

A model trained on Java/C# Strategy examples will reach for a `Strategy` interface, two `ConcreteStrategy` classes, and a `Context` that holds one. In TypeScript, the equivalent when the strategy has **one method and no internal state** is a function-typed parameter. The class form survives only when the strategy carries configuration, lifecycle, or is enumerated by a registry — see the Strategy pattern entry in [`implementation-design-patterns`](../../implementation-design-patterns/references/behavioral-strategy.md) for those cases.

### Shapes to recognize

- A `Strategy` interface declaring a single method
- Two-to-three classes each implementing that one method with no fields
- A `Context` that takes the strategy in its constructor and calls `strategy.method(args)` in exactly one place
- Domain-specific examples that almost always collapse to a lambda: comparators, predicates, formatters, validators, mappers, key-extractors

**Incorrect (Strategy class for one method, no state):**

```typescript
interface InvoiceSortStrategy {
  compare(a: Invoice, b: Invoice): number;
}

class SortByDueDate implements InvoiceSortStrategy {
  compare(a: Invoice, b: Invoice) {
    return a.dueDate.getTime() - b.dueDate.getTime();
  }
}

class SortByAmountDesc implements InvoiceSortStrategy {
  compare(a: Invoice, b: Invoice) {
    return b.amount - a.amount;
  }
}

class InvoiceList {
  constructor(private invoices: Invoice[], private strategy: InvoiceSortStrategy) {}
  sorted() {
    return [...this.invoices].sort((a, b) => this.strategy.compare(a, b));
  }
}

const overdue = new InvoiceList(invoices, new SortByDueDate()).sorted();
```

**Correct (lambda as the strategy):**

```typescript
type InvoiceComparator = (a: Invoice, b: Invoice) => number;

const byDueDate: InvoiceComparator = (a, b) => a.dueDate.getTime() - b.dueDate.getTime();
const byAmountDesc: InvoiceComparator = (a, b) => b.amount - a.amount;

function sortInvoices(invoices: Invoice[], compare: InvoiceComparator): Invoice[] {
  return [...invoices].sort(compare);
}

const overdue = sortInvoices(invoices, byDueDate);
```

The named type `InvoiceComparator` is the interface; named consts are the implementations; the call site reads identically to the class version with none of the ceremony. Adding a new sort order is one line, not one file.

### When NOT to apply (keep the class)

- The strategy holds configuration shared across calls (`new TaxStrategy(region, year)` where `region` and `year` are reused on many invocations)
- The strategy participates in a runtime registry — the system enumerates available strategies for a UI picker, plugin loader, or feature flag
- The strategy has multiple methods (`apply`, `undo`, `cost`, `describe`) — at that point it's not a strategy, it's a small object, and a class or factory function returning an object is appropriate
- The strategy is serialized (saved to disk, sent over a wire) — closures can't cross those boundaries; named class instances can be reconstructed by tag

### Related

- GoF class form: [`behavioral-strategy`](../../implementation-design-patterns/references/behavioral-strategy.md)
- Closures that carry state are not "strategies with state" — see [`closure-as-command`](closure-as-command.md) for the data-carrying-function counterpart

Reference: [Mostly Adequate Guide — Ch. 4 "Curry"](https://mostly-adequate.gitbook.io/mostly-adequate-guide/ch04)
