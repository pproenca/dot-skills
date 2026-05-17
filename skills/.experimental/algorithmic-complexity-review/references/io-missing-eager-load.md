---
title: Declare Eager-Loading for ORM Relations You Will Access
impact: CRITICAL
impactDescription: N+1 to 1-2 queries — same as N+1 but framed at the schema-traversal level
tags: io, eager-loading, orm, prefetch, select-related
---

## Declare Eager-Loading for ORM Relations You Will Access

Most ORMs lazy-load relations: accessing `order.customer.address.city` issues a query the first time each `.` is dereferenced. Inside a loop, this hides N+1 (then N+1+N, then N+1+N+M…) behind property accesses. Declare upfront which relations the code path needs (`select_related`, `prefetch_related`, `Include`, `JOIN FETCH`) so the ORM emits one or two joined queries instead of a fan-out. This is the same problem as [`io-n-plus-one-query`](io-n-plus-one-query.md) but framed at the schema-graph level: you must tell the ORM *how deep* you intend to traverse.

**Incorrect (lazy chains issue queries on every dot):**

```python
# Django — 1 + N + N queries for a 2-deep traversal
orders = Order.objects.all()
for order in orders:
    print(order.customer.name)                  # query 1
    print(order.customer.address.city)          # query 2
# 200 orders → 401 queries
```

**Correct (declare the traversal upfront):**

```python
orders = Order.objects.select_related('customer__address').all()
for order in orders:
    print(order.customer.name)                  # already joined
    print(order.customer.address.city)          # already joined
# 200 orders → 1 query
```

**Alternative (collection relations use prefetch):**

```python
# Many line items per order — JOIN would explode rows; use a 2-query plan
orders = (
    Order.objects
        .select_related('customer')
        .prefetch_related('line_items__product')
)
```

**Detection:**
The Django debug toolbar (or `django.db.connection.queries`) shows query counts per request. Any controller whose query count scales with rendered items is missing an eager load. Sequelize has `logging`, Active Record has `ActiveSupport::Notifications`, Hibernate has SQL logging.

Reference: [Hibernate — `JOIN FETCH` for eager loading](https://docs.jboss.org/hibernate/orm/current/userguide/html_single/Hibernate_User_Guide.html#fetching)
