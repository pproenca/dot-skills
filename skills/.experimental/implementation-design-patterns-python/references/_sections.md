# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group pattern references.

The 22 patterns are the original Gang of Four (GoF) catalog grouped by purpose: Creational (object instantiation), Structural (class/object composition), and Behavioral (object collaboration and responsibility assignment). All three categories are foundational — the impact label reflects the impact of *applying the right pattern when the situation fits*, not a global ranking between categories. In Python many of these patterns shrink to a language feature; each reference leads with the idiomatic form and keeps the class-based GoF structure only where it earns its weight.

---

## 1. Creational Patterns (creational)

**Impact:** HIGH  
**Description:** Five patterns that decouple client code from the concrete classes it instantiates. Apply when object construction is non-trivial, varies by configuration, or risks tight coupling to specific classes. In Python they often reduce to a registry dict, a `@classmethod` alternative constructor, a keyword-only `@dataclass`, `copy.deepcopy`/`dataclasses.replace`, or a module-level instance — reach for the class hierarchy only when you need polymorphic creation or extension points.

## 2. Structural Patterns (structural)

**Impact:** HIGH  
**Description:** Seven patterns that compose classes and objects into larger structures while keeping the structure flexible and the parts substitutable. Apply when integrating incompatible APIs, building tree-shaped models, attaching responsibilities at runtime, hiding subsystem complexity, or controlling access to expensive resources. Python leans on duck typing and `typing.Protocol`, `__getattr__` delegation, `functools.wraps` decorators, `__slots__`/`functools.lru_cache` sharing, and `cached_property` rather than deep wrapper hierarchies.

## 3. Behavioral Patterns (behavioral)

**Impact:** HIGH  
**Description:** Ten patterns that distribute responsibility between objects and define how they communicate. Apply when behavior must vary at runtime, when responsibilities pass through a sequence of handlers, when state changes must propagate to many listeners, or when an algorithm's skeleton is fixed but specific steps vary. Python's first-class functions, generators, `functools.singledispatch`, and structural pattern matching (`match`) collapse several of these to a few lines — keep the GoF object form only when you need stored state, identity, or pluggable extension.
