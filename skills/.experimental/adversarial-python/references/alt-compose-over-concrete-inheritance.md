---
title: Compose instead of subclassing concrete classes for reuse
tags: alt, inheritance, composition, coupling
---

## Compose instead of subclassing concrete classes for reuse

Subclassing a concrete class purely to reuse its methods buys the tightest
coupling Python offers: the child inherits the parent's entire public surface
(including what makes no sense for it), depends on the parent's private
attribute layout and call order, and breaks when the parent refactors
internals. If no call site ever substitutes the child where the parent is
expected, the inheritance is not modeling an is-a relationship — it is an
import with extra steps. Holding the parent as an attribute and delegating the
two or three calls actually used keeps the dependency explicit and the surface
intentional.

**Incorrect (inherits a cache's whole surface to reuse two methods):**

```python
class SessionStore(RedisCache):  # SessionStore now IS-A RedisCache:
    def load(self, session_id: str) -> Session:      # .flush_all(), .keys(),
        return Session.decode(self.get(session_id))  # .ttl() all leak through

    def persist(self, session: Session) -> None:
        self.set(session.id, session.encode())
```

**Correct (delegates exactly what it uses):**

```python
class SessionStore:
    def __init__(self, cache: RedisCache) -> None:
        self._cache = cache

    def load(self, session_id: str) -> Session:
        return Session.decode(self._cache.get(session_id))

    def persist(self, session: Session) -> None:
        self._cache.set(session.id, session.encode())
```

**Evidence of violation:** a class in the target subclassing a **concrete**
project class (not an ABC, not a `Protocol`), where repo search finds **no
substitution site** — no code passing the child where the parent type is
expected, no `isinstance(x, Parent)` meant to include it, no polymorphic
registry holding both — and the subclass exists to reuse or lightly override
the parent's methods. Search beyond the diff before ruling. PASS: a cited
substitution site exists, the base is a framework class that mandates
subclassing (`django.db.models.Model`, `unittest.TestCase`, and kin — cite the
framework contract), or the hierarchy is an exception tree (`except` clauses
are substitution by nature). N/A: no concrete-class subclassing in the target.

Reference: [Python documentation — inheritance and composition (tutorial, classes)](https://docs.python.org/3/tutorial/classes.html)
