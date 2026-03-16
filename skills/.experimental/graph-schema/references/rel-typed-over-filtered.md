---
title: Prefer Typed Relationships Over Generic + Property Filter
impact: CRITICAL
impactDescription: eliminates property filtering on every traversal
tags: rel, types, filtering, performance
---

## Prefer Typed Relationships Over Generic + Property Filter

**This rule is about performance.** Creating a generic relationship with a `type` property forces every query to filter: `WHERE r.type = "friend"`. The database must scan every edge of that type and check the property -- it cannot use the relationship type index to skip irrelevant edges. Separate relationship types let the engine skip entire edge sets. The cost is more relationship types in your schema, but the benefit is faster queries.

**Incorrect (generic relationship with type property):**

```cypher
// Must filter on every query — scans all KNOWS edges
CREATE (alice:Person {name: "Alice"})-[:KNOWS {type: "friend", since: "2020-01-01"}]->(bob:Person {name: "Bob"})
CREATE (alice)-[:KNOWS {type: "colleague", since: "2022-06-15"}]->(charlie:Person {name: "Charlie"})
CREATE (alice)-[:KNOWS {type: "neighbor", since: "2023-03-01"}]->(dana:Person {name: "Dana"})
// Finding Alice's friends:
// MATCH (alice)-[r:KNOWS {type: "friend"}]->(friend) — filters all KNOWS edges
```

**Correct (distinct relationship types):**

```cypher
// Each relationship type is traversed independently — no filtering needed
CREATE (alice:Person {name: "Alice"})-[:FRIEND_OF {since: date("2020-01-01")}]->(bob:Person {name: "Bob"})
CREATE (alice)-[:COLLEAGUE_OF {since: date("2022-06-15")}]->(charlie:Person {name: "Charlie"})
CREATE (alice)-[:NEIGHBOR_OF {since: date("2023-03-01")}]->(dana:Person {name: "Dana"})
// MATCH (alice)-[:FRIEND_OF]->(friend) — only traverses friend edges, skips all others
```

**See also:** [`rel-specific-types`](rel-specific-types.md) for the semantic naming argument. [`anti-generic-relationships`](anti-generic-relationships.md) for avoiding truly generic types like RELATED_TO.
