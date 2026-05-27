# Sections

This file defines the categories and their order. The prefix in parentheses is
the filename prefix that groups rules. Categories are ordered by **importance ×
frequency** — the dimensions that most often make UI look generic, unfinished, or
AI-generated go first. This is a taste/correctness skill, not a performance one,
so categories carry no fixed impact tier: assign each *finding* a severity at
review time based on its impact in that specific UI.

---

## 1. Visual Hierarchy (hier)

**Description:** Whether the screen tells the eye where to look first. The single biggest reason an interface reads as "flat" or "wireframe-like" is that everything carries equal weight. Covers focal point, de-emphasis technique, primary-action dominance, and separating with space instead of borders.

## 2. Spacing & Layout (space)

**Description:** How elements are sized and grouped in space. Arbitrary, cramped, or uniform spacing destroys rhythm and hides the relationships between elements. Covers spacing scales, generous whitespace, proximity grouping, and constraining content width.

## 3. Typography (type)

**Description:** How text is sized, set, and aligned for reading. Ad-hoc font sizes, unbounded line length, and uniform line-height are the typographic tells of unconsidered UI. Covers type scales, measure, line-height, alignment, and readable body text.

## 4. Color & Contrast (color)

**Description:** Color choices that affect legibility, mood, and accessibility. Pure black, low-contrast grey, one-off hex values, and over-saturation all signal a missing system. Covers near-black text, WCAG contrast, HSL shade ramps, restrained accents, and never relying on color alone.

## 5. Component States & Feedback (state)

**Description:** Whether interactive elements respond and whether every state is designed. Default UI ships only the happy path — no press feedback, no focus ring, no empty/loading/error states. Covers active feedback, accessible focus, the full state matrix, and empty states.

## 6. Motion & Animation (motion)

**Description:** Whether motion has a purpose and is executed with the right easing, timing, and properties. The top review flags for animation; defer to the emilkowal-animations skill for the full rule set. Covers purpose/frequency, ease-out custom curves, sub-300ms timing, enter origin/scale, and animating only transform/opacity.

## 7. Responsiveness & Touch (resp)

**Description:** Whether the layout adapts and whether it works under a finger. Fixed pixel widths, sub-44px targets, and hover-only affordances break on real devices. Covers fluid mobile-first layout, touch target size, and gating hover interactions.

## 8. Accessibility & Semantics (access)

**Description:** Whether the markup conveys meaning and the experience is usable assistively. The structural accessibility wrong-defaults not already caught by color, state, or responsiveness. Covers semantic elements, accessible names for icon controls, and honoring reduced-motion preferences.

## 9. Flow & Navigation (flow)

**Description:** Whether the experience holds together *across* pages, not just within one screen. Single-screen review can't see that the app shell drifts route to route, that navigation drops the user's scroll and filters, that a deep link or refresh renders a broken page, or that users can't tell where they are. Reviewed by walking the multi-page flow (see `_runtime-capture.md`). Covers app-shell consistency, view-state persistence, entry-point integrity, and wayfinding.

## 10. Interaction Continuity (interact)

**Description:** Whether the experience stays continuous *over time and across transitions* as the user interacts — the dimension a screenshot cannot show. Distinct from `state` (how one control *looks* in each state): this is whether the bridge *between* states and views holds — route changes that flash blank, async actions that leave a dead interval, and navigations that strand keyboard/AT focus. Best reviewed against a captured trace or recording (see `_runtime-capture.md`). Covers bridging route transitions, spanning async feedback, and moving focus on navigation.
