---
title: Avoid Redundant Reverse Relationships
impact: CRITICAL
impactDescription: halves storage cost and prevents data inconsistency
tags: rel, redundancy, direction, storage
---

## Avoid Redundant Reverse Relationships

Cypher traverses relationships in any direction. Adding both (:A)-[:FOLLOWS]->(:B) AND (:B)-[:FOLLOWED_BY]->(:A) doubles storage and creates an update consistency problem. Only create reverse relationships when they carry genuinely different semantics.

**Incorrect (redundant reverse relationship):**

```cypher
// Double storage, must keep both in sync on every write
CREATE (alice:User {name: "Alice"})-[:FOLLOWS]->(bob:User {name: "Bob"})
CREATE (bob)-[:FOLLOWED_BY]->(alice)
// Deleting the follow requires removing BOTH relationships
// If one is missed, the graph becomes inconsistent
```

**Correct (single directional relationship, traverse either way):**

```cypher
// Single relationship, query in either direction
CREATE (alice:User {name: "Alice"})-[:FOLLOWS]->(bob:User {name: "Bob"})
// Who does Alice follow?
// MATCH (alice:User {name: "Alice"})-[:FOLLOWS]->(following) RETURN following
// Who follows Bob?
// MATCH (bob:User {name: "Bob"})<-[:FOLLOWS]-(follower) RETURN follower
```

**Exception:** When the reverse relationship carries different properties or semantics, such as a logistics graph where `:SHIPS_TO` and `:RECEIVES_FROM` track different metadata (shipping cost vs. receiving dock).
