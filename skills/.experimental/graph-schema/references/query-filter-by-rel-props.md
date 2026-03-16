---
title: Use Relationship Properties to Filter Traversals
impact: MEDIUM-HIGH
impactDescription: "reduces traversal scope by 10-100× on time-filtered queries"
tags: query, filtering, relationship-properties, traversal
---

## Use Relationship Properties to Filter Traversals

When relationship properties carry filtering criteria (date ranges, roles, weights), the database can skip entire branches without loading the target node. This is especially effective for time-scoped queries: "find Alice's current employer" filters on the WORKS_AT relationship's `endDate` property, avoiding loading every company Alice has ever worked at.

**Incorrect (loads all target nodes then filters by node property):**

```cypher
// Find Alice's current employer — loads every Company node first, then filters:
MATCH (a:Person {name: "Alice"})-[:WORKS_AT]->(c:Company)
WHERE c.isCurrent = true
RETURN c.name
// Problem: "isCurrent" is on the Company node, but a Company isn't inherently "current" —
// Alice's employment status is about her relationship to the company.
// Also loads all historical employers before filtering.
```

**Correct (filters on relationship properties to prune early):**

```cypher
// Filter on the relationship — the database skips historical employments immediately:
MATCH (a:Person {name: "Alice"})-[w:WORKS_AT]->(c:Company)
WHERE w.endDate IS NULL
RETURN c.name, w.startDate, w.role
// Only current employment relationships (endDate IS NULL) are traversed.
// Historical relationships are pruned at the relationship level,
// their target Company nodes are never loaded.
```
