---
title: Denormalize for Read-Heavy Paths
impact: MEDIUM-HIGH
impactDescription: "eliminates N+1 traversals on read-heavy display paths"
tags: query, denormalization, read-heavy, caching
---

## Denormalize for Read-Heavy Paths

In read-heavy workloads (dashboards, feeds, search results), copying a few key properties onto nodes that are always co-fetched avoids extra hops. For example, storing `authorName` on a :Post node avoids traversing to the :Author node on every timeline render. This is a conscious trade-off: don't denormalize if the source data changes frequently or if the read path is not a proven bottleneck.

**Incorrect (N+1 traversal pattern for every timeline render):**

```cypher
// Rendering a feed of 50 posts requires 50 extra traversals to get author names:
MATCH (post:Post)-[:AUTHORED_BY]->(author:Author)
WHERE post.publishedAt > datetime() - duration("P7D")
RETURN post.title, post.body, author.name, author.avatarUrl
ORDER BY post.publishedAt DESC
LIMIT 50
// Each post triggers a hop to the Author node — multiplied across millions of feed renders
```

**Correct (denormalized display fields on the Post node):**

```cypher
// Store frequently co-fetched display fields directly on the Post node:
CREATE (p:Post {
  title: "GraphQL at Scale",
  body: "...",
  publishedAt: datetime("2024-11-15T10:00:00Z"),
  authorName: "Alice Chen",         // denormalized for display
  authorAvatar: "/img/alice.jpg"    // denormalized for display
})-[:AUTHORED_BY]->(a:Author {name: "Alice Chen", avatarUrl: "/img/alice.jpg"})

// Feed query needs zero extra hops:
MATCH (post:Post)
WHERE post.publishedAt > datetime() - duration("P7D")
RETURN post.title, post.body, post.authorName, post.authorAvatar
ORDER BY post.publishedAt DESC
LIMIT 50
// Canonical AUTHORED_BY relationship remains for mutations and author-centric queries
// Update denormalized fields when Author properties change
```
