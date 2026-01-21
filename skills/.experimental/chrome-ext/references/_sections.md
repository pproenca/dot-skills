# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Service Worker Lifecycle (sw)

**Impact:** CRITICAL
**Description:** Service workers are ephemeral with 30-second idle timeouts. Global state loss, improper persistence, and unnecessary keep-alive patterns are the #1 performance killers in Manifest V3 extensions.

## 2. Content Script Optimization (content)

**Impact:** CRITICAL
**Description:** Content scripts run on every matching page. Heavy script injection, poor timing, and DOM manipulation bottlenecks cascade across all user browsing sessions.

## 3. Message Passing Efficiency (msg)

**Impact:** HIGH
**Description:** Cross-context messaging between service workers, content scripts, and popups adds latency. Poor patterns cause N×M message storms and serialization overhead.

## 4. Storage Operations (storage)

**Impact:** HIGH
**Description:** Storage I/O is asynchronous and can block extension responsiveness. Excessive reads/writes, wrong storage type selection, and unbatched operations create significant delays.

## 5. Network & Permissions (net)

**Impact:** MEDIUM-HIGH
**Description:** Over-requesting permissions triggers store rejection. Using webRequest instead of declarativeNetRequest blocks the main thread and degrades browsing performance.

## 6. Memory Management (mem)

**Impact:** MEDIUM
**Description:** Memory leaks from detached DOM nodes, uncleaned event listeners, and closure retention accumulate over the extension's lifetime, eventually degrading browser performance.

## 7. UI Performance (ui)

**Impact:** MEDIUM
**Description:** Popup startup time, options page rendering, and badge updates affect perceived responsiveness and user experience.

## 8. API Usage Patterns (api)

**Impact:** LOW-MEDIUM
**Description:** Chrome API misuse including wrong timer APIs, sync vs async patterns, and inefficient query patterns causes subtle but cumulative performance degradation.
