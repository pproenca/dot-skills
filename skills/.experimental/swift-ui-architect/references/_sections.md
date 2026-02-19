# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. View Identity & Diffing (diff)

**Impact:** CRITICAL
**Description:** Non-diffable view properties cause full-tree re-evaluation on every state change. Airbnb measured a 15% reduction in scroll hitches after enforcing @Equatable and proper diffing — this is the single highest-impact SwiftUI optimization.

## 2. State Architecture (state)

**Impact:** CRITICAL
**Description:** Wrong state ownership (@State vs plain property vs @Environment) cascades unnecessary rebuilds across the entire view hierarchy. @Observable scoping and single-source-of-truth violations multiply render cost geometrically.

## 3. View Composition (view)

**Impact:** HIGH
**Description:** Monolithic view bodies prevent SwiftUI's diff engine from isolating changes. When a body exceeds ~10 nodes, every property change re-evaluates the entire body instead of just the affected subtree.

## 4. Navigation & Coordination (nav)

**Impact:** HIGH
**Description:** Without a coordinator pattern, navigation logic scatters across views creating tight coupling, untestable flows, and impossible deep linking. Type-safe NavigationStack routing via coordinators is mandatory for scalable apps.

## 5. Layer Architecture (layer)

**Impact:** HIGH
**Description:** Modular MVVM-C boundaries (App/Feature/Domain/Data) with strict dependency rules ensure the app remains testable, maintainable, and modular as it scales beyond 50+ screens.

## 6. Dependency Injection (di)

**Impact:** MEDIUM-HIGH
**Description:** Hard-coded dependencies prevent unit testing, break module boundaries, and make feature isolation impossible. Environment-based injection with protocol abstractions is the SwiftUI-native DI pattern.

## 7. List & Collection Performance (list)

**Impact:** MEDIUM
**Description:** Variable view counts per element, AnyView usage, and inline filtering force SwiftUI to instantiate all list items to gather identifiers, destroying scroll performance on large datasets.

## 8. Async & Data Flow (data)

**Impact:** MEDIUM
**Description:** Synchronous data loading in init blocks app launch, missing .task usage leaks Tasks, and over-broad observation triggers cascade updates across unrelated views.
