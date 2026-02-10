# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Concurrency & Async (conc)

**Impact:** CRITICAL
**Description:** Replacing Combine with async/await, using @MainActor for compile-time thread safety, task management, actors for shared state, and AsyncSequence streams modernize concurrency and prevent data races under Swift 6 strict concurrency.

## 2. Render & Scroll Performance (perf)

**Impact:** HIGH
**Description:** View decomposition for state granularity, lazy containers, drawingGroup, task modifiers, and Equatable views ensure smooth 120fps scrolling and efficient rendering by minimizing unnecessary body re-evaluations.

## 3. Animation Performance (anim)

**Impact:** MEDIUM
**Description:** Spring animations, matchedGeometryEffect, gesture-driven animations, withAnimation, and transition effects create performant, fluid motion that feels native to iOS.
