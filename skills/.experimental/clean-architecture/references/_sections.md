# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Dependency Direction (dep)

**Impact:** CRITICAL
**Description:** The Dependency Rule is the architectural foundation. Source code dependencies must point inward only; violations cascade failures across all layers.

## 2. Entity Design (entity)

**Impact:** CRITICAL
**Description:** Enterprise business rules must be framework-agnostic, stable, and completely independent of databases, UI, and external systems.

## 3. Use Case Isolation (usecase)

**Impact:** HIGH
**Description:** Application-specific business rules orchestrate entities without leaking infrastructure details or depending on presentation concerns.

## 4. Component Cohesion (comp)

**Impact:** HIGH
**Description:** Components grouped by business capability enable independent deployment, parallel team development, and controlled change propagation.

## 5. Boundary Definition (bound)

**Impact:** MEDIUM-HIGH
**Description:** Architectural boundaries isolate volatile from stable elements; Humble Objects maximize testability by separating hard-to-test from easy-to-test code.

## 6. Interface Adapters (adapt)

**Impact:** MEDIUM
**Description:** Controllers, presenters, and gateways translate between use cases and external systems without leaking implementation details.

## 7. Framework Isolation (frame)

**Impact:** MEDIUM
**Description:** Frameworks are details, not architecture. Business logic must never import, reference, or depend on framework-specific types.

## 8. Testing Architecture (test)

**Impact:** LOW-MEDIUM
**Description:** Tests are architectural components. Layer isolation enables fast unit tests, while boundaries enable targeted integration tests.
