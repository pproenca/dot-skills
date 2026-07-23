---
title: Design the logical structure before choosing an RDBMS
tags: proc, logical-design, rdbms
---

## Design the logical structure before choosing an RDBMS

This rule is about *ordering*: do the logical design first, choose and target an RDBMS second. The wrong default collapses the two — designing tables and rules against the product already in hand, its data types and constraint support standing in for the requirements. An RDBMS gives you tools to *implement* a design; it gives you no principles or rationale for *creating* one, so a product-first order lets the tool's shape substitute for the organization's information requirements.

Design the tables, fields, keys, relationships, and integrity rules as pure logical structure, with no product in mind — a deletion rule is "Cascade" and a field's range is "{WA, OR, ID, MT}" regardless of what any product calls those. Only once the logical design is sound do you pick the implementation (single-user, client/server, web) and the RDBMS, and then realize every logical characteristic with SQL, constraints, triggers, or application code — filling any gaps in native support rather than removing the characteristic from the design.

(The failure *symptoms* of the reverse order — decisions bent to what the product does, a schema bounded by your skill with it — are catalogued in [`anti-rdbms-driven-design`](anti-rdbms-driven-design.md); this rule is the ordering principle that avoids them.)

**Incorrect (product-first: the tool's limits shape the model):**

```text
"Our RDBMS makes deletion rules awkward, so leave the Orders→OrderItems
 relationship without one."
"It has no clean range constraint, so let the app validate CustState."
→ the schema now reflects the product's gaps, not the business's requirements.
```

**Correct (requirements-first: specify the logical rule, then implement it):**

```text
Logical design says: Orders→OrderItems uses a Cascade deletion rule; CustState is
restricted to {WA, OR, ID, MT}.
Implementation step (after choosing the RDBMS): express the deletion rule with
ON DELETE CASCADE (or a trigger if unsupported) and the range with a validation
table or CHECK constraint.
```
