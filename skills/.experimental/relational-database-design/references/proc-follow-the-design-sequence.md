---
title: Follow the design sequence — each step depends on the last
tags: proc, process, sequence
---

## Follow the design sequence — each step depends on the last

The wrong default is to jump straight to `CREATE TABLE` from a mental picture of the data. The method is ordered because every step consumes the output of the one before it: you cannot choose a primary key before the table's fields are final, cannot place a foreign key before the relationship is identified, and cannot write a business rule before the field specifications exist. Skipping or reordering steps is what produces tables with no sound key, relationships with no referential integrity, and constraints enforced in the wrong place.

The sequence for the logical design:

```text
1. Mission statement + mission objectives   (why the database exists, its subjects)
2. Analyze current system + interview        (users AND management, separately)
3. Preliminary field list                    (every characteristic the org tracks)
4. Table list                                (one subject per table)
5. Assign fields to tables, then refine      (resolve multivalued/multipart/calculated)
6. Keys                                       (candidate → primary; foreign keys)
7. Relationships                             (type, FK placement, deletion rule, participation)
8. Business rules                            (field-specific, then relationship-specific)
9. Views                                      (data / aggregate / validation)
10. Data-integrity review                     (table, field, relationship, business-rule)
```

Work a step to completion before moving on; when a later step exposes a defect (for example a field that turns out to be multivalued), take the affected table back through the earlier steps rather than patching in place.
