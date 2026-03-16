---
title: Define Uniqueness Constraints on Natural Identifiers
impact: MEDIUM
impactDescription: "prevents duplicate entities and enables fast lookups"
tags: constraint, uniqueness, identifiers, data-integrity
---

## Define Uniqueness Constraints on Natural Identifiers

Without uniqueness constraints, duplicate nodes can silently accumulate — two `:Person` nodes for "Alice" with slightly different property sets. Constraints enforce data integrity at the database level AND automatically create an index for O(1) lookups. Always constrain natural identifiers: email, SSN, product SKU, order number.

**Incorrect (no uniqueness constraint — duplicates accumulate silently):**

```cypher
// No constraint defined — MERGE may create duplicates if properties don't match exactly
// and lookups by identifier require full label scans
CREATE (:Person {email: "alice@example.com", name: "Alice"})
CREATE (:Person {email: "alice@example.com", name: "Alice Smith"})
// Two Person nodes for the same email now exist
// MATCH (p:Person {email: "alice@example.com"}) returns both — which is correct?
```

**Correct (uniqueness constraint prevents duplicates and auto-indexes):**

```cypher
// Constraint enforces uniqueness and creates an automatic index
CREATE CONSTRAINT person_email_unique FOR (p:Person) REQUIRE p.email IS UNIQUE

// Now this fails immediately with a constraint violation
CREATE (:Person {email: "alice@example.com", name: "Alice"})
CREATE (:Person {email: "alice@example.com", name: "Alice Smith"}) // ERROR: already exists

// MERGE safely finds-or-creates with O(1) lookup via the auto-index
MERGE (p:Person {email: "alice@example.com"})
ON CREATE SET p.name = "Alice Smith", p.createdAt = datetime()
ON MATCH SET p.lastSeen = datetime()
```
