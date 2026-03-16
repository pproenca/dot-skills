---
title: Avoid Property Arrays When You Need Relationships
impact: HIGH
impactDescription: "prevents O(n) scans on opaque array values"
tags: prop, arrays, relationships, traversal
---

## Avoid Property Arrays When You Need Relationships

Storing connections as arrays (e.g., `skills: ["Python", "Go", "Rust"]`) prevents you from querying "who else has Python?", adding metadata to each skill (proficiency level), or connecting skills to certifications. Arrays are opaque blobs; relationships are traversable.

**Incorrect (connections stored as property arrays):**

```cypher
// Arrays are opaque — can't traverse, index, or enrich individual items
CREATE (:Person {
  name: "Alice",
  skills: ["Python", "Go", "Rust"],
  interests: ["hiking", "chess"]
})

// Finding who shares a skill with Alice requires scanning ALL Person nodes
// and comparing array contents — no graph traversal possible
MATCH (a:Person {name: "Alice"}), (other:Person)
WHERE any(s IN a.skills WHERE s IN other.skills) AND other <> a
RETURN other
```

**Correct (connections modeled as relationships to nodes):**

```cypher
// Each skill is a node — traversable, queryable, enrichable with metadata
CREATE (alice:Person {name: "Alice"})
CREATE (python:Skill {name: "Python"})
CREATE (go:Skill {name: "Go"})
CREATE (rust:Skill {name: "Rust"})
CREATE (alice)-[:HAS_SKILL {level: "expert", since: date("2018-01-01")}]->(python)
CREATE (alice)-[:HAS_SKILL {level: "intermediate"}]->(go)
CREATE (alice)-[:HAS_SKILL {level: "beginner"}]->(rust)

// Finding shared skills is a natural traversal — no scanning
MATCH (:Person {name: "Alice"})-[:HAS_SKILL]->(s:Skill)<-[:HAS_SKILL]-(other)
RETURN other, collect(s.name) AS sharedSkills
```
