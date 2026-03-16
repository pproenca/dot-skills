---
title: Promote Shared Property Values to Nodes
impact: CRITICAL
impactDescription: eliminates redundant data, enables faceted queries
tags: entity, deduplication, shared-values, normalization
---

## Promote Shared Property Values to Nodes

When the same value (e.g., a city name, a skill, a tag) appears as a property on hundreds of nodes, you lose the ability to query "all people in London" efficiently and you duplicate storage. Promote to a node when the value is shared across 3+ entities OR when you need to traverse through it.

**Incorrect (shared value duplicated as inline properties):**

```cypher
// No way to find all Londoners without a full property scan across every Person node
CREATE (:Person {name: "Alice", city: "London"})
CREATE (:Person {name: "Bob", city: "London"})
CREATE (:Person {name: "Charlie", city: "London"})
// MATCH (p:Person {city: "London"}) must scan all Person nodes
```

**Correct (shared value promoted to a node):**

```cypher
// All Londoners found by traversing from the City node
CREATE (london:City {name: "London", country: "UK"})
CREATE (:Person {name: "Alice"})-[:LIVES_IN]->(london)
CREATE (:Person {name: "Bob"})-[:LIVES_IN]->(london)
CREATE (:Person {name: "Charlie"})-[:LIVES_IN]->(london)
// MATCH (:City {name: "London"})<-[:LIVES_IN]-(p) traverses only relevant edges
```
