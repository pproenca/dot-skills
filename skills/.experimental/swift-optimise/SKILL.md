---
name: swift-optimise
description: Swift 6.2 and SwiftUI performance optimization for iOS 26 clinic architecture codebases. Covers async/await concurrency patterns, Sendable/actor isolation, view/render performance, and animation performance while preserving modular MVVM-C boundaries across App, Feature, Domain, and Data layers. Use when profiling or optimizing Swift/SwiftUI behavior in clinic modules.
---

# Apple Swift/SwiftUI Performance Optimization Best Practices

Comprehensive guide for Swift and SwiftUI performance optimization. Contains 19 rules across 3 categories covering modern concurrency, render performance, and animation performance. Targets iOS 26 / Swift 6.2 with @Observable and Swift 6 strict concurrency.


## Clinic Architecture Contract (iOS 26 / Swift 6.2)

All guidance in this skill assumes the clinic modular MVVM-C architecture:

- Feature modules import `Domain` + `DesignSystem` only (never `Data`, never sibling features)
- App target is the convergence point and owns `DependencyContainer`, concrete coordinators, and Route Shell wiring
- `Domain` stays pure Swift and defines models plus repository, `*Coordinating`, `ErrorRouting`, and `AppError` contracts
- `Data` owns SwiftData/network/sync/retry/background I/O and implements Domain protocols
- Read/write flow defaults to stale-while-revalidate reads and optimistic queued writes
- ViewModels call repository protocols directly (no default use-case/interactor layer)

## When to Apply

Reference these guidelines when:
- Migrating to Swift 6 strict concurrency (Sendable, actor isolation)
- Replacing Combine publishers with async/await
- Implementing @MainActor isolation and actor-based concurrency
- Decomposing views to reduce state invalidation blast radius
- Optimizing scroll and render performance with lazy containers
- Using Canvas/TimelineView for high-performance rendering
- Profiling with SwiftUI Instruments before optimizing
- Building performant spring animations and transitions

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Concurrency & Async | CRITICAL | `conc-` |
| 2 | Render & Scroll Performance | HIGH | `perf-` |
| 3 | Animation Performance | MEDIUM | `anim-` |

## Quick Reference

### 1. Concurrency & Async (CRITICAL)

- [`conc-combine-to-async`](references/conc-combine-to-async.md) - Replace Combine publishers with async/await
- [`conc-mainactor-isolation`](references/conc-mainactor-isolation.md) - Use @MainActor instead of DispatchQueue.main
- [`conc-swift6-sendable`](references/conc-swift6-sendable.md) - Adopt Sendable and Swift 6 strict concurrency
- [`conc-task-id-pattern`](references/conc-task-id-pattern.md) - Use .task(id:) for reactive data loading
- [`conc-actor-for-shared-state`](references/conc-actor-for-shared-state.md) - Replace lock-based shared state with actors
- [`conc-asyncsequence-streams`](references/conc-asyncsequence-streams.md) - Replace NotificationCenter observers with AsyncSequence

### 2. Render & Scroll Performance (HIGH)

- [`perf-view-decomposition`](references/perf-view-decomposition.md) - Decompose views to limit state invalidation blast radius
- [`perf-instruments-profiling`](references/perf-instruments-profiling.md) - Profile with SwiftUI Instruments before optimizing
- [`perf-lazy-containers`](references/perf-lazy-containers.md) - Use lazy containers for large collections
- [`perf-canvas-timeline`](references/perf-canvas-timeline.md) - Use Canvas and TimelineView for high-performance rendering
- [`perf-drawinggroup`](references/perf-drawinggroup.md) - Use drawingGroup for complex graphics
- [`perf-equatable-views`](references/perf-equatable-views.md) - Add Equatable conformance to prevent spurious redraws
- [`perf-task-modifier`](references/perf-task-modifier.md) - Use .task modifier instead of .onAppear for async work
- [`perf-async-image`](references/perf-async-image.md) - Use AsyncImage with caching strategy for remote images

### 3. Animation Performance (MEDIUM)

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
