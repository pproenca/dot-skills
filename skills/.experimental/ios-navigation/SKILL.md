---
name: ios-navigation
description: Opinionated SwiftUI navigation enforcement for iOS 26 / Swift 6.2 modular MVVM-C apps. Enforces Domain coordinator protocols, App-target concrete coordinators + route shells, NavigationPath-owned NavigationStack, coordinator-owned modal state, and deep-link/state-restoration readiness. Use when designing or refactoring navigation flows under the clinic architecture.
---

# iOS Navigation (Modular MVVM-C)

Opinionated navigation enforcement for SwiftUI apps using the clinic modular architecture. Focus on coordinator + route shell wiring, feature isolation, and resilient push/sheet/deep-link flows.

## Non-Negotiable Constraints (iOS 26 / Swift 6.2)

- `@Equatable` macro on every navigation view, `AnyView` never
- `@Observable` everywhere, `ObservableObject` / `@Published` never
- App-target coordinators own `NavigationPath`; route shells own `.navigationDestination` mappings
- Coordinator-owned modal state, inline `@State` booleans for sheets never
- Domain layer defines coordinator protocols; concrete coordinators stay out of feature modules

## When to Apply

Reference these guidelines when:
- Designing navigation hierarchies with NavigationStack or NavigationSplitView
- Choosing between push, sheet, and fullScreenCover
- Implementing hero animations, zoom transitions, or gesture-driven dismissals
- Building multi-step flows (onboarding, checkout, registration)
- Using @Observable with @Environment and @Bindable for shared navigation state
- Reviewing code for navigation anti-patterns and modular architecture compliance
- Adding deep linking, state restoration, or tab persistence
- Ensuring VoiceOver and reduce motion support for navigation

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Navigation Architecture | CRITICAL | `arch-` |
| 2 | Navigation Anti-Patterns | CRITICAL | `anti-` |

| 3 | Transition & Animation | HIGH | `anim-` |
| 4 | Modal Presentation | HIGH | `modal-` |
| 5 | Flow Orchestration | HIGH | `flow-` |
| 6 | Navigation Performance | MEDIUM-HIGH | `perf-` |
| 7 | Navigation Accessibility | MEDIUM | `ally-` |
| 8 | State & Restoration | MEDIUM | `state-` |

## Quick Reference

### 1. Navigation Architecture (CRITICAL)

- [`arch-navigation-stack`](references/arch-navigation-stack.md) - Use NavigationStack over deprecated NavigationView
- [`arch-value-based-links`](references/arch-value-based-links.md) - Use value-based NavigationLink over destination closures
- [`arch-destination-registration`](references/arch-destination-registration.md) - Register navigationDestination at stack root
- [`arch-destination-item`](references/arch-destination-item.md) - Use navigationDestination(item:) for optional-based navigation (iOS 17+)
- [`arch-route-enum`](references/arch-route-enum.md) - Define routes as Hashable enums
- [`arch-split-view`](references/arch-split-view.md) - Use NavigationSplitView for multi-column layouts
- [`arch-coordinator`](references/arch-coordinator.md) - Extract navigation logic into Observable coordinator
- [`arch-observable-environment`](references/arch-observable-environment.md) - Use @Environment with @Observable and @Bindable for shared state
- [`arch-deep-linking`](references/arch-deep-linking.md) - Handle deep links by appending to NavigationPath
- [`arch-navigation-path`](references/arch-navigation-path.md) - Use NavigationPath for heterogeneous type-erased navigation
- [`arch-equatable-views`](references/arch-equatable-views.md) - Apply @Equatable macro to every navigation view
- [`arch-observable-only`](references/arch-observable-only.md) - Use @Observable only — never ObservableObject or @Published
- [`arch-no-anyview`](references/arch-no-anyview.md) - Never use AnyView in navigation — use @ViewBuilder or generics
- [`arch-coordinator-modals`](references/arch-coordinator-modals.md) - Present all modals via coordinator — never inline @State

### 2. Navigation Anti-Patterns (CRITICAL)

- [`anti-mixed-link-styles`](references/anti-mixed-link-styles.md) - Avoid mixing NavigationLink(destination:) with NavigationLink(value:)
- [`anti-scattered-destinations`](references/anti-scattered-destinations.md) - Avoid scattering navigationDestination across views
- [`anti-shared-stack`](references/anti-shared-stack.md) - Avoid sharing NavigationStack across tabs
- [`anti-hidden-back-button`](references/anti-hidden-back-button.md) - Avoid hiding back button without preserving swipe gesture
- [`anti-navigation-in-init`](references/anti-navigation-in-init.md) - Avoid heavy work in view initializers
- [`anti-hamburger-menu`](references/anti-hamburger-menu.md) - Avoid hamburger menu navigation
- [`anti-programmatic-tab-switch`](references/anti-programmatic-tab-switch.md) - Avoid programmatic tab selection changes

### 3. Transition & Animation (HIGH)

- [`anim-zoom-transition`](references/anim-zoom-transition.md) - Use zoom navigation transition for hero animations (iOS 18+)
- [`anim-matched-geometry-same-view`](references/anim-matched-geometry-same-view.md) - Use matchedGeometryEffect only within same view hierarchy
- [`anim-spring-config`](references/anim-spring-config.md) - Use modern spring animation syntax (iOS 17+)
- [`anim-gesture-driven`](references/anim-gesture-driven.md) - Use interactive spring animations for gesture-driven transitions
- [`anim-transition-source-styling`](references/anim-transition-source-styling.md) - Style transition sources with shape and background
- [`anim-reduce-motion-transitions`](references/anim-reduce-motion-transitions.md) - Respect reduce motion for all navigation animations
- [`anim-scroll-driven`](references/anim-scroll-driven.md) - Use onScrollGeometryChange for scroll-driven transitions (iOS 18+)

### 4. Modal Presentation (HIGH)

- [`modal-sheet-vs-push`](references/modal-sheet-vs-push.md) - Use push for drill-down, sheet for supplementary content
- [`modal-detents`](references/modal-detents.md) - Use presentation detents for contextual sheet sizing
- [`modal-fullscreen-cover`](references/modal-fullscreen-cover.md) - Use fullScreenCover only for immersive standalone experiences
- [`modal-sheet-placement`](references/modal-sheet-placement.md) - Place .sheet on container view, not on NavigationLink
- [`modal-interactive-dismiss`](references/modal-interactive-dismiss.md) - Guard unsaved changes with interactiveDismissDisabled
- [`modal-nested-navigation`](references/modal-nested-navigation.md) - Use separate NavigationStack inside modals

### 5. Flow Orchestration (HIGH)

- [`flow-tab-independence`](references/flow-tab-independence.md) - Give each tab its own NavigationStack
- [`flow-multi-step`](references/flow-multi-step.md) - Use NavigationStack with route array for multi-step flows
- [`flow-sidebar-navigation`](references/flow-sidebar-navigation.md) - Use NavigationSplitView with selection binding for sidebar
- [`flow-tab-sidebar-adaptive`](references/flow-tab-sidebar-adaptive.md) - Use sidebarAdaptable TabView for iPad tab-to-sidebar (iOS 18+)
- [`flow-pop-to-root`](references/flow-pop-to-root.md) - Implement pop-to-root by clearing NavigationPath
- [`flow-screen-independence`](references/flow-screen-independence.md) - Keep screens independent of parent navigation context

### 6. Navigation Performance (MEDIUM-HIGH)

- [`perf-lazy-destinations`](references/perf-lazy-destinations.md) - Use value-based NavigationLink for lazy destination construction
- [`perf-task-modifier`](references/perf-task-modifier.md) - Use .task for async data loading on navigation
- [`perf-state-object-ownership`](references/perf-state-object-ownership.md) - Own @Observable state with @State, pass as plain property
- [`perf-avoid-body-side-effects`](references/perf-avoid-body-side-effects.md) - Avoid side effects in view body


### 7. Navigation Accessibility (MEDIUM)

- [`ally-rotor-headers`](references/ally-rotor-headers.md) - Mark navigation section headers for VoiceOver rotor
- [`ally-focus-after-navigation`](references/ally-focus-after-navigation.md) - Manage focus after programmatic navigation events
- [`ally-group-navigation-elements`](references/ally-group-navigation-elements.md) - Group related navigation elements to reduce swipe count
- [`ally-hide-decorative-navigation`](references/ally-hide-decorative-navigation.md) - Hide decorative navigation elements from VoiceOver
- [`ally-keyboard-focus`](references/ally-keyboard-focus.md) - Use @FocusState for keyboard navigation in forms

### 8. State & Restoration (MEDIUM)

- [`state-codable-routes`](references/state-codable-routes.md) - Make route enums Codable for navigation persistence
- [`state-scene-storage`](references/state-scene-storage.md) - Use SceneStorage for per-scene navigation persistence
- [`state-tab-persistence`](references/state-tab-persistence.md) - Persist selected tab with SceneStorage
- [`state-deep-link-urls`](references/state-deep-link-urls.md) - Parse deep link URLs into route enums
- [`state-avoid-app-level-path`](references/state-avoid-app-level-path.md) - Avoid defining NavigationPath at App level

## How to Use

Read individual reference files for detailed explanations and code examples:

- [Section definitions](references/_sections.md) - Category structure and impact levels
- [Rule template](assets/templates/_template.md) - Template for adding new rules

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [metadata.json](metadata.json) | Version and reference information |
