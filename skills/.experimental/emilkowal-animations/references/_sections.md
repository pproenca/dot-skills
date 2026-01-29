# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Easing Selection (ease)

**Impact:** CRITICAL
**Description:** Easing is the most important part of any animation—it can make a bad animation feel great and vice versa. Wrong easing choice propagates poor feel throughout the entire interaction.

## 2. Timing & Duration (timing)

**Impact:** CRITICAL
**Description:** Animations over 300ms feel slow and disconnected from user actions. Duration directly affects perceived performance and interface responsiveness.

## 3. Property Selection (props)

**Impact:** HIGH
**Description:** Animating transform and opacity triggers only the composite rendering step; animating layout properties causes expensive reflows and visual jank.

## 4. Transform Techniques (transform)

**Impact:** HIGH
**Description:** CSS transforms are the foundation of most web animations. Proper scale, translate, rotate, and transform-origin usage defines animation quality.

## 5. Interaction Patterns (interact)

**Impact:** MEDIUM-HIGH
**Description:** Momentum-based gestures, interruptibility, and responsive feedback make interfaces feel alive and connected to user actions.

## 6. Strategic Animation (strategy)

**Impact:** MEDIUM
**Description:** Knowing when NOT to animate is as important as knowing how. Over-animation and animating high-frequency actions destroys user experience.

## 7. Accessibility & Polish (polish)

**Impact:** MEDIUM
**Description:** Respecting prefers-reduced-motion, providing safe fallbacks, blur bridging, clip-path reveals, and staggered orchestration elevate good animations to great ones.
