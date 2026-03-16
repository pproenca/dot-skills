---
title: Model Hierarchies with Category Nodes and Depth Relationships
impact: HIGH
impactDescription: "enables both drill-down and roll-up queries on taxonomies"
tags: pattern, hierarchy, taxonomy, tree, category
---

## Model Hierarchies with Category Nodes and Depth Relationships

Domain taxonomies (product categories, org structures, geographic regions) are natural trees. Model each level as a node with `:PARENT_OF` or `:CHILD_OF` relationships. Add a `:Root` label to the top node. For deep hierarchies, consider shortcut `:ANCESTOR_OF` relationships for O(1) ancestry queries.

**Incorrect (hierarchy flattened into properties):**

```cypher
// Flat properties destroy the tree structure — can't traverse or aggregate
CREATE (:Product {
  name: "iPhone 15 Pro",
  category: "Electronics",
  subcategory: "Phones",
  subsubcategory: "Smartphones"
})

// Finding all products under "Electronics" requires scanning every product
// and checking string values — no tree traversal possible
MATCH (p:Product {category: "Electronics"})
RETURN p
// Misses products where someone typed "electronics" (case mismatch)
```

**Correct (hierarchy modeled as a tree of nodes):**

```cypher
// Each level is a node; relationships encode parent-child structure
CREATE (root:Category:Root {name: "Electronics"})
CREATE (phones:Category {name: "Phones"})
CREATE (smartphones:Category {name: "Smartphones"})
CREATE (accessories:Category {name: "Accessories"})
CREATE (root)-[:PARENT_OF]->(phones)
CREATE (phones)-[:PARENT_OF]->(smartphones)
CREATE (root)-[:PARENT_OF]->(accessories)
CREATE (:Product {name: "iPhone 15 Pro"})-[:IN_CATEGORY]->(smartphones)

// Drill-down: all products under Electronics at any depth
MATCH (:Category {name: "Electronics"})-[:PARENT_OF*]->(sub)<-[:IN_CATEGORY]-(p)
RETURN p.name, sub.name AS directCategory

// Roll-up: full ancestry path for a product
MATCH (p:Product {name: "iPhone 15 Pro"})-[:IN_CATEGORY]->(c)<-[:PARENT_OF*0..]-(ancestor)
RETURN [node IN collect(ancestor) | node.name] AS breadcrumb
```
