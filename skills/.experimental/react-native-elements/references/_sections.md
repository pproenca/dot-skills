# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Import & Setup (setup)

**Impact:** CRITICAL
**Description:** Correct imports and ThemeProvider configuration prevent bundle bloat and ensure consistent theming across your entire application.

## 2. Theme Architecture (theme)

**Impact:** CRITICAL
**Description:** Centralized theme configuration affects entire app's visual consistency, reduces prop drilling, and enables seamless dark/light mode switching.

## 3. Component Selection (comp)

**Impact:** HIGH
**Description:** Choosing the right React Native Elements component for each use case maximizes built-in optimizations and accessibility.

## 4. List Performance (list)

**Impact:** HIGH
**Description:** FlatList optimization is the #1 mobile performance factor. Poor list handling causes jank, memory issues, and dropped frames.

## 5. Props & Configuration (props)

**Impact:** MEDIUM-HIGH
**Description:** Proper prop usage enables accessibility features, loading states, platform-specific behavior, and avoids common configuration pitfalls.

## 6. Styling Patterns (style)

**Impact:** MEDIUM
**Description:** Memoized styles and StyleSheet usage prevents object recreation on each render, reducing unnecessary re-renders.

## 7. Callbacks & Events (event)

**Impact:** MEDIUM
**Description:** Stable callbacks prevent cascading re-renders in list items and child components, improving UI responsiveness.

## 8. Advanced Patterns (adv)

**Impact:** LOW
**Description:** Complex patterns for specific use cases including custom components, platform-specific code, and performance edge cases.
