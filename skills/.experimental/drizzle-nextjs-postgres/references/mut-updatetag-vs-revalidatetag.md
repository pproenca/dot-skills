---
title: Use updateTag after a mutation the user must see immediately
tags: mut, server-actions, revalidate-tag, cache-invalidation
---

## Use updateTag after a mutation the user must see immediately

`revalidateTag('invoices')` is the reflex after a write, and in Next.js 16 it is no longer the only option or the clearest one. `revalidateTag` with a cache profile like `'max'` is stale-while-revalidate: the next request is served the *old* value while a fresh one is computed behind it, so a user who just created an invoice and gets redirected to the list may not see it. `updateTag` expires the tag outright, making the next request wait for fresh data — which is the behavior "read your own writes" actually requires. The trade is a slower next request in exchange for correctness, and after a user's own mutation that is the right side of the trade.

```typescript
// app/invoices/actions.ts
'use server'

import { updateTag } from 'next/cache'
import { redirect } from 'next/navigation'

export async function createInvoice(formData: FormData) {
  const session = await requireSession()
  const [invoice] = await db.insert(invoices).values(/* ... */).returning()

  updateTag(`org-${session.organizationId}-invoices`) // the list page
  updateTag(`invoice-${invoice.id}`)                   // the detail page

  redirect(`/invoices/${invoice.id}`) // lands on fresh data, not the stale cache
}
```

`updateTag` throws outside a Server Action. In a Route Handler or an inbound webhook — where nobody is waiting to see their own change — use `revalidateTag(tag, 'max')` and take the stale-while-revalidate behavior.

Reference: [Next.js — updateTag](https://nextjs.org/docs/app/api-reference/functions/updateTag) · [Next.js — revalidateTag](https://nextjs.org/docs/app/api-reference/functions/revalidateTag)
