# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Component Architecture (arch)

**Impact:** CRITICAL
**Description:** Component structure determines reusability, testability, and change isolation. Compound components, headless patterns, and composition over props explosion reduce component coupling by 60-80%.

## 2. State Architecture (state)

**Impact:** CRITICAL
**Description:** State placement and shape are the #1 source of unnecessary complexity. Colocation, lifting only when shared, and state machines eliminate 70% of prop drilling and sync bugs.

## 3. Hook Patterns (hook)

**Impact:** HIGH
**Description:** Custom hooks are the primary abstraction mechanism in React. Single responsibility, stable dependencies, and composition over nesting produce testable, reusable behavior units.

## 4. Component Decomposition (decomp)

**Impact:** HIGH
**Description:** Oversized components resist change and testing. The scroll test, extraction by change reason, and view/logic separation keep components focused and independently evolvable.

## 5. Modern React Migration (migrate)

**Impact:** MEDIUM-HIGH
**Description:** React 19 Server Components, Actions, and useOptimistic change where code runs and how mutations flow. Incremental migration from client-first to server-first architecture reduces client JS by 30-60%.

## 6. Coupling & Cohesion (couple)

**Impact:** MEDIUM
**Description:** Feature modules with stable public APIs enable independent development and deletion. Breaking circular dependencies and barrel-free imports prevent cascading change propagation.

## 7. Data & Side Effects (data)

**Impact:** MEDIUM
**Description:** Server-first data fetching, granular error boundaries, and eliminating derived-state effects simplify data flow and improve resilience across component boundaries.

## 8. Refactoring Safety (safety)

**Impact:** LOW-MEDIUM
**Description:** Characterization tests, behavior-focused testing, and pure function extraction create safety nets that enable aggressive refactoring without regression risk.
