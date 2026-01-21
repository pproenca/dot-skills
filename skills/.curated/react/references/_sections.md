# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Concurrent Rendering (conc)

**Impact:** CRITICAL
**Description:** useTransition, useDeferredValue, and automatic batching enable non-blocking UI updates, improving responsiveness by up to 40%.

## 2. Server Components (rsc)

**Impact:** CRITICAL
**Description:** Proper server/client boundaries and data fetching patterns reduce client JavaScript by 38% and eliminate client-side waterfalls.

## 3. Actions & Forms (form)

**Impact:** HIGH
**Description:** useActionState, useOptimistic, and form actions provide declarative mutation handling with automatic pending states.

## 4. Data Fetching (data)

**Impact:** HIGH
**Description:** The use() hook, Suspense for data, and cache() for deduplication enable efficient async data patterns.

## 5. State Management (rstate)

**Impact:** MEDIUM-HIGH
**Description:** Proper useState patterns, useReducer for complex state, and context optimization prevent unnecessary re-renders.

## 6. Memoization & Performance (memo)

**Impact:** MEDIUM
**Description:** Strategic useMemo, useCallback, and React Compiler integration reduce computation and stabilize references.

## 7. Effects & Events (effect)

**Impact:** MEDIUM
**Description:** Proper useEffect patterns, useEffectEvent for non-reactive logic, and avoiding unnecessary effects improve reliability.

## 8. Component Patterns (rcomp)

**Impact:** LOW-MEDIUM
**Description:** Composition over inheritance, render props, and children patterns enable flexible, reusable components.
