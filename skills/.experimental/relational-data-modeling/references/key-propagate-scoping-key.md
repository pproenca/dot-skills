---
title: Propagate the scoping key into child keys
tags: key, composite-key, multi-tenancy, referential-integrity
---

## Propagate the scoping key into child keys

When every table gets its own opaque `id` and children point at parents through
a single-column foreign key, the database can verify that a child's parent
exists but not that the parent is the *right* one. In a multi-tenant schema that
means nothing structurally prevents an order in tenant 7 from referencing a
customer in tenant 3 — the check lives in whatever `WHERE tenant_id = $1` the
application remembered to write, and one missed predicate is a cross-tenant data
leak that no constraint will catch. Carrying the scoping column into the child's
key turns that invariant into a composite foreign key: the mismatch becomes
unrepresentable rather than merely unlikely.

```sql
CREATE TABLE customers (
    tenant_id  bigint NOT NULL REFERENCES tenants,
    id         bigint GENERATED ALWAYS AS IDENTITY,
    email      text   NOT NULL,
    PRIMARY KEY (tenant_id, id),
    UNIQUE (tenant_id, email)
);

CREATE TABLE orders (
    tenant_id    bigint NOT NULL,
    id           bigint GENERATED ALWAYS AS IDENTITY,
    customer_id  bigint NOT NULL,
    placed_at    timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (tenant_id, id),
    -- The tenant column is shared between both halves of this reference, so a
    -- customer from another tenant cannot satisfy it.
    FOREIGN KEY (tenant_id, customer_id) REFERENCES customers (tenant_id, id)
);

CREATE TABLE order_lines (
    tenant_id  bigint NOT NULL,
    order_id   bigint NOT NULL,
    line_no    int    NOT NULL,
    product_id bigint NOT NULL,
    quantity   int    NOT NULL CHECK (quantity > 0),
    PRIMARY KEY (tenant_id, order_id, line_no),
    FOREIGN KEY (tenant_id, order_id) REFERENCES orders (tenant_id, id) ON DELETE CASCADE
);
```

The same shape applies without tenancy wherever a child has no independent
existence: `(order_id, line_no)` gives an order line a meaningful key, natural
clustering with its siblings, and a stable citation in an invoice — none of
which a standalone `line_id` provides.

**When NOT to use this pattern:** the propagated column widens every key and
every index below it. It pays when the invariant it enforces is one you would
otherwise be checking in application code on every query — tenancy, ownership,
containment. It does not pay for a scoping column nobody would ever get wrong.

Reference: [PostgreSQL 18 — Constraints](https://www.postgresql.org/docs/18/ddl-constraints.html)
