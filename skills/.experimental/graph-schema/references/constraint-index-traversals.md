---
title: Create Indexes on Properties Used as Traversal Entry Points
impact: MEDIUM
impactDescription: "turns O(n) lookups into O(log n) for query starting points"
tags: constraint, index, lookup, entry-point
---

## Create Indexes on Properties Used as Traversal Entry Points

Every graph query starts somewhere — typically by finding a specific node via a property lookup (`WHERE p.email = "alice@example.com"`). Without an index, this requires a full label scan over every node with that label. Index the properties that serve as query entry points: identifiers, names, dates used in range filters. Don't index properties that are only accessed after a traversal — those nodes are already found by following edges.

**Incorrect (no index — full label scan on every query start):**

```cypher
// No index on email — this scans every Person node to find Alice
MATCH (p:Person {email: "alice@example.com"})-[:PLACED]->(o:Order)
RETURN o.total, o.date
// With 10M Person nodes, this initial lookup is O(n) — slow

// No index on Order.date — range queries scan all orders
MATCH (o:Order)
WHERE o.date >= date("2024-01-01") AND o.date < date("2024-02-01")
RETURN o.orderNumber, o.total
// Full scan of every Order node to filter by date range
```

**Correct (indexes on entry-point properties — O(log n) lookups):**

```cypher
// Index on the property used to start traversals
CREATE INDEX person_email FOR (p:Person) ON (p.email)

// Composite index for queries that filter on multiple properties
CREATE INDEX order_date_status FOR (o:Order) ON (o.date, o.status)

// Now these queries use the index for fast entry-point lookup
MATCH (p:Person {email: "alice@example.com"})-[:PLACED]->(o:Order)
RETURN o.total, o.date
// O(log n) lookup for Alice, then traversal to her orders

// Range query uses the composite index
MATCH (o:Order)
WHERE o.date >= date("2024-01-01") AND o.status = "SHIPPED"
RETURN o.orderNumber, o.total
// Index narrows to matching orders — no full scan
```
