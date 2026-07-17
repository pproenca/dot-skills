---
title: Annotate with builtin generics and PEP 604 unions
tags: typing, generics, unions, annotations
---

## Annotate with builtin generics and PEP 604 unions

Requires Python ≥ 3.10 (builtin generics alone require only ≥ 3.9).

`typing.List`, `typing.Dict`, `typing.Optional`, and `typing.Union` are the
pre-3.9 spellings that survive purely by training-data inertia — since 3.9 the
builtin types subscript directly (`list[str]`, PEP 585) and since 3.10 unions
write as `X | Y` and `X | None` (PEP 604), valid at runtime including in
`isinstance` checks. The old spellings add an import block, read as a distinct
dialect from the new code around them, and `typing.List` et al. are formally
deprecated in the typing spec. New code on a ≥ 3.10 floor has no reason to
carry them.

```python
def group_invoices(
    invoices: list[Invoice],
    cutoff: date | None = None,
) -> dict[str, list[Invoice]]:
    ...

# PEP 604 unions work at runtime too:
isinstance(value, int | float)
```

**Evidence of violation:** `typing.List`, `typing.Dict`, `typing.Set`,
`typing.Tuple`, `typing.FrozenSet`, `typing.Type`, `typing.Optional[...]`, or
`typing.Union[...]` in code the target adds or modifies, on a Python floor
≥ 3.10. PASS: annotations use builtin generics and `|` unions throughout the
changed code. N/A: Python floor < 3.10 (< 3.9 for the generics half), or the
spellings appear only in unchanged legacy lines the diff does not touch —
though a diff that adds *new* occurrences next to old ones is a FAIL, since
consistency with legacy spelling is not a carve-out.

Reference: [PEP 604 — Allow writing union types as X | Y (What's New in Python 3.10)](https://docs.python.org/3/whatsnew/3.10.html#pep-604-new-type-union-operator)
