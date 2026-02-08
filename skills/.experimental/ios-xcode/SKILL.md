---
name: ios-xcode
description: Xcode project setup, SwiftData persistence, testing, debugging, profiling, and app distribution for iOS development. This skill should be used when setting up Xcode projects, working with SwiftData models and queries, writing Swift tests, debugging with breakpoints, profiling with Instruments, distributing via TestFlight, or building for visionOS and ML features.
---

# iOS Xcode & Tooling Best Practices

Comprehensive guide for Xcode project configuration, SwiftData persistence, testing, debugging, profiling, and app distribution. Contains 19 rules across 6 categories.

## When to Apply

Reference these guidelines when:
- Setting up Xcode projects with AppStorage, ScenePhase, or widgets
- Implementing SwiftData models, queries, and CRUD operations
- Writing tests with Swift Testing framework
- Debugging with breakpoints and console output
- Profiling performance with Instruments
- Distributing apps via TestFlight
- Building for visionOS or integrating ML features

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | SwiftData & Persistence | CRITICAL | `data-` |
| 2 | Project & Platform | HIGH | `platform-` |
| 3 | Testing | HIGH | `test-` |
| 4 | Debugging & Profiling | MEDIUM-HIGH | `debug-`, `perf-` |
| 5 | Distribution | MEDIUM | `dist-` |
| 6 | Specialty Platforms | MEDIUM | `ml-`, `spatial-` |

## Quick Reference

### 1. Project & Platform (HIGH)

- [`platform-app-storage`](references/platform-app-storage.md) - Use AppStorage for user preferences
- [`platform-scene-phase`](references/platform-scene-phase.md) - Respond to app lifecycle with ScenePhase
- [`platform-widget-integration`](references/platform-widget-integration.md) - Design for widget and Live Activity integration
- [`platform-system-features`](references/platform-system-features.md) - Integrate system features natively

### 2. SwiftData & Persistence (CRITICAL)

- [`data-model-macro`](references/data-model-macro.md) - Define models with @Model macro
- [`data-query-for-fetching`](references/data-query-for-fetching.md) - Use @Query for fetching data
- [`data-model-container`](references/data-model-container.md) - Configure model containers
- [`data-relationships`](references/data-relationships.md) - Define model relationships
- [`data-crud-operations`](references/data-crud-operations.md) - Implement CRUD operations

### 3. Testing (HIGH)

- [`test-swift-testing`](references/test-swift-testing.md) - Use Swift Testing framework
- [`test-preview-sample-data`](references/test-preview-sample-data.md) - Create preview sample data
- [`test-preview-macro`](references/test-preview-macro.md) - Use #Preview macro for rapid iteration

### 4. Debugging & Profiling (MEDIUM-HIGH)

- [`debug-breakpoints`](references/debug-breakpoints.md) - Use breakpoints for debugging
- [`debug-console-output`](references/debug-console-output.md) - Use console output for debugging
- [`perf-instruments-profiling`](references/perf-instruments-profiling.md) - Profile SwiftUI with Instruments

### 5. Distribution (MEDIUM)

- [`dist-testflight`](references/dist-testflight.md) - Distribute via TestFlight
- [`dist-app-icons`](references/dist-app-icons.md) - Design app icons for distribution

### 6. Specialty Platforms (MEDIUM)

- [`ml-natural-language`](references/ml-natural-language.md) - Integrate Natural Language ML
- [`spatial-visionos-windows`](references/spatial-visionos-windows.md) - Build for visionOS spatial computing

## How to Use

Read individual reference files for detailed explanations and code examples:

- [Section definitions](references/_sections.md) - Category structure and impact levels
- [Rule template](assets/templates/_template.md) - Template for adding new rules

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
