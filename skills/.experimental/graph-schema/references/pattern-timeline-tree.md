---
title: Apply Timeline Trees for Temporal Data
impact: HIGH
impactDescription: "enables efficient time-based queries without scanning all events"
tags: pattern, timeline, temporal, time-tree
---

## Apply Timeline Trees for Temporal Data

When events must be queried by time range (logs, transactions, sensor readings), scanning all events is O(n). A timeline tree (Year -> Month -> Day -> Event) lets you jump directly to the right time slice. Use when you have thousands of time-series events.

**Incorrect (flat events with timestamp properties):**

```cypher
// All events at the same level — finding events in a time range
// requires scanning every single event node
CREATE (:Order {orderId: "ord-1001", date: date("2024-03-15"), total: 89.99})
CREATE (:Order {orderId: "ord-1002", date: date("2024-03-16"), total: 45.50})
// ... thousands more orders

// Finding all orders in March 2024 scans every Order node
MATCH (o:Order)
WHERE o.date >= date("2024-03-01") AND o.date < date("2024-04-01")
RETURN o
```

**Correct (timeline tree partitions events by time):**

```cypher
// Timeline tree lets you jump directly to the right time slice
CREATE (y:Year {value: 2024})
CREATE (m3:Month {value: 3})
CREATE (d15:Day {value: 15})
CREATE (d16:Day {value: 16})
CREATE (y)-[:HAS_MONTH]->(m3)
CREATE (m3)-[:HAS_DAY]->(d15)
CREATE (m3)-[:HAS_DAY]->(d16)
CREATE (d15)-[:HAS_EVENT]->(:Order {orderId: "ord-1001", total: 89.99})
CREATE (d16)-[:HAS_EVENT]->(:Order {orderId: "ord-1002", total: 45.50})

// All orders in March 2024 — jumps directly to the month node
MATCH (:Year {value: 2024})-[:HAS_MONTH]->(:Month {value: 3})-[:HAS_DAY]->(d)-[:HAS_EVENT]->(o:Order)
RETURN d.value AS day, o.orderId, o.total
ORDER BY d.value
```
