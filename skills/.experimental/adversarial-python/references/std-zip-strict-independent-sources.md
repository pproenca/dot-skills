---
title: Pass strict=True when zipping independently-sourced sequences
tags: std, zip, strict, silent-truncation
---

## Pass strict=True when zipping independently-sourced sequences

Requires Python ≥ 3.10 (PEP 618 added the `strict` keyword).

`zip` stops at the shortest input silently. When the sequences come from
independent producers — two queries, a file and an API response, two separate
parameters — equal length is an *assumption*, and plain `zip` converts a
violated assumption into silently dropped rows instead of an error. PEP 618
added `strict=True` exactly for this: it raises `ValueError` on length
mismatch, turning data loss into a stack trace at the zip site. When unequal
lengths are *expected*, `itertools.zip_longest` states that intent explicitly.

```python
# user_ids from the auth service, balances from the ledger — nothing
# guarantees they stayed in lockstep:
for user_id, balance in zip(user_ids, balances, strict=True):
    statements.append(render_statement(user_id, balance))
```

**Evidence of violation:** a `zip()` call over two or more sequences that
originate from **independent producers** (trace each argument: different
function parameters, separate queries/requests/files) with no `strict=True`
and no adjacent explicit length check, on a Python floor ≥ 3.10. PASS:
`strict=True` is passed, a length assertion guards the call, or
`zip_longest` is used where unequal lengths are the design. N/A: Python floor
< 3.10; the sequences derive from the same source (slices, `keys()`/`values()`
of one dict, a list and a transform of that same list), where equal length is
structural, not assumed.

Reference: [PEP 618 — Add Optional Length-Checking To zip (What's New in Python 3.10)](https://docs.python.org/3/whatsnew/3.10.html#pep-618-add-optional-length-checking-to-zip)
