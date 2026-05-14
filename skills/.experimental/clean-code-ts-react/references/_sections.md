# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

Categories are ordered by **cognitive cost across a code change's lifetime** (read → understand → modify → verify → ship → maintain). Earlier stages cascade — bad names taint every read, bad function shapes taint every modify.

---

## 1. Meaningful Names (name)

**Impact:** CRITICAL  
**Description:** Names are read far more often than they are written. Bad names cascade confusion through every future read, review, and modification — they are the single highest-leverage form of documentation in TS+React code.

## 2. Functions, Components & Hooks (func)

**Impact:** CRITICAL  
**Description:** Functions, components, and hooks are the units of comprehension in TS+React. Small, focused units enable understanding, testing, and reuse — but pursued blindly they create "shallow modules" that scatter logic. The principle is comprehensibility, not line count.

## 3. Self-Documentation: Types & Comments (doc)

**Impact:** HIGH  
**Description:** In TypeScript, types are the primary documentation mechanism — they are checked, refactored, and read by the compiler. Comments are a fallback for the rare cases types cannot express. Stale or redundant comments cost more than no comments.

## 4. Formatting (Beyond Prettier) (fmt)

**Impact:** HIGH  
**Description:** Prettier and ESLint handle whitespace and syntax. What remains is human judgment: vertical density, reading order, file organization, and team consistency. A file should read top-to-bottom like a newspaper article — high-level concepts first, details below.

## 5. Error Handling (err)

**Impact:** HIGH  
**Description:** Clean error handling separates the happy path from exceptional cases. In TS+React this means narrowing as the primitive, error boundaries and Suspense as the framework-level pattern, and a deliberate choice between throwing exceptions and returning Result-like discriminated unions. Swallowed errors are silent bugs.

## 6. Data Shape & Immutability (data)

**Impact:** MEDIUM-HIGH  
**Description:** Type shapes encode invariants. Discriminated unions over boolean flags, readonly where mutation is not intended, branded types for opaque identifiers — these turn "could not happen" comments into compile errors. Prop-drilling smells like a Law-of-Demeter violation, but is sometimes the right call.

## 7. Boundaries (bound)

**Impact:** MEDIUM-HIGH  
**Description:** Third-party hooks, SDKs, and external APIs are boundaries. Wrap them in custom hooks or thin adapters to isolate change, ease testing, and keep your codebase's vocabulary stable when a vendor swaps an interface. Type assertions belong at boundaries, never in the middle.

## 8. Composition over Inheritance (comp)

**Impact:** MEDIUM-HIGH  
**Description:** React composes via `children`, render props, and hooks — not class hierarchies. Keep components cohesive, prefer composition over HOC stacks, and inject dependencies via context only when prop-passing genuinely hurts. The 2008 advice on "small classes" maps to "small components and hooks" in modern React.

## 9. Tests (test)

**Impact:** MEDIUM  
**Description:** Tests are first-class code that enables safe refactoring. In React Testing Library and Vitest terms: test behavior not implementation, mock only at true boundaries (not your own modules), one concept per test, and apply the same naming and structure discipline as production code.

## 10. Emergence & Simple Design (emerge)

**Impact:** MEDIUM  
**Description:** Good design emerges from four rules applied in order: passes tests, reveals intent, no duplication, fewest elements. Premature abstraction is the most common violation in modern TS+React — generic gymnastics, HOC over composition, and "just-in-case" hooks all fail rule four.

## 11. Meta: When Principles Conflict (meta)

**Impact:** MEDIUM  
**Description:** Clean code principles routinely conflict — DRY vs Single Responsibility, small functions vs deep modules, type safety vs ergonomic APIs. The mark of seniority is knowing which principle to bend in a given context. This category gives explicit guidance for the most common conflicts.
