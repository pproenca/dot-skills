---
title: Keep key separate from index, and view separate from table
tags: term, vocabulary, definitions
---

## Keep key separate from index, and view separate from table

Two vocabulary confusions actually change designs, so they are worth stating even though the rest of the relational glossary is familiar. First, a **key** is a logical construct — a field or minimal field-set that identifies records (primary, candidate, alternate) or relates tables (foreign); an **index** is a *physical* structure that speeds retrieval. They belong to different phases: keys are decided during logical design, indexes during physical implementation. Treating "add an index" as "add a key" (or vice versa) mixes a correctness decision with a performance one.

Second, a **view** is not a table. A view is a virtual table assembled from one or more base tables at access time; it stores no data of its own and has no primary key of its own. Modeling a view as if it were a table — giving it a stored key, or storing its computed rows — reintroduces the calculated-field and redundant-data problems the base tables were designed to avoid.

```text
Key   (logical): Orders.CustomerID identifies the parent — decided in logical design.
Index (physical): an index on Orders.CustomerID speeds the join — decided at implementation.
                  Same column, two different concerns, two different phases.

View: OrderTotals is derived from OrderItems on each read — no stored rows, no own key.
      It is not a table; do not give it a primary key or persist its results.
```

For reference, the remaining core terms carry their standard relational meanings: a **table** represents one subject (object or event) as **fields** (one atomic characteristic each) and **records** (one instance's values); a **relationship** is a one-to-one, one-to-many, or many-to-many association between tables.
