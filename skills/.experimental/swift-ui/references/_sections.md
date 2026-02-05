# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Data Flow & State Management (state)

**Impact:** CRITICAL
**Description:** Wrong state patterns cause cascading re-renders, memory leaks, and broken UIs. Mastering @Observable, @State, and @Binding is the foundation of performant SwiftUI.

## 2. Visual Design System (design)

**Impact:** CRITICAL
**Description:** HIG compliance with proper spacing, typography, and colors is what separates amateur apps from Apple-quality experiences. These patterns create visual harmony.

## 3. Component Selection (comp)

**Impact:** HIGH
**Description:** Choosing the right SwiftUI component for each use case determines implementation success. Wrong component choice leads to performance issues and UX problems.

## 4. Navigation Patterns (nav)

**Impact:** HIGH
**Description:** NavigationStack, sheets, and modals define how users move through your app. Wrong patterns cause navigation bugs, state loss, and poor user experience.

## 5. View Composition (view)

**Impact:** HIGH
**Description:** How views are structured affects performance, maintainability, and reusability. Proper extraction and composition enable SwiftUI's diffing optimization.

## 6. Animation & Haptics (anim)

**Impact:** MEDIUM-HIGH
**Description:** Spring physics, haptic feedback, and smooth transitions create the polished native feel that users expect from Apple-quality apps.

## 7. Accessibility (acc)

**Impact:** MEDIUM-HIGH
**Description:** VoiceOver, Dynamic Type, and system colors are not optional. Accessibility support is required for App Store quality and reaches 15%+ of users.

## 8. Lists & Scroll Performance (perf)

**Impact:** MEDIUM
**Description:** LazyVStack vs List selection, 120fps scrolling, and view body optimization ensure smooth performance even with large datasets.

## 9. Platform Integration (platform)

**Impact:** MEDIUM
**Description:** SF Symbols, Dark Mode, system features, and platform conventions create apps that feel native and integrate seamlessly with iOS.
