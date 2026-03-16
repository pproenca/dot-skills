---
title: Use Composite Node Keys for Natural Multi-Part Identifiers
impact: MEDIUM
impactDescription: "enforces uniqueness on combinations, not just single properties"
tags: constraint, node-key, composite, identifiers
---

## Use Composite Node Keys for Natural Multi-Part Identifiers

Some entities have natural composite identifiers: a flight is unique by (airline + flightNumber + date), a course enrollment by (studentId + courseId + semester), a warehouse slot by (warehouseId + aisle + shelf). A single-property uniqueness constraint cannot express this. Composite node key constraints enforce that the combination of properties is unique and that all component properties exist, while also creating a composite index for efficient lookups.

**Incorrect (single-property constraint on a naturally composite identifier):**

```cypher
// Only constraining flightNumber — but flight numbers are reused across airlines and dates
CREATE CONSTRAINT flight_number_unique FOR (f:Flight) REQUIRE f.flightNumber IS UNIQUE

// These are different flights but "123" alone collides
CREATE (:Flight {airline: "UA", flightNumber: "123", date: date("2024-03-15")})
CREATE (:Flight {airline: "AA", flightNumber: "123", date: date("2024-03-15")})
// ERROR: constraint violation — but these are legitimately different flights

// Without any constraint, duplicates accumulate
CREATE (:Flight {airline: "UA", flightNumber: "123", date: date("2024-03-15")})
CREATE (:Flight {airline: "UA", flightNumber: "123", date: date("2024-03-15")})
// Two identical flights — no constraint to prevent it
```

**Correct (composite node key enforces uniqueness on the combination):**

```cypher
// Node key: the combination of airline + flightNumber + date must be unique
// Also enforces that all three properties exist (IS NOT NULL implied)
CREATE CONSTRAINT flight_key FOR (f:Flight)
  REQUIRE (f.airline, f.flightNumber, f.date) IS NODE KEY

// Different airlines with same flight number — allowed
CREATE (:Flight {airline: "UA", flightNumber: "123", date: date("2024-03-15")}) // OK
CREATE (:Flight {airline: "AA", flightNumber: "123", date: date("2024-03-15")}) // OK

// Same airline, same number, same date — rejected
CREATE (:Flight {airline: "UA", flightNumber: "123", date: date("2024-03-15")})
// ERROR: node key constraint violation

// Composite index is auto-created — fast lookup by combination
MATCH (f:Flight {airline: "UA", flightNumber: "123", date: date("2024-03-15")})
RETURN f // O(log n) via composite index
```

**Note:** `IS NODE KEY` constraints require Neo4j Enterprise Edition. On Community Edition, combine a uniqueness constraint with individual existence constraints to approximate this. Memgraph and Neptune have different constraint mechanisms — consult their documentation for equivalents.
