---
title: Promote Frequently-Queried Values to Nodes
impact: HIGH
impactDescription: "converts O(n) full-label scans to O(k) targeted traversals"
tags: prop, promotion, nodes, query-optimization
---

## Promote Frequently-Queried Values to Nodes

If you frequently query "find all X with property value Y" (e.g., "all users in London", "all products with tag 'electronics'"), that value should be a node. Traversing from a :City node is instant; scanning every :User's `city` property is linear.

**Incorrect (shared value repeated as property on every node):**

```cypher
// Every product duplicates the category string — finding all electronics
// requires scanning every Product node's category property
CREATE (:Product {name: "iPhone 15", category: "Electronics"})
CREATE (:Product {name: "Galaxy S24", category: "Electronics"})
CREATE (:Product {name: "MacBook Pro", category: "Electronics"})
// ... thousands more

// O(n) scan across all products
MATCH (p:Product {category: "Electronics"})
RETURN p
```

**Correct (shared value promoted to its own node):**

```cypher
// One Category node, connected to all relevant products
CREATE (cat:Category {name: "Electronics"})
CREATE (p1:Product {name: "iPhone 15"})-[:IN_CATEGORY]->(cat)
CREATE (p2:Product {name: "Galaxy S24"})-[:IN_CATEGORY]->(cat)
CREATE (p3:Product {name: "MacBook Pro"})-[:IN_CATEGORY]->(cat)

// O(log n) index lookup + O(k) traversal
MATCH (c:Category {name: "Electronics"})<-[:IN_CATEGORY]-(p)
RETURN p
```
