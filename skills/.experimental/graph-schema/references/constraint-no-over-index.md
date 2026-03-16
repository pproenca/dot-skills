---
title: Avoid Over-Indexing — Each Index Has a Write Cost
impact: MEDIUM
impactDescription: "prevents write amplification that degrades insert and update performance"
tags: constraint, index, write-performance, over-indexing
---

## Avoid Over-Indexing — Each Index Has a Write Cost

Every index must be updated on every write to the indexed property. In write-heavy workloads (event ingestion, IoT sensors, real-time activity feeds), over-indexing can degrade write throughput significantly. Index only properties that serve as query entry points or appear in frequent WHERE clauses — not every property on a node.

**Incorrect (indexes on every property — write amplification):**

```cypher
// Indexing every property on Person — 7 indexes
CREATE INDEX person_email FOR (p:Person) ON (p.email)
CREATE INDEX person_name FOR (p:Person) ON (p.name)
CREATE INDEX person_age FOR (p:Person) ON (p.age)
CREATE INDEX person_created FOR (p:Person) ON (p.createdAt)
CREATE INDEX person_last_login FOR (p:Person) ON (p.lastLogin)
CREATE INDEX person_bio FOR (p:Person) ON (p.bio)
CREATE INDEX person_avatar FOR (p:Person) ON (p.avatarUrl)

// Every Person write now updates 7 indexes
// lastLogin updates on every session — 7 index writes per login
SET p.lastLogin = datetime() // triggers index maintenance on all 7
```

**Correct (index only entry-point properties — minimal write overhead):**

```cypher
// email is a unique identifier — constrained (auto-indexed)
CREATE CONSTRAINT person_email_unique FOR (p:Person) REQUIRE p.email IS UNIQUE

// createdAt is used for time-range queries (e.g., "users who signed up this month")
CREATE INDEX person_created FOR (p:Person) ON (p.createdAt)

// name, age, bio, avatarUrl, lastLogin are NOT indexed
// They are accessed after traversal, not used as query entry points
// e.g., MATCH (p:Person)-[:FRIEND_OF]->(f) RETURN f.name
//        f is found via traversal — f.name doesn't need an index

// Only 2 indexes maintained on writes instead of 7
SET p.lastLogin = datetime() // no unnecessary index maintenance
```
