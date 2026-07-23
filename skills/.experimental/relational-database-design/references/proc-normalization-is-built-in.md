---
title: Normalization is built into the method, not a separate phase
tags: proc, normalization, integrity
---

## Normalization is built into the method, not a separate phase

The wrong default — inherited from the traditional teaching order — is to design tables however, then run a distinct "normalization" pass at the end, testing each table against 1NF, 2NF, 3NF, and so on. That back-loaded, iterative pass is where most people stall. This method reaches the same destination by construction: apply the ideal-field, ideal-table, and key guidelines as you build, and the tables come out fully normalized without a separate normal-form step.

The mapping is direct — each design guideline resolves the issue a normal form addresses:

```text
Ideal Field  (single value, atomic, no calculation)  → 1NF: no repeating groups / scalar values
Ideal Table  (one subject, no transitive dependence)  → 2NF / 3NF: no partial or transitive deps
Candidate/Primary Key (minimal, uniquely identifies)  → BCNF: determinants are keys
Resolve multivalued fields into their own table       → 4NF: no multivalued dependencies
Foreign key draws values from its primary key         → referential integrity
```

Practical consequence: you deal with functional dependencies, modification anomalies, and multivalued dependencies *as you design each table*, not two-thirds of the way through the project. Following the guidelines yields normalized tables only if you follow them faithfully — shortcuts produce the same poor structures any skipped methodology would.
