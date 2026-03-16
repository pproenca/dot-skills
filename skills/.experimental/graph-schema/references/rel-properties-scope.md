---
title: Put Data on Relationships Only When It Describes the Connection
impact: CRITICAL
impactDescription: prevents misplaced data that becomes unqueryable
tags: rel, properties, scope, placement
---

## Put Data on Relationships Only When It Describes the Connection

Relationship properties should describe the connection itself (when it started, its strength, its role), not the entities it connects. Properties like `since`, `weight`, `role` belong on relationships. Properties like `name`, `email`, `age` belong on nodes. If you need to connect the relationship to other entities, it should be a node.

**Incorrect (entity data placed on the relationship):**

```cypher
// Company data lives on the relationship — duplicated across every employee edge
CREATE (:Person {name: "Alice"})-[:WORKS_AT {
  companyAddress: "123 Main St",
  companyPhone: "555-0100",
  companyIndustry: "Technology",
  role: "Engineer",
  since: "2023-01-15"
}]->(:Company {name: "Acme Corp"})
// If the company moves offices, every WORKS_AT relationship must be updated
```

**Correct (data placed where it belongs):**

```cypher
// Connection data on the relationship, entity data on the nodes
CREATE (:Person {name: "Alice"})-[:WORKS_AT {
  role: "Engineer",
  since: date("2023-01-15"),
  department: "Platform"
}]->(:Company {
  name: "Acme Corp",
  address: "123 Main St",
  phone: "555-0100",
  industry: "Technology"
})
// Company address updated in one place, relationship describes only the connection
```
