# Relational database design (RDBMS-agnostic)

**Version 0.1.0**  
community  
July 2026

---

## Abstract

Distills a logical relational-database design methodology into rules an agent applies while designing or reviewing a schema. Covers the design sequence, one-subject tables, atomic single-valued fields, candidate/primary/foreign keys, relationships with deletion rules and participation, the four levels of data integrity, business rules and views, and the bad-design antipatterns to avoid — all expressed as logical structure that is independent of any specific RDBMS and normalized by construction.

---

## Table of Contents

1. [Design Process & Requirements](references/_sections.md#1-design-process-&-requirements)
   - 1.1 [Analyze the current system and interview before inventing fields](references/proc-analyze-and-interview-before-designing.md)
   - 1.2 [Design the logical structure before choosing an RDBMS](references/proc-design-logically-before-choosing-rdbms.md)
   - 1.3 [Follow the design sequence — each step depends on the last](references/proc-follow-the-design-sequence.md)
   - 1.4 [Normalization is built into the method, not a separate phase](references/proc-normalization-is-built-in.md)
   - 1.5 [Start from a mission statement and mission objectives](references/proc-start-from-mission-and-objectives.md)
2. [Table Structure](references/_sections.md#2-table-structure)
   - 2.1 [Avoid reference fields copied from another table](references/tbl-no-reference-fields.md)
   - 2.2 [Distinguish acceptable from harmful redundant data](references/tbl-minimize-redundant-data.md)
   - 2.3 [Each table represents exactly one subject](references/tbl-one-subject-per-table.md)
   - 2.4 [Test every table against the ideal-table checklist](references/tbl-ideal-table-checklist.md)
3. [Field Design](references/_sections.md#3-field-design)
   - 3.1 [Calculations belong in a view, not a stored field](references/fld-derive-dont-store-calculated-values.md)
   - 3.2 [Decompose multipart fields into one field per distinct item](references/fld-keep-fields-atomic.md)
   - 3.3 [Give each field one unambiguous, singular name](references/fld-clear-singular-field-names.md)
   - 3.4 [Move a multivalued field into its own table](references/fld-store-single-values-not-lists.md)
   - 3.5 [Test every field against the ideal-field checklist](references/fld-ideal-field-checklist.md)
4. [Keys](references/_sections.md#4-keys)
   - 4.1 [Give every table exactly one primary key](references/key-one-primary-key-per-table.md)
   - 4.2 [Mirror the referenced primary key in every foreign key](references/key-foreign-key-mirrors-its-primary-key.md)
   - 4.3 [Prefer a key value that rarely changes and exposes nothing sensitive](references/key-prefer-stable-non-sensitive-keys.md)
   - 4.4 [Qualify a candidate key against every element before trusting it](references/key-candidate-key-elements.md)
5. [Relationships](references/_sections.md#5-relationships)
   - 5.1 [Define a deletion rule for every relationship](references/rel-deletion-rule-guards-orphans.md)
   - 5.2 [Give a self-referencing table a distinctly named foreign key](references/rel-self-referencing-relationships.md)
   - 5.3 [Participation type and degree capture real business limits](references/rel-participation-encodes-constraints.md)
   - 5.4 [Place the foreign key on the many side of a one-to-many](references/rel-foreign-key-on-the-many-side.md)
   - 5.5 [Resolve many-to-many with a junction table](references/rel-junction-table-for-many-to-many.md)
6. [Data Integrity, Rules & Views](references/_sections.md#6-data-integrity,-rules-&-views)
   - 6.1 [Data integrity is the sum of four levels — review all four](references/intg-four-levels-of-data-integrity.md)
   - 6.2 [Enforce structural rules in the schema, conditional rules in the application](references/intg-database-vs-application-rules.md)
   - 6.3 [Pin down every field with a full field specification](references/intg-field-specifications.md)
   - 6.4 [Use a validation table for a field's allowed values](references/intg-validation-tables-for-allowed-values.md)
   - 6.5 [Use views for derived, combined, and restricted data](references/intg-views-for-derived-and-restricted-data.md)
7. [Antipatterns](references/_sections.md#7-antipatterns)
   - 7.1 [Bend the design rules only for two reasons, and document it](references/anti-bend-rules-only-deliberately.md)
   - 7.2 [Drive the design from requirements, not the RDBMS product](references/anti-rdbms-driven-design.md)
   - 7.3 [Reject flat-file design — the one-giant-table structure](references/anti-flat-file-design.md)
   - 7.4 [Reject the spreadsheet layout as a schema](references/anti-spreadsheet-as-database.md)
8. [Terminology](references/_sections.md#8-terminology)
   - 8.1 [Data is what you store; information is what you present](references/term-data-versus-information.md)
   - 8.2 [Keep key separate from index, and view separate from table](references/term-relational-vocabulary.md)
   - 8.3 [Treat a null as unknown, not as zero or blank](references/term-null-is-unknown-not-zero.md)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |