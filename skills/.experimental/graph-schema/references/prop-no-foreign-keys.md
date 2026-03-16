---
title: Avoid Embedding Foreign Keys as Properties
impact: HIGH
impactDescription: "eliminates the #1 relational-thinking mistake in graphs"
tags: prop, foreign-keys, relational-thinking, relationships
---

## Avoid Embedding Foreign Keys as Properties

In relational databases, foreign keys link tables. In graph databases, relationships ARE the links. Storing `managerId: "123"` as a property on an Employee node duplicates the graph's native capability and forces queries to do property lookups instead of traversals.

**Incorrect (foreign keys stored as properties):**

```cypher
// Foreign keys force expensive property lookups to resolve connections
CREATE (:Employee {name: "Alice", managerId: "emp-42", departmentId: "dept-7"})

// Finding Alice's manager requires scanning all employees by ID
MATCH (e:Employee {name: "Alice"})
MATCH (mgr:Employee {employeeId: e.managerId})
RETURN mgr
```

**Correct (relationships replace foreign keys):**

```cypher
// Relationships are the native connection mechanism in graphs
CREATE (alice:Employee {name: "Alice"})
CREATE (mgr:Employee {employeeId: "emp-42", name: "Bob"})
CREATE (dept:Department {deptId: "dept-7", name: "Engineering"})
CREATE (alice)-[:REPORTS_TO]->(mgr)
CREATE (alice)-[:BELONGS_TO]->(dept)

// Finding Alice's manager is a single traversal — no property scan
MATCH (:Employee {name: "Alice"})-[:REPORTS_TO]->(mgr)
RETURN mgr
```
