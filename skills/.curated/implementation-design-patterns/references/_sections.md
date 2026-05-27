# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group pattern references.

The 22 patterns are the original Gang of Four (GoF) catalog grouped by purpose: Creational (object instantiation), Structural (class/object composition), and Behavioral (object collaboration and responsibility assignment). All three categories are foundational — the impact label reflects the impact of *applying the right pattern when the situation fits*, not a global ranking between categories.

---

## 1. Creational Patterns (creational)

**Impact:** HIGH
**Description:** Five patterns that decouple client code from the concrete classes it instantiates. Apply when object construction is non-trivial, varies by configuration, or risks tight coupling to specific classes — they isolate creation, enable polymorphic instantiation, and prevent constructor explosion.

## 2. Structural Patterns (structural)

**Impact:** HIGH
**Description:** Seven patterns that compose classes and objects into larger structures while keeping the structure flexible and the parts substitutable. Apply when integrating incompatible APIs, building tree-shaped models, attaching responsibilities at runtime, hiding subsystem complexity, or controlling access to expensive resources.

## 3. Behavioral Patterns (behavioral)

**Impact:** HIGH
**Description:** Ten patterns that distribute responsibility between objects and define how they communicate. Apply when behavior must vary at runtime, when responsibilities should pass through a sequence of handlers, when state changes must propagate to many listeners, or when an algorithm's skeleton should be fixed but specific steps vary by subclass.
