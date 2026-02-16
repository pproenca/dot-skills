# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Spring Physics (spring)

**Impact:** CRITICAL
**Description:** Springs are the universal iOS animation primitive — the only animation type that preserves velocity on interruption. Motion tokens (enum Motion) standardize spring selection across the app, preventing scattered .smooth/.snappy/.bouncy literals. Wrong spring choice cascades through the entire app's tactile quality. Airbnb tokenizes motion values as part of their DLS.

## 2. Timing & Feel (feel)

**Impact:** CRITICAL
**Description:** Duration and rhythm determine perceived responsiveness. Animations over 250ms feel sluggish, symmetric enter/exit feels robotic, and unsynchronized haptics break immersion. Getting timing wrong makes a fast app feel slow.

## 3. Gesture Continuity (gesture)

**Impact:** HIGH
**Description:** The touch-to-motion connection is what makes iOS feel alive. Rubber banding, velocity preservation, interruptibility, and momentum dismissal transform rigid state machines into fluid physical interfaces.

## 4. Spatial Transitions (spatial)

**Impact:** HIGH
**Description:** Every view change needs a spatial origin. Without one, elements teleport — breaking the user's mental model of where content lives. matchedGeometryEffect, zoom transitions, and navigation morphs maintain spatial continuity.

## 5. Micro-interactions (micro)

**Impact:** HIGH
**Description:** Button press scale, haptic pairing, symbol effects, and toggle animations. These sub-second moments accumulate into the overall sensation of quality — or cheapness. Apple's own apps obsess over these details.

## 6. Orchestration (orch)

**Impact:** HIGH
**Description:** When multiple elements animate, they must form a choreography — not a mob. PhaseAnimator, KeyframeAnimator, and staggered reveals create the composed, intentional motion that distinguishes premium apps like Airbnb's Host Passport. Complex animation state orchestration should use @Observable ViewModels per swift-ui-architect constraints.

## 7. Craft & Polish (craft)

**Impact:** HIGH
**Description:** Respecting reduce motion (accessibility requirement, not polish), blur bridging imperfect states, Metal-backed rendering for complex scenes, and layout animation isolation. These patterns are essential for production-quality animation — 35% of adults experience motion sensitivity.

## 8. Content Motion (content)

**Impact:** MEDIUM-HIGH
**Description:** Numbers that roll, text that morphs, symbols that replace, scroll items that react to position. Making content changes feel physical rather than digital eliminates the "database on a screen" feel.
