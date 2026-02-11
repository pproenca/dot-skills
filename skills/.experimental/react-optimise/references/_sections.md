# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. React Compiler Mastery (compiler)

**Impact:** CRITICAL
**Description:** React Compiler v1.0 auto-memoizes components but silently bails out on non-idiomatic code. Writing compiler-friendly patterns unlocks automatic 2-10x render optimization without manual useMemo/useCallback.

## 2. Bundle & Loading (bundle)

**Impact:** CRITICAL
**Description:** JavaScript bundle size is the #1 controllable factor for Time to Interactive. Route splitting, barrel elimination, and dynamic imports reduce initial load by 40-70%.

## 3. Rendering Optimization (render)

**Impact:** HIGH
**Description:** Unnecessary re-renders and layout recalculations cause jank in data-heavy UIs. Virtualization, stable keys, and CSS containment keep frame times under 16ms.

## 4. Data Fetching Performance (fetch)

**Impact:** HIGH
**Description:** Sequential data waterfalls add 200-2000ms to page loads. Parallel fetching, route preloading, and request deduplication eliminate round-trip waste.

## 5. Core Web Vitals (cwv)

**Impact:** MEDIUM-HIGH
**Description:** INP, LCP, and CLS directly affect user experience and search ranking. Yielding to the main thread, priority loading, and size reservations target each vital.

## 6. State & Subscription Performance (sub)

**Impact:** MEDIUM-HIGH
**Description:** Overly broad context and global subscriptions cause cascade re-renders across unrelated components. Context splitting and selector patterns isolate updates to affected subtrees.

## 7. Profiling & Measurement (profile)

**Impact:** MEDIUM
**Description:** Optimizing without profiling wastes effort on non-bottlenecks. React Performance Tracks, flame charts, and CI budgets ensure optimization targets real user impact.

## 8. Memory Management (mem)

**Impact:** LOW-MEDIUM
**Description:** Leaked subscriptions, uncancelled async operations, and retained closures cause gradual performance degradation in long-lived SPAs. Cleanup patterns prevent memory growth.
