# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Concurrency & Async (conc)

**Impact:** CRITICAL
**Description:** Replacing Combine with async/await, using @MainActor, task management, actors for shared state, and AsyncSequence streams modernize concurrency and prevent data races.

## 2. Render & Scroll Performance (perf)

**Impact:** HIGH
**Description:** Equatable views, lazy containers, drawingGroup, AsyncImage, and task modifiers ensure smooth 120fps scrolling and efficient rendering.

## 3. Animation Performance (anim)

**Impact:** MEDIUM-HIGH
**Description:** Spring animations, matchedGeometryEffect, gesture-driven animations, withAnimation, and transition effects create performant, fluid motion that feels native.
