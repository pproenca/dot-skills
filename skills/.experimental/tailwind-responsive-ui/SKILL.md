---
name: tailwind-responsive-ui
description: Responsive UI transformation patterns for Tailwind CSS applications. This skill should be used when making interfaces responsive, refactoring layouts for multiple screen sizes, or reviewing responsive Tailwind code. Triggers on tasks involving breakpoint strategy, layout adaptation, responsive spacing, fluid typography, mobile navigation, touch interaction, responsive media, or data table responsiveness.
---

# Community Responsive UI Tailwind CSS Best Practices

Comprehensive responsive transformation guide for Tailwind CSS applications, based on Refactoring UI by Adam Wathan & Steve Schoger and modern responsive design patterns. Contains 49 rules across 8 categories, prioritized by impact to guide automated refactoring and code generation.

## When to Apply

Reference these guidelines when:
- Making an existing UI responsive across screen sizes
- Building new responsive layouts with Tailwind CSS
- Refactoring desktop-only interfaces for mobile support
- Reviewing responsive code for breakpoint, spacing, and typography issues
- Adapting navigation, forms, and data tables for touch devices

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Breakpoint Strategy | CRITICAL | `bp-` |
| 2 | Layout Transformation | CRITICAL | `layout-` |
| 3 | Responsive Spacing | HIGH | `rspac-` |
| 4 | Fluid Typography | HIGH | `fluid-` |
| 5 | Navigation Patterns | MEDIUM-HIGH | `nav-` |
| 6 | Touch & Interaction | MEDIUM | `touch-` |
| 7 | Responsive Media | MEDIUM | `rmedia-` |
| 8 | Data Adaptation | LOW-MEDIUM | `data-` |

## Quick Reference

### 1. Breakpoint Strategy (CRITICAL)

- [`bp-mobile-first-default`](references/bp-mobile-first-default.md) - Use Mobile-First Breakpoint Direction
- [`bp-content-driven-breakpoints`](references/bp-content-driven-breakpoints.md) - Set Breakpoints Where Content Breaks
- [`bp-avoid-device-widths`](references/bp-avoid-device-widths.md) - Avoid Device-Specific Breakpoint Values
- [`bp-consolidate-breakpoints`](references/bp-consolidate-breakpoints.md) - Consolidate Breakpoints to Three or Four
- [`bp-min-width-over-max`](references/bp-min-width-over-max.md) - Use min-width Over max-width for Breakpoints
- [`bp-debug-breakpoints`](references/bp-debug-breakpoints.md) - Use Visual Breakpoint Indicators During Development

### 2. Layout Transformation (CRITICAL)

- [`layout-stack-to-row`](references/layout-stack-to-row.md) - Stack Elements on Mobile, Row on Desktop
- [`layout-sidebar-collapse`](references/layout-sidebar-collapse.md) - Collapse Sidebar to Top or Bottom on Mobile
- [`layout-grid-column-reduction`](references/layout-grid-column-reduction.md) - Reduce Grid Columns at Narrower Breakpoints
- [`layout-holy-grail-responsive`](references/layout-holy-grail-responsive.md) - Use Responsive Holy Grail Layout with Grid
- [`layout-sticky-to-static`](references/layout-sticky-to-static.md) - Convert Sticky Elements to Static on Mobile
- [`layout-fixed-to-relative`](references/layout-fixed-to-relative.md) - Replace Fixed Positioning with Relative on Mobile
- [`layout-aspect-ratio-containers`](references/layout-aspect-ratio-containers.md) - Use Aspect Ratio for Responsive Containers

### 3. Responsive Spacing (HIGH)

- [`rspac-scale-padding-per-bp`](references/rspac-scale-padding-per-bp.md) - Scale Padding Independently Per Breakpoint
- [`rspac-responsive-gap`](references/rspac-responsive-gap.md) - Use Responsive Gap for Grid and Flex Spacing
- [`rspac-compact-mobile-generous-desktop`](references/rspac-compact-mobile-generous-desktop.md) - Use Compact Spacing on Mobile, Generous on Desktop
- [`rspac-section-spacing`](references/rspac-section-spacing.md) - Scale Section Dividers with Viewport
- [`rspac-inline-to-stack-spacing`](references/rspac-inline-to-stack-spacing.md) - Convert Inline Spacing to Stack Spacing on Mobile
- [`rspac-container-padding`](references/rspac-container-padding.md) - Use Responsive Container Padding

### 4. Fluid Typography (HIGH)

- [`fluid-clamp-font-size`](references/fluid-clamp-font-size.md) - Use clamp() for Fluid Font Sizing
- [`fluid-responsive-line-height`](references/fluid-responsive-line-height.md) - Tighten Line Height as Font Size Increases
- [`fluid-responsive-measure`](references/fluid-responsive-measure.md) - Constrain Line Length to 45-75 Characters
- [`fluid-scale-headings-independently`](references/fluid-scale-headings-independently.md) - Scale Heading Sizes Independently Across Breakpoints
- [`fluid-responsive-letter-spacing`](references/fluid-responsive-letter-spacing.md) - Adjust Letter Spacing for Responsive Headlines
- [`fluid-type-scale`](references/fluid-type-scale.md) - Use a Responsive Type Scale

### 5. Navigation Patterns (MEDIUM-HIGH)

- [`nav-horizontal-to-hamburger`](references/nav-horizontal-to-hamburger.md) - Collapse Horizontal Nav to Hamburger on Mobile
- [`nav-tab-bar-mobile`](references/nav-tab-bar-mobile.md) - Use Bottom Tab Bar for Primary Mobile Navigation
- [`nav-breadcrumb-collapse`](references/nav-breadcrumb-collapse.md) - Truncate Breadcrumbs on Mobile
- [`nav-sidebar-drawer`](references/nav-sidebar-drawer.md) - Convert Sidebar Nav to Off-Canvas Drawer on Mobile
- [`nav-dropdown-to-fullscreen`](references/nav-dropdown-to-fullscreen.md) - Expand Dropdown Menus to Full-Width on Mobile
- [`nav-sticky-header-compact`](references/nav-sticky-header-compact.md) - Compact the Header on Scroll for Mobile

### 6. Touch & Interaction (MEDIUM)

- [`touch-min-touch-target`](references/touch-min-touch-target.md) - Ensure Minimum 44px Touch Targets on Mobile
- [`touch-hover-to-tap`](references/touch-hover-to-tap.md) - Replace Hover Interactions with Tap-Friendly Alternatives
- [`touch-swipe-affordance`](references/touch-swipe-affordance.md) - Add Visual Swipe Affordances for Horizontal Scrolling
- [`touch-scroll-snap-mobile`](references/touch-scroll-snap-mobile.md) - Use Scroll Snap for Carousel-Like Mobile Interfaces
- [`touch-input-sizing-mobile`](references/touch-input-sizing-mobile.md) - Size Form Inputs to Prevent iOS Zoom
- [`touch-focus-visible-touch`](references/touch-focus-visible-touch.md) - Use focus-visible for Touch-Friendly Focus Styles

### 7. Responsive Media (MEDIUM)

- [`rmedia-responsive-images`](references/rmedia-responsive-images.md) - Use Responsive Image Sizing with Object-Fit
- [`rmedia-video-aspect-ratio`](references/rmedia-video-aspect-ratio.md) - Maintain Video Aspect Ratio Across Breakpoints
- [`rmedia-icon-size-scaling`](references/rmedia-icon-size-scaling.md) - Scale Icons Per Breakpoint, Not with Font Size
- [`rmedia-avatar-responsive`](references/rmedia-avatar-responsive.md) - Scale Avatar Sizes Per Context and Breakpoint
- [`rmedia-background-image-bp`](references/rmedia-background-image-bp.md) - Swap Background Images at Breakpoints
- [`rmedia-embed-responsive`](references/rmedia-embed-responsive.md) - Make Embedded Content Responsive with Container Constraints

### 8. Data Adaptation (LOW-MEDIUM)

- [`data-table-to-cards`](references/data-table-to-cards.md) - Transform Tables to Cards on Mobile
- [`data-horizontal-scroll-table`](references/data-horizontal-scroll-table.md) - Use Horizontal Scroll for Dense Data Tables
- [`data-responsive-data-grid`](references/data-responsive-data-grid.md) - Adapt Data Grid Density for Screen Size
- [`data-list-density-mobile`](references/data-list-density-mobile.md) - Increase List Item Density on Mobile
- [`data-truncate-overflow`](references/data-truncate-overflow.md) - Truncate Overflowing Text on Mobile
- [`data-responsive-form-layout`](references/data-responsive-form-layout.md) - Stack Form Fields on Mobile, Use Grid on Desktop

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
