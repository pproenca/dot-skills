---
title: Avoid Generic RELATED_TO or CONNECTED Relationships
impact: MEDIUM
impactDescription: "prevents ambiguous traversals that return wrong results"
tags: anti, generic, naming, semantics
---

## Avoid Generic RELATED_TO or CONNECTED Relationships

**This rule is about semantic ambiguity.** Generic relationship types like `:RELATED_TO`, `:CONNECTED`, `:LINKED`, or `:HAS` convey no meaning. When different developers use the same generic type for different meanings (friendship, employment, purchase), queries return wrong results because the database cannot distinguish between them. A `MATCH ()-[:RELATED_TO]->()` traversal silently mixes friends, employers, and products into a single result set.

**Incorrect (generic relationships that obscure meaning):**

```cypher
// What does RELATED_TO mean? Different things in every context.
CREATE (alice:Person {name: "Alice"})
CREATE (bob:Person {name: "Bob"})
CREATE (acme:Company {name: "Acme Corp"})
CREATE (laptop:Product {name: "Laptop Pro"})

CREATE (alice)-[:RELATED_TO {type: "friend"}]->(bob)
CREATE (alice)-[:RELATED_TO {type: "employee"}]->(acme)
CREATE (alice)-[:RELATED_TO {type: "purchased"}]->(laptop)

// Every query must filter by a string property — error-prone and unindexable by type:
MATCH (alice:Person {name: "Alice"})-[r:RELATED_TO]->(target)
WHERE r.type = "friend"
RETURN target.name
// Typo "freind" silently returns zero results. No schema enforcement.
```

**Correct (specific, self-documenting relationship types):**

```cypher
CREATE (alice:Person {name: "Alice"})
CREATE (bob:Person {name: "Bob"})
CREATE (acme:Company {name: "Acme Corp"})
CREATE (laptop:Product {name: "Laptop Pro"})

CREATE (alice)-[:FRIEND_OF {since: date("2020-03-15")}]->(bob)
CREATE (alice)-[:WORKS_AT {role: "Engineer", startDate: date("2022-01-10")}]->(acme)
CREATE (alice)-[:PURCHASED {orderDate: date("2024-06-01")}]->(laptop)

// Queries are precise and self-documenting:
MATCH (alice:Person {name: "Alice"})-[:FRIEND_OF]->(friend:Person)
RETURN friend.name
// Relationship type IS the filter — no string matching, no ambiguity
```

**See also:** [`rel-typed-over-filtered`](rel-typed-over-filtered.md) for the performance cost of property filtering. [`rel-specific-types`](rel-specific-types.md) for naming conventions.
