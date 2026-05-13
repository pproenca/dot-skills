# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Concurrent Rendering (conc)

**Impact:** CRITICAL
**Description:** useTransition, useDeferredValue, and automatic batching enable non-blocking UI updates, improving responsiveness by up to 40%.

## 2. Server Components (rsc)

**Impact:** CRITICAL
**Description:** Proper server/client boundaries and data fetching patterns significantly reduce client JavaScript and eliminate client-side waterfalls.

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

## 9. Codebase Hygiene (cross)

**Impact:** LOW-MEDIUM
**Description:** Cross-cutting findings that only surface across files: duplicated logic that should be a shared hook, near-duplicate components that should be one, unused components/hooks/utilities, `'use client'` files that don't need client execution, and same-concept-different-name prop drift. The category sits at LOW-MEDIUM **as a baseline urgency** because most well-maintained codebases are clean here; the *individual rule impacts* within are calibrated separately (extract-shared-logic and component-consolidation are HIGH when they fire, dead-code and boundary-coherence are MEDIUM-HIGH, etc.). These rules use a multi-file format alongside the standard single-file Incorrect/Correct shape, and run as a final sweep after Categories 1–8 in the review algorithm. Required for any whole-repo audit — single-file rule sweeps cannot, by construction, produce these findings.
