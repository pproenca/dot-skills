---
title: Data integrity is the sum of four levels — review all four
tags: intg, data-integrity, review
---

## Data integrity is the sum of four levels — review all four

The wrong default is to treat "data integrity" as one thing (usually just constraints on a couple of columns) and assume it is handled. Overall integrity is the sum of four distinct levels, each established at a different point in the design and each with its own failure mode. The final design step is a deliberate review that every level holds — a gap in any one lets bad data in.

```text
Table-level integrity        — no duplicate records; the primary key uniquely
                               identifies each record; primary-key values are never null.
Field-level integrity        — each field's identity and purpose are clear; its
                               definition is consistent everywhere it appears; its
                               values are valid; allowed operations are defined.
                               (Established by the field specification.)
Relationship-level integrity — the connection between related tables is sound:
                               valid foreign keys, appropriate deletion rules.
Business-rule integrity      — the constraints that reflect how the organization
                               uses its data are defined and enforced.
```

Do not consider the design done until all four have been reviewed and the documentation assembled; this review is the last step before implementation.
