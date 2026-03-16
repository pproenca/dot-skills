---
title: Use APOC or Batched Queries for Schema Refactoring
impact: LOW-MEDIUM
impactDescription: "prevents out-of-memory errors on large-scale schema changes"
tags: scale, batch, refactoring, apoc, migration
---

## Use APOC or Batched Queries for Schema Refactoring

Running a single Cypher query to refactor millions of nodes (promoting a property to a node, splitting a label, restructuring relationships) will attempt to hold the entire change in one transaction, exhausting heap memory. Use APOC's `apoc.periodic.iterate` or Neo4j 5+'s `CALL {} IN TRANSACTIONS` to process changes in controlled batches. This is especially critical when creating new nodes and relationships from existing data.

**Incorrect (single transaction — out of memory on large datasets):**

```cypher
// Promoting city property to a City node for 5M Person records
// This creates 5M City nodes + 5M relationships in ONE transaction
MATCH (p:Person)
WHERE p.city IS NOT NULL
CREATE (c:City {name: p.city})
CREATE (p)-[:LIVES_IN]->(c)
REMOVE p.city
// Transaction log grows to gigabytes, heap exhausted, query killed
// Partial work is rolled back — nothing is saved

// Same problem with relationship restructuring
MATCH (p:Person)-[r:WORKS_AT]->(c:Company)
CREATE (e:Employment {since: r.since, until: r.until, role: r.role})
CREATE (p)-[:HAS_EMPLOYMENT]->(e)
CREATE (e)-[:AT_COMPANY]->(c)
DELETE r
// 2M employees x 3 new entities each = 6M creates in one transaction
```

**Correct (batched processing — controlled memory usage):**

```cypher
// Using APOC periodic iterate — processes 1000 nodes per batch
CALL apoc.periodic.iterate(
  "MATCH (p:Person) WHERE p.city IS NOT NULL AND NOT (p)-[:LIVES_IN]->() RETURN p",
  "MERGE (c:City {name: p.city})
   CREATE (p)-[:LIVES_IN]->(c)
   REMOVE p.city",
  {batchSize: 1000, parallel: false}
)
// Processes 1000 Person nodes at a time, commits each batch
// If interrupted, completed batches are saved

// Neo4j 5+ native batching — no APOC required
MATCH (p:Person) WHERE p.city IS NOT NULL AND NOT (p)-[:LIVES_IN]->()
CALL (p) {
  MERGE (c:City {name: p.city})
  CREATE (p)-[:LIVES_IN]->(c)
  REMOVE p.city
} IN TRANSACTIONS OF 1000 ROWS
// Commits every 1000 rows — predictable memory usage
// Reports progress: "Added X nodes, created Y relationships"
```
