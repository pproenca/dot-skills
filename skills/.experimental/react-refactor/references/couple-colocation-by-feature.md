---
title: Colocate Code by Feature Domain
impact: MEDIUM
impactDescription: reduces cross-directory navigation by 70%, makes features self-contained and deletable
tags: couple, colocation, feature-modules, cohesion
---

## Colocate Code by Feature Domain

Organizing by file type (components/, hooks/, styles/) scatters every feature across the entire directory tree. Adding or deleting a feature touches 5-8 directories. Feature-based colocation keeps all related code in one directory, so deleting a feature means deleting one folder.

**Incorrect (type-based layout — feature scattered across directories):**

```tsx
// src/
//   components/
//     InvoiceList.tsx
//     InvoiceDetail.tsx
//     InvoiceForm.tsx
//   hooks/
//     useInvoices.ts
//     useInvoiceFilters.ts
//   types/
//     invoice.ts
//   utils/
//     invoiceCalculations.ts
//   styles/
//     invoice.module.css

// Deleting "invoice" requires changes in 5 directories
import { Invoice } from "../../types/invoice";
import { useInvoices } from "../../hooks/useInvoices";
import { calculateTotal } from "../../utils/invoiceCalculations";
import styles from "../../styles/invoice.module.css";

export function InvoiceList() {
  const { invoices } = useInvoices();
  return (
    <ul className={styles.list}>
      {invoices.map((invoice: Invoice) => (
        <li key={invoice.id}>{invoice.vendor} — ${calculateTotal(invoice)}</li>
      ))}
    </ul>
  );
}
```

**Correct (feature-based layout — one directory per domain):**

```tsx
// src/features/
//   invoice/
//     InvoiceList.tsx
//     InvoiceDetail.tsx
//     InvoiceForm.tsx
//     useInvoices.ts
//     useInvoiceFilters.ts
//     invoiceCalculations.ts
//     invoice.types.ts
//     invoice.module.css
//     index.ts          <-- public API surface

// index.ts — only public exports
export { InvoiceList } from "./InvoiceList";
export { InvoiceDetail } from "./InvoiceDetail";
export type { Invoice } from "./invoice.types";

// InvoiceList.tsx — all imports are sibling files
import type { Invoice } from "./invoice.types";
import { useInvoices } from "./useInvoices";
import { calculateTotal } from "./invoiceCalculations";
import styles from "./invoice.module.css";

export function InvoiceList() {
  const { invoices } = useInvoices();
  return (
    <ul className={styles.list}>
      {invoices.map((invoice: Invoice) => (
        <li key={invoice.id}>{invoice.vendor} — ${calculateTotal(invoice)}</li>
      ))}
    </ul>
  );
}
```

Reference: [Patterns.dev - Module Pattern](https://www.patterns.dev/react/module-pattern)
