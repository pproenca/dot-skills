---
title: Use Fan-Out Pattern for Event Streams and Activity Feeds
impact: HIGH
impactDescription: "reduces timeline queries from O(n) to O(k) for last k events"
tags: pattern, fan-out, events, activity-feed
---

## Use Fan-Out Pattern for Event Streams and Activity Feeds

Social feeds, notification systems, and audit logs produce high-volume event streams. The fan-out pattern connects each actor to their latest event, then chains events via `:PREVIOUS` relationships. This avoids scanning all events to build a user's timeline.

**Incorrect (flat relationship to every event):**

```cypher
// Every event directly connected to the user — building a feed
// requires sorting ALL events by timestamp
CREATE (alice:User {name: "Alice"})
CREATE (alice)-[:PERFORMED]->(:Event {type: "post", content: "Hello!", ts: datetime("2024-03-15T10:00:00")})
CREATE (alice)-[:PERFORMED]->(:Event {type: "like", targetId: "post-42", ts: datetime("2024-03-15T10:05:00")})
CREATE (alice)-[:PERFORMED]->(:Event {type: "comment", content: "Great!", ts: datetime("2024-03-15T10:10:00")})
// ... thousands of events

// Getting last 10 events requires scanning and sorting all of Alice's events
MATCH (u:User {name: "Alice"})-[:PERFORMED]->(e)
RETURN e ORDER BY e.ts DESC LIMIT 10
```

**Correct (linked event chain with LATEST_EVENT pointer):**

```cypher
// Each user points to their most recent event; events chain backwards
CREATE (alice:User {name: "Alice"})
CREATE (e3:Event {type: "comment", content: "Great!", ts: datetime("2024-03-15T10:10:00")})
CREATE (e2:Event {type: "like", targetId: "post-42", ts: datetime("2024-03-15T10:05:00")})
CREATE (e1:Event {type: "post", content: "Hello!", ts: datetime("2024-03-15T10:00:00")})
CREATE (alice)-[:LATEST_EVENT]->(e3)
CREATE (e3)-[:PREVIOUS]->(e2)
CREATE (e2)-[:PREVIOUS]->(e1)

// Getting last N events follows the chain — no scanning or sorting
MATCH (u:User {name: "Alice"})-[:LATEST_EVENT]->(latest)-[:PREVIOUS*0..9]->(event)
RETURN event.type, event.ts
```
