---
title: Use Specific Relationship Types Over Generic Ones
impact: CRITICAL
impactDescription: enables targeted traversals, avoids full-graph scans
tags: rel, naming, specificity, semantics
---

## Use Specific Relationship Types Over Generic Ones

A relationship type like `:RELATED_TO` or `:CONNECTS` forces every query to check a property to understand the relationship's meaning. Specific types (`:MANAGES`, `:REPORTS_TO`, `:AUTHORED`) let the database follow only relevant edges and make queries self-documenting.

**Incorrect (generic relationship with type property):**

```cypher
// Must filter by property on every traversal
CREATE (alice:Person {name: "Alice"})-[:RELATED_TO {type: "manages"}]->(bob:Person {name: "Bob"})
CREATE (alice)-[:RELATED_TO {type: "mentors"}]->(charlie:Person {name: "Charlie"})
// Finding who Alice manages requires filtering:
// MATCH (alice)-[r:RELATED_TO {type: "manages"}]->(report) — scans all RELATED_TO edges
```

**Correct (specific relationship type per semantic meaning):**

```cypher
// Traversal only follows management edges
CREATE (alice:Person {name: "Alice"})-[:MANAGES]->(bob:Person {name: "Bob"})
CREATE (alice)-[:MENTORS]->(charlie:Person {name: "Charlie"})
// MATCH (alice)-[:MANAGES]->(report) — skips all non-MANAGES edges entirely
```
