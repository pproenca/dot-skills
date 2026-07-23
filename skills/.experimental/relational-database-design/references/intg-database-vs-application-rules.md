---
title: Enforce structural rules in the schema, conditional rules in the application
tags: intg, business-rules, constraints
---

## Enforce structural rules in the schema, conditional rules in the application

The wrong default is to sort business rules by topic instead of by *where they can be enforced*, then either try to bake a conditional rule into the schema (and fail) or scatter a structural constraint into application code (and lose it). Every business rule is one of two kinds, and the kind decides where it lives.

```text
Database-oriented rule — enforceable in the logical design itself, by modifying
  a field specification or a relationship characteristic.
    "We only sell to WA, OR, ID, MT"
        → set VendState field spec: Range of Values = {WA, OR, ID, MT}.
    "A county must be recorded for every customer"
        → set CustCounty: Required = Yes, Null Support = No Nulls.
    "An instructor teaches 1–8 classes"
        → set the relationship degree of participation to (1,8).

Application-oriented rule — cannot be expressed in the logical design; it needs a
  derived value or a runtime condition, so it lives in the physical/application layer.
    "A Preferred customer gets 15% off"
        → there is no field to hold the discount (it is calculated) and no way to
          express the 'Preferred' condition structurally; enforce it in the app.
```

Two categories cut across this: *field-specific* rules modify a field spec; *relationship-specific* rules modify a relationship characteristic. Define field-specific rules first, then relationship-specific, and record each rule (statement, constraint, what it affects, which insert/update/delete tests it) so it can be maintained.
