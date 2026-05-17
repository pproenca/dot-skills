---
title: Paginate by Cursor (`starting_after`/`ending_before`), Not by Offset
impact: HIGH
impactDescription: prevents skipped and duplicated items when the dataset changes mid-iteration
tags: format, pagination, cursor, offset
---

## Paginate by Cursor (`starting_after`/`ending_before`), Not by Offset

List endpoints paginate by object ID, not by numeric offset. Parameters: `limit` (default 10, max 100), `starting_after=<id>` to move forward, `ending_before=<id>` to move backward. The cursor is the ID of the last (or first) item on the previous page. The two cursor params are mutually exclusive — you can paginate in one direction at a time.

Offset pagination (`?page=3&page_size=10` or `?offset=30&limit=10`) breaks under concurrent inserts and deletes: an item added between requests can be skipped, an item deleted can cause the next page to repeat. Cursor pagination is stable — each page is anchored to an immutable ID, so iteration produces the correct items even when the underlying dataset is changing.

**Incorrect (offset-based pagination):**

```text
GET /v1/customers?page=2&page_size=10
GET /v1/customers?offset=20&limit=10
```

```text
// Between page 2 and page 3, a new customer is inserted → page 3 repeats one item.
// Or a customer is deleted → page 3 skips one item.
// Total counts (page count) require expensive table scans.
```

**Correct (cursor pagination with object IDs):**

```text
# First page
GET /v1/customers?limit=10

# Response: data = [cus_a, cus_b, ..., cus_j], has_more = true

# Next page — cursor is the ID of the last item on the previous page
GET /v1/customers?limit=10&starting_after=cus_j

# Response: data = [cus_k, cus_l, ..., cus_t], has_more = true
```

```text
// Cursor is the immutable ID `cus_j` — points to a specific item.
// Inserts/deletes elsewhere in the dataset don't shift the iteration position.
// No skipped or duplicated items even under heavy concurrent writes.
```

**Backward pagination:**

```text
GET /v1/customers?limit=10&ending_before=cus_k
# Returns the 10 items immediately preceding cus_k
```

**Default ordering is reverse-chronological** (newest first). The cursor implicitly inherits this order — `starting_after` means "give me items older than this one" because the list is sorted newest-first.

**Iterate until `has_more` is false, not by checking `data.length`:**

```javascript
let starting_after = null;
while (true) {
  const params = { limit: 100 };
  if (starting_after) params.starting_after = starting_after;
  const page = await stripe.customers.list(params);
  for (const customer of page.data) {
    // process customer
  }
  if (!page.has_more) break;
  starting_after = page.data[page.data.length - 1].id;
}
```

**Provide SDK auto-pagination helpers** that hide the cursor mechanics behind a generator or async iterator — most integrators want to iterate, not paginate.

**Limit clamping:** if a caller sends `limit=10000`, clamp silently to the maximum (Stripe uses 100). Don't error — let them iterate.

Reference: [Stripe pagination](https://docs.stripe.com/api/pagination)
