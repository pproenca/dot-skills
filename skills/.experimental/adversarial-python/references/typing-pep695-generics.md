---
title: Declare generics with PEP 695 syntax
tags: typing, pep695, typevar, type-alias
---

## Declare generics with PEP 695 syntax

Requires Python ≥ 3.12 (≥ 3.13 when a type parameter needs a default, PEP 696).

The `TypeVar("T")` + `Generic[T]` ritual declares the type parameter far from
its use, leaks it into module scope, and makes variance a manual annotation
(`covariant=True`) that most authors guess at. PEP 695 (3.12) declares the
parameter inline — `class Repo[T]:`, `def first[T](items: list[T]) -> T:`,
`type Pair[T] = tuple[T, T]` — with lexical scoping, inferred variance, and no
`typing` imports. Models keep emitting the old ritual because a decade of
training data uses it; on a ≥ 3.12 floor it is pure ceremony.

**Incorrect (parameter declared at module scope, wired up manually):**

```python
from typing import Generic, TypeVar

T = TypeVar("T")

class Repository(Generic[T]):
    def first(self, matching: Callable[[T], bool]) -> T | None: ...
```

**Correct (parameter declared where it is used):**

```python
class Repository[T]:
    def first(self, matching: Callable[[T], bool]) -> T | None: ...

def dedupe[T: Hashable](items: list[T]) -> list[T]: ...

type JsonScalar = str | int | float | bool | None
```

**Evidence of violation:** a `TypeVar(...)` assignment, `Generic[...]` base, or
`X: TypeAlias = ...`/bare alias assignment in code the target adds or modifies,
on a Python floor ≥ 3.12. PASS: generics use square-bracket parameter syntax
and aliases use the `type` statement. Carve-outs (cite the evidence): the
parameter needs a default and the floor is 3.12 (PEP 696 defaults land in
3.13), or the repo's type checker is pinned below PEP 695 support (cite the
pinned version in CI/requirements). N/A: Python floor < 3.12, or no generic
declarations in the target.

Reference: [PEP 695 — Type Parameter Syntax (What's New in Python 3.12)](https://docs.python.org/3/whatsnew/3.12.html#pep-695-type-parameter-syntax)
