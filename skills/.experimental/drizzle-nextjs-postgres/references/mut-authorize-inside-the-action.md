---
title: Authorize and validate inside the Server Action, not at the call site
tags: mut, server-actions, authorization, drizzle-zod
---

## Authorize and validate inside the Server Action, not at the call site

A Server Action reads like a function the component calls, so the checks end up where the button is rendered — the page confirms the user is an admin, then hands the action to a form. But the action compiles to a public POST endpoint with a stable generated ID: anyone who has seen the page can call it directly with any payload, skipping the component that did the checking. Treat every action body as the top of an untrusted request. The same applies to the payload — `FormData` values are strings of arbitrary length and content until something narrows them, and passing them straight into `db.insert()` hands the caller control of the row.

```typescript
// app/invoices/actions.ts
'use server'

import { createInsertSchema } from 'drizzle-zod'
import { updateTag } from 'next/cache'
import { db } from '@/lib/db'
import { invoices } from '@/lib/db/schema'
import { getSession } from '@/lib/auth'

const newInvoiceSchema = createInsertSchema(invoices).pick({ reference: true, amountCents: true })

export async function createInvoice(formData: FormData) {
  // 1. Authenticate and authorize here — not in the component that rendered the form.
  const session = await getSession()
  if (!session) throw new Error('Unauthorized')

  // 2. Validate the payload before it reaches the query builder.
  const input = newInvoiceSchema.parse({
    reference: formData.get('reference'),
    amountCents: Number(formData.get('amountCents')),
  })

  // 3. Scope the write to the session's tenant — never to an id from the payload.
  const [invoice] = await db
    .insert(invoices)
    .values({ ...input, organizationId: session.organizationId })
    .returning()

  updateTag(`org-${session.organizationId}-invoices`)
  return invoice
}
```

Step 3 is the one most often skipped: taking `organizationId` from `formData` rather than the session turns a validated action into a cross-tenant write. Derive every ownership column from the session.

Reference: [Next.js — Security thinking in Server Components and Server Actions](https://nextjs.org/blog/security-nextjs-server-components-actions) · [Drizzle — drizzle-zod](https://orm.drizzle.team/docs/zod)
