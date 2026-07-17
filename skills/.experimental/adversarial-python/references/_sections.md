# Sections

This file defines the categories and their order. The prefix in parentheses is
the filename prefix that groups rules. Categories are ordered by **importance** —
architectural mistakes that shape the whole feature go first, modernization
mistakes that bloat individual call sites follow; the verdict report's fix list
follows this order.

This is a pass/fail review gate, not a performance skill, so there are no impact
tiers. The gate hunts two failure modes: **code that a modern Python feature
makes unnecessary** (written from a pre-3.10 habit the author never updated) and
**legacy-pattern propagation** (new code copying the surrounding codebase's bad
structure instead of modeling the feature end-to-end). Each rule carries an
**Evidence of violation** paragraph — the artifact evidence that decides
PASS/FAIL/N/A — and, where the fix depends on a language feature, a
`Requires` version gate: when the target's Python floor is below the gate,
the rule is judged N/A, never FAIL. Carve-outs must be claimed with citable
evidence (fail closed otherwise).

---

## 1. Dispatch & Control Flow (disp)

**Description:** Branch ladders written where the language or the design has a
dispatch construct. The default failure is additive: each new event, version, or
kind grows an `if/elif` chain nobody designed, because the model extends the
shape it found instead of asking what the shape should be. A discriminator with
parallel-shaped branches is a routing problem — a registry keyed by the
discriminator, a `match` statement, or polymorphism makes each handler
independently testable and makes the unhandled case explicit. The same
correction applies to type-and-shape ladders (`isinstance` + key checks →
structural patterns), stringly-typed state (repeated literals → `StrEnum`), and
boolean parameters that fork a function into two disjoint bodies.

## 2. Data Modeling (model)

**Description:** Data that never got a shape. Related values travel as bare
parameter clumps and string-keyed dicts, so every function re-states the group
and every access is unchecked; hand-written `__init__`/`__repr__`/`__eq__`
boilerplate re-implements what `@dataclass(slots=True)` generates; external
payloads (request bodies, webhooks, queue messages) are navigated by string
keys deep into the codebase instead of being converted once at the boundary
into a `TypedDict` or dataclass. Rethinking the data model is where "less code
by re-architecting" usually starts — a declared shape deletes the defensive
checks, the repeated signatures, and the boilerplate at once.

## 3. Abstraction Altitude (alt)

**Description:** Layers imported from class-first languages or copied from the
legacy codebase that add indirection without adding a decision. A class whose
`__init__` stores arguments for its single public method is a function wearing
a costume; a wrapper layer whose methods forward 1:1 adds a file to read and
nothing else; an ABC with exactly one implementation and no test double is an
extension point nobody asked for (a `Protocol` at the consumer gives the typing
seam structurally, when one is actually needed); subclassing a concrete class
purely to reuse its methods couples the child to internals composition would
not touch. Consistency with the surrounding codebase is not a defense — these
rules judge the artifact as if greenfield.

## 4. Modern Typing (typing)

**Description:** Pre-3.10 typing spellings that survive by habit and double the
annotation noise. `typing.List`/`Optional`/`Union` where builtin generics and
`X | None` have been the documented spelling since 3.9/3.10;
`TypeVar` + `Generic` boilerplate and `TypeAlias` assignments where PEP 695
(3.12) declares the parameter inline (`class Repo[T]`, `def first[T]`,
`type Pair = ...`) with correct scoping and inferred variance; bound-TypeVar or
hardcoded-class-name returns on chainable and factory methods where `Self`
(3.11) is both shorter and correct under subclassing.

## 5. Stdlib Currency (std)

**Description:** Hand-rolled code duplicating a battery the stdlib has shipped
— often for years. `os.path` string surgery where `pathlib` composes; manual
chunking, pairwise loops, memo dicts, TOML parsing, and cwd juggling where
`itertools.batched` (3.12), `itertools.pairwise` (3.10), `functools.cache`
(3.9), `tomllib` (3.11), and `contextlib.chdir` (3.11) exist; deprecated naive
`datetime.utcnow()` where `datetime.now(UTC)` is the aware replacement; `zip`
over independently-sourced sequences silently truncating where `strict=True`
(3.10) raises. This category is the gate's refresh surface: the version-delta
briefing extends it when the target's Python exceeds the version these rules
were last verified against.

## 6. Async & Error Flow (flow)

**Description:** Failure paths that vanish. `asyncio.create_task` called
fire-and-forget drops exceptions on the floor and lets the task be
garbage-collected mid-flight — the asyncio docs' own warning — where
`asyncio.TaskGroup` (3.11) owns the lifecycle and propagates errors; broad
`except Exception`/bare `except` handlers whose body neither re-raises, logs,
nor returns an explicit error value convert every future bug into silence.
