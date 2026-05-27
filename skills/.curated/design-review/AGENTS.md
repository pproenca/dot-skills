# UI Design Review (React / CSS / Tailwind)

**Version 0.2.0**  
dot-skills  
May 2026

---

## Abstract

A design review for UI that reports findings as a prioritised Before/After/Why table across visual hierarchy, spacing, typography, colour and contrast, component states, motion, responsiveness, accessibility, multi-page flow and navigation, and interaction continuity — grounded in Refactoring UI and Emil Kowalski's design-engineering principles. Reviews static code (React/JSX, CSS, Tailwind) and, when the verdict turns on rendered behaviour, drives a real browser via chrome-devtools-mcp to measure animation timing, jank/FPS, focus order, the accessibility tree, and the multi-page flow that a screenshot cannot show.

---

## Table of Contents

1. [Visual Hierarchy](references/_sections.md#1-visual-hierarchy)
   - 1.1 [Establish one clear focal point per screen](references/hier-one-focal-point.md)
   - 1.2 [Limit each view to one primary action](references/hier-one-primary-action.md)
   - 1.3 [Make values louder than their labels](references/hier-values-over-labels.md)
   - 1.4 [Replace borders with spacing and background](references/hier-replace-borders-with-space.md)
   - 1.5 [Use colour and weight to set emphasis, not size alone](references/hier-emphasis-color-weight.md)
2. [Spacing & Layout](references/_sections.md#2-spacing-&-layout)
   - 2.1 [Cap and centre the page container width](references/space-constrain-measure.md)
   - 2.2 [Give layouts more whitespace than feels necessary](references/space-start-generous.md)
   - 2.3 [Size spacing from a consistent scale](references/space-use-a-scale.md)
   - 2.4 [Vary spacing to show what is grouped](references/space-proximity-groups.md)
3. [Typography](references/_sections.md#3-typography)
   - 3.1 [Align multi-line text to the left](references/type-left-align-prose.md)
   - 3.2 [Choose font sizes from a small type scale](references/type-modular-scale.md)
   - 3.3 [Keep body text large and solid enough to read](references/type-readable-body-size.md)
   - 3.4 [Limit body line length for readability](references/type-limit-line-length.md)
   - 3.5 [Set line-height relative to font size](references/type-line-height-by-size.md)
4. [Color & Contrast](references/_sections.md#4-color-&-contrast)
   - 4.1 [Define colour as HSL shade ramps](references/color-hsl-scales.md)
   - 4.2 [Limit the palette to one accent plus neutrals](references/color-limit-accents.md)
   - 4.3 [Meet WCAG contrast for body text](references/color-meet-contrast.md)
   - 4.4 [Pair colour with a second cue for state](references/color-not-only-signal.md)
   - 4.5 [Use a near-black instead of pure black](references/color-avoid-pure-black.md)
5. [Component States & Feedback](references/_sections.md#5-component-states-&-feedback)
   - 5.1 [Design every interactive state, not just the default](references/state-design-all-states.md)
   - 5.2 [Design the empty state with guidance](references/state-empty-state.md)
   - 5.3 [Give pressable elements active feedback](references/state-press-feedback.md)
   - 5.4 [Keep an accessible focus indicator](references/state-focus-visible.md)
6. [Motion & Animation](references/_sections.md#6-motion-&-animation)
   - 6.1 [Animate only transform and opacity](references/motion-transform-opacity-only.md)
   - 6.2 [Animate only with a purpose](references/motion-needs-purpose.md)
   - 6.3 [Enter from a near scale and the trigger's origin](references/motion-enter-origin-scale.md)
   - 6.4 [Keep UI transitions under 300ms](references/motion-under-300ms.md)
   - 6.5 [Use ease-out with a custom curve for UI transitions](references/motion-ease-out-custom.md)
7. [Responsiveness & Touch](references/_sections.md#7-responsiveness-&-touch)
   - 7.1 [Build mobile-first with fluid widths](references/resp-fluid-not-fixed.md)
   - 7.2 [Gate hover-only affordances behind a pointer query](references/resp-gate-hover.md)
   - 7.3 [Size touch targets to at least 44px](references/resp-touch-target-size.md)
8. [Accessibility & Semantics](references/_sections.md#8-accessibility-&-semantics)
   - 8.1 [Give icon-only controls an accessible name](references/access-name-icon-controls.md)
   - 8.2 [Honor the reduced-motion preference](references/access-respect-reduced-motion.md)
   - 8.3 [Use semantic elements for interactive controls](references/access-semantic-elements.md)
9. [Flow & Navigation](references/_sections.md#9-flow-&-navigation)
   - 9.1 [Keep the app shell consistent across pages](references/flow-consistent-shell.md)
   - 9.2 [Make every page work as a first entry point](references/flow-entry-point-integrity.md)
   - 9.3 [Preserve scroll and view state across navigation](references/flow-preserve-state-on-nav.md)
   - 9.4 [Show where the user is and the way back](references/flow-wayfinding.md)
10. [Interaction Continuity](references/_sections.md#10-interaction-continuity)
   - 10.1 [Bridge route changes so the screen never flashes blank](references/interact-bridge-route-transitions.md)
   - 10.2 [Fill the gap while an interaction is in flight](references/interact-feedback-spans-async.md)
   - 10.3 [Move focus to new content after client-side navigation](references/interact-move-focus-on-navigation.md)

---

## References

1. [https://www.refactoringui.com/](https://www.refactoringui.com/)
2. [https://medium.com/refactoring-ui/7-practical-tips-for-cheating-at-design-40c736799886](https://medium.com/refactoring-ui/7-practical-tips-for-cheating-at-design-40c736799886)
3. [https://emilkowal.ski/ui/great-animations](https://emilkowal.ski/ui/great-animations)
4. [https://emilkowal.ski/ui/good-vs-great-animations](https://emilkowal.ski/ui/good-vs-great-animations)
5. [https://emilkowal.ski/ui/you-dont-need-animations](https://emilkowal.ski/ui/you-dont-need-animations)
6. [https://practicaltypography.com/](https://practicaltypography.com/)
7. [https://www.w3.org/WAI/WCAG22/](https://www.w3.org/WAI/WCAG22/)
8. [https://developer.mozilla.org/en-US/docs/Web/CSS/:focus-visible](https://developer.mozilla.org/en-US/docs/Web/CSS/:focus-visible)
9. [https://developer.apple.com/design/human-interface-guidelines/layout](https://developer.apple.com/design/human-interface-guidelines/layout)
10. [https://www.nngroup.com/articles/ten-usability-heuristics/](https://www.nngroup.com/articles/ten-usability-heuristics/)
11. [https://www.nngroup.com/articles/breadcrumbs/](https://www.nngroup.com/articles/breadcrumbs/)
12. [https://www.nngroup.com/articles/response-times-3-important-limits/](https://www.nngroup.com/articles/response-times-3-important-limits/)
13. [https://developer.mozilla.org/en-US/docs/Web/API/History/scrollRestoration](https://developer.mozilla.org/en-US/docs/Web/API/History/scrollRestoration)
14. [https://developer.mozilla.org/en-US/docs/Web/API/History_API](https://developer.mozilla.org/en-US/docs/Web/API/History_API)
15. [https://developer.mozilla.org/en-US/docs/Web/API/View_Transition_API](https://developer.mozilla.org/en-US/docs/Web/API/View_Transition_API)
16. [https://www.gatsbyjs.com/blog/2019-07-11-user-testing-accessible-client-routing/](https://www.gatsbyjs.com/blog/2019-07-11-user-testing-accessible-client-routing/)
17. [https://github.com/ChromeDevTools/chrome-devtools-mcp](https://github.com/ChromeDevTools/chrome-devtools-mcp)
18. [https://github.com/steipete/agent-scripts/blob/main/skills/browser-use/mcporter-config.md](https://github.com/steipete/agent-scripts/blob/main/skills/browser-use/mcporter-config.md)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |