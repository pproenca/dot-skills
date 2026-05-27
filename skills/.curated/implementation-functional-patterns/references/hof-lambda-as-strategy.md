---
title: Pass a lambda instead of defining a Strategy class when variation is one function
tags: hof, strategy-alternative, comparator, predicate, transformer
---

## Pass a lambda instead of defining a Strategy class when variation is one function

A model trained on Java/C# Strategy examples will reach for a `Strategy` interface, two `ConcreteStrategy` classes, and a `Context` that holds one. In TypeScript, the equivalent when the strategy has **one method and no internal state** is a function-typed parameter. The class form survives only when the strategy carries configuration, lifecycle, or is enumerated by a registry — see the Strategy pattern entry in [`implementation-design-patterns`](../../../.experimental/implementation-design-patterns/references/behavioral-strategy.md) for those cases.

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

### Common pitfalls

- **The strategy lambda captures mutable outer state.** `let multiplier = 1; const scale: Strategy = (x) => x * multiplier` looks like a strategy but its behavior changes silently when `multiplier` is reassigned elsewhere. Either close over a `const`, or accept the mutable state as an argument.
- **Inline strategy lambda inside JSX/loops.** Passing `<Sortable comparator={(a, b) => a.x - b.x}>` creates a new function identity each render. If the consumer memoizes on the comparator (e.g., caches a sorted result), the cache busts. Move the comparator to module scope or use a stable reference — see [`place-module-scope-pure-transformers`](place-module-scope-pure-transformers.md).
- **Two strategies that look equal aren't `===` equal.** `(x) => x.id === byId` and `(x) => x.id === byId` are different references. Don't compare strategy lambdas for equality; identify them by a separate tag or name when you need that.

### Performance trade-offs

- **Time:** function call vs method call is the same on modern V8; both inline equivalently in hot paths.
- **Memory:** a closure holding zero captures is comparable to a class instance with zero fields — both small. The class wins one field per per-call constructor invocation (the `private strategy` field); the closure wins by not allocating the wrapper at all when you pass the lambda directly.
- **Code size:** the functional form is meaningfully smaller — ~5 lines per strategy vs ~10 for the class form. In a tree-shaken bundle, unused functional strategies disappear; unused class methods don't if the class is referenced.

### When NOT to apply (keep the class)

- The strategy holds configuration shared across calls (`new TaxStrategy(region, year)` where `region` and `year` are reused on many invocations)
- The strategy participates in a runtime registry — the system enumerates available strategies for a UI picker, plugin loader, or feature flag
- The strategy has multiple methods (`apply`, `undo`, `cost`, `describe`) — at that point it's not a strategy, it's a small object, and a class or factory function returning an object is appropriate
- The strategy is serialized (saved to disk, sent over a wire) — closures can't cross those boundaries; named class instances can be reconstructed by tag

### Related

- GoF class form: [`behavioral-strategy`](../../../.experimental/implementation-design-patterns/references/behavioral-strategy.md)
- Closures that carry state are not "strategies with state" — see [`closure-as-command`](closure-as-command.md) for the data-carrying-function counterpart

Reference: [Mostly Adequate Guide — Ch. 4 "Curry"](https://mostly-adequate.gitbook.io/mostly-adequate-guide/ch04)
