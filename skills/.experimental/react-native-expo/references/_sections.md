# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. App Startup Optimization (launch)

**Impact:** CRITICAL
**Description:** Cold start time directly impacts user retention; every 100ms delay loses 1% of users. Hermes initialization, splash screens, and eager loading patterns determine first-frame timing.

## 2. Bundle Size & Dependencies (bundle)

**Impact:** CRITICAL
**Description:** Larger bundles increase JavaScript parsing time and memory pressure on mobile devices. Direct imports and tree-shaking workarounds are essential since Metro lacks native tree-shaking.

## 3. List Virtualization (list)

**Impact:** CRITICAL
**Description:** FlatList misconfiguration is the #1 cause of frame drops in React Native apps. Proper virtualization props and FlashList migration can improve FPS from 30 to 60.

## 4. Navigation & Routing (nav)

**Impact:** HIGH
**Description:** Screen transitions and lazy loading affect perceived app speed. Expo Router's async routes and proper navigation state management prevent unnecessary screen re-renders.

## 5. Data Fetching Patterns (data)

**Impact:** HIGH
**Description:** Network waterfalls multiply latency by the number of sequential requests. Parallel fetching, proper caching, and request deduplication reduce redundant network calls.

## 6. Re-render Prevention (render)

**Impact:** MEDIUM
**Description:** Unnecessary re-renders waste CPU cycles and drain battery. Strategic memoization and state management prevent cascading re-renders through component trees.

## 7. Animation Performance (anim)

**Impact:** MEDIUM
**Description:** JavaScript thread animations drop frames when the JS thread is busy. Reanimated worklets and native driver achieve consistent 60 FPS by running on the UI thread.

## 8. Memory & Resource Management (mem)

**Impact:** LOW-MEDIUM
**Description:** Memory leaks cause crashes over app lifetime. Proper useEffect cleanup, event listener removal, and timer cancellation prevent resource accumulation.
