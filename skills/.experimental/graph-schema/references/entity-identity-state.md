---
title: Separate Identity from Mutable State
impact: CRITICAL
impactDescription: enables history tracking and temporal queries
tags: entity, identity, state, temporal, versioning
---

## Separate Identity from Mutable State

When mutable attributes (address, job title, status) live directly on the identity node, you lose history. Separating identity (who/what) from state (current attributes) via relationships lets you track changes over time and answer "what was X's address in January?"

**Incorrect (mutable state on the identity node):**

```cypher
// Overwriting loses previous values — no history
CREATE (:Patient {name: "Alice", address: "123 Main St", insurance: "BlueCross", primaryDoctor: "Dr. Smith"})
// When Alice moves:
MATCH (p:Patient {name: "Alice"})
SET p.address = "456 Oak Ave"
// Previous address "123 Main St" is gone forever
```

**Correct (identity separated from versioned state):**

```cypher
// Previous states preserved as separate nodes
CREATE (alice:Patient {id: "P-1001", name: "Alice", dob: date("1990-05-12")})
CREATE (alice)-[:HAS_STATE {from: date("2023-01-01"), to: date("2024-06-30")}]->(:PatientState {address: "123 Main St", insurance: "BlueCross", primaryDoctor: "Dr. Smith"})
CREATE (alice)-[:HAS_STATE {from: date("2024-07-01")}]->(:PatientState {address: "456 Oak Ave", insurance: "Aetna", primaryDoctor: "Dr. Jones"})
// Query: "What was Alice's address in March 2024?"
// MATCH (p:Patient {name: "Alice"})-[s:HAS_STATE]->(state)
// WHERE s.from <= date("2024-03-01") AND (s.to IS NULL OR s.to >= date("2024-03-01"))
// RETURN state.address
```

**See also:** [`scale-temporal-versioning`](scale-temporal-versioning.md) for optimizing current vs. historical state queries at scale.
