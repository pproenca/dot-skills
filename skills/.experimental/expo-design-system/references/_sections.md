# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Token Architecture (token)

**Clinic architecture alignment:** Feature modules import the `design-system` package + `domain`, never another feature's internals. Tokens live in the Unistyles theme owned by `design-system`; features consume them and never define their own.

**Impact:** CRITICAL  
**Description:** The foundation layer — how tokens are defined and layered (raw to semantic to component) inside the Unistyles theme determines whether the whole system stays consistent or drifts into ad-hoc values that every screen copies.

## 2. Theming & Adaptivity (theme)

**Impact:** CRITICAL  
**Description:** How themes switch and adapt to light/dark and screen size at the Unistyles runtime layer affects every styled component and decides whether a theme change costs a full JavaScript re-render or none at all.

## 3. Component API Contracts (api)

**Impact:** CRITICAL  
**Description:** The public prop interface of each component is the design system's contract; variant-driven APIs (the Airbnb DLS pattern) keep usage consistent, while a leaked style prop lets any screen bypass tokens and break the system.

## 4. Styling Engine — Unistyles (style)

**Impact:** HIGH  
**Description:** How styles are authored with Unistyles StyleSheet, variants, and dynamic functions determines per-render allocation cost and whether token theming reaches every component including third-party ones.

## 5. Typography & Iconography (type)

**Impact:** HIGH  
**Description:** A shared type scale and a typed icon registry drive visual hierarchy and accessibility; without them, raw fontSize values and ad-hoc icon imports proliferate across every screen.

## 6. Spacing, Layout & Safe Areas (space)

**Impact:** HIGH  
**Description:** A spacing scale, safe-area handling, and minimum touch targets create native rhythm and prevent layouts that feel off or collide with notches, status bars, and the home indicator.

## 7. Native-Feel & Performance (perf)

**Impact:** HIGH  
**Description:** List virtualization, UI-thread animation, gesture handling, and image loading decide whether the app feels native at 60-120fps or drops frames under the load of clinic data.

## 8. Complex Domain Components (domain)

**Impact:** MEDIUM-HIGH  
**Description:** Clinic surfaces like the appointment calendar, treatment-note editor, and Skia body-chart drawing must compose from design system primitives and stay responsive with large datasets and offline writes.

## 9. Governance & Consistency (govern)

**Impact:** MEDIUM  
**Description:** Package boundaries, lint rules, and a component catalog keep the system from decaying as many contributors add features on top of it over time.
