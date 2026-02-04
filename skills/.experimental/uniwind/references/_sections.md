# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Build-Time Configuration (build)

**Impact:** CRITICAL
**Description:** Metro plugin setup, CSS entry points, and type generation determine base performance ceiling. Misconfigurations cascade through the entire app, causing missing styles or build failures.

## 2. Theme Architecture (theme)

**Impact:** CRITICAL
**Description:** CSS variables, custom themes, and theming patterns affect every styled component. Poor theme setup causes inconsistent UI, runtime overhead, and broken dark mode.

## 3. Component Integration (comp)

**Impact:** HIGH
**Description:** withUniwind wrapper, third-party component styling, and className bindings. Incorrect integration causes missing styles, broken props, or unnecessary re-renders.

## 4. Responsive Design (resp)

**Impact:** HIGH
**Description:** Breakpoints, media queries, and mobile-first patterns. Wrong approaches cause layout breaks across device sizes and inconsistent spacing.

## 5. Performance Optimization (perf)

**Impact:** MEDIUM-HIGH
**Description:** Runtime style resolution, dynamic classNames, and render optimization. Impacts FPS, app responsiveness, and memory usage on lower-end devices.

## 6. Platform Patterns (plat)

**Impact:** MEDIUM
**Description:** iOS/Android selectors, safe area handling, and platform-specific styling. Ensures correct behavior across platforms without conditional code.

## 7. State & Interaction (state)

**Impact:** MEDIUM
**Description:** Pressable states, pseudo-classes, and data selectors for conditional styling. Incorrect patterns cause broken interactive UI and inaccessible components.

## 8. Migration & Compatibility (compat)

**Impact:** LOW-MEDIUM
**Description:** NativeWind migration, Tailwind 4 syntax, and common pitfalls. Helps teams transition smoothly and avoid breaking changes.
