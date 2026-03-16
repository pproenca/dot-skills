# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Entity Classification (entity)

**Impact:** CRITICAL
**Description:** What becomes a node determines the entire graph's shape and queryability — events, shared values, and domain concepts modeled as properties instead of nodes cripple traversal and insight.

## 2. Relationship Design (rel)

**Impact:** CRITICAL
**Description:** Relationship type naming, direction, granularity, and property placement define traversal semantics — generic or misnamed relationships make the graph unreadable and unqueryable.

## 3. Property Placement (prop)

**Impact:** HIGH
**Description:** Choosing whether data lives on a node, a relationship, or as a separate node affects correctness, deduplication, and query flexibility — misplaced properties are the most common modeling error.

## 4. Query-Driven Refinement (query)

**Impact:** HIGH
**Description:** Understand your access patterns first, then design the model to serve them — shortcut relationships, denormalization, materialized paths — without breaking semantic correctness.

## 5. Structural Patterns (pattern)

**Impact:** HIGH
**Description:** Proven graph structures (intermediary nodes, linked lists, hierarchies, temporal trees) solve recurring modeling challenges that ad-hoc designs get wrong.

## 6. Anti-Patterns (anti)

**Impact:** MEDIUM
**Description:** Relational thinking habits (join tables as nodes, foreign key properties, generic relationships, over-modeling) are the most common source of bad graph schemas.

## 7. Constraints & Integrity (constraint)

**Impact:** MEDIUM
**Description:** Uniqueness constraints, existence constraints, indexes, and validation rules enforce data quality in graph databases' schema-flexible world.

## 8. Scale & Evolution (scale)

**Impact:** LOW-MEDIUM
**Description:** Supernode mitigation, temporal versioning, schema migration, and growth planning keep a correct model performant as data volume and complexity increase.
