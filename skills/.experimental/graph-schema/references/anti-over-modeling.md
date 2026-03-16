---
title: Avoid Making Everything a Node
impact: MEDIUM
impactDescription: "avoids graph bloat and unnecessary traversal complexity"
tags: anti, over-modeling, simplicity, pragmatism
---

## Avoid Making Everything a Node

Not every piece of data needs to be a node. Email addresses, phone numbers, and timestamps rarely need their own relationships. If a value is only ever accessed as part of its parent entity and never queried independently or shared across entities, keep it as a property. Over-modeling inflates the graph and adds traversal hops with no analytical benefit.

**Incorrect (over-modeled contact information as separate nodes):**

```cypher
// Every scalar value promoted to a node — unless you're building an email analytics platform
CREATE (alice:Person {name: "Alice"})
CREATE (email:Email {value: "alice@example.com"})
CREATE (domain:Domain {name: "example.com"})
CREATE (phone:Phone {number: "+1-555-0123"})
CREATE (country:CountryCode {code: "+1"})

CREATE (alice)-[:HAS_EMAIL]->(email)
CREATE (email)-[:HAS_DOMAIN]->(domain)
CREATE (alice)-[:HAS_PHONE]->(phone)
CREATE (phone)-[:HAS_COUNTRY_CODE]->(country)

// "Get Alice's contact info" requires 4 hops across 5 nodes:
MATCH (a:Person {name: "Alice"})-[:HAS_EMAIL]->(e:Email),
      (a)-[:HAS_PHONE]->(p:Phone)
RETURN e.value, p.number
```

**Correct (simple properties for data that doesn't need independent identity):**

```cypher
// Contact info as properties — accessed only through the Person node
CREATE (alice:Person {
  name: "Alice",
  email: "alice@example.com",
  phone: "+1-555-0123"
})

// "Get Alice's contact info" is a single node lookup:
MATCH (a:Person {name: "Alice"})
RETURN a.email, a.phone

// Promote to a node ONLY when needed:
// - Multiple people share the same email (shared mailbox)
// - You query "find all people at example.com" frequently
// - The email itself has relationships (e.g., linked to a VerificationToken)
```
