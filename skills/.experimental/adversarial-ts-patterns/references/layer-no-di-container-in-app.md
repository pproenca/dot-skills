---
title: No DI container in application code where every token has one production implementation
tags: layer, dependency-injection, ioc, enterprise
---

## No DI container in application code where every token has one production implementation

The wrong default is installing an IoC container (inversify, tsyringe, or a hand-rolled service locator) in an application because "dependencies should be injected". Dependency injection is a technique — pass collaborators as parameters — and ES modules plus function parameters already deliver it. A container earns its runtime resolution only when there are multiple production implementations to select among or a host framework that owns construction; with one implementation per token, the container replaces compile-time-checked imports with string/symbol lookups that fail at runtime, plus decorator metadata and a composition-root file, while every consumer still gets the same object a plain import would give.

**Evidence of violation:** a container registration module (`container.bind(...)`, `@injectable`/`@inject` decorators, or a `services` locator object resolved by key at runtime) in application code, where the registrations map each token to exactly one production implementation. Test doubles do not count as second implementations — parameters and module mocks already cover substitution in tests. The carve-out is two or more production implementations selected per environment/tenant at runtime, or a framework (e.g. NestJS, Angular) whose component model requires the container.

**Incorrect (runtime lookup for a compile-time-known graph):**

```ts
container.bind<MailSender>(TYPES.MailSender).to(SendgridMailSender)
container.bind<InvoiceService>(TYPES.InvoiceService).to(InvoiceService)

const invoices = container.get<InvoiceService>(TYPES.InvoiceService)
```

**Correct (the module graph is the container):**

```ts
import { sendMail } from "./mail/sendgrid"

export function createInvoiceService(deps = { sendMail }) {
  return {
    async issue(invoice: Invoice) {
      await deps.sendMail(invoiceIssuedEmail(invoice))
    },
  }
}
```

Reference: [Martin Fowler — Inversion of Control Containers and the Dependency Injection pattern](https://martinfowler.com/articles/injection.html)
