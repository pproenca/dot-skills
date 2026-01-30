# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. State Architecture (state)

**Impact:** CRITICAL
**Description:** State explosion and prop drilling are the #1 maintainability killers. Fixing state architecture yields 10× improvements in component complexity and test isolation.

## 2. Component Composition (comp)

**Impact:** CRITICAL
**Description:** Props explosion and inheritance hierarchies create rigid, untestable code. Composition patterns enable flexible, reusable components with clear boundaries.

## 3. Abstraction Quality (abs)

**Impact:** HIGH
**Description:** Premature abstraction creates coupling without value. Right-sized abstractions reduce cognitive load and maintenance burden by 40-60%.

## 4. Coupling & Cohesion (couple)

**Impact:** HIGH
**Description:** Tight coupling makes changes cascade unpredictably. Proper boundaries enable independent evolution and parallel development.

## 5. Hook Hygiene (hook)

**Impact:** MEDIUM-HIGH
**Description:** Poorly structured hooks create implicit dependencies and testing nightmares. Well-designed hooks are composable, testable, and self-documenting.

## 6. Render Patterns (render)

**Impact:** MEDIUM
**Description:** Complex conditional rendering obscures intent and creates bugs. Clean render patterns make component behavior obvious at a glance.

## 7. Side Effect Management (effect)

**Impact:** MEDIUM
**Description:** Scattered effects create race conditions and memory leaks. Consolidated effect patterns improve reliability and debugging.

## 8. Testability (test)

**Impact:** LOW-MEDIUM
**Description:** Untestable code is unmaintainable code. Testability-driven refactoring creates natural seams and improves design quality.
