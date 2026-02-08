# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. API Modernization (api)

**Impact:** CRITICAL
**Description:** Migrating from deprecated APIs (@ObservableObject → @Observable, NavigationView → NavigationStack, old onChange) prevents future breakage and unlocks modern SwiftUI performance.

## 2. State Architecture (state)

**Impact:** CRITICAL
**Description:** Minimizing state scope, preferring derived values, extracting bindings, and removing unnecessary observation reduce re-renders and simplify debugging.

## 3. View Decomposition (view)

**Impact:** HIGH
**Description:** Extracting subviews, eliminating AnyView, converting computed properties to structs, and reducing body complexity improve diffing performance and maintainability.

## 4. Navigation Refactoring (nav)

**Impact:** HIGH
**Description:** Centralizing destinations, using value-based links, managing NavigationPath state, and adopting NavigationSplitView create scalable navigation architecture.

## 5. Architecture Patterns (arch)

**Impact:** HIGH
**Description:** Eliminating unnecessary ViewModels, using protocol dependencies, Environment key injection, and feature module extraction create testable, maintainable codebases.

## 6. Type Safety & Protocols (type)

**Impact:** MEDIUM-HIGH
**Description:** Tagged identifiers, Result types, phantom types, and force-unwrap elimination catch bugs at compile time instead of runtime.

## 7. Swift Language Fundamentals (swift)

**Impact:** MEDIUM
**Description:** Core Swift patterns—let vs var, structs vs classes, naming conventions, optionals, closures—form the foundation for all Swift/SwiftUI development.
