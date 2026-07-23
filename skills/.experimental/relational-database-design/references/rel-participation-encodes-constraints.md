---
title: Participation type and degree capture real business limits
tags: rel, participation, cardinality
---

## Participation type and degree capture real business limits

The wrong default is to model a relationship as just its type (1:1, 1:M, M:N) and stop, leaving the actual business limits — "a class needs at least five students," "an agent handles at most 25 clients" — unrecorded and unenforced. Two further characteristics carry those limits: the *type* of participation and the *degree* of participation. They are where a relationship-specific business rule is enforced.

```text
Type of participation (per table in the relationship):
  Mandatory — a record must exist in this table before a related record can be entered.
  Optional  — no record need exist here first.

Degree of participation (per table), written (min,max):
  (1,1)  — relates to exactly one record on the other side.
  (0,15) — optional, up to 15 related records.
  (0,N)  — optional, unlimited related records.
```

A relationship-specific business rule modifies these: "an instructor must teach at least one but no more than eight classes" sets the junction side to mandatory with degree (1,8). One consequence worth flagging: such a rule can force a **Restrict** deletion rule on the *child* table — the exception to the usual "deleting a child is harmless" — because removing the last child would violate the minimum.
