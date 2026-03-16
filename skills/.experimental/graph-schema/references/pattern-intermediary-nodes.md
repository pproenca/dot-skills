---
title: Use Intermediary Nodes for Multi-Entity Relationships
impact: HIGH
impactDescription: "enables connecting 3+ entities through one event node"
tags: pattern, intermediary, hyperedge, reification
---

## Use Intermediary Nodes for Multi-Entity Relationships

Property graphs only support binary relationships (node-to-node). When a real-world event involves 3+ participants (a person, a role, a company, a time period), you need an intermediary node. This is the most important structural pattern in graph modeling.

**Incorrect (multi-entity data crammed onto a single relationship):**

```cypher
// Employment involves person + role + company + department + time period
// A single relationship can only connect two of these
CREATE (p:Person {name: "Alice"})
CREATE (c:Company {name: "Acme Corp"})
CREATE (p)-[:WORKS_AT {
  role: "CTO",
  department: "Engineering",
  startDate: date("2023-01-01"),
  salary: 180000
}]->(c)

// Can't connect this employment to a Department node or track role changes
// Can't model Alice being promoted from VP to CTO at the same company
```

**Correct (intermediary node connects all participants):**

```cypher
// The Employment node reifies the relationship into a first-class entity
CREATE (p:Person {name: "Alice"})
CREATE (c:Company {name: "Acme Corp"})
CREATE (d:Department {name: "Engineering"})
CREATE (emp:Employment {role: "CTO", startDate: date("2023-01-01"), salary: 180000})
CREATE (p)-[:HAS_ROLE]->(emp)
CREATE (emp)-[:AT]->(c)
CREATE (emp)-[:IN_DEPARTMENT]->(d)

// Role changes are just new Employment nodes
// Can query "who has worked in Engineering?" by traversing from Department
MATCH (d:Department {name: "Engineering"})<-[:IN_DEPARTMENT]-(emp)<-[:HAS_ROLE]-(p)
RETURN p.name, emp.role, emp.startDate
```
