---
title: Avoid Modeling Relational Join Tables as Nodes
impact: MEDIUM
impactDescription: reduces traversal depth by 2× per join-table elimination
tags: anti, join-table, relational-thinking, indirection
---

## Avoid Modeling Relational Join Tables as Nodes

In relational databases, many-to-many relationships require a join table. In graphs, relationships ARE the join. Creating a node to represent a pure many-to-many connection (no additional data) adds an unnecessary hop to every traversal. Only create intermediary nodes when they carry meaningful data or need their own relationships.

**Incorrect (relational join table ported as a node):**

```cypher
// StudentCourse node is a relational artifact — it carries no additional data
CREATE (s:Student {name: "Alice", id: "s1"})
CREATE (sc:StudentCourse {studentId: "s1", courseId: "c1"})
CREATE (c:Course {name: "Graph Theory", id: "c1"})
CREATE (s)-[:ENROLLED]->(sc)-[:FOR_COURSE]->(c)

// "What courses is Alice taking?" requires 2 hops through a meaningless intermediary:
MATCH (s:Student {name: "Alice"})-[:ENROLLED]->(:StudentCourse)-[:FOR_COURSE]->(c:Course)
RETURN c.name
```

**Correct (relationship carries the enrollment context directly):**

```cypher
// The relationship IS the join — enrollment metadata lives on the relationship
CREATE (s:Student {name: "Alice"})
CREATE (c:Course {name: "Graph Theory"})
CREATE (s)-[:ENROLLED_IN {semester: "Fall 2024", grade: "A", enrolledAt: date("2024-09-01")}]->(c)

// "What courses is Alice taking?" is a single hop:
MATCH (s:Student {name: "Alice"})-[e:ENROLLED_IN]->(c:Course)
RETURN c.name, e.semester, e.grade
// Only promote to a node if enrollment needs its own relationships
// (e.g., linking to an Instructor, Classroom, or FinancialAid entity)
```
