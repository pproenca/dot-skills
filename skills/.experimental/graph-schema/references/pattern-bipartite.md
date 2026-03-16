---
title: Use Bipartite Structure for Many-to-Many with Context
impact: HIGH
impactDescription: "reduces entity confusion and prevents 2× node duplication"
tags: pattern, bipartite, many-to-many, modeling
---

## Use Bipartite Structure for Many-to-Many with Context

Many domains have two primary entity classes with rich connections between them: students and courses, doctors and patients, users and products. The bipartite pattern keeps entity types separate and lets relationships carry context (grade, diagnosis, rating). Collapsing the two types into one node type loses semantic clarity.

**Incorrect (single generic label with type property):**

```cypher
// A single :Person label for both doctors and patients loses type safety
// Generic relationship types obscure the domain model
CREATE (:Person {name: "Dr. Smith", type: "doctor", specialty: "Cardiology"})
CREATE (:Person {name: "Jane Doe", type: "patient", dob: date("1985-06-15")})
CREATE (d)-[:RELATED_TO {type: "treats", since: date("2023-06-01")}]->(p)

// Querying requires filtering by type property — error-prone and slow
MATCH (d:Person {type: "doctor"})-[:RELATED_TO {type: "treats"}]->(p:Person {type: "patient"})
RETURN d.name, p.name
// Nothing prevents a "patient" from having a "treats" relationship to a "doctor"
```

**Correct (distinct labels with typed relationships):**

```cypher
// Separate labels enforce domain constraints and enable clear queries
CREATE (dr:Doctor {name: "Dr. Smith"})
CREATE (pt:Patient {name: "Jane Doe", dob: date("1985-06-15")})
CREATE (cardio:Specialty {name: "Cardiology"})
CREATE (hypertension:Condition {name: "Hypertension"})

CREATE (dr)-[:TREATS {since: date("2023-06-01"), primaryCare: true}]->(pt)
CREATE (dr)-[:SPECIALIZES_IN]->(cardio)
CREATE (pt)-[:DIAGNOSED_WITH {diagnosedOn: date("2023-06-01"), severity: "Stage 2"}]->(hypertension)

// Bipartite queries are clean and type-safe
MATCH (d:Doctor)-[:SPECIALIZES_IN]->(:Specialty {name: "Cardiology"})
MATCH (d)-[:TREATS]->(p:Patient)-[:DIAGNOSED_WITH]->(c:Condition)
RETURN d.name, p.name, c.name
```
