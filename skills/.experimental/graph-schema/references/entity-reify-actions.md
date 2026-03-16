---
title: Reify Lifecycle Actions into Nodes
impact: CRITICAL
impactDescription: enables 3-5x richer queries on business events
tags: entity, reification, actions, lifecycle, event-sourcing
---

## Reify Lifecycle Actions into Nodes

When an action has its own lifecycle or needs to connect to follow-up events, it must be a node. A Purchase transitions through states (created, shipped, delivered, returned) and links to downstream events (refund, complaint, review). Modeling it as a relationship locks out the entire event chain. Verbs like "purchased", "reviewed", "transferred" carry rich context (amount, rating, reason) that doesn't fit on a relationship.

**Incorrect (action collapsed into a relationship):**

```cypher
// Can't connect to ShippingAddress, link to a return/refund, or add line items
CREATE (:Customer {name: "Alice"})-[:PURCHASED {price: 29.99, date: "2024-03-15", paymentMethod: "card", shippingSpeed: "express"}]->(:Product {name: "Wireless Headphones"})
```

**Correct (action reified as a node):**

```cypher
// The Purchase node connects to all participants in the transaction
CREATE (alice:Customer {name: "Alice"})-[:MADE]->(purchase:Purchase {price: 29.99, date: date("2024-03-15"), status: "completed"})-[:OF]->(headphones:Product {name: "Wireless Headphones"})
CREATE (purchase)-[:PAID_WITH]->(card:CreditCard {last4: "4242"})
CREATE (purchase)-[:SHIPPED_TO]->(addr:Address {street: "456 Oak Ave", city: "Portland"})
CREATE (purchase)-[:FULFILLED_BY]->(warehouse:Warehouse {code: "PDX-01"})
// Returns and refunds can now link back to the Purchase
CREATE (refund:Refund {amount: 29.99, reason: "defective"})-[:FOR]->(purchase)
```

**See also:** [`entity-events`](entity-events.md) for multi-participant events (3+ entities connected to the same action).
