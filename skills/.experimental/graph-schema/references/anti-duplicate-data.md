---
title: Avoid Duplicating Data Instead of Creating Relationships
impact: MEDIUM
impactDescription: "eliminates update anomalies and storage waste"
tags: anti, duplication, relationships, normalization
---

## Avoid Duplicating Data Instead of Creating Relationships

Copying data between nodes (e.g., storing company name on every Employee node) is a relational-world habit. In graphs, you traverse: the company name lives on the Company node, and every Employee reaches it via the WORKS_AT relationship. Duplicated data becomes stale and inconsistent the moment the source changes.

**Incorrect (company data duplicated on every employee node):**

```cypher
// Company info copied onto every employee — update nightmare when Acme moves offices
CREATE (alice:Employee {name: "Alice", companyName: "Acme Corp", companyAddress: "123 Main St"})
CREATE (bob:Employee {name: "Bob", companyName: "Acme Corp", companyAddress: "123 Main St"})
CREATE (carol:Employee {name: "Carol", companyName: "Acme Corp", companyAddress: "123 Main St"})

// Acme moves to a new address — must update every employee node:
MATCH (e:Employee {companyName: "Acme Corp"})
SET e.companyAddress = "456 Oak Ave"
// If one update fails or a new employee is created with the old address,
// the data is silently inconsistent. No constraint can prevent this.
```

**Correct (single source of truth reached via traversal):**

```cypher
// Company data lives in one place — all employees reach it via WORKS_AT
CREATE (acme:Company {name: "Acme Corp", address: "123 Main St"})
CREATE (alice:Employee {name: "Alice"})
CREATE (bob:Employee {name: "Bob"})
CREATE (carol:Employee {name: "Carol"})
CREATE (alice)-[:WORKS_AT {role: "Engineer"}]->(acme)
CREATE (bob)-[:WORKS_AT {role: "Designer"}]->(acme)
CREATE (carol)-[:WORKS_AT {role: "Manager"}]->(acme)

// Acme moves — single update, instantly consistent for all employees:
MATCH (c:Company {name: "Acme Corp"})
SET c.address = "456 Oak Ave"

// Every employee query gets the current address via traversal:
MATCH (e:Employee)-[:WORKS_AT]->(c:Company)
RETURN e.name, c.name, c.address
```
