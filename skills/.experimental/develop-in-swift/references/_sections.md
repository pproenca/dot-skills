# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Swift Language Fundamentals (swift)

**Impact:** CRITICAL
**Description:** Master Swift's type system, value vs reference semantics, optionals, and error handling. These foundations determine code safety, readability, and maintainability across all Apple platforms.

## 2. SwiftUI View Basics (view)

**Impact:** CRITICAL
**Description:** Understand how to create, compose, and customize SwiftUI views. Views are the fundamental building blocks of your app's interface, and proper view architecture ensures performance and maintainability.

## 3. State & Data Flow (state)

**Impact:** CRITICAL
**Description:** Use @State, @Binding, @Observable, and @Environment correctly. Proper state management prevents UI bugs, unnecessary re-renders, and makes your app predictable.

## 4. SwiftData & Persistence (data)

**Impact:** HIGH
**Description:** Model your app's data with SwiftData using @Model, @Query, and model relationships. Proper data modeling ensures data integrity and enables efficient queries.

## 5. Navigation & Presentation (nav)

**Impact:** HIGH
**Description:** Implement NavigationStack, TabView, sheets, and detail views correctly. Navigation patterns define user flow and must maintain state across transitions.

## 6. Lists & Dynamic Content (list)

**Impact:** HIGH
**Description:** Display collections with List, ForEach, and lazy containers. Handle dynamic data with proper identifiers and efficient rendering.

## 7. User Input & Forms (input)

**Impact:** MEDIUM-HIGH
**Description:** Capture user input with TextField, TextEditor, Picker, Toggle, and forms. Proper input handling includes validation, keyboard management, and accessibility.

## 8. Testing & Quality (test)

**Impact:** MEDIUM-HIGH
**Description:** Write unit tests with Swift Testing framework. Test your models and logic to ensure correctness before shipping.

## 9. Accessibility & Localization (access)

**Impact:** MEDIUM-HIGH
**Description:** Make apps accessible with VoiceOver labels, Dynamic Type, and proper localization. Accessibility is required for quality apps.

## 10. Debugging & Refinement (debug)

**Impact:** MEDIUM
**Description:** Use Xcode's debugging tools, breakpoints, and console to find and fix bugs. Systematic debugging saves time and improves code quality.

## 11. Machine Learning Integration (ml)

**Impact:** MEDIUM
**Description:** Add intelligent features with Natural Language, Vision, Create ML, and Core ML frameworks. On-device ML enables privacy-preserving features.

## 12. visionOS & Spatial Computing (spatial)

**Impact:** MEDIUM
**Description:** Build for Apple Vision Pro with windows, ornaments, and volumes. Spatial computing requires understanding 3D space and immersive contexts.

## 13. App Distribution (dist)

**Impact:** LOW
**Description:** Prepare apps for TestFlight and App Store distribution. Proper submission requires icons, metadata, and testing workflows.
