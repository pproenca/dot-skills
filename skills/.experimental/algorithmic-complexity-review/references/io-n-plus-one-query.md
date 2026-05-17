---
title: Eliminate N+1 Queries by Fetching Related Data in One Round Trip
impact: CRITICAL
impactDescription: N+1 round trips to 1-2 — typical 10-100× wall-clock speedup
tags: io, n-plus-one, orm, batching, database
---

## Eliminate N+1 Queries by Fetching Related Data in One Round Trip

The N+1 problem: 1 query to fetch a list, then N queries to fetch each item's related data. Each extra round trip pays the network/parsing cost regardless of how trivial the SQL is. At 200 items and 5ms per query, that's a full second of latency that vanishes if you fetch all related rows in a single query with `IN (...)` or a join. The pattern is universal across ORMs (Active Record, Django, Sequelize, Hibernate, SQLAlchemy) because the lazy-loading default makes the bug invisible at the call site.

**Incorrect (N+1 — one query per item):**

```python
# Django — issues 1 + len(orders) queries
orders = Order.objects.filter(status='paid')           # 1 query
for order in orders:
    print(order.customer.name)                          # 1 query each
# 200 orders → 201 queries → 201 round trips
```

**Correct (eager load related rows in one query):**

```python
orders = (
    Order.objects.filter(status='paid')
        .select_related('customer')                     # JOIN customer in
)
for order in orders:
    print(order.customer.name)                          # already loaded
# 200 orders → 1 query
```

**Alternative (when relation is many-to-many or reverse FK):**

```python
# Use prefetch_related for collections — 2 queries total, joined in Python
orders = Order.objects.filter(status='paid').prefetch_related('line_items')
```

**Detection:**
Enable query logging in development. Any view that issues queries proportional to the number of items rendered has an N+1 — see the framework's debug toolbar or `django.db.connection.queries`.

Reference: [Django — `select_related` and `prefetch_related`](https://docs.djangoproject.com/en/stable/ref/models/querysets/#select-related)
