# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Navigation & Drive (drive)

**Impact:** CRITICAL
**Description:** Turbo Drive is the foundation of every Hotwire app — it intercepts all clicks and form submissions, so misconfiguration cascades into broken Frames, Streams, and 5× slower navigation (1200ms full reload vs 250ms Drive visit).

## 2. Turbo Frames (frame)

**Impact:** CRITICAL
**Description:** Frames scope server responses to targeted page regions; wrong scoping causes full page reloads, broken back-button navigation, or invisible content failures that bypass error tracking.

## 3. Turbo Streams (stream)

**Impact:** HIGH
**Description:** Streams deliver surgical DOM mutations via 9 built-in actions; choosing the wrong delivery method (HTTP vs WebSocket) or skipping progressive enhancement breaks non-JS clients and wastes server resources.

## 4. Broadcasting & Real-Time (bcast)

**Impact:** HIGH
**Description:** N+1 broadcasts are the #1 Hotwire production performance killer — 1 create can trigger 100 broadcasts × 100 partial renders, degrading response times from 50ms to 3.2 seconds.

## 5. Morphing & Page Refresh (morph)

**Impact:** HIGH
**Description:** Turbo 8 morphing updates only changed DOM nodes (23ms vs 180ms full replace — 7.8× faster), but requires explicit scroll preservation and permanent element configuration to avoid state loss.

## 6. Performance Optimization (perf)

**Impact:** MEDIUM-HIGH
**Description:** Lazy-loaded frames, optimistic UI, and batched stream updates reduce initial load from 2.4s to 0.7s and cut perceived latency to near-zero for common interactions.

## 7. Architecture Decisions (arch)

**Impact:** MEDIUM
**Description:** The progressive enhancement hierarchy (HTML → CSS → Drive → Frames → Streams → Stimulus) determines which tool to reach for; wrong choice leads to over-engineered JavaScript replacing server-rendered simplicity.

## 8. Testing Hotwire (test)

**Impact:** MEDIUM
**Description:** Turbo's async DOM updates, WebSocket broadcasts, and frame navigations require specific Capybara patterns and test helpers to avoid flaky tests and false positives.
