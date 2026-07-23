---
title: Give each field one unambiguous, singular name
tags: fld, naming, clarity
---

## Give each field one unambiguous, singular name

The wrong default is a terse or plural field name — `Cat`, `Notes`, `Phones` — that either hides what the field holds or signals that it holds a list. The name is the primary evidence of what a field is; an ambiguous one invites the wrong data, and a plural one is a warning sign of a multivalued field. Name each field for the single characteristic it represents.

```text
Guidelines for a field name:
  - Unique and meaningful across the whole database.
  - Accurately and unambiguously identifies the one characteristic it represents.
  - Uses the minimum number of words needed to convey that meaning.
  - Uses the SINGULAR form (a plural name signals a multivalued field to resolve).
  - No acronyms; abbreviations only where they are genuinely unambiguous.
  - Does not identify more than one characteristic.
```

```text
Poor → Better
  Cat          → CategoryTaught
  Phones       → HomePhone / MobilePhone   (plural signalled a multivalued field)
  DOB          → DateOfBirth
  Name         → CustFirstName / CustLastName   (one name = two characteristics)
```

Table names follow the same rules but use the *plural* form (CUSTOMERS, ORDERS) and must not encode physical characteristics.
