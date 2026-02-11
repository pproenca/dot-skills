---
name: ios-animations
description: iOS animation craft guidelines for SwiftUI — spring physics, gesture continuity, spatial transitions, micro-interactions, and orchestration. This skill should be used when writing, reviewing, or refactoring SwiftUI animation code to achieve fluid, native-feeling motion. Triggers on tasks involving SwiftUI animations, transitions, gesture-driven motion, spring parameters, matchedGeometryEffect, PhaseAnimator, haptic feedback, or any motion design work in iOS apps.
---

# dot-skills iOS SwiftUI Animations Best Practices

Comprehensive animation guidelines for SwiftUI apps, designed to produce fluid, native-feeling motion that matches Apple's first-party quality. Contains 47 rules across 8 categories, prioritized by impact — from spring physics fundamentals to orchestration polish.

## When to Apply

Reference these guidelines when:
- Adding animations to SwiftUI views or transitions
- Building gesture-driven interactions (drag, swipe, pan)
- Connecting views with spatial transitions (expand/collapse, navigation morphs)
- Designing micro-interactions (button press, toggle, loading states)
- Making content changes feel physical (number rolls, symbol replacements)
- Choreographing multi-element animation sequences
- Reviewing animation code for performance and accessibility

## Rule Categories by Priority

| Priority | Category | Impact | Prefix | Rules |
|----------|----------|--------|--------|-------|
| 1 | Spring Physics | CRITICAL | `spring-` | 7 |
| 2 | Timing & Feel | CRITICAL | `feel-` | 6 |
| 3 | Gesture Continuity | HIGH | `gesture-` | 7 |
| 4 | Spatial Transitions | HIGH | `spatial-` | 6 |
| 5 | Micro-interactions | HIGH | `micro-` | 6 |
| 6 | Content Motion | MEDIUM-HIGH | `content-` | 5 |
| 7 | Orchestration | MEDIUM | `orch-` | 5 |
| 8 | Craft & Polish | MEDIUM | `craft-` | 5 |

## Quick Reference

### 1. Spring Physics (CRITICAL)

- [`spring-smooth-default`](references/spring-smooth-default.md) — Default to .smooth spring for all UI transitions
- [`spring-snappy-responsive`](references/spring-snappy-responsive.md) — Use .snappy spring for responsive interactions
- [`spring-bouncy-celebration`](references/spring-bouncy-celebration.md) — Use .bouncy spring for playful and celebratory moments
- [`spring-custom-parameters`](references/spring-custom-parameters.md) — Tune custom springs with response and dampingFraction
- [`spring-velocity-preservation`](references/spring-velocity-preservation.md) — Springs preserve velocity on interruption
- [`spring-never-linear`](references/spring-never-linear.md) — Never use linear or easeInOut for interactive UI
- [`spring-completion-chaining`](references/spring-completion-chaining.md) — Use withAnimation completion for chained sequences

### 2. Timing & Feel (CRITICAL)

- [`feel-250ms-max`](references/feel-250ms-max.md) — Keep UI animations under 250ms
- [`feel-faster-better`](references/feel-faster-better.md) — Faster animations almost always feel better
- [`feel-asymmetric-enter-exit`](references/feel-asymmetric-enter-exit.md) — Use asymmetric timing for enter and exit
- [`feel-distance-proportional`](references/feel-distance-proportional.md) — Match duration to distance traveled
- [`feel-haptic-sync`](references/feel-haptic-sync.md) — Sync haptic feedback to visual animation keyframes
- [`feel-stagger-timing`](references/feel-stagger-timing.md) — Stagger reveals at 30-50ms intervals

### 3. Gesture Continuity (HIGH)

- [`gesture-rubber-band`](references/gesture-rubber-band.md) — Rubber band at drag boundaries
- [`gesture-momentum-dismiss`](references/gesture-momentum-dismiss.md) — Dismiss on velocity OR distance threshold
- [`gesture-snap-points`](references/gesture-snap-points.md) — Use velocity-aware snap points
- [`gesture-interruptible`](references/gesture-interruptible.md) — Make all gesture animations interruptible
- [`gesture-scroll-drag-conflict`](references/gesture-scroll-drag-conflict.md) — Resolve scroll and drag gesture conflicts
- [`gesture-state-transient`](references/gesture-state-transient.md) — Use GestureState for transient drag state
- [`gesture-projected-landing`](references/gesture-projected-landing.md) — Project gesture velocity for natural landing position

### 4. Spatial Transitions (HIGH)

- [`spatial-matched-geometry`](references/spatial-matched-geometry.md) — Use matchedGeometryEffect for expand/collapse morphs
- [`spatial-zoom-navigation`](references/spatial-zoom-navigation.md) — Use zoom navigation transition for collection detail (iOS 18)
- [`spatial-transition-origin`](references/spatial-transition-origin.md) — Anchor transitions to their trigger location
- [`spatial-hero-shared-element`](references/spatial-hero-shared-element.md) — Share multiple element IDs for rich hero animations
- [`spatial-sheet-morph`](references/spatial-sheet-morph.md) — Use matchedGeometryEffect for sheet presentations
- [`spatial-tab-continuity`](references/spatial-tab-continuity.md) — Maintain spatial direction in tab transitions

### 5. Micro-interactions (HIGH)

- [`micro-button-press-scale`](references/micro-button-press-scale.md) — Scale buttons to 0.97 on press for tactile feedback
- [`micro-haptic-pairing`](references/micro-haptic-pairing.md) — Pair every visual state change with haptic feedback
- [`micro-symbol-effect`](references/micro-symbol-effect.md) — Use symbolEffect for SF Symbol animations
- [`micro-toggle-bounce`](references/micro-toggle-bounce.md) — Add bounce to toggle state changes
- [`micro-long-press-fill`](references/micro-long-press-fill.md) — Animate progressive fill for long press actions
- [`micro-loading-phase`](references/micro-loading-phase.md) — Use repeating spring for organic loading states

### 6. Content Motion (MEDIUM-HIGH)

- [`content-numeric-text`](references/content-numeric-text.md) — Use contentTransition(.numericText) for number changes
- [`content-scroll-transition`](references/content-scroll-transition.md) — Use scrollTransition for scroll-position effects
- [`content-visual-effect`](references/content-visual-effect.md) — Use visualEffect for position-aware animations
- [`content-symbol-replace`](references/content-symbol-replace.md) — Animate symbol replacement with contentTransition
- [`content-text-renderer`](references/content-text-renderer.md) — Use Text Renderer for character-level animation (iOS 18)

### 7. Orchestration (MEDIUM)

- [`orch-phase-animator`](references/orch-phase-animator.md) — Use PhaseAnimator for multi-step sequences
- [`orch-keyframe-animator`](references/orch-keyframe-animator.md) — Use KeyframeAnimator for timeline-precise motion
- [`orch-stagger-children`](references/orch-stagger-children.md) — Stagger child elements for orchestrated reveals
- [`orch-coordinated-entrance`](references/orch-coordinated-entrance.md) — Coordinate multi-element entrances with shared trigger
- [`orch-timeline-view`](references/orch-timeline-view.md) — Use TimelineView for continuous repeating animations

### 8. Craft & Polish (MEDIUM)

- [`craft-reduce-motion`](references/craft-reduce-motion.md) — Respect accessibilityReduceMotion with crossfade fallback
- [`craft-blur-bridge`](references/craft-blur-bridge.md) — Use blur to bridge imperfect transition states
- [`craft-drawing-group`](references/craft-drawing-group.md) — Use drawingGroup() for Metal-backed complex animations
- [`craft-geometry-group`](references/craft-geometry-group.md) — Use geometryGroup() to isolate layout animation propagation
- [`craft-transaction-debug`](references/craft-transaction-debug.md) — Use Transaction to debug and override animation behavior

## How to Use

Read individual reference files for detailed explanations with incorrect/correct code examples:

- [Section definitions](references/_sections.md) — Category structure and impact levels
- [Rule template](assets/templates/_template.md) — Template for adding new rules

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [metadata.json](metadata.json) | Version and reference information |
