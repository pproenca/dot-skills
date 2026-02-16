# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Token Architecture (token)

**Impact:** CRITICAL
**Description:** The foundation layer — how to define, organize, and layer design tokens (raw → semantic → component) determines whether the entire system stays consistent or drifts into ad-hoc chaos.

## 2. Color System Engineering (color)

**Impact:** CRITICAL
**Description:** Colors are the most visible and most duplicated tokens in any app. A well-engineered color system eliminates scattered Color literals and survives rebrands with zero view-level changes.

## 3. Component Style Library (style)

**Impact:** CRITICAL
**Description:** Airbnb's DLS uses style protocols as the primary component API. SwiftUI's built-in Style protocols (ButtonStyle, ToggleStyle) plus custom DLS-style protocols for complex components ensure every variant inherits accessibility, animation, and interaction behavior. All design system views must use @Equatable for optimal diffing performance.

## 4. Typography Scale (type)

**Impact:** HIGH
**Description:** Typography drives visual hierarchy. A reusable type scale prevents the proliferation of .system(size:) calls and ensures Dynamic Type support is baked in, not bolted on.

## 5. Spacing & Sizing System (space)

**Impact:** HIGH
**Description:** Inconsistent spacing is the most common cause of "something feels off" in production apps. A spacing token system eliminates ad-hoc pixel values and creates visual rhythm.

## 6. Consistency & Governance (govern)

**Impact:** HIGH
**Description:** Without governance, design systems decay. Airbnb's approach uses SPM package boundaries, SwiftLint custom rules, consistent naming conventions (Airbnb Swift Style Guide), and automated auditing to enforce token usage and prevent drift.

## 7. Asset Management (asset)

**Impact:** MEDIUM-HIGH
**Description:** Poorly organized asset catalogs lead to duplicate images, inconsistent icon treatments, and bloated bundles. Structured asset management keeps the visual system lean and discoverable.

## 8. Theme & Brand Infrastructure (theme)

**Impact:** MEDIUM
**Description:** Environment-based theming allows brand identity to be layered on top of the system without polluting individual views with conditional logic. Uses @Observable and @Environment per swift-ui-architect constraints.
