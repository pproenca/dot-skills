# Graph Database Schema Design

**Version 0.1.0**  
dot-skills  
March 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive graph database data modeling guide designed for AI agents and LLMs. Contains 46 rules across 8 categories, prioritized by impact from critical (entity classification, relationship design) to incremental (scale and evolution). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct graph models using Cypher, and specific impact descriptions to guide schema design decisions. Focuses primarily on data modeling correctness — understanding the user's goal and translating it into the right graph structure — with performance as a secondary concern.

---

## Table of Contents

1. [Entity Classification](references/_sections.md#1-entity-classification) — **CRITICAL**
   - 1.1 [Avoid Kitchen-Sink Entity Nodes](references/entity-avoid-god-nodes.md) — CRITICAL (prevents unqueryable monoliths and supernodes)
   - 1.2 [Model Multi-Participant Events as First-Class Nodes](references/entity-events.md) — CRITICAL (prevents N+1 queries on event attributes)
   - 1.3 [Promote Shared Property Values to Nodes](references/entity-shared-values.md) — CRITICAL (eliminates redundant data, enables faceted queries)
   - 1.4 [Qualify Entities with Multiple Labels](references/entity-multi-label.md) — CRITICAL (enables cross-cutting queries without duplication)
   - 1.5 [Reify Lifecycle Actions into Nodes](references/entity-reify-actions.md) — CRITICAL (enables 3-5x richer queries on business events)
   - 1.6 [Separate Identity from Mutable State](references/entity-identity-state.md) — CRITICAL (enables history tracking and temporal queries)
   - 1.7 [Use Specific Labels Over Generic Ones](references/entity-specific-labels.md) — CRITICAL (reduces traversal scope by orders of magnitude)
2. [Relationship Design](references/_sections.md#2-relationship-design) — **CRITICAL**
   - 2.1 [Avoid Redundant Reverse Relationships](references/rel-no-redundant-reverse.md) — CRITICAL (halves storage cost and prevents data inconsistency)
   - 2.2 [Choose Semantically Meaningful Relationship Direction](references/rel-meaningful-direction.md) — CRITICAL (prevents directional ambiguity and query logic errors)
   - 2.3 [Follow UPPER_SNAKE_CASE for Relationship Types](references/rel-naming-conventions.md) — CRITICAL (prevents query bugs from inconsistent naming)
   - 2.4 [One Relationship Type per Semantic Meaning](references/rel-single-semantic.md) — CRITICAL (prevents ambiguous traversals and query errors)
   - 2.5 [Prefer Typed Relationships Over Generic + Property Filter](references/rel-typed-over-filtered.md) — CRITICAL (eliminates property filtering on every traversal)
   - 2.6 [Put Data on Relationships Only When It Describes the Connection](references/rel-properties-scope.md) — CRITICAL (prevents misplaced data that becomes unqueryable)
   - 2.7 [Use Specific Relationship Types Over Generic Ones](references/rel-specific-types.md) — CRITICAL (enables targeted traversals, avoids full-graph scans)
3. [Property Placement](references/_sections.md#3-property-placement) — **HIGH**
   - 3.1 [Avoid Embedding Foreign Keys as Properties](references/prop-no-foreign-keys.md) — HIGH (eliminates the #1 relational-thinking mistake in graphs)
   - 3.2 [Avoid Property Arrays When You Need Relationships](references/prop-no-arrays-for-connections.md) — HIGH (prevents O(n) scans on opaque array values)
   - 3.3 [Know When Data Belongs on Relationship vs. Node](references/prop-relationship-vs-node-data.md) — HIGH (prevents unqueryable properties and semantic confusion)
   - 3.4 [Promote Frequently-Queried Values to Nodes](references/prop-promote-to-node.md) — HIGH (converts O(n) full-label scans to O(k) targeted traversals)
   - 3.5 [Use Appropriate Data Types for Properties](references/prop-correct-data-types.md) — HIGH (enables range queries, saves storage, prevents data corruption)
4. [Query-Driven Refinement](references/_sections.md#4-query-driven-refinement) — **HIGH**
   - 4.1 [Add Shortcut Relationships for Frequent Multi-Hop Queries](references/query-shortcut-relationships.md) — MEDIUM-HIGH (reduces 3-5 hop traversals to 1 hop for hot paths)
   - 4.2 [Denormalize for Read-Heavy Paths](references/query-denormalize-reads.md) — MEDIUM-HIGH (eliminates N+1 traversals on read-heavy display paths)
   - 4.3 [Design the Model for Your Most Critical Traversals First](references/query-critical-traversals.md) — MEDIUM-HIGH (prevents costly schema refactors after deployment)
   - 4.4 [Test Your Model Against Real Queries Before Deploying](references/query-test-before-deploy.md) — MEDIUM-HIGH (prevents 10-100× refactoring cost post-deployment)
   - 4.5 [Use Relationship Properties to Filter Traversals](references/query-filter-by-rel-props.md) — MEDIUM-HIGH (reduces traversal scope by 10-100× on time-filtered queries)
5. [Structural Patterns](references/_sections.md#5-structural-patterns) — **HIGH**
   - 5.1 [Apply Timeline Trees for Temporal Data](references/pattern-timeline-tree.md) — HIGH (enables efficient time-based queries without scanning all events)
   - 5.2 [Model Hierarchies with Category Nodes and Depth Relationships](references/pattern-hierarchy.md) — HIGH (enables both drill-down and roll-up queries on taxonomies)
   - 5.3 [Use Bipartite Structure for Many-to-Many with Context](references/pattern-bipartite.md) — HIGH (reduces entity confusion and prevents 2× node duplication)
   - 5.4 [Use Fan-Out Pattern for Event Streams and Activity Feeds](references/pattern-fan-out.md) — HIGH (reduces timeline queries from O(n) to O(k) for last k events)
   - 5.5 [Use Intermediary Nodes for Multi-Entity Relationships](references/pattern-intermediary-nodes.md) — HIGH (enables connecting 3+ entities through one event node)
   - 5.6 [Use Linked Lists for Ordered Sequences](references/pattern-linked-list.md) — HIGH (preserves insertion order without index properties)
6. [Anti-Patterns](references/_sections.md#6-anti-patterns) — **MEDIUM**
   - 6.1 [Avoid Duplicating Data Instead of Creating Relationships](references/anti-duplicate-data.md) — MEDIUM (eliminates update anomalies and storage waste)
   - 6.2 [Avoid Encoding Structured Data as Delimited Strings](references/anti-string-encoded-structure.md) — MEDIUM (prevents unqueryable opaque blobs hiding in properties)
   - 6.3 [Avoid Generic RELATED_TO or CONNECTED Relationships](references/anti-generic-relationships.md) — MEDIUM (prevents ambiguous traversals that return wrong results)
   - 6.4 [Avoid Making Everything a Node](references/anti-over-modeling.md) — MEDIUM (avoids graph bloat and unnecessary traversal complexity)
   - 6.5 [Avoid Modeling Relational Join Tables as Nodes](references/anti-join-table-nodes.md) — MEDIUM (reduces traversal depth by 2× per join-table elimination)
   - 6.6 [Avoid Porting Relational Schemas Directly to Graph](references/anti-relational-porting.md) — MEDIUM (prevents graphs that are just slow, denormalized relational databases)
7. [Constraints & Integrity](references/_sections.md#7-constraints-&-integrity) — **MEDIUM**
   - 7.1 [Avoid Over-Indexing — Each Index Has a Write Cost](references/constraint-no-over-index.md) — MEDIUM (prevents write amplification that degrades insert and update performance)
   - 7.2 [Create Indexes on Properties Used as Traversal Entry Points](references/constraint-index-traversals.md) — MEDIUM (turns O(n) lookups into O(log n) for query starting points)
   - 7.3 [Define Uniqueness Constraints on Natural Identifiers](references/constraint-unique-identifiers.md) — MEDIUM (prevents duplicate entities and enables fast lookups)
   - 7.4 [Use Composite Node Keys for Natural Multi-Part Identifiers](references/constraint-node-key.md) — MEDIUM (enforces uniqueness on combinations, not just single properties)
   - 7.5 [Use Existence Constraints for Required Properties](references/constraint-existence.md) — MEDIUM (prevents NULL-related query failures at insert time)
8. [Scale & Evolution](references/_sections.md#8-scale-&-evolution) — **LOW-MEDIUM**
   - 8.1 [Mitigate Supernodes with Fan-Out or Partitioning](references/scale-supernode-mitigation.md) — LOW-MEDIUM (prevents single nodes from becoming traversal bottlenecks at scale)
   - 8.2 [Monitor and Detect Emerging Supernodes](references/scale-dense-node-detection.md) — LOW-MEDIUM (prevents 10-100× query slowdown from undetected supernodes)
   - 8.3 [Plan for Label and Relationship Type Evolution](references/scale-schema-migration.md) — LOW-MEDIUM (prevents breaking changes when the domain model evolves)
   - 8.4 [Separate Current State from Historical State](references/scale-temporal-versioning.md) — LOW-MEDIUM (enables time-travel queries without polluting current-state traversals)
   - 8.5 [Use APOC or Batched Queries for Schema Refactoring](references/scale-batch-refactoring.md) — LOW-MEDIUM (prevents out-of-memory errors on large-scale schema changes)

---

## References

1. [https://neo4j.com/docs/getting-started/data-modeling/](https://neo4j.com/docs/getting-started/data-modeling/)
2. [https://neo4j.com/docs/getting-started/data-modeling/modeling-tips/](https://neo4j.com/docs/getting-started/data-modeling/modeling-tips/)
3. [https://neo4j.com/docs/getting-started/data-modeling/modeling-designs/](https://neo4j.com/docs/getting-started/data-modeling/modeling-designs/)
4. [https://neo4j.com/blog/graph-data-science/data-modeling-pitfalls/](https://neo4j.com/blog/graph-data-science/data-modeling-pitfalls/)
5. [https://memgraph.com/docs/data-modeling/best-practices](https://memgraph.com/docs/data-modeling/best-practices)
6. [https://bigbear.ai/blog/property-graphs-is-it-a-node-a-relationship-or-a-property/](https://bigbear.ai/blog/property-graphs-is-it-a-node-a-relationship-or-a-property/)
7. [https://neo4j.com/graphacademy/training-gdm-40/03-graph-data-modeling-core-principles/](https://neo4j.com/graphacademy/training-gdm-40/03-graph-data-modeling-core-principles/)
8. [https://neo4j.com/docs/cypher-manual/current/syntax/naming/](https://neo4j.com/docs/cypher-manual/current/syntax/naming/)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |