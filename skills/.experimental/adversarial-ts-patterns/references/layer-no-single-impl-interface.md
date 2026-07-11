---
title: No interface with a single implementation and no test double
tags: layer, interfaces, structural-typing, enterprise
---

## No interface with a single implementation and no test double

The wrong default is the C#/Java reflex of declaring `IUserService` (or `UserServicePort`) for every class, "programming to the interface". That reflex assumes nominal typing, where substitution requires a declared interface. TypeScript is structural — any object matching the shape is already substitutable, and a class declaration **is** an interface (`InstanceType`, or the class name used as a type). A shape declared twice is a shape maintained twice; the speculative interface adds a rename hop to every go-to-definition and drifts from the implementation it mirrors.

**Evidence of violation:** an `interface`/`type` implemented or satisfied by exactly one concrete implementation in the repository under review, with no second implementation — including test fakes — anywhere in the codebase, where consumers could equally have named the concrete type. Grep for implementors before judging; absence of a second one anywhere is the evidence. The carve-outs are seams that exist by design — a published library boundary where consumers implement the contract, or an interface introduced together with a fake/in-memory implementation used in tests (the fake is the second implementation).

**Incorrect (shape declared twice, one implementor, no double):**

```ts
export interface IInvoicePdfRenderer {
  render(invoice: Invoice): Promise<Buffer>
}
export class InvoicePdfRenderer implements IInvoicePdfRenderer {
  async render(invoice: Invoice): Promise<Buffer> { /* ... */ }
}
```

**Correct (the class is the type; extract an interface when a second implementor arrives):**

```ts
export class InvoicePdfRenderer {
  async render(invoice: Invoice): Promise<Buffer> { /* ... */ }
}
// Consumers: function email(renderer: InvoicePdfRenderer) { ... }
// Structural typing already accepts any object with a matching render().
```

Reference: [TypeScript Handbook — Type Compatibility (structural typing)](https://www.typescriptlang.org/docs/handbook/type-compatibility.html)
