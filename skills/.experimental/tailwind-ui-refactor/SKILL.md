---
name: tailwind-ui-refactor
description: Refactoring UI design patterns for Tailwind CSS applications. This skill should be used when writing, reviewing, or refactoring HTML with Tailwind utility classes to improve visual hierarchy, spacing, typography, color, depth, and polish. Triggers on tasks involving UI cleanup, design review, Tailwind refactoring, component styling, or visual improvements.
---

# Refactoring UI Tailwind CSS Best Practices

Comprehensive UI refactoring guide based on Refactoring UI by Adam Wathan & Steve Schoger, implemented with Tailwind CSS utility classes. Contains 44 rules across 8 categories, prioritized by visual impact to guide automated refactoring and code generation.

## When to Apply

Reference these guidelines when:
- Refactoring existing Tailwind CSS components
- Writing new UI with Tailwind utility classes
- Reviewing code for visual hierarchy and spacing issues
- Improving design quality without a designer
- Fixing accessibility contrast problems

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Visual Hierarchy | CRITICAL | `hier-` |
| 2 | Layout & Spacing | CRITICAL | `space-` |
| 3 | Typography | HIGH | `type-` |
| 4 | Color Systems | HIGH | `color-` |
| 5 | Depth & Shadows | MEDIUM | `depth-` |
| 6 | Borders & Separation | MEDIUM | `sep-` |
| 7 | Images & Content | LOW-MEDIUM | `img-` |
| 8 | Polish & Details | LOW | `polish-` |

## Quick Reference

### 1. Visual Hierarchy (CRITICAL)

- [`hier-size-weight-color`](references/hier-size-weight-color.md) - Use size, weight, and color for hierarchy — not just size
- [`hier-deemphasize-secondary`](references/hier-deemphasize-secondary.md) - De-emphasize secondary content instead of emphasizing primary
- [`hier-button-hierarchy`](references/hier-button-hierarchy.md) - Style buttons by visual hierarchy, not semantic importance
- [`hier-label-value-pairs`](references/hier-label-value-pairs.md) - Combine labels and values into natural language
- [`hier-semantic-vs-visual`](references/hier-semantic-vs-visual.md) - Separate visual hierarchy from document hierarchy
- [`hier-icon-sizing`](references/hier-icon-sizing.md) - Size icons relative to adjacent text, not to fill space
- [`hier-color-hierarchy-on-dark`](references/hier-color-hierarchy-on-dark.md) - Use opacity or muted colors for hierarchy on colored backgrounds

### 2. Layout & Spacing (CRITICAL)

- [`space-start-generous`](references/space-start-generous.md) - Start with too much whitespace, then remove
- [`space-systematic-scale`](references/space-systematic-scale.md) - Use a constrained spacing scale, not arbitrary values
- [`space-relationship-proximity`](references/space-relationship-proximity.md) - Use spacing to show relationships between elements
- [`space-dont-fill-screen`](references/space-dont-fill-screen.md) - Don't fill the whole screen — constrain content width
- [`space-grids-not-required`](references/space-grids-not-required.md) - Don't force everything into a grid — use fixed widths
- [`space-relative-sizing-fails`](references/space-relative-sizing-fails.md) - Avoid viewport-relative units for element sizing
- [`space-mobile-first`](references/space-mobile-first.md) - Design mobile-first at ~400px, then expand

### 3. Typography (HIGH)

- [`type-line-length`](references/type-line-length.md) - Keep line length between 45-75 characters
- [`type-line-height-inverse`](references/type-line-height-inverse.md) - Line height and font size are inversely proportional
- [`type-font-weight-variety`](references/type-font-weight-variety.md) - Choose fonts with at least 5 weight variations
- [`type-no-center-long-text`](references/type-no-center-long-text.md) - Don't center long-form text — left-align body content
- [`type-letter-spacing`](references/type-letter-spacing.md) - Tighten letter spacing for headlines, loosen for uppercase
- [`type-align-numbers-right`](references/type-align-numbers-right.md) - Right-align numbers in tables for easy comparison

### 4. Color Systems (HIGH)

- [`color-define-palette-upfront`](references/color-define-palette-upfront.md) - Define a complete color palette upfront — don't pick colors ad-hoc
- [`color-grayscale-first`](references/color-grayscale-first.md) - Design in grayscale first, add color last
- [`color-accessible-contrast`](references/color-accessible-contrast.md) - Ensure 4.5:1 contrast ratio for body text
- [`color-dark-gray-not-black`](references/color-dark-gray-not-black.md) - Use dark gray instead of pure black for text
- [`color-saturated-grays`](references/color-saturated-grays.md) - Add subtle saturation to grays for warmth or coolness
- [`color-light-backgrounds-dark-text`](references/color-light-backgrounds-dark-text.md) - Use light-colored backgrounds with dark text for badges

### 5. Depth & Shadows (MEDIUM)

- [`depth-shadow-scale`](references/depth-shadow-scale.md) - Define a fixed shadow scale — small to extra large
- [`depth-shadow-vertical-offset`](references/depth-shadow-vertical-offset.md) - Use vertical offset for natural-looking shadows
- [`depth-interactive-elevation`](references/depth-interactive-elevation.md) - Use shadow changes to communicate interactivity
- [`depth-light-closer-dark-recedes`](references/depth-light-closer-dark-recedes.md) - Lighter colors feel closer, darker colors recede
- [`depth-overlap-layers`](references/depth-overlap-layers.md) - Overlap elements to create visual layers

### 6. Borders & Separation (MEDIUM)

- [`sep-fewer-borders`](references/sep-fewer-borders.md) - Use fewer borders — replace with spacing, shadows, or background color
- [`sep-background-color-separation`](references/sep-background-color-separation.md) - Use background color differences to separate sections
- [`sep-table-spacing-not-lines`](references/sep-table-spacing-not-lines.md) - Use spacing instead of lines in simple tables
- [`sep-card-radio-buttons`](references/sep-card-radio-buttons.md) - Convert radio buttons and checkboxes to selectable cards

### 7. Images & Content (LOW-MEDIUM)

- [`img-control-user-content`](references/img-control-user-content.md) - Control user-uploaded image size and aspect ratio
- [`img-text-overlay`](references/img-text-overlay.md) - Add overlays or reduce contrast for text over images
- [`img-dont-scale-up-icons`](references/img-dont-scale-up-icons.md) - Don't scale up icons designed for small sizes
- [`img-empty-states`](references/img-empty-states.md) - Design meaningful empty states with clear CTAs

### 8. Polish & Details (LOW)

- [`polish-accent-borders`](references/polish-accent-borders.md) - Add accent borders to highlight important elements
- [`polish-custom-bullets`](references/polish-custom-bullets.md) - Replace default bullets with icons or checkmarks
- [`polish-border-radius-personality`](references/polish-border-radius-personality.md) - Match border radius to brand personality
- [`polish-gradient-close-hues`](references/polish-gradient-close-hues.md) - Use gradients with hues within 30 degrees of each other
- [`polish-inner-shadow-images`](references/polish-inner-shadow-images.md) - Add inner shadow to prevent image background bleed

## How to Use

Read individual reference files for detailed explanations and code examples:

- [Section definitions](references/_sections.md) - Category structure and impact levels
- [Rule template](assets/templates/_template.md) - Template for adding new rules

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [metadata.json](metadata.json) | Version and reference information |
