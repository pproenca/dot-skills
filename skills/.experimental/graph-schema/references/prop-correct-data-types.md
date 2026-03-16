---
title: Use Appropriate Data Types for Properties
impact: HIGH
impactDescription: "enables range queries, saves storage, prevents data corruption"
tags: prop, data-types, temporal, validation
---

## Use Appropriate Data Types for Properties

Storing dates as strings ("2024-03-15") prevents range queries and sorting. Storing booleans as strings ("true") wastes 4x storage. Storing numbers as strings prevents arithmetic. Use native types: `date()`, `datetime()`, `duration()`, boolean, integer, float.

**Incorrect (everything stored as strings):**

```cypher
// String properties prevent range queries, arithmetic, and proper sorting
CREATE (:Order {
  orderId: "ord-1001",
  createdAt: "2024-03-15T10:30:00",
  isActive: "true",
  price: "29.99",
  quantity: "5"
})

// Inconsistent date formats break lexicographic sorting:
// "9/15/2024" > "10/1/2024" lexicographically (because "9" > "1"), but October is later
// Even with consistent formats, strings prevent date arithmetic:
// o.createdAt + duration("P30D") — impossible with a string
MATCH (o:Order)
WHERE o.createdAt > "2024-01-01"
RETURN o
```

**Correct (native data types used):**

```cypher
// Native types enable range queries, arithmetic, and correct sorting
CREATE (:Order {
  orderId: "ord-1001",
  createdAt: datetime("2024-03-15T10:30:00"),
  isActive: true,
  price: 29.99,
  quantity: 5
})

// Temporal comparison works correctly with datetime type
MATCH (o:Order)
WHERE o.createdAt > datetime("2024-01-01T00:00:00")
  AND o.price * o.quantity > 100
RETURN o
```
