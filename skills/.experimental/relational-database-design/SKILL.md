---
name: relational-database-design
description: Distills a logical relational-database design methodology into rules an agent applies while designing or reviewing a schema. Covers the design sequence (mission → tables → fields → keys → relationships → business rules → views → integrity review), one-subject-per-table decomposition, atomic single-valued fields, candidate/primary/foreign keys, relationship types with deletion rules and participation, the four levels of data integrity, database-vs-application business rules, validation tables, views for derived data, and the flat-file / spreadsheet / RDBMS-driven antipatterns to avoid. The structure is logical and RDBMS-agnostic, and normalized by construction. Use when designing a new relational schema, reviewing or refactoring an existing one, resolving redundant or repeating data, choosing keys, modeling relationships, or deciding where a constraint belongs.
---

# Relational Database Design

A logical, RDBMS-agnostic method for designing sound relational databases — the decisions a schema forces and how a disciplined logical-design methodology settles them, written so an agent applies them while designing or reviewing a schema. Each rule names a specific wrong default it corrects; there is no rule for things the model already gets right.

The whole method produces the logical structure first — the tables, fields, keys, relationships, and integrity rules an organization's information requires — deliberately independent of any particular RDBMS product or physical/performance concern. Followed faithfully, it yields fully normalized tables without treating normalization as a separate back-end phase.

## When to Apply

- Designing a new relational schema from requirements
- Reviewing or refactoring an existing schema for structural soundness
- Resolving repeating groups, multivalued/multipart fields, or redundant data
- Choosing candidate, primary, and foreign keys for a table
- Modeling one-to-one, one-to-many, many-to-many, or self-referencing relationships
- Deciding deletion rules (restrict, cascade, nullify, deny, set default) and participation constraints
- Deciding where a constraint belongs — field spec, relationship, validation table, or application
- Diagnosing a schema that duplicates, loses, or corrupts data

This skill covers **logical** design. It does not cover SQL dialects, indexing, partitioning, query tuning, or analytical/dimensional (star-schema) modeling — those are physical/implementation concerns handled after the logical design is sound.

## Rule Categories

| # | Category | Prefix | Covers |
|---|----------|--------|--------|
| 1 | Design Process & Requirements | `proc-` | Design logically before choosing an RDBMS, follow the sequence, drive from mission + analysis, normalization is built in |
| 2 | Table Structure | `tbl-` | One subject per table, the ideal table, no reference fields, minimal redundancy |
| 3 | Field Design | `fld-` | The ideal field, single values, atomic fields, no stored calculations, clear names |
| 4 | Keys | `key-` | Candidate key elements, one primary key per table, foreign keys mirror primary keys, stable non-sensitive keys |
| 5 | Relationships | `rel-` | Junction tables for many-to-many, foreign-key placement, deletion rules, participation, self-referencing |
| 6 | Data Integrity, Rules & Views | `intg-` | The four integrity levels, field specifications, database-vs-application rules, validation tables, views |
| 7 | Antipatterns | `anti-` | Flat-file, spreadsheet-as-database, RDBMS-driven design, when bending the rules is defensible |
| 8 | Terminology | `term-` | Data vs information, nulls, core relational vocabulary |

## Quick Reference

### 1. Design Process & Requirements

- [`proc-follow-the-design-sequence`](references/proc-follow-the-design-sequence.md) — later steps depend on earlier ones; skipping steps yields poor integrity
- [`proc-design-logically-before-choosing-rdbms`](references/proc-design-logically-before-choosing-rdbms.md) — design the logical structure with no RDBMS in mind; choose and implement afterward
- [`proc-start-from-mission-and-objectives`](references/proc-start-from-mission-and-objectives.md) — a mission statement and objectives scope the database and reveal its subjects
- [`proc-analyze-and-interview-before-designing`](references/proc-analyze-and-interview-before-designing.md) — analyze the current system and interview users and management before inventing fields
- [`proc-normalization-is-built-in`](references/proc-normalization-is-built-in.md) — the ideal-field/ideal-table/key guidelines yield normalized tables; normalization is not a separate phase

### 2. Table Structure

- [`tbl-one-subject-per-table`](references/tbl-one-subject-per-table.md) — each table represents exactly one subject (object or event)
- [`tbl-ideal-table-checklist`](references/tbl-ideal-table-checklist.md) — the six-point test for a sound table structure
- [`tbl-no-reference-fields`](references/tbl-no-reference-fields.md) — don't copy fields from another table for reporting convenience
- [`tbl-minimize-redundant-data`](references/tbl-minimize-redundant-data.md) — FK-driven redundancy is fine; keep everything else to an absolute minimum

### 3. Field Design

- [`fld-ideal-field-checklist`](references/fld-ideal-field-checklist.md) — the test for a sound field
- [`fld-store-single-values-not-lists`](references/fld-store-single-values-not-lists.md) — a multivalued field becomes its own table
- [`fld-keep-fields-atomic`](references/fld-keep-fields-atomic.md) — decompose multipart/composite fields into one field per distinct item
- [`fld-derive-dont-store-calculated-values`](references/fld-derive-dont-store-calculated-values.md) — calculations belong in a view, not a stored field
- [`fld-clear-singular-field-names`](references/fld-clear-singular-field-names.md) — one unambiguous, singular name per characteristic

### 4. Keys

- [`key-candidate-key-elements`](references/key-candidate-key-elements.md) — the test a field (or field set) must pass to be a candidate key
- [`key-one-primary-key-per-table`](references/key-one-primary-key-per-table.md) — exactly one non-null, unique, stable primary key per table
- [`key-foreign-key-mirrors-its-primary-key`](references/key-foreign-key-mirrors-its-primary-key.md) — same name, replica spec, values drawn from the referenced primary key
- [`key-prefer-stable-non-sensitive-keys`](references/key-prefer-stable-non-sensitive-keys.md) — a key value should rarely change and must not expose sensitive data

### 5. Relationships

- [`rel-junction-table-for-many-to-many`](references/rel-junction-table-for-many-to-many.md) — resolve M:N with a linking table keyed on both foreign keys
- [`rel-foreign-key-on-the-many-side`](references/rel-foreign-key-on-the-many-side.md) — the foreign key lives on the many side of a one-to-many
- [`rel-deletion-rule-guards-orphans`](references/rel-deletion-rule-guards-orphans.md) — every relationship gets a deletion rule; restrict by default
- [`rel-participation-encodes-constraints`](references/rel-participation-encodes-constraints.md) — mandatory/optional and degree (min,max) capture real business limits
- [`rel-self-referencing-relationships`](references/rel-self-referencing-relationships.md) — a table related to itself needs a distinctly named foreign key

### 6. Data Integrity, Rules & Views

- [`intg-four-levels-of-data-integrity`](references/intg-four-levels-of-data-integrity.md) — table, field, relationship, and business-rule integrity together
- [`intg-field-specifications`](references/intg-field-specifications.md) — pin down every field's general, physical, and logical elements
- [`intg-database-vs-application-rules`](references/intg-database-vs-application-rules.md) — enforce structural rules in the schema; conditional/derived rules in the application
- [`intg-validation-tables-for-allowed-values`](references/intg-validation-tables-for-allowed-values.md) — a lookup table beats a hardcoded value list
- [`intg-views-for-derived-and-restricted-data`](references/intg-views-for-derived-and-restricted-data.md) — data, aggregate, and validation views instead of extra stored fields

### 7. Antipatterns

- [`anti-flat-file-design`](references/anti-flat-file-design.md) — the throw-everything-in-one-table structure and how to spot it
- [`anti-spreadsheet-as-database`](references/anti-spreadsheet-as-database.md) — a spreadsheet layout is not a relational schema
- [`anti-rdbms-driven-design`](references/anti-rdbms-driven-design.md) — don't let the product you know dictate the design
- [`anti-bend-rules-only-deliberately`](references/anti-bend-rules-only-deliberately.md) — the only two defensible reasons to break the rules, and how to document it

### 8. Terminology

- [`term-data-versus-information`](references/term-data-versus-information.md) — data is stored; information is data made meaningful for presentation
- [`term-null-is-unknown-not-zero`](references/term-null-is-unknown-not-zero.md) — a null is a missing/unknown value, not zero or blank
- [`term-relational-vocabulary`](references/term-relational-vocabulary.md) — key is logical, index is physical; a view is not a table

## How to Use

Read a reference file when its decision comes up. Each rule names the wrong default it corrects, then shows the canonical way (with an incorrect/correct contrast only where the wrong way is a real trap).

- [Section definitions](references/_sections.md) — category structure
- [Rule template](assets/templates/_template.md) — for adding new rules
- [AGENTS.md](AGENTS.md) — auto-built table of contents across all rules

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [metadata.json](metadata.json) | Version and source references |
