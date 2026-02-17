---
name: tailwind-ui-refactor
description: Refactoring UI design patterns for Tailwind CSS applications, informed by Apple's design philosophy, with a simplification-first bias. This skill should be used when writing, reviewing, or refactoring HTML with Tailwind utility classes to improve visual hierarchy, spacing, typography, color, depth, and polish while avoiding unnecessary boxes, wrappers, and decorative surfaces. Triggers on tasks involving UI cleanup, design review, Tailwind refactoring, component styling, visual improvements, or when the user wants UI that feels considered and crafted rather than generic.
---

# Refactoring UI Tailwind CSS Best Practices

Comprehensive UI refactoring guide based on Refactoring UI by Adam Wathan & Steve Schoger, implemented with Tailwind CSS utility classes. Informed by the design philosophy of Creative Selection (Ken Kocienda) and Design Like Apple (John Edson). Contains 62 rules across 12 categories, organized into three meta-layers — Empathy, Craft, and Taste — and prioritized by design impact.

**Core philosophy:** Rules produce competent UI. Taste produces remarkable UI. This skill teaches both: the mechanical transforms that fix common problems (Craft), the user understanding that prevents wrong problems from being solved (Empathy), and the judgment to know when rules don't apply (Taste).

**Important: Empathy first, craft second, taste always.** Before applying any visual rule, understand the user's task and emotional state. Then apply craft rules with care. Then step back and ask: does this feel right? A component that follows every rule but feels generic is worse than one that breaks a rule with conviction.

**Simplicity bias (non-negotiable):** When in doubt, remove instead of add. Prefer fewer wrappers, fewer visual surfaces, and fewer decorative treatments.

**Mandatory simplification gate (run before Depth, Borders, or Polish rules):**
- Remove at least one unnecessary wrapper or surface before adding new styling.
- Use typography and spacing first; add border, shadow, ring, or extra background only if it improves comprehension or interaction feedback.
- Keep one primary surface per logical region; avoid nested card-in-card patterns.
- If two treatments communicate the same thing, keep the lighter one.

## When to Apply

Reference these guidelines when:
- Refactoring existing Tailwind CSS components
- Writing new UI with Tailwind utility classes
- Reviewing code for visual hierarchy and spacing issues
- Improving design quality without a designer
- Fixing accessibility contrast problems
- Building UI that needs to feel considered, not just correct

## Rule Categories

Organized into three meta-layers: Empathy → Craft → Taste.

### Empathy — Understand the Person

Before touching CSS, understand the user's task and how they feel.

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Design Intent | CRITICAL | `intent-` |
| 2 | Emotional Context | CRITICAL | `emotion-` |

### Craft — Build with Care

The mechanical transforms that turn understanding into pixels.

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 3 | Visual Hierarchy | CRITICAL | `hier-` |
| 4 | Layout & Spacing | CRITICAL | `space-` |
| 5 | Typography | HIGH | `type-` |
| 6 | Color Systems | HIGH | `color-` |
| 7 | System Coherence | HIGH | `system-` |
| 8 | Depth & Shadows | MEDIUM | `depth-` |
| 9 | Borders & Separation | MEDIUM | `sep-` |
| 10 | Images & Content | LOW-MEDIUM | `img-` |

### Taste — Select the Best

After applying craft rules, step back: generate alternatives, evaluate tradeoffs, and have the conviction to break rules when they don't serve the user.

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 11 | Polish & Delight | LOW | `polish-` |
| 12 | Taste & Judgment | CRITICAL | `taste-` |

## Quick Reference

### 1. Design Intent (CRITICAL)

- [`intent-audit-before-styling`](references/intent-audit-before-styling.md) - Audit what each element communicates before changing any CSS
- [`intent-remove-before-decorating`](references/intent-remove-before-decorating.md) - Remove unnecessary elements before styling what remains
- [`intent-reduce-cognitive-load`](references/intent-reduce-cognitive-load.md) - Reduce choices per screen — fewer options beat prettier options
- [`intent-progressive-disclosure`](references/intent-progressive-disclosure.md) - Hide secondary information behind interactions
- [`intent-content-drives-layout`](references/intent-content-drives-layout.md) - Let real content determine layout — not the other way around
- [`intent-simplify-over-decorate`](references/intent-simplify-over-decorate.md) - Prefer removing a wrapper over adding 5 utility classes to it
- [`intent-match-context-fidelity`](references/intent-match-context-fidelity.md) - Match design polish to context and emotional state
- [`intent-match-existing-patterns`](references/intent-match-existing-patterns.md) - Audit sibling component patterns before restyling

### 2. Emotional Context (CRITICAL)

- [`emotion-design-for-emotional-state`](references/emotion-design-for-emotional-state.md) - Design for the user's emotional state, not just their task

### 3. Visual Hierarchy (CRITICAL)

- [`hier-size-weight-color`](references/hier-size-weight-color.md) - Use size, weight, and color for hierarchy — not just size
- [`hier-deemphasize-secondary`](references/hier-deemphasize-secondary.md) - De-emphasize secondary content instead of emphasizing primary
- [`hier-button-hierarchy`](references/hier-button-hierarchy.md) - Style buttons by visual hierarchy, not semantic importance
- [`hier-label-value-pairs`](references/hier-label-value-pairs.md) - Combine labels and values into natural language
- [`hier-semantic-vs-visual`](references/hier-semantic-vs-visual.md) - Separate visual hierarchy from document hierarchy
- [`hier-icon-sizing`](references/hier-icon-sizing.md) - Size icons relative to adjacent text, not to fill space
- [`hier-color-hierarchy-on-dark`](references/hier-color-hierarchy-on-dark.md) - Use opacity or muted colors for hierarchy on colored backgrounds

### 4. Layout & Spacing (CRITICAL)

- [`space-start-generous`](references/space-start-generous.md) - Start with too much whitespace, then remove
- [`space-systematic-scale`](references/space-systematic-scale.md) - Use a constrained spacing scale, not arbitrary values
- [`space-relationship-proximity`](references/space-relationship-proximity.md) - Use spacing to show relationships between elements
- [`space-dont-fill-screen`](references/space-dont-fill-screen.md) - Constrain content width — avoid filling the whole screen
- [`space-grids-not-required`](references/space-grids-not-required.md) - Use fixed widths when grids are not needed
- [`space-relative-sizing-fails`](references/space-relative-sizing-fails.md) - Avoid raw viewport units without clamping
- [`space-mobile-first`](references/space-mobile-first.md) - Design mobile-first at ~400px, then expand

### 5. Typography (HIGH)

- [`type-line-length`](references/type-line-length.md) - Keep line length between 45-75 characters
- [`type-line-height-inverse`](references/type-line-height-inverse.md) - Line height and font size are inversely proportional
- [`type-font-weight-variety`](references/type-font-weight-variety.md) - Choose fonts with at least 5 weight variations
- [`type-no-center-long-text`](references/type-no-center-long-text.md) - Left-align body content — avoid centering long-form text
- [`type-letter-spacing`](references/type-letter-spacing.md) - Tighten letter spacing for headlines, loosen for uppercase
- [`type-align-numbers-right`](references/type-align-numbers-right.md) - Align numbers right in tables for easy comparison

### 6. Color Systems (HIGH)

- [`color-define-palette-upfront`](references/color-define-palette-upfront.md) - Define a complete color palette upfront — don't pick colors ad-hoc
- [`color-grayscale-first`](references/color-grayscale-first.md) - Design in grayscale first, add color last
- [`color-accessible-contrast`](references/color-accessible-contrast.md) - Ensure 4.5:1 contrast ratio for body text
- [`color-dark-gray-not-black`](references/color-dark-gray-not-black.md) - Use dark gray instead of pure black for text
- [`color-saturated-grays`](references/color-saturated-grays.md) - Add subtle saturation to grays for warmth or coolness
- [`color-light-backgrounds-dark-text`](references/color-light-backgrounds-dark-text.md) - Use light-colored backgrounds with dark text for badges

### 7. System Coherence (HIGH)

- [`system-design-tokens-first`](references/system-design-tokens-first.md) - Establish design tokens before writing component code
- [`system-brand-voice-consistency`](references/system-brand-voice-consistency.md) - Decide your visual voice once — radius, shadows, spacing — then defend it
- [`system-transitions-communicate`](references/system-transitions-communicate.md) - Use transitions to acknowledge user actions, not to decorate

### 8. Depth & Shadows (MEDIUM)

- [`depth-shadow-scale`](references/depth-shadow-scale.md) - Define a fixed shadow scale — small to extra large
- [`depth-shadow-vertical-offset`](references/depth-shadow-vertical-offset.md) - Use vertical offset for natural-looking shadows
- [`depth-interactive-elevation`](references/depth-interactive-elevation.md) - Use shadow changes to communicate interactivity
- [`depth-light-closer-dark-recedes`](references/depth-light-closer-dark-recedes.md) - Lighter colors feel closer, darker colors recede
- [`depth-overlap-layers`](references/depth-overlap-layers.md) - Overlap elements to create visual layers

### 9. Borders & Separation (MEDIUM)

- [`sep-fewer-borders`](references/sep-fewer-borders.md) - Use fewer borders — replace with spacing, shadows, or background color
- [`sep-background-color-separation`](references/sep-background-color-separation.md) - Use background color differences to separate sections
- [`sep-table-spacing-not-lines`](references/sep-table-spacing-not-lines.md) - Use spacing instead of lines in simple tables
- [`sep-card-radio-buttons`](references/sep-card-radio-buttons.md) - Keep standard radios by default; only use card-style radios for high-stakes choices with supporting descriptions

### 10. Images & Content (LOW-MEDIUM)

- [`img-control-user-content`](references/img-control-user-content.md) - Control user-uploaded image size and aspect ratio
- [`img-text-overlay`](references/img-text-overlay.md) - Add overlays or reduce contrast for text over images
- [`img-dont-scale-up-icons`](references/img-dont-scale-up-icons.md) - Avoid scaling up icons designed for small sizes
- [`img-empty-states`](references/img-empty-states.md) - Design meaningful empty states with clear CTAs

### 11. Polish & Delight (LOW)

- [`polish-accent-borders`](references/polish-accent-borders.md) - Use accent borders sparingly, only when simpler hierarchy signals are insufficient
- [`polish-custom-bullets`](references/polish-custom-bullets.md) - Replace default bullets with icons or checkmarks
- [`polish-border-radius-personality`](references/polish-border-radius-personality.md) - Choose your border radius with conviction and apply it everywhere
- [`polish-gradient-close-hues`](references/polish-gradient-close-hues.md) - Use gradients with hues within 30 degrees of each other
- [`polish-inner-shadow-images`](references/polish-inner-shadow-images.md) - Add inner shadow to prevent image background bleed
- [`polish-product-is-marketing`](references/polish-product-is-marketing.md) - Treat every pixel as marketing — the product sells itself through quality

### 12. Taste & Judgment (CRITICAL)

- [`taste-generate-variants`](references/taste-generate-variants.md) - Generate 2-3 visual variants before committing to one
- [`taste-demo-at-three-sizes`](references/taste-demo-at-three-sizes.md) - Demo every component at 320px, 768px, and 1440px before finalizing
- [`taste-break-rules-with-conviction`](references/taste-break-rules-with-conviction.md) - Break rules when breaking them better serves the user
- [`taste-feel-over-formula`](references/taste-feel-over-formula.md) - Trust your felt sense — if something feels off, investigate
- [`taste-know-when-done`](references/taste-know-when-done.md) - Stop when nothing more can be removed — not when everything has been added

## How to Use

Use this order of operations:

1. Run Design Intent rules first, especially `intent-remove-before-decorating` and `intent-simplify-over-decorate`.
2. Establish hierarchy, spacing, and typography before adding visual containers.
3. Add separation/depth only where users need faster scanning or clearer interaction feedback.
4. Apply polish rules last and sparingly; skip them if the UI already feels clear and coherent.
5. Stop when no additional class or wrapper improves task clarity.

Read individual reference files for detailed explanations and code examples:

- [Section definitions](references/_sections.md) - Category structure, meta-layers, and impact levels
- [Rule template](assets/templates/_template.md) - Template for adding new rules

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [metadata.json](metadata.json) | Version and reference information |
