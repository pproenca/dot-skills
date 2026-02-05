# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. View Composition (comp)

**Impact:** CRITICAL
**Description:** Views are the fundamental building blocks of SwiftUI interfaces. Incorrect composition — bloated body properties, wrong modifier order, missing view extraction — cascades into layout bugs, performance issues, and unmaintainable code.

## 2. Layout & Sizing (layout)

**Impact:** CRITICAL
**Description:** Stack containers, Grid, LazyVGrid, Spacer, and frame modifiers determine how views arrange on screen. Wrong layout choices cause broken UIs across device sizes and orientations.

## 3. Styling & Theming (style)

**Impact:** HIGH
**Description:** System colors, SF Symbols, gradients, fonts, and material backgrounds ensure visual consistency and platform integration. Hardcoded values break dark mode and accessibility.

## 4. State & Data Flow (state)

**Impact:** HIGH
**Description:** @State, @Binding, @Observable, @Environment, and @Bindable control how data flows through the view hierarchy. Incorrect state management causes stale UI, unnecessary rebuilds, and data loss.

## 5. Navigation & Presentation (nav)

**Impact:** HIGH
**Description:** NavigationStack, TabView, sheets, and programmatic navigation define user flow. Navigation must maintain state across transitions and support deep linking.

## 6. Lists & Dynamic Content (list)

**Impact:** MEDIUM-HIGH
**Description:** List, ForEach, and lazy containers display collections efficiently. Proper use of Identifiable, swipe actions, and searchable keeps scrolling smooth and data correct.

## 7. User Input & Interaction (input)

**Impact:** MEDIUM-HIGH
**Description:** TextField, Button, Picker, Toggle, and forms capture user intent. Proper input handling includes validation, keyboard management, and clear affordances.

## 8. Accessibility & Adaptivity (access)

**Impact:** MEDIUM
**Description:** Accessibility labels, Dynamic Type, @ScaledMetric, and VoiceOver support are required for quality apps. Adaptive layouts with ViewThatFits ensure usability across all users and devices.

## 9. Testing & Debugging (test)

**Impact:** MEDIUM
**Description:** Swift Testing framework, #Preview macro, breakpoints, and console debugging catch bugs before users do. Systematic testing of models and logic ensures correctness.

## 10. App Polish & Refinement (polish)

**Impact:** LOW
**Description:** Animations, transitions, inclusive features, and app refinement turn functional apps into delightful experiences. Polish is the difference between a working app and a great one.
