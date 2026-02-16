# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. View Identity & Diffing (diff)

**Impact:** CRITICAL
**Description:** Non-diffable view properties cause full-tree re-evaluation on every state change. Airbnb measured a 15% reduction in scroll hitches after enforcing @Equatable and proper diffing — this is the single highest-impact SwiftUI optimization.

## 2. API Modernization (api)

**Impact:** CRITICAL
**Description:** Migrating from deprecated APIs (@ObservableObject → @Observable, NavigationView → NavigationStack, old onChange) prevents future breakage and unlocks modern SwiftUI performance.

## 3. State Architecture (state)

**Impact:** CRITICAL
**Description:** Wrong state ownership (@State vs plain property vs @Environment) cascades unnecessary rebuilds. @Observable scoping and single-source-of-truth violations multiply render cost geometrically.

## 4. View Composition (view)

**Impact:** HIGH
**Description:** Monolithic view bodies prevent SwiftUI's diff engine from isolating changes. When a body exceeds ~10 nodes, every property change re-evaluates the entire body instead of just the affected subtree.

## 5. Navigation & Coordination (nav)

**Impact:** HIGH
**Description:** Without a coordinator pattern, navigation logic scatters across views creating tight coupling, untestable flows, and impossible deep linking. Type-safe NavigationStack routing via coordinators is mandatory.

## 6. Layer Architecture (layer)

**Impact:** HIGH
**Description:** Clean Architecture boundaries (Domain/Data/Presentation) with strict inward-only dependency rules ensure the app remains testable, maintainable, and modular as it scales.

## 7. Architecture Patterns (arch)

**Impact:** HIGH
**Description:** Restructuring inline state into @Observable ViewModels, extracting protocol dependencies through proper layers, and feature module extraction create testable, maintainable codebases.

## 8. Dependency Injection (di)

**Impact:** MEDIUM-HIGH
**Description:** Hard-coded dependencies prevent unit testing, break module boundaries, and make feature isolation impossible. Environment-based injection with protocol abstractions is the SwiftUI-native DI pattern.

## 9. Type Safety & Protocols (type)

**Impact:** MEDIUM-HIGH
**Description:** Tagged identifiers, Result types, phantom types, and force-unwrap elimination catch bugs at compile time instead of runtime.

## 10. List & Collection Performance (list)

**Impact:** MEDIUM
**Description:** Variable view counts per element, inline filtering, and eager stacks force SwiftUI to instantiate all list items, destroying scroll performance on large datasets.

## 11. Async & Data Flow (data)

**Impact:** MEDIUM
**Description:** Synchronous data loading blocks app launch, missing .task usage leaks Tasks, and boolean loading flags create impossible state combinations.

## 12. Swift Language Fundamentals (swift)

**Impact:** MEDIUM
**Description:** Core Swift patterns—let vs var, structs vs classes, naming conventions, optionals, closures—form the foundation for all Swift/SwiftUI development.
