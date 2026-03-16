---
title: Know When Data Belongs on Relationship vs. Node
impact: HIGH
impactDescription: "prevents unqueryable properties and semantic confusion"
tags: prop, placement, relationships, nodes, decision
---

## Know When Data Belongs on Relationship vs. Node

Data that describes the connection (when, how much, in what role) belongs on the relationship. Data that describes the entity itself (name, type, inherent attributes) belongs on the node. Data that needs its own connections belongs on an intermediary node. Decision heuristic: (1) Does this data describe the connection? Put it on the relationship. (2) Does this data describe the entity? Put it on the node. (3) Does this data need connections to other entities? Promote to an intermediary node.

**Incorrect (course data collapsed onto the enrollment relationship):**

```cypher
// Course attributes don't describe the enrollment — they describe the course itself
// This makes it impossible to query course details independently
CREATE (s:Student {name: "Alice"})
CREATE (d:Department {name: "Computer Science"})
CREATE (s)-[:ENROLLED_IN {
  courseName: "CS101",
  courseCredits: 3,
  grade: "A",
  semester: "Fall 2024"
}]->(d)

// Can't answer "which courses offer 3 credits?" without scanning all relationships
```

**Correct (enrollment data on relationship, course data on node):**

```cypher
// Connection-specific data (grade, semester) on the relationship
// Entity data (name, credits) on the Course node
CREATE (s:Student {name: "Alice"})
CREATE (c:Course {name: "CS101", credits: 3})
CREATE (d:Department {name: "Computer Science"})
CREATE (s)-[:ENROLLED_IN {grade: "A", semester: "Fall 2024"}]->(c)
CREATE (c)-[:OFFERED_BY]->(d)

// Course details are independently queryable
MATCH (c:Course {credits: 3})-[:OFFERED_BY]->(d)
RETURN c.name, d.name
```
