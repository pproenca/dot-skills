# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Navigation Architecture (arch)

**Clinic architecture alignment (iOS 26 / Swift 6.2):** Keep Feature modules on `Domain` + `DesignSystem` only; keep App-target `DependencyContainer`, route shells, and concrete coordinators as the integration point; keep `Data` as the only owner of SwiftData/network/sync I/O.

**Impact:** CRITICAL
**Description:** NavigationStack, NavigationSplitView, value-based links, destination registration, and coordinator patterns are the foundation of every navigation flow. Wrong architecture makes fluid transitions, deep linking, and state restoration impossible.

## 2. Navigation Anti-Patterns (anti)

**Impact:** CRITICAL
**Description:** Deprecated APIs, mixed navigation paradigms, scattered destination registrations, and shared navigation stacks cause crashes, state loss, and undefined behavior that cascade through the entire app.

## 3. Transition & Animation (anim)

**Impact:** HIGH
**Description:** Zoom transitions, hero animations, spring configurations, gesture-driven dismissals, and matched geometry effects are what separate fluid, golden-standard navigation from jarring screen swaps.

## 4. Modal Presentation (modal)

**Impact:** HIGH
**Description:** Choosing sheet vs fullScreenCover vs push, configuring detents, managing nested navigation in modals, and handling interactive dismissal determines whether supplementary content feels native or fights the user.

## 5. Flow Orchestration (flow)

**Impact:** HIGH
**Description:** Tab independence, multi-step wizards, onboarding sequences, sidebar navigation, and programmatic route manipulation define how users move through complex journeys without losing context.

## 6. Navigation Performance (perf)

**Impact:** MEDIUM-HIGH
**Description:** Lazy destination construction, avoiding view reconstruction on navigation, prefetching with .task, and correct state object ownership prevent hitches and memory spikes during screen transitions.

## 7. Navigation Accessibility (ally)

**Impact:** MEDIUM
**Description:** VoiceOver rotor navigation, programmatic focus management, reduce motion support for transitions, and element grouping ensure all users can navigate your app fluidly.

## 8. State & Restoration (state)

**Impact:** MEDIUM
**Description:** NavigationPath persistence with SceneStorage, Codable route enums, deep link URL handling, and tab selection persistence ensure users never lose their place across app launches and scene changes.
