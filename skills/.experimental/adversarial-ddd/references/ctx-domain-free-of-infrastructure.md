---
title: Keep infrastructure imports out of the domain model
tags: ctx, layering, domain-purity, dependencies
---

## Keep infrastructure imports out of the domain model

The wrong default is importing whatever gets the job done into the model: the entity saves itself through the ORM, the domain service calls the HTTP client directly. Each infrastructure import couples the domain's meaning to a delivery mechanism — the model can no longer be tested, reasoned about, or reused without dragging the database along, and domain concepts start bending to fit infrastructure shapes.

**Evidence of violation:** an import inside a module identified as the domain model, from any of: database drivers or ORMs, HTTP clients or web frameworks, message broker SDKs, cloud provider SDKs, or filesystem/OS I/O APIs. **Prerequisite:** a domain module is identifiable — by structure (`domain/`, `model/`, `core/`) or as the module holding the entity types under review; when no domain layer is distinguishable at all, this rule is N/A — say so.

**Carve-outs (must be cited to claim):** value-level libraries carry no I/O and are fine — dates, decimals, money, UUIDs, validation. Ports (interfaces the domain defines for infrastructure to implement) are the fix, not a violation: a `PaymentGateway` interface in the domain with its HTTP implementation outside is exactly right — cite the implementation living outside the domain module.

**Incorrect (the model cannot exist without the database):**

```ts
// domain/invoice.ts
import { db } from "../infrastructure/postgres"

export class Invoice {
  async settle(payment: Payment): Promise<void> {
    this.state = InvoiceState.SETTLED
    await db.query("UPDATE invoices SET state = $1 WHERE id = $2", ["settled", this.id])
  }
}
```

**Correct (the domain states what must happen; infrastructure says how):**

```ts
// domain/invoice.ts — no infrastructure imports
export class Invoice {
  settle(payment: Payment): InvoiceSettled {
    this.state = InvoiceState.SETTLED
    return new InvoiceSettled(this.id, payment.id)
  }
}

// domain/invoice-repository.ts — a port, implemented in infrastructure/
export interface InvoiceRepository {
  save(invoice: Invoice): Promise<void>
}
```

Reference: [Eric Evans — Domain-Driven Design Reference: Isolating the Domain, Repositories](https://www.domainlanguage.com/ddd/reference/), [Martin Fowler — DomainDrivenDesign](https://martinfowler.com/bliki/DomainDrivenDesign.html)
