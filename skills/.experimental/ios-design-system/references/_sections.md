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

## 3. Typography Scale (type)

**Impact:** HIGH
**Description:** Typography drives visual hierarchy. A reusable type scale prevents the proliferation of .system(size:) calls and ensures Dynamic Type support is baked in, not bolted on.

## 4. Spacing & Sizing System (space)

**Impact:** HIGH
**Description:** Inconsistent spacing is the most common cause of "something feels off" in production apps. A spacing token system eliminates magic numbers and creates visual rhythm.

## 5. Component Style Library (style)

**Impact:** HIGH
**Description:** SwiftUI's Style protocols (ButtonStyle, LabelStyle, ToggleStyle) are the proper mechanism for reusable component styling — not wrapper views with hardcoded modifiers.

## 6. Asset Management (asset)

**Impact:** MEDIUM-HIGH
**Description:** Poorly organized asset catalogs lead to duplicate images, inconsistent icon treatments, and bloated bundles. Structured asset management keeps the visual system lean and discoverable.

## 7. Theme & Brand Infrastructure (theme)

**Impact:** MEDIUM
**Description:** Environment-based theming allows brand identity to be layered on top of the system without polluting individual views with conditional logic.

## 8. Consistency & Governance (govern)

**Impact:** MEDIUM
**Description:** Without governance, design systems decay. Practical patterns for finding duplicates, enforcing token usage, and migrating from ad-hoc styles keep the system healthy over time.
