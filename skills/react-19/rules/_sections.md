# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Actions & Async Patterns (action)

**Impact:** CRITICAL
**Description:** Actions are React 19's paradigm shift for handling mutations. Improper action patterns cause request waterfalls, poor pending states, and broken error handling.

## 2. Data Fetching & Suspense (async)

**Impact:** CRITICAL
**Description:** The `use` hook and Suspense boundaries determine initial load performance. Misusing promises in render or improper boundary placement blocks streaming and creates waterfalls.

## 3. Server Components (server)

**Impact:** HIGH
**Description:** Server-first architecture reduces bundle size by 25-60% and improves Time-to-Interactive. Wrong client/server boundaries negate these gains entirely.

## 4. React Compiler Optimization (compiler)

**Impact:** HIGH
**Description:** React Compiler handles automatic memoization, but edge cases and third-party libraries can break compilation. Understanding limits prevents silent performance regressions.

## 5. State Management (state)

**Impact:** MEDIUM-HIGH
**Description:** New hooks like useOptimistic and useDeferredValue replace verbose patterns. Misuse causes stale UI, unnecessary renders, or broken optimistic updates.

## 6. Rendering Optimization (render)

**Impact:** MEDIUM
**Description:** Concurrent rendering, transitions, and streaming affect perceived performance. Blocking the main thread or improper transition boundaries degrades user experience.

## 7. Component Patterns (component)

**Impact:** MEDIUM
**Description:** Ref as prop, metadata support, and directive patterns affect code organization. Legacy patterns like forwardRef add unnecessary complexity in React 19.

## 8. DOM & Hydration (dom)

**Impact:** LOW-MEDIUM
**Description:** Hydration errors and DOM API improvements are incremental optimizations. Proper error handling prevents cryptic mismatches in SSR applications.
