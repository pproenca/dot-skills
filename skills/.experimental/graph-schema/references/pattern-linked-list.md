---
title: Use Linked Lists for Ordered Sequences
impact: HIGH
impactDescription: "preserves insertion order without index properties"
tags: pattern, linked-list, ordering, sequence
---

## Use Linked Lists for Ordered Sequences

When order matters (playlist tracks, workflow steps, version history), encoding order as an `index` property breaks on insertions and requires re-indexing. A linked list with `:NEXT` relationships preserves order naturally and supports O(1) insertions.

**Incorrect (order encoded as index properties):**

```cypher
// Index properties must be renumbered on every insert or delete
CREATE (pl:Playlist {name: "Road Trip"})
CREATE (t1:Track {title: "Bohemian Rhapsody"})
CREATE (t2:Track {title: "Hotel California"})
CREATE (t3:Track {title: "Stairway to Heaven"})
CREATE (pl)-[:HAS_TRACK {position: 1}]->(t1)
CREATE (pl)-[:HAS_TRACK {position: 2}]->(t2)
CREATE (pl)-[:HAS_TRACK {position: 3}]->(t3)

// Inserting a track at position 2 requires updating positions 2, 3, ...
// In a 1000-track playlist, that's 999 relationship updates
```

**Correct (linked list with NEXT relationships):**

```cypher
// Order is encoded in the chain — insertions update only two relationships
CREATE (pl:Playlist {name: "Road Trip"})
CREATE (t1:Track {title: "Bohemian Rhapsody"})
CREATE (t2:Track {title: "Hotel California"})
CREATE (t3:Track {title: "Stairway to Heaven"})
CREATE (pl)-[:FIRST]->(t1)
CREATE (t1)-[:NEXT]->(t2)
CREATE (t2)-[:NEXT]->(t3)
CREATE (pl)-[:LAST]->(t3)

// Insert "Free Bird" between t1 and t2: delete t1-[:NEXT]->t2,
// create t1-[:NEXT]->newTrack-[:NEXT]->t2 — only 2 relationship changes
// Get ordered tracks:
MATCH (pl:Playlist {name: "Road Trip"})-[:FIRST]->(first)
MATCH path = (first)-[:NEXT*0..]->(track)
RETURN track.title, length(path) AS position
```
