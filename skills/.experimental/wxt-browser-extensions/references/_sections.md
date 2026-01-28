# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Service Worker Lifecycle (svc)

**Impact:** CRITICAL
**Description:** MV3 service workers are ephemeral and can terminate at any time. Improper event registration and state management causes missed events and broken extension functionality.

## 2. Content Script Injection (inject)

**Impact:** CRITICAL
**Description:** Content script timing, world selection, and DOM access patterns determine whether extensions interact correctly with web pages. Wrong patterns cause race conditions and security issues.

## 3. Messaging Architecture (msg)

**Impact:** HIGH
**Description:** Cross-context communication between background, content scripts, and UI is the backbone of extensions. Type-safe async patterns prevent data loss and silent failures.

## 4. Storage Patterns (store)

**Impact:** HIGH
**Description:** Type-safe storage with proper area selection and watch patterns prevents data corruption, race conditions, and quota issues in extension state management.

## 5. Bundle Optimization (bundle)

**Impact:** MEDIUM-HIGH
**Description:** Extension package size affects Chrome Web Store install rates and startup time. Tree-shaking, code splitting, and dependency optimization reduce overhead.

## 6. Manifest Configuration (manifest)

**Impact:** MEDIUM
**Description:** Proper permission scoping, host permissions, and web accessible resource declarations affect security review outcomes and extension capabilities.

## 7. UI Performance (ui)

**Impact:** MEDIUM
**Description:** Shadow DOM isolation, efficient rendering, and proper lifecycle management in popups, sidepanels, and options pages affect user experience.

## 8. TypeScript Patterns (ts)

**Impact:** LOW-MEDIUM
**Description:** WXT-specific TypeScript patterns, API usage, and type safety improve code maintainability and catch errors at build time.
