---
title: Defer audit and analytics writes with after()
tags: mut, after, latency, audit-log
---

## Defer audit and analytics writes with after()

Secondary writes get appended to the action body because that is where the data is — the invoice is created, then an audit row is inserted, then a usage counter is bumped, then a webhook is posted. Every one of those is on the user's critical path even though none of them affects what the user sees. `after()` schedules work to run once the response is finished, so the round trips move off the response and onto the platform's post-response window. On serverless this is implemented via `waitUntil`, which keeps the invocation alive until the callback settles rather than letting it be killed mid-insert — which is what happens if you merely drop the `await` and let the promise float.

```typescript
// app/invoices/actions.ts
'use server'

import { after } from 'next/server'
import { updateTag } from 'next/cache'

export async function createInvoice(formData: FormData) {
  const session = await requireSession()
  const [invoice] = await db.insert(invoices).values(/* ... */).returning()

  updateTag(`org-${session.organizationId}-invoices`)

  after(async () => {
    await db.insert(auditLog).values({
      actorId: session.userId,
      action: 'invoice.created',
      subjectId: invoice.id,
    })
  })

  return invoice // the user is not waiting on the audit write
}
```

`after` runs even when the action throws, redirects, or calls `notFound()`, so it is a reasonable place for "this happened" logging but a poor place for anything the mutation's correctness depends on. In a **Server Component** (not an action), `cookies()` and `headers()` throw inside the callback — read them during render and close over the values.

Reference: [Next.js — after](https://nextjs.org/docs/app/api-reference/functions/after)
