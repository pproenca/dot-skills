---
title: Test Your Model Against Real Queries Before Deploying
impact: MEDIUM-HIGH
impactDescription: "prevents 10-100× refactoring cost post-deployment"
tags: query, testing, validation, proof-of-concept
---

## Test Your Model Against Real Queries Before Deploying

Create a small test dataset (50-100 nodes) and run your top 10 queries against it. If a query requires awkward workarounds, the model is wrong — fix it now. Use `PROFILE` to check execution plans and verify traversal patterns match expectations. A model that can't answer your questions with clean Cypher needs redesign before it reaches production.

**Incorrect (deploy a whiteboard design, discover problems in production):**

```cypher
// Schema designed on a whiteboard, deployed directly.
// In production, "find mutual friends" requires 4 collections and UNWIND:
MATCH (a:Person {name: "Alice"})-[:KNOWS]->(f:Person)
WITH collect(f) AS aliceFriends
MATCH (b:Person {name: "Bob"})-[:KNOWS]->(f:Person)
WITH aliceFriends, collect(f) AS bobFriends
UNWIND aliceFriends AS af
WITH af, bobFriends
WHERE af IN bobFriends
RETURN af.name
// Awkward — the model forces collecting and intersecting instead of traversing.
// This could have been caught with a 10-node test dataset.
```

**Correct (test early with sample data and PROFILE):**

```cypher
// Step 1: Create a small test dataset
CREATE (alice:Person {name: "Alice"})
CREATE (bob:Person {name: "Bob"})
CREATE (carol:Person {name: "Carol"})
CREATE (dave:Person {name: "Dave"})
CREATE (alice)-[:FRIEND_OF]->(carol)
CREATE (bob)-[:FRIEND_OF]->(carol)
CREATE (alice)-[:FRIEND_OF]->(dave)
CREATE (bob)-[:FRIEND_OF]->(dave)

// Step 2: Run the query — clean 2-hop traversal confirms the model works
PROFILE
MATCH (a:Person {name: "Alice"})-[:FRIEND_OF]->(mutual)<-[:FRIEND_OF]-(b:Person {name: "Bob"})
RETURN mutual.name
// PROFILE output shows: NodeByLabelScan -> Expand -> Expand -> Filter
// Clean traversal, no UNWIND hacks, no collection gymnastics.
// If the PROFILE showed CartesianProduct or EagerAggregation, refactor the model.
```
