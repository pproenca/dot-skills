# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Structure & Decomposition (struct)

**Impact:** CRITICAL
**Description:** Long methods and large classes are the root cause of most code smells. Decomposing structure into small, focused units unlocks all downstream refactorings and improves testability.

## 2. Conditional Simplification (cond)

**Impact:** CRITICAL
**Description:** Complex conditionals are the #2 source of bugs and coupling. Guard clauses, polymorphism, and pattern matching eliminate deep nesting and make intent explicit.

## 3. Coupling & Dependencies (couple)

**Impact:** HIGH
**Description:** Tight coupling blocks all refactoring. Law of Demeter violations, feature envy, and rigid inheritance hierarchies make changes cascade unpredictably across the codebase.

## 4. Ruby Idioms (idiom)

**Impact:** HIGH
**Description:** Non-idiomatic Ruby resists automated refactoring tools and confuses developers. Duck typing, Enumerable methods, and keyword arguments make code intent-revealing and tool-friendly.

## 5. Data & Value Objects (data)

**Impact:** MEDIUM-HIGH
**Description:** Primitive obsession and data clumps scatter implicit dependencies across the codebase. Value objects and Data.define centralize domain concepts and enforce invariants.

## 6. Design Patterns (pattern)

**Impact:** MEDIUM
**Description:** Strategy, Factory, Template Method, and Decorator resolve recurring structural problems by replacing ad-hoc conditionals with composable, extensible objects.

## 7. Modern Ruby 3.x (modern)

**Impact:** MEDIUM
**Description:** Pattern matching, Data.define, and endless methods provide cleaner, more expressive alternatives to traditional conditional and value object patterns.

## 8. Naming & Readability (name)

**Impact:** LOW-MEDIUM
**Description:** Clear naming is the cheapest refactoring with the highest ROI for code comprehension. Intention-revealing names eliminate the need for explanatory comments.
