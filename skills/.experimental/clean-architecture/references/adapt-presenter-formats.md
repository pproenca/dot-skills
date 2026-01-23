---
title: Presenters Format Data for the View
impact: MEDIUM
impactDescription: enables multiple view formats from same use case
tags: adapt, presenter, formatting, view-model
---

## Presenters Format Data for the View

Presenters accept data from use cases and format it for presentation. They create view models with strings, booleans, and pre-formatted values - nothing left for the view to compute.

**Incorrect (view does formatting):**

```tsx
// View component does formatting - logic spread across UI
function InvoiceView({ invoice }: { invoice: Invoice }) {
  // Formatting logic in view
  const formattedDate = new Date(invoice.dueDate).toLocaleDateString('en-US', {
    month: 'long',
    day: 'numeric',
    year: 'numeric'
  })

  const formattedTotal = new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: invoice.currency
  }).format(invoice.total / 100)

  const statusColor = invoice.status === 'paid' ? 'green'
    : invoice.status === 'overdue' ? 'red'
    : 'yellow'

  const daysOverdue = invoice.status === 'overdue'
    ? Math.floor((Date.now() - new Date(invoice.dueDate).getTime()) / 86400000)
    : 0

  return (
    <div>
      <span style={{ color: statusColor }}>{invoice.status.toUpperCase()}</span>
      <span>Due: {formattedDate}</span>
      <span>Total: {formattedTotal}</span>
      {daysOverdue > 0 && <span>{daysOverdue} days overdue</span>}
    </div>
  )
}
```

**Correct (presenter formats, view renders):**

```tsx
// presenter/InvoicePresenter.ts
interface InvoiceViewModel {
  invoiceNumber: string
  status: string
  statusColor: 'green' | 'yellow' | 'red'
  dueDate: string
  total: string
  overdueMessage: string | null
}

class InvoicePresenter {
  present(invoice: InvoiceResult, locale: string): InvoiceViewModel {
    return {
      invoiceNumber: `INV-${invoice.id.padStart(6, '0')}`,
      status: invoice.status.toUpperCase(),
      statusColor: this.getStatusColor(invoice.status),
      dueDate: this.formatDate(invoice.dueDate, locale),
      total: this.formatMoney(invoice.total, invoice.currency, locale),
      overdueMessage: this.getOverdueMessage(invoice)
    }
  }

  private getStatusColor(status: string): 'green' | 'yellow' | 'red' {
    const colors = { paid: 'green', pending: 'yellow', overdue: 'red' }
    return colors[status] || 'yellow'
  }

  private formatDate(date: Date, locale: string): string {
    return new Intl.DateTimeFormat(locale, {
      month: 'long', day: 'numeric', year: 'numeric'
    }).format(date)
  }

  private getOverdueMessage(invoice: InvoiceResult): string | null {
    if (invoice.status !== 'overdue') return null
    const days = this.calculateDaysOverdue(invoice.dueDate)
    return `${days} day${days !== 1 ? 's' : ''} overdue`
  }
}

// view/InvoiceView.tsx - Humble, just renders
function InvoiceView({ vm }: { vm: InvoiceViewModel }) {
  return (
    <div>
      <span style={{ color: vm.statusColor }}>{vm.status}</span>
      <span>Due: {vm.dueDate}</span>
      <span>Total: {vm.total}</span>
      {vm.overdueMessage && <span>{vm.overdueMessage}</span>}
    </div>
  )
}
```

**Benefits:**
- Formatting logic tested without UI framework
- Same use case serves different locales via different presenter configs
- View components trivially simple, easy to redesign

Reference: [Clean Architecture - Presenters and Humble Objects](https://www.oreilly.com/library/view/clean-architecture-a/9780134494272/ch23.xhtml)
