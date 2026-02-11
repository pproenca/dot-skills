---
title: Colocate Files by Feature Instead of Type
impact: CRITICAL
impactDescription: reduces cross-directory navigation by 70%, makes features self-contained
tags: arch, colocation, project-structure, feature-modules
---

## Colocate Files by Feature Instead of Type

Organizing by type (components/, hooks/, styles/, tests/) scatters the files for a single feature across the entire tree. Changing one feature requires editing 4-6 directories. Feature-based colocation puts everything for a feature in one folder, so additions and deletions affect a single directory.

**Incorrect (type-based — feature scattered across directories):**

```tsx
// Adding "invoice" feature touches 5 directories
// src/
//   components/
//     InvoiceList.tsx
//     InvoiceRow.tsx
//     InvoiceForm.tsx
//   hooks/
//     useInvoices.ts
//     useInvoiceForm.ts
//   types/
//     invoice.ts
//   utils/
//     invoiceCalculations.ts
//   __tests__/
//     InvoiceList.test.tsx
//     useInvoices.test.ts

// Deleting the feature means hunting across all 5 directories
import { useInvoices } from "../../hooks/useInvoices";
import { Invoice } from "../../types/invoice";
import { calculateTotal } from "../../utils/invoiceCalculations";
import { InvoiceRow } from "./InvoiceRow";
```

**Correct (feature-based — self-contained module):**

```tsx
// Deleting "invoice" feature = delete one folder
// src/
//   features/
//     invoice/
//       InvoiceList.tsx
//       InvoiceRow.tsx
//       InvoiceForm.tsx
//       useInvoices.ts
//       useInvoiceForm.ts
//       invoice.types.ts
//       invoiceCalculations.ts
//       __tests__/
//         InvoiceList.test.tsx
//         useInvoices.test.ts
//       index.ts          <- public API for other features

// All imports are local — no cross-directory navigation
import { useInvoices } from "./useInvoices";
import { Invoice } from "./invoice.types";
import { calculateTotal } from "./invoiceCalculations";
import { InvoiceRow } from "./InvoiceRow";
```

Reference: [Kent C. Dodds - Colocation](https://kentcdodds.com/blog/colocation)
