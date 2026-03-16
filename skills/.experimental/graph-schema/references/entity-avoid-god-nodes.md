---
title: Avoid Kitchen-Sink Entity Nodes
impact: CRITICAL
impactDescription: prevents unqueryable monoliths and supernodes
tags: entity, god-node, decomposition, modeling
---

## Avoid Kitchen-Sink Entity Nodes

Stuffing every attribute into a single node type creates "god nodes" that are hard to query, hard to evolve, and become supernodes. If a node has 20+ properties or connects to 10+ relationship types, it likely represents multiple domain concepts that should be decomposed.

**Incorrect (monolithic node with everything inlined):**

```cypher
// 20+ properties spanning multiple domain concepts crammed into one node
CREATE (:User {
  name: "Alice", email: "alice@corp.com", phone: "+1-555-0100",
  addressStreet: "123 Main St", addressCity: "Portland", addressZip: "97201",
  companyName: "Acme Corp", companyRole: "Staff Engineer", companyStartDate: "2021-03-01",
  department: "Platform", managerId: "U-2002",
  skill1: "Python", skill2: "GraphQL", skill3: "Neo4j",
  cert1: "AWS Solutions Architect", cert2: "Neo4j Certified Professional",
  emergencyContactName: "Bob", emergencyContactPhone: "+1-555-0200"
})
```

**Correct (decomposed into focused domain entities):**

```cypher
// Each node type represents one domain concept
CREATE (alice:User {name: "Alice", email: "alice@corp.com", phone: "+1-555-0100"})
CREATE (alice)-[:LIVES_AT]->(:Address {street: "123 Main St", city: "Portland", zip: "97201"})
CREATE (alice)-[:WORKS_AT {role: "Staff Engineer", since: date("2021-03-01")}]->(acme:Company {name: "Acme Corp"})
CREATE (acme)-[:HAS_DEPARTMENT]->(platform:Department {name: "Platform"})
CREATE (alice)-[:IN_DEPARTMENT]->(platform)
CREATE (alice)-[:REPORTS_TO]->(:User {name: "Bob"})
CREATE (alice)-[:HAS_SKILL]->(:Skill {name: "Python"})
CREATE (alice)-[:HAS_SKILL]->(:Skill {name: "GraphQL"})
CREATE (alice)-[:HAS_CERTIFICATION]->(:Certification {name: "AWS Solutions Architect"})
```
