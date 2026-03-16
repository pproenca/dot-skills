---
title: Plan for Label and Relationship Type Evolution
impact: LOW-MEDIUM
impactDescription: "prevents breaking changes when the domain model evolves"
tags: scale, migration, evolution, schema-change
---

## Plan for Label and Relationship Type Evolution

Unlike relational databases with formal ALTER TABLE migrations, graph databases don't have built-in schema migration tools. Relationship types and labels are immutable identifiers — you cannot rename `:WORKS_AT` to `:EMPLOYED_BY` in-place. Plan for evolution: add new labels and relationships alongside old ones, migrate data in batches, update application code to read from both, then remove the old structure. Never do a big-bang rename.

**Incorrect (big-bang rename — breaks queries during rollout):**

```cypher
// Attempt to rename WORKS_AT to EMPLOYED_BY in a single deployment
// Step 1: Application code changes all queries from WORKS_AT to EMPLOYED_BY
// Step 2: Deploy application — but data still uses WORKS_AT
// Result: All queries return empty results until data is migrated

// During migration window, some servers use old code, some use new
// Old servers: MATCH (p)-[:WORKS_AT]->(c) — works until data is migrated
// New servers: MATCH (p)-[:EMPLOYED_BY]->(c) — returns nothing yet
// Queries are broken for the duration of the migration
```

**Correct (gradual migration — zero downtime):**

```cypher
// Phase 1: Create new relationships alongside old ones
MATCH (p:Employee)-[r:WORKS_AT]->(c:Company)
CREATE (p)-[:EMPLOYED_BY {since: r.since, role: r.role}]->(c)
// Both WORKS_AT and EMPLOYED_BY now exist

// Phase 2: Update application to read from BOTH, write to NEW only
// Queries during transition:
MATCH (p:Employee)-[:WORKS_AT|EMPLOYED_BY]->(c:Company)
RETURN p.name, c.name
// Works regardless of which relationship exists

// Phase 3: Verify data consistency
MATCH (p:Employee)-[old:WORKS_AT]->(c)
WHERE NOT (p)-[:EMPLOYED_BY]->(c)
RETURN count(p) // should be 0 — all migrated

// Phase 4: Remove old relationships (after application no longer reads them)
MATCH ()-[r:WORKS_AT]->()
DELETE r

// Phase 5: Remove WORKS_AT from application query paths
// Now only EMPLOYED_BY exists in both data and code
```
