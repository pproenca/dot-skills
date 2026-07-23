---
title: Rule Title Here
tags: prefix, concept
---

## Rule Title Here

Name the wrong default this rule corrects and its concrete consequence, in 1-3
sentences. Explain the *why* — the model generalizes from the reason, not the
instruction. Don't restate something the model already does correctly.

```sql
-- The canonical way. Real, domain-realistic table and field names — not foo/bar.
CREATE TABLE Customers (
  CustomerID   INTEGER PRIMARY KEY,
  CustFirstName TEXT NOT NULL
);
```
<!-- Add an **Incorrect (…):** / **Correct (…):** pair ONLY when the wrong way is
     a genuine, common trap. Keep the diff minimal. A strawman foil is worse than
     a single good example. -->
