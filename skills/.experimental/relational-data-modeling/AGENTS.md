# Relational Data Modeling

**Version 0.1.0**  
community  
July 2026

---

## Abstract

Corrects the wrong defaults a capable model has when designing a relational schema, covering the decisions where it imports ORM habits that discard referential integrity — polymorphic foreign keys, reflexive surrogate keys, one-to-one splits, blanket soft-delete flags — and the ones where it leaves an invariant to application code that the engine could prove instead. Examples are PostgreSQL 18, executed against 18.4 including their failure cases.

---

## Table of Contents

1. [Identity and Keys](references/_sections.md#1-identity-and-keys)
   - 1.1 [Give a table the key its rows actually have](references/key-primary-key-is-real-identity.md)
   - 1.2 [Propagate the scoping key into child keys](references/key-propagate-scoping-key.md)
   - 1.3 [Treat the partition axis as a key decision, not a later tuning knob](references/key-partition-axis-binds-the-key.md)
   - 1.4 [Use GENERATED ALWAYS AS IDENTITY, not serial](references/key-identity-not-serial.md)
   - 1.5 [Use uuidv7 when keys must be client-generated](references/key-uuidv7-for-client-generated.md)
2. [Relationships and Cardinality](references/_sections.md#2-relationships-and-cardinality)
   - 2.1 [Avoid polymorphic foreign keys](references/rel-no-polymorphic-fk.md)
   - 2.2 [Choose the referential action per relationship](references/rel-choose-referential-action.md)
   - 2.3 [Enforce disjoint subtypes through the key](references/rel-subtypes-through-the-key.md)
   - 2.4 [Index the referencing side of every foreign key yourself](references/rel-index-referencing-side.md)
   - 2.5 [Keep a one-to-one relationship in one table](references/rel-one-to-one-is-one-table.md)
   - 2.6 [Model a many-to-many as an entity when the relationship has facts of its own](references/rel-relationship-as-entity.md)
3. [Constraints as the Model](references/_sections.md#3-constraints-as-the-model)
   - 3.1 [Add constraints to live tables NOT VALID, then VALIDATE](references/cons-not-valid-then-validate.md)
   - 3.2 [Keep CHECK constraints single-row and immutable](references/cons-check-is-single-row.md)
   - 3.3 [Know where NULL silently defeats a constraint](references/cons-not-null-by-default.md)
   - 3.4 [Use a partial unique index for at most one active row](references/cons-partial-unique-index.md)
   - 3.5 [Use deferrable constraints for genuine cycles instead of nullable columns](references/cons-deferrable-for-cycles.md)
   - 3.6 [Use EXCLUDE constraints for non-overlap instead of application checks](references/cons-exclude-for-non-overlap.md)
4. [Types and Domains](references/_sections.md#4-types-and-domains)
   - 4.1 [Choose between CHECK, a lookup table, and an enum type deliberately](references/type-enum-lookup-or-check.md)
   - 4.2 [Model a period as a range type, not two loose columns](references/type-range-not-two-columns.md)
   - 4.3 [Store amounts as exact numerics with an explicit currency](references/type-numeric-with-currency.md)
   - 4.4 [Use text with a CHECK rather than varchar(n)](references/type-text-over-varchar.md)
   - 4.5 [Use timestamptz for instants and date or time for civil values](references/type-timestamptz-for-instants.md)
5. [Derived and Encoded Data](references/_sections.md#5-derived-and-encoded-data)
   - 5.1 [Give every derived value an enforcement mechanism](references/norm-derived-needs-a-mechanism.md)
   - 5.2 [Store the parts and generate the composite, never parse it back](references/norm-encoded-composite-values.md)
   - 5.3 [Use JSONB for genuinely open shapes, not as a schema escape hatch](references/norm-jsonb-for-open-shapes.md)
6. [Time, History and Lifecycle](references/_sections.md#6-time,-history-and-lifecycle)
   - 6.1 [Model auditable facts as immutable events and derive the state](references/time-events-not-in-place-updates.md)
   - 6.2 [Model validity as a range and let the database enforce it](references/time-validity-as-a-range.md)
   - 6.3 [Separate valid time from transaction time only when you must reproduce a past belief](references/time-valid-vs-transaction-time.md)
   - 6.4 [Treat soft-delete flags as constraint-disabling, not free](references/time-soft-delete-breaks-constraints.md)

---

## References

1. [https://www.postgresql.org/docs/18/ddl-constraints.html](https://www.postgresql.org/docs/18/ddl-constraints.html)
2. [https://www.postgresql.org/docs/18/sql-createtable.html](https://www.postgresql.org/docs/18/sql-createtable.html)
3. [https://www.postgresql.org/docs/18/sql-altertable.html](https://www.postgresql.org/docs/18/sql-altertable.html)
4. [https://www.postgresql.org/docs/18/sql-altertype.html](https://www.postgresql.org/docs/18/sql-altertype.html)
5. [https://www.postgresql.org/docs/18/indexes-partial.html](https://www.postgresql.org/docs/18/indexes-partial.html)
6. [https://www.postgresql.org/docs/18/ddl-partitioning.html](https://www.postgresql.org/docs/18/ddl-partitioning.html)
7. [https://www.postgresql.org/docs/18/ddl-generated-columns.html](https://www.postgresql.org/docs/18/ddl-generated-columns.html)
8. [https://www.postgresql.org/docs/18/rangetypes.html](https://www.postgresql.org/docs/18/rangetypes.html)
9. [https://www.postgresql.org/docs/18/datatype-datetime.html](https://www.postgresql.org/docs/18/datatype-datetime.html)
10. [https://www.postgresql.org/docs/18/datatype-numeric.html](https://www.postgresql.org/docs/18/datatype-numeric.html)
11. [https://www.postgresql.org/docs/18/datatype-character.html](https://www.postgresql.org/docs/18/datatype-character.html)
12. [https://www.postgresql.org/docs/18/datatype-enum.html](https://www.postgresql.org/docs/18/datatype-enum.html)
13. [https://www.postgresql.org/docs/18/datatype-json.html](https://www.postgresql.org/docs/18/datatype-json.html)
14. [https://www.postgresql.org/docs/18/functions-uuid.html](https://www.postgresql.org/docs/18/functions-uuid.html)
15. [https://www.postgresql.org/docs/18/btree-gist.html](https://www.postgresql.org/docs/18/btree-gist.html)
16. [https://www.postgresql.org/docs/18/storage-toast.html](https://www.postgresql.org/docs/18/storage-toast.html)
17. [https://www.postgresql.org/docs/18/sql-set-constraints.html](https://www.postgresql.org/docs/18/sql-set-constraints.html)
18. [https://www.postgresql.org/docs/18/sql-refreshmaterializedview.html](https://www.postgresql.org/docs/18/sql-refreshmaterializedview.html)
19. [https://www.postgresql.org/docs/release/18.0/](https://www.postgresql.org/docs/release/18.0/)
20. [https://wiki.postgresql.org/wiki/Don%27t_Do_This](https://wiki.postgresql.org/wiki/Don%27t_Do_This)
21. [https://dev.mysql.com/doc/refman/8.4/en/create-table-foreign-keys.html](https://dev.mysql.com/doc/refman/8.4/en/create-table-foreign-keys.html)
22. [https://pragprog.com/titles/bksap1/sql-antipatterns-volume-1/](https://pragprog.com/titles/bksap1/sql-antipatterns-volume-1/)
23. [https://martinfowler.com/eaaCatalog/](https://martinfowler.com/eaaCatalog/)
24. [https://martinfowler.com/eaaDev/AccountingEntry.html](https://martinfowler.com/eaaDev/AccountingEntry.html)
25. [https://www2.cs.arizona.edu/~rts/tdbbook.pdf](https://www2.cs.arizona.edu/~rts/tdbbook.pdf)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |