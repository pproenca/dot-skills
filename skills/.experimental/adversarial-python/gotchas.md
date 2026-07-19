# Gotchas

Scope guards pre-recorded at authoring time so the reviewer does not judge outside
the rules; verdict-instability patterns (a rule flipping across re-reviews, or an
overridden verdict) get appended below with dates as reviews accumulate.

### Proven both ways (release dry-run)

The full protocol ran on two constructed billing-webhook artifacts (floor
3.12, no delta briefing). The legacy-style artifact — event/version `elif`
ladder, stringly-typed status, hand-written `__init__`/`__repr__`/`__eq__`,
string-keyed payload threading, `typing.Dict`/`Optional`, `os.path`,
`utcnow()`, a hand-rolled chunker, a single-method `AuditWriter` class,
fire-and-forget `create_task`, `except Exception: pass` — merged to **FAIL**
with both blind reviewers agreeing on all 20 per-rule verdicts (11 FAIL, 1
PASS, 8 N/A) and every FAIL carrying a flip-test fix. The modern
re-architecture of the same feature (registry dispatch, `StrEnum`, frozen
dataclasses, `TypedDict` boundary, `TaskGroup`, `pathlib`, `batched`,
`now(UTC)`) merged to **PASS**, again with per-rule unanimity. Zero contested
rules across both runs. One planting lesson: a boolean flag whose `True`
branch is a strict superset of the `False` branch correctly PASSes
`disp-split-boolean-switch-params` via the superset carve-out — the rule
gates disjoint bodies, not added logging steps. (Recorded under the earlier
two-reviewer protocol; the gate now dispatches a single blind reviewer.)
Added: 2026-07-17

### The version probe decides more verdicts than any rule — get the floor right

The floor is the *minimum* supported Python, not the developer's interpreter.
`requires-python = ">=3.10"` means 3.10 is the floor even if CI also tests
3.14 — PEP 695 rules are N/A for that target. A `.python-version` file pins a
dev interpreter, not necessarily a support floor; prefer `requires-python`
when both exist and disagree, and cite which one decided. If nothing declares
a floor, judge as the newest stable Python and say so in the verdict — an
undeclared floor is the author's choice, not the gate's problem.
Added: 2026-07-17

### Greenfield judgment licenses shape criticism, not scope creep

"Judged as if greenfield" applies to the *shapes in the target* — it lets a
reviewer fail a ladder that legacy code inspired. It does not license failing
the target for not refactoring untouched legacy files, not migrating the whole
repo to the new idiom, or not adopting an architecture outside the rules.
Unchanged lines the diff never touches are context for repo-search rules, not
review subjects.
Added: 2026-07-17

### Shapes, not brands — pydantic and attrs count

`model-` rules name `@dataclass` as canonical, but a pydantic `BaseModel`,
`attrs` class, or `NamedTuple` satisfies the same shape. Do not fail a FastAPI
codebase for modeling payloads with pydantic instead of `TypedDict` — that IS
the declared boundary shape. Conversely a `dict[str, Any]` threaded past a
pydantic-using boundary still fails `model-typed-boundary-payloads`.
Added: 2026-07-17

### The repo-search rules fail closed on lazy searches

`alt-no-single-impl-interfaces` and `alt-compose-over-concrete-inheritance`
require repo-wide searches (implementer counts, substitution sites). A
reviewer that rules FAIL without stating what it searched produces verdicts
that flip between runs. The search performed is part of the
evidence — "grepped for `(BillingBackend)` subclasses: one hit" is a verdict;
"looks like a single-impl ABC" is not.
Added: 2026-07-17

### Delta briefings are additive only

When the floor exceeds `verified_python` and a what's-new delta briefing is
composed, it may *extend* rules (new batteries, new syntax targets) but never
contradict or retire a written rule mid-review. If a delta genuinely
invalidates a rule (a battery deprecated, a syntax superseded), finish the
review on the written rules, then update the rule files and bump
`verified_python` — the gate's text is the contract, the briefing is an
appendix. Record every briefing here with its date so re-verification has a
trail.
Added: 2026-07-17
