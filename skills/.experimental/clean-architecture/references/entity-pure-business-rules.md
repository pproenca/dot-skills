---
title: Entities Contain Only Enterprise Business Rules
impact: CRITICAL
impactDescription: enables reuse across applications, prevents coupling
tags: entity, business-rules, domain, purity
---

## Entities Contain Only Enterprise Business Rules

Entities encapsulate enterprise-wide business rules that would exist regardless of automation. They must not contain application-specific logic, persistence code, or UI concerns.

**Incorrect (entity mixed with infrastructure concerns):**

```typescript
class Invoice {
  id: string
  items: LineItem[]
  status: InvoiceStatus
  dueDate: Date

  calculateTotal(): Money {
    return this.items.reduce((sum, item) => sum.add(item.amount), Money.zero())
  }

  isOverdue(): boolean {
    return this.status === InvoiceStatus.Unpaid && new Date() > this.dueDate
  }

  markPaid(): void {
    this.status = InvoiceStatus.Paid
    database.invoices.update(this)  // Entity cannot be tested without database
    emailService.send(this.customerEmail, 'Payment received')  // Coupled to email system
  }
}
```

**Correct (entity contains only business rules):**

```typescript
class Invoice {
  id: string
  items: LineItem[]
  status: InvoiceStatus
  dueDate: Date

  calculateTotal(): Money {
    return this.items.reduce((sum, item) => sum.add(item.amount), Money.zero())
  }

  isOverdue(): boolean {
    return this.status === InvoiceStatus.Unpaid && new Date() > this.dueDate
  }

  markPaid(): void {
    if (this.status !== InvoiceStatus.Unpaid) {
      throw new InvalidOperationError('Invoice already processed')
    }
    this.status = InvoiceStatus.Paid
  }
}
```

**Benefits:**
- Entity can be used in billing system, reporting system, mobile app
- Business rules tested without database or email setup
- Rules documented in one place, not scattered across application

Reference: [Clean Architecture - Entities](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
