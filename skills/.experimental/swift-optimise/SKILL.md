---
name: swift-optimise
description: Swift and SwiftUI performance optimization, concurrency patterns, and animation performance. Covers async/await migration, actor isolation, render performance, lazy containers, and fluid animations. This skill should be used when optimizing Swift/SwiftUI performance, implementing async/await concurrency, improving scroll performance, profiling render issues, or building performant animations.
---

# Swift Optimise — Performance & Concurrency

Comprehensive guide for Swift and SwiftUI performance optimization. Contains 15 rules across 3 categories covering modern concurrency, render performance, and animation performance.

## When to Apply

Reference these guidelines when:
- Migrating from Combine to async/await
- Implementing @MainActor isolation and actor-based concurrency
- Optimizing scroll and render performance
- Using lazy containers and Equatable views for efficient diffing
- Building performant spring animations and transitions
- Profiling and fixing performance bottlenecks

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Concurrency & Async | CRITICAL | `conc-` |
| 2 | Render & Scroll Performance | HIGH | `perf-` |
| 3 | Animation Performance | MEDIUM-HIGH | `anim-` |

## Quick Reference

### 1. Concurrency & Async (CRITICAL)

- [`conc-combine-to-async`](references/conc-combine-to-async.md) - Replace Combine publishers with async/await
- [`conc-mainactor-isolation`](references/conc-mainactor-isolation.md) - Use @MainActor instead of DispatchQueue.main
- [`conc-task-id-pattern`](references/conc-task-id-pattern.md) - Use .task(id:) for reactive data loading
- [`conc-actor-for-shared-state`](references/conc-actor-for-shared-state.md) - Replace lock-based shared state with actors
- [`conc-asyncsequence-streams`](references/conc-asyncsequence-streams.md) - Replace NotificationCenter observers with AsyncSequence

### 2. Render & Scroll Performance (HIGH)

- [`perf-equatable-views`](references/perf-equatable-views.md) - Conform views to Equatable for efficient diffing
- [`perf-lazy-containers`](references/perf-lazy-containers.md) - Use lazy containers for large collections
- [`perf-drawinggroup`](references/perf-drawinggroup.md) - Use drawingGroup for complex graphics
- [`perf-async-image`](references/perf-async-image.md) - Use AsyncImage for remote images
- [`perf-task-modifier`](references/perf-task-modifier.md) - Use task modifier for async work

### 3. Animation Performance (MEDIUM-HIGH)

- [`anim-spring`](references/anim-spring.md) - Use spring animations as default
- [`anim-matchedgeometry`](references/anim-matchedgeometry.md) - Use matchedGeometryEffect for shared transitions
- [`anim-gesture-driven`](references/anim-gesture-driven.md) - Make animations gesture-driven
- [`anim-with-animation`](references/anim-with-animation.md) - Use withAnimation for state-driven transitions
- [`anim-transition-effects`](references/anim-transition-effects.md) - Apply transition effects for view insertion and removal

## How to Use

Read individual reference files for detailed explanations and code examples:

- [Section definitions](references/_sections.md) - Category structure and impact levels
- [Rule template](assets/templates/_template.md) - Template for adding new rules

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
