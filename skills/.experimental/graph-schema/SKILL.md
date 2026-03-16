---
name: graph-schema
description: Graph database schema design and data modeling expert. Use when designing, reviewing, or refactoring graph database schemas (Neo4j, Memgraph, Neptune, etc.). Triggers on graph modeling, node/relationship design, Cypher schema, property graph design, knowledge graph modeling, or when translating a domain into a graph structure. Focuses primarily on data modeling correctness — understanding the user's goal and translating it into the right graph structure — with performance as a secondary concern.
---

# dot-skills Graph Database Schema Design Best Practices

Comprehensive graph database data modeling guide for property graphs (Neo4j, Memgraph, Amazon Neptune, etc.). Contains 46 rules across 8 categories, prioritized by modeling impact from critical (entity classification, relationship design) to incremental (scale and evolution). Each rule includes detailed explanations, real-world Cypher examples comparing incorrect vs. correct models, and specific impact descriptions.

**Philosophy:** Data modeling correctness first, performance second. Always ask "what is the user trying to achieve?" before choosing structure.

## When to Apply

Reference these guidelines when:
- Designing a new graph database schema from domain requirements
- Translating a relational schema to a graph model
- Deciding whether something should be a node, relationship, or property
- Reviewing an existing graph schema for modeling errors
- Refactoring a graph that produces awkward or slow queries
- Planning for schema evolution and data growth

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Entity Classification | CRITICAL | `entity-` |
| 2 | Relationship Design | CRITICAL | `rel-` |
| 3 | Property Placement | HIGH | `prop-` |
| 4 | Query-Driven Refinement | HIGH | `query-` |
| 5 | Structural Patterns | HIGH | `pattern-` |
| 6 | Anti-Patterns | MEDIUM | `anti-` |
| 7 | Constraints & Integrity | MEDIUM | `constraint-` |
| 8 | Scale & Evolution | LOW-MEDIUM | `scale-` |

## Quick Reference

### 1. Entity Classification (CRITICAL)

- [`entity-events`](references/entity-events.md) - Model multi-participant events as first-class nodes
- [`entity-shared-values`](references/entity-shared-values.md) - Promote shared property values to nodes
- [`entity-specific-labels`](references/entity-specific-labels.md) - Use specific labels over generic ones
- [`entity-multi-label`](references/entity-multi-label.md) - Qualify entities with multiple labels
- [`entity-identity-state`](references/entity-identity-state.md) - Separate identity from mutable state
- [`entity-reify-actions`](references/entity-reify-actions.md) - Reify lifecycle actions into nodes
- [`entity-avoid-god-nodes`](references/entity-avoid-god-nodes.md) - Avoid kitchen-sink entity nodes

### 2. Relationship Design (CRITICAL)

- [`rel-specific-types`](references/rel-specific-types.md) - Use specific relationship types over generic ones
- [`rel-meaningful-direction`](references/rel-meaningful-direction.md) - Choose semantically meaningful direction
- [`rel-naming-conventions`](references/rel-naming-conventions.md) - Follow UPPER_SNAKE_CASE for relationship types
- [`rel-no-redundant-reverse`](references/rel-no-redundant-reverse.md) - Don't create redundant reverse relationships
- [`rel-properties-scope`](references/rel-properties-scope.md) - Put data on relationships only when it describes the connection
- [`rel-single-semantic`](references/rel-single-semantic.md) - One relationship type per semantic meaning
- [`rel-typed-over-filtered`](references/rel-typed-over-filtered.md) - Prefer typed relationships over generic + property filter

### 3. Property Placement (HIGH)

- [`prop-no-foreign-keys`](references/prop-no-foreign-keys.md) - Don't embed foreign keys as properties
- [`prop-promote-to-node`](references/prop-promote-to-node.md) - Promote frequently-queried values to nodes
- [`prop-correct-data-types`](references/prop-correct-data-types.md) - Use appropriate data types for properties
- [`prop-no-arrays-for-connections`](references/prop-no-arrays-for-connections.md) - Don't use property arrays when you need relationships
- [`prop-relationship-vs-node-data`](references/prop-relationship-vs-node-data.md) - Know when data belongs on relationship vs. node

### 4. Query-Driven Refinement (HIGH)

- [`query-critical-traversals`](references/query-critical-traversals.md) - Design for your most critical traversals first
- [`query-shortcut-relationships`](references/query-shortcut-relationships.md) - Add shortcut relationships for frequent multi-hop queries
- [`query-denormalize-reads`](references/query-denormalize-reads.md) - Denormalize for read-heavy paths
- [`query-filter-by-rel-props`](references/query-filter-by-rel-props.md) - Use relationship properties to filter traversals
- [`query-test-before-deploy`](references/query-test-before-deploy.md) - Test model against real queries before deploying

### 5. Structural Patterns (HIGH)

- [`pattern-intermediary-nodes`](references/pattern-intermediary-nodes.md) - Use intermediary nodes for multi-entity relationships
- [`pattern-hierarchy`](references/pattern-hierarchy.md) - Model hierarchies with category nodes and depth relationships
- [`pattern-linked-list`](references/pattern-linked-list.md) - Use linked lists for ordered sequences
- [`pattern-timeline-tree`](references/pattern-timeline-tree.md) - Apply timeline trees for temporal data
- [`pattern-fan-out`](references/pattern-fan-out.md) - Fan-out pattern for event streams and activity feeds
- [`pattern-bipartite`](references/pattern-bipartite.md) - Use bipartite structure for many-to-many with context

### 6. Anti-Patterns (MEDIUM)

- [`anti-join-table-nodes`](references/anti-join-table-nodes.md) - Don't model relational join tables as nodes
- [`anti-generic-relationships`](references/anti-generic-relationships.md) - Don't use generic RELATED_TO or CONNECTED relationships
- [`anti-relational-porting`](references/anti-relational-porting.md) - Don't port relational schemas directly to graph
- [`anti-over-modeling`](references/anti-over-modeling.md) - Don't make everything a node
- [`anti-duplicate-data`](references/anti-duplicate-data.md) - Don't duplicate data instead of creating relationships
- [`anti-string-encoded-structure`](references/anti-string-encoded-structure.md) - Don't encode structured data as delimited strings

### 7. Constraints & Integrity (MEDIUM)

- [`constraint-unique-identifiers`](references/constraint-unique-identifiers.md) - Define uniqueness constraints on natural identifiers
- [`constraint-existence`](references/constraint-existence.md) - Use existence constraints for required properties
- [`constraint-index-traversals`](references/constraint-index-traversals.md) - Create indexes on traversal entry point properties
- [`constraint-no-over-index`](references/constraint-no-over-index.md) - Don't over-index — each index has a write cost
- [`constraint-node-key`](references/constraint-node-key.md) - Use composite node keys for natural multi-part identifiers

### 8. Scale & Evolution (LOW-MEDIUM)

- [`scale-supernode-mitigation`](references/scale-supernode-mitigation.md) - Mitigate supernodes with fan-out or partitioning
- [`scale-temporal-versioning`](references/scale-temporal-versioning.md) - Separate current state from historical state
- [`scale-schema-migration`](references/scale-schema-migration.md) - Plan for label and relationship type evolution
- [`scale-batch-refactoring`](references/scale-batch-refactoring.md) - Use APOC or batched queries for schema refactoring
- [`scale-dense-node-detection`](references/scale-dense-node-detection.md) - Monitor and detect emerging supernodes

## How to Use

Read individual reference files for detailed explanations and code examples:

- [Section definitions](references/_sections.md) - Category structure and impact levels
- [Rule template](assets/templates/_template.md) - Template for adding new rules

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [metadata.json](metadata.json) | Version and reference information |
