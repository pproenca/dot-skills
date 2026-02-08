# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. API Modernization (api)

**Impact:** CRITICAL
**Description:** Deprecated SwiftUI APIs block adoption of modern features and cause compiler warnings. Migrating them first unblocks all downstream refactoring.

## 2. State Architecture (state)

**Impact:** CRITICAL
**Description:** Over-observation and misplaced state are the #1 cause of unnecessary re-renders in SwiftUI. Fixing state architecture yields the largest performance gains.

## 3. View Decomposition (view)

**Impact:** HIGH
**Description:** Massive view bodies force SwiftUI to diff hundreds of nodes on every state change. Extracting subviews creates diffing checkpoints that skip unchanged branches.

## 4. Navigation Refactoring (nav)

**Impact:** HIGH
**Description:** Legacy NavigationView patterns break deep linking, state restoration, and programmatic navigation. Modern NavigationStack fixes all three.

## 5. Concurrency Migration (conc)

**Impact:** MEDIUM-HIGH
**Description:** Combine chains add complexity and retain-cycle risk. Structured concurrency with async/await and .task simplifies data flow and enables Swift 6 safety.

## 6. Architecture Patterns (arch)

**Impact:** MEDIUM
**Description:** MVVM view models fight SwiftUI's declarative model. Refactoring to idiomatic patterns reduces boilerplate and improves testability.

## 7. Type Safety & Protocols (type)

**Impact:** LOW-MEDIUM
**Description:** Force-unwraps, stringly-typed identifiers, and missing protocol conformances cause runtime crashes that compile-time safety prevents.

## 8. Performance Optimization (perf)

**Impact:** LOW
**Description:** Micro-optimizations like Equatable conformance and lazy containers provide final polish after structural refactoring is complete.
