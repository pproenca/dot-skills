---
title: One Relationship Type per Semantic Meaning
impact: CRITICAL
impactDescription: prevents ambiguous traversals and query errors
tags: rel, semantics, types, clarity
---

## One Relationship Type per Semantic Meaning

Using the same relationship type for different meanings (e.g., `:HAS` for both "Company HAS Employee" and "Order HAS LineItem") makes queries return wrong results. Each relationship type should have one clear meaning across the entire graph.

**Incorrect (overloaded relationship type):**

```cypher
// "HAS" means three completely different things
CREATE (:Company {name: "Acme"})-[:HAS]->(:Employee {name: "Alice"})
CREATE (:Order {id: "ORD-1001"})-[:HAS]->(:LineItem {product: "Widget", qty: 2})
CREATE (:Person {name: "Alice"})-[:HAS]->(:Skill {name: "Python"})
// MATCH (n)-[:HAS]->(target) returns employees, line items, AND skills
// Queries become unpredictable and require label filtering to disambiguate
```

**Correct (one type per semantic meaning):**

```cypher
// Each relationship type has one unambiguous meaning across the graph
CREATE (:Company {name: "Acme"})-[:EMPLOYS]->(:Employee {name: "Alice"})
CREATE (:Order {id: "ORD-1001"})-[:CONTAINS]->(:LineItem {product: "Widget", qty: 2})
CREATE (:Person {name: "Alice"})-[:HAS_SKILL]->(:Skill {name: "Python"})
// MATCH (o:Order)-[:CONTAINS]->(li) returns only line items, never employees or skills
```
