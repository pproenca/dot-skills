---
title: Separate Current State from Historical State
impact: LOW-MEDIUM
impactDescription: "enables time-travel queries without polluting current-state traversals"
tags: scale, temporal, versioning, history, time-travel
---

## Separate Current State from Historical State

As entities change over time (address changes, role changes, status transitions), you need both "what is X's current state?" (fast, frequent) and "what was X's state on date Y?" (slower, occasional). Mixing current and historical data on the same node makes current-state queries traverse historical noise, and storing history as array properties makes temporal queries nearly impossible.

**Incorrect (history stored as arrays on the same node):**

```cypher
// All address history crammed into one node as array properties
CREATE (:Patient {
  name: "Alice",
  currentAddress: "456 Oak Ave",
  previousAddresses: ["123 Main St", "789 Elm St"],
  currentDoctor: "Dr. Smith",
  previousDoctors: ["Dr. Jones", "Dr. Lee"]
})

// Can't answer: "Who was Alice's doctor on 2022-06-15?"
// No temporal information attached to previous values
// Can't answer: "Which patients lived at 123 Main St in 2022?"
// Would need to scan every Patient's previousAddresses array

MATCH (p:Patient)
WHERE "123 Main St" IN p.previousAddresses
RETURN p.name // no date filtering possible — when did they live there?
```

**Correct (state separated into versioned nodes with temporal relationships):**

```cypher
// Current state is a direct, typed relationship — fast to query
CREATE (alice:Patient {name: "Alice", patientId: "P-1001"})
CREATE (alice)-[:CURRENT_ADDRESS]->(:Address {street: "456 Oak Ave", city: "Portland"})
CREATE (alice)-[:CURRENT_DOCTOR]->(:Doctor {name: "Dr. Smith"})

// Historical states linked with temporal metadata
CREATE (alice)-[:PREVIOUS_ADDRESS {from: date("2020-03-01"), until: date("2023-06-15")}]->
  (:Address {street: "123 Main St", city: "Seattle"})
CREATE (alice)-[:PREVIOUS_DOCTOR {from: date("2019-01-01"), until: date("2022-12-31")}]->
  (:Doctor {name: "Dr. Jones"})

// Current-state query — fast, no historical noise
MATCH (p:Patient {patientId: "P-1001"})-[:CURRENT_ADDRESS]->(a)
RETURN a.street, a.city

// Time-travel query — who was Alice's doctor on 2022-06-15?
MATCH (p:Patient {patientId: "P-1001"})-[r:PREVIOUS_DOCTOR]->(d)
WHERE r.from <= date("2022-06-15") AND r.until >= date("2022-06-15")
RETURN d.name // "Dr. Jones"

// Which patients lived at 123 Main St in 2022?
MATCH (p:Patient)-[r:PREVIOUS_ADDRESS|CURRENT_ADDRESS]->(a:Address {street: "123 Main St"})
WHERE r.from <= date("2022-12-31") AND coalesce(r.until, date("9999-12-31")) >= date("2022-01-01")
RETURN p.name
```

**See also:** [`entity-identity-state`](entity-identity-state.md) for the foundational principle of separating identity from mutable state.
