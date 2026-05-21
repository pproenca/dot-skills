# Gotchas

Append entries as they're discovered. Format:

```markdown
### {Short title of the failure mode}
{What went wrong, how to recognize it, and how to avoid it.}
Added: {YYYY-MM-DD}
```

---

### Reach for the language feature before the class-based GoF template
The biggest mistake porting these patterns to Python is translating a Java-shaped class hierarchy verbatim. Most of the catalog collapses into a language feature:

- **Strategy** → pass a function / `Callable` directly; no Strategy interface
- **Iterator** → a generator (`yield`) or `__iter__`; `for`, `sum`, `in` work for free
- **Observer** → a list of callbacks, or a `property` setter; or a signals library
- **Command** → a closure or `functools.partial` (add an `undo` closure for undo/redo)
- **Singleton** → a module-level instance, or `functools.cache` on a factory function
- **Template Method** → a higher-order function taking the varying steps as callables
- **Visitor** → `functools.singledispatch`, or a `match` statement
- **Prototype** → `copy.deepcopy` / `dataclasses.replace`
- **Factory Method** → a registry `dict` keyed by string, or a `@classmethod`
- **Builder** → a keyword-only `@dataclass` with defaults
- **Proxy** → `__getattr__` delegation or `functools.cached_property`
- **Adapter** → duck typing often means no adapter at all; otherwise a small wrapper function

Recommend the class-based form only when the user genuinely needs the extra structure: stored state, object identity, runtime registration, or polymorphic dispatch the language feature can't express. Over-engineering is the more common failure with this catalog than under-engineering.
Added: 2026-05-21

### Prefer `typing.Protocol` over forcing ABC inheritance
Several references type their interfaces as `Protocol`. Use a `Protocol` for structural ("duck") typing when implementers should NOT have to inherit a base class — adapters, strategies, plug-in products. Reach for `abc.ABC` only when you want enforced subclassing, shared concrete base logic (e.g., Template Method's skeleton), or `isinstance` checks at runtime. Forcing an ABC where a `Protocol` suffices couples every implementer to your base class and defeats the looseness Python gives you for free.
Added: 2026-05-21

### Don't use a mutable default or a class attribute for per-instance pattern state
Observer subscriber lists, Command history stacks, and Mediator component sets are mutable. Two traps: (1) a mutable default argument (`def __init__(self, subs=[])`) is shared across all instances and accumulates state between them; (2) a mutable **class attribute** (`_subscribers: list = []` at class scope) is shared by every instance for the same reason. Initialize this state inside `__init__` (`self._subscribers = []`) or use `dataclasses.field(default_factory=list)`. The bug shows up as one subject mysteriously seeing another subject's subscribers.
Added: 2026-05-21

### `functools.singledispatch` keys on the first argument only — and methods need `singledispatchmethod`
The Pythonic Visitor uses `@singledispatch`, which dispatches on the runtime type of the **first** positional argument. It cannot dispatch on two arguments (no true double dispatch) and ignores type *annotations* at call time — only the concrete runtime type matters, so a subclass dispatches to its registered base unless separately registered. Inside a class, a plain `@singledispatch` would dispatch on `self`; use `functools.singledispatchmethod` and register on the second parameter instead. When dispatch needs more than one type or you prefer all cases in one place, use a `match` statement.
Added: 2026-05-21

### A `functools.cache` singleton must be reset between tests
The module-global / `functools.cache` Singleton is testable precisely because the accessor is a seam — but a cached instance persists across tests in the same process and leaks state. Call `get_config.cache_clear()` in test setup/teardown, or inject the dependency instead of importing the global. If you skip this, tests pass in isolation and fail when run together.
Added: 2026-05-21
