---
title: Avoid Encoding Structured Data as Delimited Strings
impact: MEDIUM
impactDescription: "prevents unqueryable opaque blobs hiding in properties"
tags: anti, strings, structured-data, parsing
---

## Avoid Encoding Structured Data as Delimited Strings

Storing structured data as delimited strings (e.g., `tags: "python,go,rust"` or `path: "US/CA/SF"`) requires string parsing in every query. This defeats the graph's native ability to traverse structure. Split structured values into nodes or use native arrays only for truly flat, non-queryable lists.

**Incorrect (structured data encoded as delimited strings):**

```cypher
// Tags and categories stored as comma-separated and slash-delimited strings
CREATE (a:Article {
  title: "Intro to Graph Databases",
  tags: "neo4j,graphs,databases,cypher",
  categories: "tech/data-science/tutorials",
  authors: "alice|bob|carol"
})

// Every query requires string manipulation:
MATCH (a:Article)
WHERE a.tags CONTAINS "neo4j"
RETURN a.title
// "neo4j" also matches "neo4j-enterprise" — no boundary safety.
// Cannot count articles per tag, find co-occurring tags, or traverse category hierarchy.
```

**Correct (structured data modeled as traversable nodes and relationships):**

```cypher
// Tags, categories, and authors are nodes with relationships
CREATE (a:Article {title: "Intro to Graph Databases"})

CREATE (neo4j:Tag {name: "neo4j"})
CREATE (graphs:Tag {name: "graphs"})
CREATE (databases:Tag {name: "databases"})
CREATE (a)-[:TAGGED]->(neo4j)
CREATE (a)-[:TAGGED]->(graphs)
CREATE (a)-[:TAGGED]->(databases)

CREATE (tutorials:Category {name: "tutorials"})
CREATE (dataSci:Category {name: "data-science"})
CREATE (tech:Category {name: "tech"})
CREATE (a)-[:IN_CATEGORY]->(tutorials)
CREATE (tutorials)-[:CHILD_OF]->(dataSci)
CREATE (dataSci)-[:CHILD_OF]->(tech)

// Precise tag query — no string parsing, no false matches:
MATCH (a:Article)-[:TAGGED]->(t:Tag {name: "neo4j"})
RETURN a.title

// Category hierarchy traversal:
MATCH (a:Article)-[:IN_CATEGORY]->(c:Category)-[:CHILD_OF*]->(parent:Category)
RETURN a.title, collect(parent.name) AS parentCategories

// Co-occurring tags analysis:
MATCH (a:Article)-[:TAGGED]->(t1:Tag), (a)-[:TAGGED]->(t2:Tag)
WHERE id(t1) < id(t2)
RETURN t1.name, t2.name, count(a) AS coOccurrences
```
