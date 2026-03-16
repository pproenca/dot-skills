---
title: Follow UPPER_SNAKE_CASE for Relationship Types
impact: CRITICAL
impactDescription: prevents query bugs from inconsistent naming
tags: rel, naming, conventions, style
---

## Follow UPPER_SNAKE_CASE for Relationship Types

Neo4j and the Cypher ecosystem use UPPER_SNAKE_CASE for relationship types by convention. This distinguishes them visually from labels (CamelCase) and properties (camelCase). Inconsistent naming causes query bugs and confuses collaborators.

**Incorrect (mixed naming styles):**

```cypher
// Each developer picks a different convention — chaos
CREATE (:Doctor)-[:treatedPatient]->(:Patient)      // camelCase
CREATE (:Doctor)-[:TreatedPatient]->(:Patient)       // PascalCase
CREATE (:Doctor)-[:treated_patient]->(:Patient)      // lower_snake_case
CREATE (:Doctor)-[:TREATED-PATIENT]->(:Patient)      // UPPER-KEBAB-CASE
// Queries fail silently when the wrong case is used:
// MATCH ()-[:TREATED_PATIENT]->() returns nothing if the actual type is "treatedPatient"
```

**Correct (consistent UPPER_SNAKE_CASE with active verb forms):**

```cypher
// Clear naming convention: UPPER_SNAKE_CASE with active verbs
CREATE (dr:Doctor {name: "Dr. Smith"})-[:TREATED]->(patient:Patient {name: "Alice"})
CREATE (dr)-[:PRESCRIBED]->(rx:Medication {name: "Amoxicillin"})
CREATE (patient)-[:ADMITTED_TO]->(ward:Ward {name: "Cardiology"})
CREATE (patient)-[:HAS_INSURANCE]->(ins:InsurancePlan {provider: "BlueCross"})
// Labels: CamelCase — Doctor, Patient, Medication
// Relationships: UPPER_SNAKE_CASE — TREATED, PRESCRIBED, ADMITTED_TO
// Properties: camelCase — name, provider
```
