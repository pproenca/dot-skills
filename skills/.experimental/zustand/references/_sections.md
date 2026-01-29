# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Store Architecture (store)

**Impact:** CRITICAL
**Description:** Foundational store design determines all downstream performance. Multiple small stores beat monolithic stores.

## 2. Selector Optimization (select)

**Impact:** CRITICAL
**Description:** Selectors are the #1 cause of unnecessary re-renders. Atomic selectors with stable returns are essential.

## 3. Re-render Prevention (render)

**Impact:** HIGH
**Description:** Zustand uses strict equality by default. Object/array selectors need useShallow or memoization.

## 4. State Updates (update)

**Impact:** MEDIUM-HIGH
**Description:** Immutable updates, functional setState, and action patterns affect predictability and debugging.

## 5. Middleware Configuration (mw)

**Impact:** MEDIUM
**Description:** Devtools, persist, and immer middleware setup for developer experience and persistence.

## 6. SSR and Hydration (ssr)

**Impact:** MEDIUM
**Description:** Next.js and SSR contexts require skipHydration and manual rehydration to avoid mismatches.

## 7. TypeScript Patterns (ts)

**Impact:** LOW-MEDIUM
**Description:** Type inference, StateCreator patterns, and proper slice typing for type-safe stores.

## 8. Advanced Patterns (adv)

**Impact:** LOW
**Description:** Context integration, external subscriptions, and computed state for specialized use cases.
