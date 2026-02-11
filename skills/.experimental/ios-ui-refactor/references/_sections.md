# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Visual Hierarchy (hier)

**Impact:** CRITICAL
**Description:** A principal designer's first question is "what am I supposed to look at?" Competing focal points, flat information density, and unclear reading order make screens feel amateur. Visual hierarchy is the single biggest differentiator between a forgettable app and one that feels Apple-quality.

## 2. Typography Discipline (typo)

**Impact:** CRITICAL
**Description:** Typography is 90% of UI design. Wrong type scale, light body weights, fixed font sizes, and emphasis through ALL CAPS instead of weight breaks the typographic rhythm that Apple's system fonts were designed for. Every type decision cascades across every screen.

## 3. Color System (color)

**Impact:** CRITICAL
**Description:** Hard-coded colors, semantic confusion, insufficient contrast, and brand colors that fight iOS conventions destroy visual coherence. A disciplined color system adapts to dark mode, respects accessibility, and integrates brand identity within Apple's semantic color roles.

## 4. Motion & Animation (motion)

**Impact:** HIGH
**Description:** Springs are now the iOS standard. Using linear/easeInOut, manually animating SF Symbols, skipping reduce motion, or adding purposeless animation makes an app feel non-native. Every motion must communicate state change or provide feedback.

## 5. Screen Transitions (trans)

**Impact:** HIGH
**Description:** Hard cuts between states, wrong navigation paradigm (push vs sheet), missing transition origins, and broken swipe-back gestures break spatial continuity. Transitions should reinforce the user's mental model of where content lives in the app's hierarchy.

## 6. Materials & Depth (depth)

**Impact:** HIGH
**Description:** Custom semi-transparent backgrounds, drop shadows for elevation, and mismatched vibrancy levels look dated against iOS's material system. Apple's materials provide automatic adaptation to light/dark mode, accessibility settings, and background content.

## 7. Spacing & Rhythm (rhythm)

**Impact:** MEDIUM-HIGH
**Description:** Inconsistent padding, undersized touch targets, mismatched corner radii, and broken safe area handling create visual noise that users feel but cannot articulate. A consistent spacing grid makes every screen feel intentional.

## 8. iOS 17+ Modernization (modern)

**Impact:** MEDIUM
**Description:** New iOS 17-18 capabilities like scroll transitions, phase animators, mesh gradients, and zoom navigation transitions elevate an app from functional to premium. Adopting these patterns signals a modern, well-maintained codebase.
