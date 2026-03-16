---
title: Choose Semantically Meaningful Relationship Direction
impact: CRITICAL
impactDescription: "prevents directional ambiguity and query logic errors"
tags: rel, direction, semantics, readability
---

## Choose Semantically Meaningful Relationship Direction

Relationship direction should reflect the domain's natural flow: who acts on whom, what contains what, what depends on what. While Cypher can traverse in either direction, a consistently-directed graph is readable as English: "Alice MANAGES Bob", not "Bob MANAGES Alice" (unless Bob manages Alice).

**Incorrect (inconsistent or inverted direction):**

```cypher
// Mixed direction conventions across the same graph — confusing and error-prone
CREATE (:Employee {name: "Alice"})-[:WORKS_FOR]->(:Company {name: "Acme"})
CREATE (:Company {name: "Globex"})-[:EMPLOYS]->(:Employee {name: "Bob"})
// Some edges flow employee->company, others company->employee
// Query authors must guess the direction for each relationship type
```

**Correct (consistent direction following natural domain flow):**

```cypher
// Always flow from actor to target, from specific to general
CREATE (alice:Employee {name: "Alice"})-[:WORKS_AT]->(acme:Company {name: "Acme"})
CREATE (bob:Employee {name: "Bob"})-[:WORKS_AT]->(globex:Company {name: "Globex"})
CREATE (alice)-[:MANAGES]->(bob)
CREATE (alice)-[:AUTHORED]->(article:Article {title: "Graph Modeling Guide"})
// Traverse either direction in queries when needed:
// MATCH (c:Company)<-[:WORKS_AT]-(e) RETURN c.name, collect(e.name)
```
