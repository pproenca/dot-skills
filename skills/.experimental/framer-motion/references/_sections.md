# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Bundle Optimization (bundle)

**Impact:** CRITICAL
**Description:** Framer Motion's default bundle is 34kb+. Using LazyMotion and the m component reduces initial payload to <5kb, dramatically improving Time to Interactive.

## 2. Re-render Prevention (rerender)

**Impact:** CRITICAL
**Description:** Motion values update the DOM without triggering React re-renders. Using state instead of motion values causes cascading re-renders on every animation frame.

## 3. Animation Properties (anim)

**Impact:** HIGH
**Description:** GPU-accelerated properties (transform, opacity, filter) animate at 60-120fps. Layout-triggering properties (width, height, top, left) cause expensive reflows.

## 4. Layout Animations (layout)

**Impact:** HIGH
**Description:** The layout prop uses FLIP technique for performant CSS transform animations. Misconfigured layout animations cause unnecessary measurements and reflows.

## 5. Scroll Animations (scroll)

**Impact:** MEDIUM-HIGH
**Description:** Hardware-accelerated scroll animations via ScrollTimeline API remain smooth during heavy JS execution. Traditional scroll handlers cause jank.

## 6. Gesture Optimization (gesture)

**Impact:** MEDIUM
**Description:** Built-in gesture props (whileHover, whileTap) are optimized internally. Custom event handlers often break memoization and cause unnecessary re-renders.

## 7. Spring & Physics (spring)

**Impact:** MEDIUM
**Description:** Physics-based springs feel natural and handle interruptions gracefully. Misconfigured damping/stiffness causes excessive oscillation or sluggish animations.

## 8. SVG & Path Animations (svg)

**Impact:** LOW-MEDIUM
**Description:** SVG animations are scalable and lightweight. Complex path morphing with mismatched point counts requires expensive interpolation.

## 9. Exit Animations (exit)

**Impact:** LOW
**Description:** AnimatePresence enables exit animations but requires proper key management. Missing keys cause animation failures or memory leaks.
