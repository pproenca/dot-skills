---
title: Drop abstract bases that have one implementation
tags: alt, abc, protocol, interfaces
---

## Drop abstract bases that have one implementation

An ABC with exactly one concrete implementation is an extension point nobody
asked for: two files where one suffices, a signature stated twice that must be
edited twice, and an inheritance edge that exists only to satisfy the base. The
habit is Java's interface-first discipline arriving in a language that does not
need it — Python's typing is structural. When a *consumer* genuinely needs a
seam (to accept alternatives or a test double), declare a `Protocol` next to
that consumer; implementations satisfy it by shape, with no import of the
interface and no inheritance, and the seam appears exactly where it is
consumed rather than speculatively at the producer.

```python
# Consumer-side seam, no inheritance required anywhere:
from typing import Protocol

class SupportsNotify(Protocol):
    def notify(self, recipient: str, message: str) -> None: ...

def escalate(incident: Incident, notifier: SupportsNotify) -> None:
    notifier.notify(incident.oncall, incident.summary)

# EmailNotifier and the test's RecordingNotifier both satisfy SupportsNotify
# structurally — neither declares it, imports it, or inherits anything.
```

**Evidence of violation:** an `abc.ABC` (or class with `@abstractmethod`
members) for which repo-wide search finds **exactly one concrete
implementation and no test double** implementing it. This rule requires
searching beyond the diff — grep for subclasses of the base before ruling.
PASS: two or more genuine implementations exist (test fakes count), or the base
carries shared concrete behavior subclasses inherit (it is a base class, not an
interface), or it is a cited published extension point (plugin registration,
entry point, or documented third-party contract). N/A: no abstract base in or
referenced by the target. The fix is to delete the ABC and use the concrete
class; where a consumer needs a typing seam, a `Protocol` declared at the
consumer.

Reference: [typing.Protocol — Python documentation](https://docs.python.org/3/library/typing.html#typing.Protocol)
