---
title: Qualify a candidate key against every element before trusting it
tags: key, candidate-key, uniqueness
---

## Qualify a candidate key against every element before trusting it

The wrong default is to grab the first field that "looks unique" — a name, an email, a phone — as the table's identifier. A candidate key has to satisfy a full set of elements, and a field that fails even one (a name that repeats, a phone that changes, an email that can be blank) will let duplicate or unidentifiable records into the table. Enumerate the candidate keys first, testing each field or minimal field-set against all elements; the primary key is then chosen from among the qualifiers.

```text
A candidate key must satisfy ALL of these:
  - It is not a multipart field.
  - Its values are unique — no duplicates.
  - It is never null, and no part of it is optional.
  - It uses the minimum number of fields needed to guarantee uniqueness.
  - Its value uniquely and exclusively identifies each record.
  - Its value exclusively identifies the value of every other field in that record.
  - Its value changes only in rare or extreme cases.
  - Its value cannot breach the organization's security or privacy rules.
```

When no single field qualifies, a *composite* candidate key (the minimum set of fields that together are unique) is valid — but keep it to the minimum; extra fields disqualify it. A candidate key that qualifies but is not chosen as the primary key becomes an *alternate key*, and its uniqueness should still be enforced.
