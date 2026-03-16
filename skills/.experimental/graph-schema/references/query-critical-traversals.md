---
title: Design the Model for Your Most Critical Traversals First
impact: MEDIUM-HIGH
impactDescription: "prevents costly schema refactors after deployment"
tags: query, traversal, design-first, use-cases
---

## Design the Model for Your Most Critical Traversals First

The #1 principle of graph modeling: know your queries before you design your schema. List the top 5-10 queries your application will run, then design the model so the most frequent queries traverse the fewest hops. A model that looks clean on a whiteboard but requires 6-hop traversals for common operations is a bad model.

**Incorrect (entity-relationship design without considering queries):**

```cypher
// Designed from an ER diagram — "recommend products" requires 6 hops:
// Customer -> Order -> OrderLine -> Product -> Category -> Product
MATCH (c:Customer {id: "c1"})-[:PLACED]->(o:Order)
      -[:CONTAINS]->(ol:OrderLine)-[:FOR_PRODUCT]->(p:Product)
      -[:IN_CATEGORY]->(cat:Category)<-[:IN_CATEGORY]-(rec:Product)
WHERE rec <> p
RETURN DISTINCT rec.name
// Every recommendation query crawls through orders, line items, and categories
```

**Correct (model designed around the critical "recommend products" query):**

```cypher
// After identifying "product recommendations" as a critical query,
// add direct relationships that reduce hops:
CREATE (c:Customer {id: "c1"})-[:VIEWED]->(p1:Product {name: "Running Shoes"})
CREATE (c)-[:PURCHASED]->(p2:Product {name: "Trail Shoes"})
CREATE (p1)-[:SIMILAR_TO]->(p3:Product {name: "Hiking Boots"})
CREATE (p2)-[:SIMILAR_TO]->(p3)

// Recommendation query is now 2 hops:
MATCH (c:Customer {id: "c1"})-[:VIEWED|PURCHASED]->(p:Product)
      -[:SIMILAR_TO]->(rec:Product)
WHERE NOT (c)-[:PURCHASED]->(rec)
RETURN DISTINCT rec.name
```
