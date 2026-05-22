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

## 4. Cross-Platform Parity (platform)

**Impact:** CRITICAL  
**Description:** An Expo app ships two frontends — web and native iOS — from one codebase, and the common failure is writing web-React styling that discards native intricacies, or native code that leaves web inert. Because Unistyles v3 is a first-class web engine, the same component can feel native on both: `_web` pseudo-classes (hover, focus, cursor) for pointer users, `Platform.OS` guards and `.web.tsx`/`.ios.tsx` splits where behavior must genuinely differ, an input model that serves touch and pointer alike, and one shared theme with a known map of where web and iOS legitimately diverge (safe-area insets, haptics). For iOS-specific native-feel decisions beyond styling — native navigation, system controls, Liquid Glass — pair this with the `expo-ios-hig` skill.

## 5. Reuse & System Fit (reuse)

**Impact:** HIGH  
**Description:** Agents default to the local optimum — a fresh style or a forked component that makes one screen look right — because at authoring time they do not see what the system already provides. These rules make reuse the first decision: read the design system index before styling, extend a shared component with a variant instead of forking it, promote a pattern to the package on its second use, and reach for a native control (React Native's own, or `@expo/ui` on iOS) before reimplementing one. This is what turns many local maxima into one coherent global system.

## 6. Styling Engine — Unistyles (style)

**Impact:** HIGH  
**Description:** How styles are authored with Unistyles StyleSheet, variants, and dynamic functions determines per-render allocation cost and whether token theming reaches every component including third-party ones.

## 7. Typography & Iconography (type)

**Impact:** HIGH  
**Description:** A shared type scale and a typed icon registry drive visual hierarchy and accessibility; without them, raw fontSize values and ad-hoc icon imports proliferate across every screen.

## 8. Spacing, Layout & Safe Areas (space)

**Impact:** HIGH  
**Description:** A spacing scale, safe-area handling, and minimum touch targets create native rhythm and prevent layouts that feel off or collide with notches, status bars, and the home indicator.

## 9. Native-Feel & Performance (perf)

**Impact:** HIGH  
**Description:** List virtualization, UI-thread animation, gesture handling, and image loading decide whether the app feels native at 60-120fps or drops frames under the load of clinic data.

## 10. Complex Domain Components (domain)

**Impact:** MEDIUM-HIGH  
**Description:** Clinic surfaces like the appointment calendar, treatment-note editor, and Skia body-chart drawing must compose from design system primitives and stay responsive with large datasets and offline writes.

## 11. Governance & Consistency (govern)

**Impact:** MEDIUM  
**Description:** Package boundaries, lint rules, and a component catalog keep the system from decaying as many contributors add features on top of it over time.
