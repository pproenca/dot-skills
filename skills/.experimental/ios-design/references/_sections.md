# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Design System (design)

**Impact:** CRITICAL
**Description:** Semantic colors, typography, spacing, dark mode, SF Symbols, and material backgrounds create visual harmony. These are what separate amateur apps from Apple-quality experiences.

## 2. Layout & Sizing (layout)

**Impact:** HIGH
**Description:** 8pt grid, stacks, spacers, frames, grids, and adaptive layouts determine how content flows across screen sizes. Correct layout ensures your UI works on every device.

## 3. View Composition (view)

**Impact:** HIGH
**Description:** View body structure, custom properties, modifier order, @ViewBuilder, and composition patterns affect performance, maintainability, and reusability.

## 4. State & Data Flow (state)

**Impact:** CRITICAL
**Description:** @State, @Binding, @Environment, @Observable, and scope management are the foundation of reactive SwiftUI. Wrong patterns cause cascading re-renders and broken UIs.

## 5. Navigation (nav)

**Impact:** HIGH
**Description:** NavigationStack, TabView, sheets, toolbars, and programmatic navigation define how users move through your app. Wrong patterns cause state loss and poor UX.

## 6. Components & Controls (comp)

**Impact:** HIGH
**Description:** Choosing and configuring the right SwiftUI component—List, Picker, Button, TextField, Sheet—determines implementation success and native feel.

## 7. Animation & Polish (anim)

**Impact:** MEDIUM
**Description:** Semantic transitions and loading state animations provide UX polish that makes your app feel alive and responsive.
