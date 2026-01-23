---
title: Group Classes That Change Together
impact: HIGH
impactDescription: localizes change impact, reduces deployment risk
tags: comp, common-closure, cohesion, change
---

## Group Classes That Change Together

Classes that change for the same reasons and at the same times should be in the same component. This is the Common Closure Principle (CCP) - the Single Responsibility Principle for components.

**Incorrect (classes that change together are separated):**

```text
src/
├── entities/
│   └── Invoice.ts           # Changes when billing rules change
├── repositories/
│   └── InvoiceRepository.ts # Changes when billing rules change
├── services/
│   └── InvoiceService.ts    # Changes when billing rules change
├── validators/
│   └── InvoiceValidator.ts  # Changes when billing rules change
└── mappers/
    └── InvoiceMapper.ts     # Changes when billing rules change

# A billing rule change touches 5 directories
# Risk of forgetting one, inconsistent changes
```

**Correct (classes that change together are grouped):**

```text
src/
├── billing/
│   ├── domain/
│   │   ├── Invoice.ts
│   │   ├── InvoiceLine.ts
│   │   ├── InvoiceRules.ts
│   │   └── InvoiceValidator.ts
│   ├── application/
│   │   ├── CreateInvoiceUseCase.ts
│   │   └── ports/
│   │       └── InvoiceRepository.ts
│   └── infrastructure/
│       ├── PostgresInvoiceRepository.ts
│       └── InvoiceMapper.ts
├── payments/
│   └── ...  # Changes for different reasons
└── shipping/
    └── ...  # Changes for different reasons

# Billing rule change isolated to billing/
# Single PR, single review, single deployment
```

**How to identify change reasons:**
- "When X business rule changes, which classes change?"
- "When the Y team requests a feature, which code changes?"
- Group by actor/stakeholder, not by technical layer

Reference: [Clean Architecture - Common Closure Principle](https://www.oreilly.com/library/view/clean-architecture-a/9780134494272/ch13.xhtml)
