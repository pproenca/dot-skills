---
title: Avoid Porting Relational Schemas Directly to Graph
impact: MEDIUM
impactDescription: "prevents graphs that are just slow, denormalized relational databases"
tags: anti, relational, migration, thinking
---

## Avoid Porting Relational Schemas Directly to Graph

Directly mapping relational tables to node labels and foreign keys to properties produces a graph that's worse than the relational original. Graph databases shine when you model relationships as first-class citizens. A ported relational schema has no traversable relationships, no semantic meaning in its labels, and pays the overhead of a graph engine while getting none of the benefits.

**Incorrect (direct table-to-label mapping with foreign keys as properties):**

```cypher
// Tables ported 1:1 — foreign keys stored as properties, no relationships
CREATE (u:users {id: 1, name: "Alice", email: "alice@example.com"})
CREATE (o:orders {id: 100, user_id: 1, product_id: 50, status: "shipped"})
CREATE (p:products {id: 50, name: "Widget", category_id: 10})
CREATE (c:categories {id: 10, name: "Gadgets"})

// "What did Alice order?" requires property-matching instead of traversal:
MATCH (u:users {id: 1})
MATCH (o:orders {user_id: u.id})
MATCH (p:products {id: o.product_id})
RETURN p.name, o.status
// This is just a relational JOIN emulated in Cypher — slower and more awkward
```

**Correct (domain-driven graph model with relationships as first-class citizens):**

```cypher
// Domain concepts replace table names; relationships replace foreign keys
CREATE (alice:Customer {name: "Alice", email: "alice@example.com"})
CREATE (order:Order {placedAt: datetime("2024-11-01T14:30:00Z"), status: "shipped"})
CREATE (widget:Product {name: "Widget"})
CREATE (gadgets:Category {name: "Gadgets"})

CREATE (alice)-[:PLACED]->(order)
CREATE (order)-[:CONTAINS {quantity: 2, unitPrice: 29.99}]->(widget)
CREATE (widget)-[:IN_CATEGORY]->(gadgets)

// "What did Alice order?" is a natural traversal:
MATCH (alice:Customer {name: "Alice"})-[:PLACED]->(o:Order)-[:CONTAINS]->(p:Product)
RETURN p.name, o.status
// Clean, readable, and leverages the graph engine's traversal strengths
```
