---
title: Replace hand-rolled helpers with their stdlib equivalents
tags: std, stdlib, itertools, functools, batteries
---

## Replace hand-rolled helpers with their stdlib equivalents

Every hand-rolled utility that duplicates a battery is code that must be
tested, maintained, and re-discovered by every reader — and it is usually
subtly worse (the manual chunker below copies its input list; `batched` is
lazy). Models keep writing these helpers because their training data predates
the battery. The reviewer's obligation under this rule is to **name the stdlib
API** the helper duplicates at the target's Python floor; "this could be
simpler" is not evidence. Frequent offenders, with the version each landed:

| Hand-rolled shape | Battery | Since |
|---|---|---|
| chunk/window a sequence into groups of n | `itertools.batched` | 3.12 |
| loop over adjacent pairs `(xs[i], xs[i+1])` | `itertools.pairwise` | 3.10 |
| memo dict guarding a pure function | `functools.cache` | 3.9 |
| `try:`/`except SomeError: pass` | `contextlib.suppress` | 3.4 |
| parse TOML via regex/configparser | `tomllib` | 3.11 |
| save/chdir/restore cwd around a block | `contextlib.chdir` | 3.11 |
| copy a dataclass with one field changed | `dataclasses.replace` / `copy.replace` | — / 3.13 |
| tally occurrences into a dict | `collections.Counter` | — |
| mean/median/stdev loops | `statistics` | — |

This table is extended by the version-delta briefing when the target's Python
floor exceeds the version this gate was last verified against — new batteries
count the moment the floor includes them.

```python
from itertools import batched

for page in batched(invoice_ids, 100):   # lazy, tuple pages, last page short
    bulk_archive(page)
```

**Evidence of violation:** a helper function (or inline loop of the same
shape) in the target whose behavior duplicates a **named** stdlib API available
at the target's Python floor — the reviewer must state the API and version.
PASS: the battery is used, or the helper's behavior differs from the battery in
a way the code relies on (cite the difference — e.g. needs an async variant,
different edge-case semantics). N/A: no helper in the target duplicates an
available battery.

Reference: [What's New in Python — itertools.batched (3.12)](https://docs.python.org/3/whatsnew/3.12.html#itertools)
