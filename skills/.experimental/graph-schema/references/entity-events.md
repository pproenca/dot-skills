---
title: Model Multi-Participant Events as First-Class Nodes
impact: CRITICAL
impactDescription: prevents N+1 queries on event attributes
tags: entity, events, reification, multi-participant
---

## Model Multi-Participant Events as First-Class Nodes

When an event involves multiple participants (sender, recipients, CCs), it MUST be a node because a relationship only connects two nodes. "Bob emailed Charlie" hides the Email event -- and the CC list, attachments, and thread that connect to it. The moment a third entity participates, a relationship cannot represent the event.

**Incorrect (event collapsed into a relationship):**

```cypher
// Can't attach CC recipients, attachments, or thread relationships to a relationship
CREATE (bob:Person {name: "Bob"})-[:EMAILED {subject: "Q1 Report", date: "2024-03-15", body: "Please review..."}]->(charlie:Person {name: "Charlie"})
```

**Correct (event modeled as a first-class node):**

```cypher
// The Email node captures the full event with all participants
CREATE (bob:Person {name: "Bob"})-[:SENT]->(email:Email {subject: "Q1 Report", date: date("2024-03-15"), body: "Please review..."})-[:TO]->(charlie:Person {name: "Charlie"})
CREATE (email)-[:CC]->(dana:Person {name: "Dana"})
CREATE (email)-[:HAS_ATTACHMENT]->(file:File {name: "q1-report.pdf"})
CREATE (email)-[:IN_THREAD]->(thread:Thread {id: "thread-442"})
```

### When NOT to apply

Don't promote to a node if the action only involves two entities and carries no additional context beyond the relationship itself. For example, `(alice)-[:FOLLOWS]->(bob)` is fine as a relationship when there are no other participants or rich attributes to attach. Promote only when a third (or more) participant needs to connect to the same event.

**See also:** [`entity-reify-actions`](entity-reify-actions.md) for actions with their own lifecycle (created, shipped, delivered, returned).
