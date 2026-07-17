---
title: Create timestamps with timezone-aware UTC datetimes
tags: std, datetime, utc, timezones
---

## Create timestamps with timezone-aware UTC datetimes

`datetime.utcnow()` returns a **naive** datetime — the UTC moment with the
timezone information thrown away — which is why it has been deprecated since
3.12: naive timestamps compare, subtract, and serialize as if they were local,
producing off-by-one-timezone bugs that only fire for users outside UTC.
`datetime.now(UTC)` returns the same moment *aware*, so arithmetic and
`.isoformat()` carry the offset and mixing with other aware datetimes is safe
(mixing naive and aware raises, which is the bug surfacing early).

**Incorrect (deprecated, and the result lies about its zone):**

```python
expires_at = datetime.utcnow() + timedelta(hours=24)
# naive: .isoformat() has no offset; comparison with aware datetimes raises
```

**Correct (aware from the start):**

```python
from datetime import UTC, datetime, timedelta

expires_at = datetime.now(UTC) + timedelta(hours=24)
# '2026-07-17T14:03:07.219148+00:00' — the offset travels with the value
```

**Evidence of violation:** a call to `datetime.utcnow()` or
`datetime.utcfromtimestamp()` anywhere in the target (deprecated since 3.12 on
every supported floor), or a naive `datetime.now()`/`datetime.fromtimestamp()`
whose result observably leaves the function as a timestamp — assigned to a
persisted field, serialized (`isoformat`, JSON, ORM write), returned, or
compared against an aware datetime. PASS: instants are created with `datetime.now(UTC)` (or
`timezone.utc` on floors < 3.11) / `datetime.fromtimestamp(ts, UTC)`. N/A: no
datetime creation in the target; `datetime.now()` without an argument used
solely for local wall-clock *display*, cited as such.

Reference: [datetime deprecations (What's New in Python 3.12)](https://docs.python.org/3/whatsnew/3.12.html#deprecated)
