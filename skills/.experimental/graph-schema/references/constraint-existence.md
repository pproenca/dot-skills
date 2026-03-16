---
title: Use Existence Constraints for Required Properties
impact: MEDIUM
impactDescription: "prevents NULL-related query failures at insert time"
tags: constraint, existence, required, validation
---

## Use Existence Constraints for Required Properties

Graph databases are schema-flexible by default — you can create a `:Person` node without a `name` property and nothing complains. Existence constraints enforce that critical properties are always present, catching data quality issues at insert time rather than discovering NULL values during downstream queries or application code. Use sparingly: only constrain properties that are truly required for the domain to function.

**Incorrect (no existence constraint — incomplete data sneaks in):**

```cypher
// No constraint — some Person nodes have name, others don't
CREATE (:Person {email: "alice@example.com", name: "Alice"})
CREATE (:Person {email: "bob@example.com"}) // no name — allowed silently

// Application code breaks on null names
MATCH (p:Person)
RETURN p.name + " (" + p.email + ")"
// Returns null for Bob — causes NullPointerException in application layer

// Worse: aggregation queries silently exclude incomplete records
MATCH (p:Person)
WHERE p.name STARTS WITH "A"
RETURN count(p) // Bob is invisible — data quality issue goes unnoticed
```

**Correct (existence constraint catches missing data at write time):**

```cypher
// Every Person must have a name — insert without one fails immediately
CREATE CONSTRAINT person_name_exists FOR (p:Person) REQUIRE p.name IS NOT NULL

// Every Order must have a total and a customerId
CREATE CONSTRAINT order_total_exists FOR (o:Order) REQUIRE o.total IS NOT NULL
CREATE CONSTRAINT order_customer_exists FOR (o:Order) REQUIRE o.customerId IS NOT NULL

// This now fails with a clear error at insert time
CREATE (:Person {email: "bob@example.com"}) // ERROR: name is required

// Correct insert
CREATE (:Person {email: "bob@example.com", name: "Bob"}) // succeeds
```
