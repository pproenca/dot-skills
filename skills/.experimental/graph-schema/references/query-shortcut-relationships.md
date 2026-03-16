---
title: Add Shortcut Relationships for Frequent Multi-Hop Queries
impact: MEDIUM-HIGH
impactDescription: "reduces 3-5 hop traversals to 1 hop for hot paths"
tags: query, shortcut, denormalization, materialized
---

## Add Shortcut Relationships for Frequent Multi-Hop Queries

When a query frequently traverses the same multi-hop path (e.g., "all colleagues who worked at the same company in the same year"), adding a precomputed shortcut relationship trades storage for query speed. The shortcut is redundant data — maintain it via application logic or triggers. Document shortcuts as derived data so future developers know the relationship is computed, not source-of-truth.

**Incorrect (every "find colleagues" query traverses the full path):**

```cypher
// Finding colleagues requires traversing through Employment nodes every time:
// Person -> Employment -> Company <- Employment <- Person
MATCH (a:Person {name: "Alice"})-[:HAD_ROLE]->(e1:Employment)
      -[:AT_COMPANY]->(c:Company)<-[:AT_COMPANY]-(e2:Employment)
      <-[:HAD_ROLE]-(colleague:Person)
WHERE e1.startYear <= e2.endYear AND e2.startYear <= e1.endYear
  AND colleague <> a
RETURN colleague.name, c.name AS company
// Expensive at social-network scale — runs on every page load of "People you may know"
```

**Correct (precomputed shortcut with canonical path preserved):**

```cypher
// Precompute the shortcut relationship via a batch job:
MATCH (a:Person)-[:HAD_ROLE]->(e1:Employment)
      -[:AT_COMPANY]->(c:Company)<-[:AT_COMPANY]-(e2:Employment)
      <-[:HAD_ROLE]-(b:Person)
WHERE e1.startYear <= e2.endYear AND e2.startYear <= e1.endYear
  AND a <> b
MERGE (a)-[:COLLEAGUE_OF {company: c.name, period: e1.startYear + "-" + e2.endYear, _derived: true}]->(b)

// Hot query is now 1 hop:
MATCH (a:Person {name: "Alice"})-[r:COLLEAGUE_OF]->(colleague:Person)
RETURN colleague.name, r.company, r.period
// The canonical Employment path remains for correctness and audit
```
