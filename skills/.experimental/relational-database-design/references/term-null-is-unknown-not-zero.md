---
title: Treat a null as unknown, not as zero or blank
tags: term, null, integrity
---

## Treat a null as unknown, not as zero or blank

The wrong default is to treat a null as if it were zero, an empty string, or "nothing." A null is the *absence* of a value — the value is unknown or does not apply — which is categorically different from a numeric zero or a blank string that are themselves real values. Conflating them produces wrong answers: a null in an arithmetic expression does not behave like zero, and a null in a count or average is excluded rather than treated as 0.

This is why keys forbid nulls: a primary key and every candidate key must be non-null, because a record whose identifier is "unknown" cannot be reliably identified or related. Allow nulls in an ordinary field only when "unknown / not applicable" is a genuine, meaningful state for that field; when it is not, set the field's specification to require a value (No Nulls). A foreign key must allow nulls only when its relationship uses a Nullify deletion rule.

```text
NULL    → value unknown or not applicable  (excluded from SUM/AVG/COUNT of the column)
0       → a real numeric value
''      → a real, empty string value
Keys    → never null; identity cannot be "unknown"
```
