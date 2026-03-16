---
title: Use Specific Labels Over Generic Ones
impact: CRITICAL
impactDescription: reduces traversal scope by orders of magnitude
tags: entity, labels, specificity, query-performance
---

## Use Specific Labels Over Generic Ones

A label like `:Entity` or `:Node` forces every query to filter by property. Specific labels (`:Customer`, `:Product`, `:Order`) let the database scan only relevant nodes. Labels are the primary access mechanism in property graphs.

**Incorrect (generic label with type property):**

```cypher
// Queries must filter every node in the graph
CREATE (:Record {type: "Customer", name: "Alice", email: "alice@example.com"})
CREATE (:Record {type: "Product", name: "Widget", price: 29.99})
CREATE (:Record {type: "Order", orderId: "ORD-1001", total: 59.98})
// MATCH (n:Record {type: "Customer"}) scans ALL Record nodes
```

**Correct (specific labels per domain concept):**

```cypher
// Queries target exactly the right subset of nodes
CREATE (:Customer {name: "Alice", email: "alice@example.com"})
CREATE (:Product {name: "Widget", price: 29.99})
CREATE (:Order {orderId: "ORD-1001", total: 59.98})
// MATCH (c:Customer) scans only Customer nodes
```
