---
name: design-review
description: Use this skill to run a structured design review of UI — existing code (React/JSX, CSS, Tailwind) and, when behaviour matters, the running app in a real browser — reported as a prioritised Before / After / Why table. Trigger when the user asks to "review this UI", "design review", "critique this component/screen/page or multi-page flow", asks why something "looks off", "looks AI-generated", or "looks like a wireframe", or wants to raise visual polish. Covers visual hierarchy, spacing, typography, colour & contrast, component states, motion, responsiveness, accessibility, multi-page flow & navigation, and interaction continuity — grounded in Refactoring UI and Emil Kowalski's principles. For animation/jank/FPS, focus order, and cross-page UX it can drive Chrome via chrome-devtools-mcp to capture what a screenshot can't. For building UI from scratch use web-taste; for the full animation set see emilkowal-animations.
---

# Design Review

Conduct a design review of UI **code** and return a prioritised critique. The reviewer's lens is Emil Kowalski's design-engineering philosophy — *taste is the differentiator; the unseen details compound; show the eye where to look* — made concrete with the heuristics from Refactoring UI, WCAG, and MDN.

This is a **read-only review skill**: it diagnoses and proposes fixes; it does not rewrite the codebase. Each finding names the wrong default the code fell into, the exact fix, and why it matters.

## When to Apply

- The user asks to "review this UI", run a "design review", or "critique" a component, screen, or page.
- The user says the output "looks off", "looks AI-generated", "looks like a wireframe", or "feels generic", and wants to know why.
- A PR touches CSS/JSX/Tailwind and the user wants design feedback before merge.
- The user wants to raise the visual polish or accessibility of an existing interface.

Not for building UI from scratch (use `web-taste`) or for the exhaustive animation rule set (use `emilkowal-animations`).

## How to Run the Review

**Two modes.** A *static* review reads the code and is the default. A *runtime* review additionally drives a real browser to measure what the code can't show — animation timing and dropped frames, layout shift, the live focus order and accessibility tree, and the multi-page flow clicked through end to end. Switch to runtime whenever the verdict turns on rendered behaviour (the `motion-`, `interact-`, and `flow-` categories), per [runtime-capture.md](references/_runtime-capture.md).

1. **Orient — the 0.5-second test.** Before reading line by line, picture the rendered screen. Where does the eye land first? Is there a single focal point, or does everything carry equal weight? This frames which categories matter most for *this* UI.
2. **Pass the categories in priority order** (table below). For each decision the code makes, read the matching reference file and check the code against it. Visual hierarchy and spacing are where the largest, most frequent problems live — start there.
3. **For multi-page or interaction-driven UX, walk it in a browser.** When the brief is a flow ("review this onboarding") or the issue is felt in motion (jank, blank route flashes, lost focus), capture runtime evidence per [runtime-capture.md](references/_runtime-capture.md) so the Before column is a measured value, not a guess.
4. **Record each problem as a finding** with a Before (the exact code or measurement), an After (the concrete fix), a Why (the principle), and a context-assigned **Severity**.
5. **Close with a verdict**: the top 3 fixes, ranked by impact, so the author knows what to change first.

## Output Format (Required)

Report findings as a **single markdown table**, one row per issue. Do **not** write findings as prose or as `Before:` / `After:` on separate lines.

| Severity | Before | After | Why |
| --- | --- | --- | --- |
| High | `transition: all 300ms ease-in` | `transition: opacity 180ms cubic-bezier(0.23, 1, 0.32, 1)` | `ease-in` feels sluggish on entry; name the property and use a strong ease-out curve |
| High | every button `bg-indigo-600` | one filled primary; others ghost/outline | Equal-weight buttons compete; one primary makes the next step obvious |
| Medium | `color: #000` on `#fff` | `color: hsl(222 47% 11%)` | Pure black is harsher than ink and reads as stark |
| Critical | `<div onClick={remove}>` | `<button type="button" onClick={remove}>` | A div is unreachable by keyboard and invisible to screen readers |

**Wrong format — never do this:**

```text
Before: transition: all 300ms
After: transition: opacity 180ms ease-out
────────────────────────────
Before: color #000
After: color slate-900
```

**Severity guide** (assigned per finding, by impact in this UI):

| Severity | Meaning |
| --- | --- |
| Critical | Breaks usability or accessibility — fails contrast, no keyboard access, unreadable text |
| High | Clearly damages the design — no hierarchy, cramped spacing, competing primary actions |
| Medium | Noticeable polish gap — default easing, uniform line-height, missing press feedback |
| Low | Minor refinement — a value slightly off the scale |

Finish with: **Top 3 fixes** — the highest-impact rows, in the order the author should tackle them.

## Rule Categories

| # | Category | Prefix | Covers |
|---|----------|--------|--------|
| 1 | Visual Hierarchy | `hier-` | Focal point, emphasis technique, one primary action, value-over-label, space over borders |
| 2 | Spacing & Layout | `space-` | Spacing scale, generous whitespace, proximity grouping, constrained width |
| 3 | Typography | `type-` | Type scale, line length, line-height, alignment, readable body text |
| 4 | Colour & Contrast | `color-` | Near-black text, WCAG contrast, HSL ramps, restrained accents, colour-plus-cue |
| 5 | Component States & Feedback | `state-` | Press feedback, focus-visible, the full state matrix, empty states |
| 6 | Motion & Animation | `motion-` | Purpose/frequency, ease-out curves, sub-300ms, enter origin/scale, transform-only |
| 7 | Responsiveness & Touch | `resp-` | Fluid mobile-first, 44px targets, gating hover |
| 8 | Accessibility & Semantics | `access-` | Semantic elements, accessible names, reduced-motion |
| 9 | Flow & Navigation | `flow-` | App-shell consistency, view-state persistence, entry-point integrity, wayfinding |
| 10 | Interaction Continuity | `interact-` | Bridging route transitions, async feedback, focus on navigation |

## Quick Reference

### 1. Visual Hierarchy (`hier-`)

- [`hier-one-focal-point`](references/hier-one-focal-point.md) — Establish one clear focal point per screen
- [`hier-emphasis-color-weight`](references/hier-emphasis-color-weight.md) — Use colour and weight to set emphasis, not size alone
- [`hier-one-primary-action`](references/hier-one-primary-action.md) — Limit each view to one primary action
- [`hier-values-over-labels`](references/hier-values-over-labels.md) — Make values louder than their labels
- [`hier-replace-borders-with-space`](references/hier-replace-borders-with-space.md) — Replace borders with spacing and background

### 2. Spacing & Layout (`space-`)

- [`space-use-a-scale`](references/space-use-a-scale.md) — Size spacing from a consistent scale
- [`space-start-generous`](references/space-start-generous.md) — Give layouts more whitespace than feels necessary
- [`space-proximity-groups`](references/space-proximity-groups.md) — Vary spacing to show what is grouped
- [`space-constrain-measure`](references/space-constrain-measure.md) — Cap and centre the page container width

### 3. Typography (`type-`)

- [`type-modular-scale`](references/type-modular-scale.md) — Choose font sizes from a small type scale
- [`type-limit-line-length`](references/type-limit-line-length.md) — Limit body line length for readability
- [`type-line-height-by-size`](references/type-line-height-by-size.md) — Set line-height relative to font size
- [`type-left-align-prose`](references/type-left-align-prose.md) — Align multi-line text to the left
- [`type-readable-body-size`](references/type-readable-body-size.md) — Keep body text large and solid enough to read

### 4. Colour & Contrast (`color-`)

- [`color-avoid-pure-black`](references/color-avoid-pure-black.md) — Use a near-black instead of pure black
- [`color-meet-contrast`](references/color-meet-contrast.md) — Meet WCAG contrast for body text
- [`color-hsl-scales`](references/color-hsl-scales.md) — Define colour as HSL shade ramps
- [`color-limit-accents`](references/color-limit-accents.md) — Limit the palette to one accent plus neutrals
- [`color-not-only-signal`](references/color-not-only-signal.md) — Pair colour with a second cue for state

### 5. Component States & Feedback (`state-`)

- [`state-press-feedback`](references/state-press-feedback.md) — Give pressable elements active feedback
- [`state-focus-visible`](references/state-focus-visible.md) — Keep an accessible focus indicator
- [`state-design-all-states`](references/state-design-all-states.md) — Design every interactive state, not just the default
- [`state-empty-state`](references/state-empty-state.md) — Design the empty state with guidance

### 6. Motion & Animation (`motion-`)

- [`motion-needs-purpose`](references/motion-needs-purpose.md) — Animate only with a purpose
- [`motion-ease-out-custom`](references/motion-ease-out-custom.md) — Use ease-out with a custom curve for UI transitions
- [`motion-under-300ms`](references/motion-under-300ms.md) — Keep UI transitions under 300ms
- [`motion-enter-origin-scale`](references/motion-enter-origin-scale.md) — Enter from a near scale and the trigger's origin
- [`motion-transform-opacity-only`](references/motion-transform-opacity-only.md) — Animate only transform and opacity

For drag, gestures, springs, stagger, clip-path, and the full timing/easing tables, defer to the `emilkowal-animations` skill.

### 7. Responsiveness & Touch (`resp-`)

- [`resp-fluid-not-fixed`](references/resp-fluid-not-fixed.md) — Build mobile-first with fluid widths
- [`resp-touch-target-size`](references/resp-touch-target-size.md) — Size touch targets to at least 44px
- [`resp-gate-hover`](references/resp-gate-hover.md) — Gate hover-only affordances behind a pointer query

### 8. Accessibility & Semantics (`access-`)

- [`access-semantic-elements`](references/access-semantic-elements.md) — Use semantic elements for interactive controls
- [`access-name-icon-controls`](references/access-name-icon-controls.md) — Give icon-only controls an accessible name
- [`access-respect-reduced-motion`](references/access-respect-reduced-motion.md) — Honor the reduced-motion preference

### 9. Flow & Navigation (`flow-`)

Reviews the experience *across* pages, which single-screen review can't see. Walk the flow in a browser ([runtime-capture.md](references/_runtime-capture.md)).

- [`flow-consistent-shell`](references/flow-consistent-shell.md) — Keep the app shell consistent across pages
- [`flow-preserve-state-on-nav`](references/flow-preserve-state-on-nav.md) — Preserve scroll and view state across navigation
- [`flow-entry-point-integrity`](references/flow-entry-point-integrity.md) — Make every page work as a first entry point
- [`flow-wayfinding`](references/flow-wayfinding.md) — Show where the user is and the way back

### 10. Interaction Continuity (`interact-`)

Reviews whether the experience stays continuous over time and across transitions — the dimension a screenshot can't show. Best judged against a captured trace ([runtime-capture.md](references/_runtime-capture.md)).

- [`interact-bridge-route-transitions`](references/interact-bridge-route-transitions.md) — Bridge route changes so the screen never flashes blank
- [`interact-feedback-spans-async`](references/interact-feedback-spans-async.md) — Fill the gap while an interaction is in flight
- [`interact-move-focus-on-navigation`](references/interact-move-focus-on-navigation.md) — Move focus to new content after client-side navigation

## How to Use

Read a reference file when its decision comes up in the code under review. Each rule names the wrong default it corrects, then shows the canonical fix (with an Incorrect/Correct contrast only where the wrong way is a real trap). Cite the rule slug in the "Why" column so the author can follow up.

- [Runtime capture](references/_runtime-capture.md) — drive a real browser (chrome-devtools-mcp) to measure motion, jank, focus order, and multi-page flow when a static read isn't enough
- [Section definitions](references/_sections.md) — category structure and order
- [Rule template](assets/templates/_template.md) — for adding new rules
- [AGENTS.md](AGENTS.md) — auto-built table of contents across all rules

## Related Skills

- `emilkowal-animations` — the exhaustive animation rule set (easing, gestures, springs, stagger); this skill defers motion depth to it.
- `web-taste` — building React/Next/Tailwind UI with taste from the ground up (the build counterpart to this review).
- `tailwind-ui-refactor` — applying these fixes as Tailwind refactors.
- `ui-design` — broader build-time frontend reference (Core Web Vitals, forms, dark mode). Where the two overlap (semantics, contrast, focus, single primary action), reach for `ui-design` while authoring and `design-review` while reviewing.

## Reference Files

| File | Description |
|------|-------------|
| [references/_runtime-capture.md](references/_runtime-capture.md) | Browser-driven capture playbook (chrome-devtools-mcp via mcporter) |
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [metadata.json](metadata.json) | Version and source references |
