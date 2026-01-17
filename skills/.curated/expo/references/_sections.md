# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Launch Time Optimization (launch)

**Impact:** CRITICAL
**Description:** App startup is the first user impression. Time to Interactive directly affects user retention and app store ratings.

## 2. Bundle Size Optimization (bundle)

**Impact:** CRITICAL
**Description:** Smaller bundles mean faster downloads, faster parsing by Hermes, and reduced memory pressure during startup.

## 3. List Virtualization (list)

**Impact:** HIGH
**Description:** Lists are ubiquitous in mobile apps. Unoptimized lists cause jank, blank frames, and memory exhaustion.

## 4. Image Optimization (image)

**Impact:** HIGH
**Description:** Images are often the largest assets. Unoptimized images cause memory pressure, slow renders, and network bottlenecks.

## 5. Navigation Performance (nav)

**Impact:** MEDIUM-HIGH
**Description:** Navigation transitions affect perceived performance. Improper stack management causes memory leaks and stuttering.

## 6. Re-render Prevention (rerender)

**Impact:** MEDIUM
**Description:** Unnecessary re-renders waste CPU cycles, block the JS thread, and cause frame drops during interactions.

## 7. Animation Performance (anim)

**Impact:** MEDIUM
**Description:** Smooth 60fps animations require running on the native UI thread. JS thread animations cause jank and dropped frames.

## 8. Memory Management (mem)

**Impact:** LOW-MEDIUM
**Description:** Memory leaks compound over time, eventually causing app crashes and degraded performance on lower-end devices.
