# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. App Startup & Bundle Size (startup)

**Impact:** CRITICAL
**Description:** Startup time determines first impression. Large bundles delay Time to Interactive. Hermes and bundle optimization can reduce startup by 40%.

## 2. List Virtualization (list)

**Impact:** CRITICAL
**Description:** Lists are the #1 performance killer in mobile apps. FlashList achieves 5-10× better FPS than FlatList on Android through view recycling.

## 3. Re-render Optimization (rerender)

**Impact:** HIGH
**Description:** Unnecessary re-renders cascade through component trees, blocking the JS thread and causing dropped frames during interactions.

## 4. Animation Performance (anim)

**Impact:** HIGH
**Description:** 60 FPS requires animations on the UI thread. Bridge crossings cause janky animations. Reanimated and native driver are essential.

## 5. Image & Asset Loading (asset)

**Impact:** MEDIUM-HIGH
**Description:** Images are the largest payload in most apps. Poor caching causes network waterfalls. expo-image provides automatic optimization and caching.

## 6. Memory Management (mem)

**Impact:** MEDIUM
**Description:** Memory leaks compound over time. Mobile apps stay in memory longer than web. Uncleaned subscriptions and timers cause crashes.

## 7. Async & Data Fetching (async)

**Impact:** MEDIUM
**Description:** Sequential awaits create network waterfalls. AbortController prevents memory leaks on unmount. Parallel fetching reduces load times.

## 8. Platform Optimizations (platform)

**Impact:** LOW-MEDIUM
**Description:** iOS and Android have different performance characteristics. Platform-specific optimizations extract maximum performance from each OS.
