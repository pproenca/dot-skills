---
title: Declare Class Field Types Instead of Relying on Assignment
impact: MEDIUM-HIGH
impactDescription: enables strict property initialization checks
tags: surface, classes, fields, initialization
---

## Declare Class Field Types Instead of Relying on Assignment

TypeScript infers a class field's type from constructor assignments, but fields set conditionally, in methods, or by a framework become implicit `any` or error under `strictPropertyInitialization`. Explicit field declarations make the class shape complete and strict-safe, and document the object's structure in one place instead of scattered across methods.

**Incorrect (fields established only by assignment):**

```typescript
class OrderProcessor {
  constructor(gateway) {
    this.gateway = gateway // gateway field is implicitly any
  }
  attachLogger(logger) {
    this.logger = logger // logger appears only here, so its type is any
  }
}
```

**Correct (explicit field declarations):**

```typescript
class OrderProcessor {
  private readonly gateway: PaymentGateway
  private logger?: Logger

  constructor(gateway: PaymentGateway) {
    this.gateway = gateway
  }

  attachLogger(logger: Logger): void {
    this.logger = logger
  }
}
```

Reference: [TypeScript Handbook: Classes](https://www.typescriptlang.org/docs/handbook/2/classes.html)
