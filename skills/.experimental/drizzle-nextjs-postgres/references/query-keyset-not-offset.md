---
title: Paginate by cursor, not by OFFSET
tags: query, pagination, keyset, index
---

## Paginate by cursor, not by OFFSET

`.limit(20).offset(page * 20)` maps directly onto a page number, which is why it is written every time. Postgres implements `OFFSET` by producing the rows and throwing them away, so page 500 reads 10,020 rows to return 20 and every page costs more than the one before it — the last page of a large list is the slowest request in the app. Keyset pagination asks a different question: not "skip 10,000 rows" but "start after this one", which an index on the sort column answers by seeking straight to the position. Cost stays flat regardless of depth, and rows inserted mid-scroll cannot shift the window and cause a skipped or duplicated row the way `OFFSET` does.

```typescript
import { and, eq, lt, desc, or } from 'drizzle-orm'

export async function listInvoices(
  organizationId: number,
  cursor?: { issuedAt: Date; id: number },
) {
  return db
    .select()
    .from(invoices)
    .where(
      and(
        eq(invoices.organizationId, organizationId),
        // Tie-break on id so rows sharing a timestamp are not skipped.
        cursor
          ? or(
              lt(invoices.issuedAt, cursor.issuedAt),
              and(eq(invoices.issuedAt, cursor.issuedAt), lt(invoices.id, cursor.id)),
            )
          : undefined,
      ),
    )
    .orderBy(desc(invoices.issuedAt), desc(invoices.id))
    .limit(20)
}
```

This requires an index matching the `ORDER BY` — `(organization_id, issued_at DESC, id DESC)` — or Postgres sorts the whole partition anyway and the seek advantage is lost.

**When NOT to use this pattern:** admin screens with genuine numbered page links and a bounded row count. `OFFSET` on a few thousand rows is fine; the problem is depth, not the keyword.

Reference: [Use The Index, Luke — We need tool support for keyset pagination](https://use-the-index-luke.com/no-offset) · [PostgreSQL — LIMIT and OFFSET](https://www.postgresql.org/docs/current/queries-limit.html)
