---
title: Qualify Entities with Multiple Labels
impact: CRITICAL
impactDescription: enables cross-cutting queries without duplication
tags: entity, labels, multi-label, classification
---

## Qualify Entities with Multiple Labels

Real-world entities have multiple facets. A person can be both an Employee and a Manager. Using a single label forces you to either duplicate the node or query by property. Multiple labels let you query by any facet: "all Managers" or "all Employees" or "all Manager-Employees."

**Incorrect (single label with role property or duplicated nodes):**

```cypher
// Option A: role as property — can't query by role without filtering
CREATE (:Person {name: "Alice", role: "manager"})
// MATCH (p:Person {role: "manager"}) requires property scan

// Option B: duplicated nodes — data inconsistency risk
CREATE (:Manager {name: "Alice", email: "alice@corp.com"})
CREATE (:Employee {name: "Alice", email: "alice@corp.com"})
// Updating Alice's email requires finding both nodes
```

**Correct (multiple labels on a single node):**

```cypher
// Queryable as Manager, Employee, or Person without duplication
CREATE (alice:Person:Employee:Manager {name: "Alice", email: "alice@corp.com"})
// MATCH (m:Manager) — finds Alice
// MATCH (e:Employee) — also finds Alice
// MATCH (p:Person:Manager) — finds all managers who are persons
```
