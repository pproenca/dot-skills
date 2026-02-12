# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Breakpoint Strategy (bp)

**Impact:** CRITICAL
**Description:** Breakpoint decisions cascade through every responsive rule. Wrong strategy (device-based, too many, max-width) forces rewrites across the entire codebase. Content-driven, consolidated breakpoints reduce CSS output by 30-50%.

## 2. Layout Transformation (layout)

**Impact:** CRITICAL
**Description:** Layout shifts are the most visible responsive change and the #1 cause of broken mobile UIs. Stack-to-row, sidebar collapse, and grid reduction patterns determine whether the interface works or breaks at each breakpoint.

## 3. Responsive Spacing (rspac)

**Impact:** HIGH
**Description:** Spacing that scales proportionally looks wrong — mobile gets cramped, desktop gets sparse. Independent spacing per breakpoint maintains visual balance and content density across screen sizes.

## 4. Fluid Typography (fluid)

**Impact:** HIGH
**Description:** Fixed font sizes create unreadable text on small screens and wasted space on large ones. Fluid type scaling with clamp(), responsive line-height, and adaptive measure keeps text readable at every width.

## 5. Navigation Patterns (nav)

**Impact:** MEDIUM-HIGH
**Description:** Navigation is the most complex responsive component. A horizontal nav that doesn't collapse properly is the fastest way to break a mobile layout. Pattern selection (hamburger, tab bar, drawer) depends on item count and depth.

## 6. Touch & Interaction (touch)

**Impact:** MEDIUM
**Description:** Desktop hover states don't exist on mobile. Touch targets below 44px cause mis-taps. Responsive interaction patterns ensure usability across input methods without duplicating code.

## 7. Responsive Media (rmedia)

**Impact:** MEDIUM
**Description:** Unresponsive images and embeds overflow containers, waste bandwidth, and break layouts. Proper srcset, aspect ratios, and adaptive sizing keep media performant and contained.

## 8. Data Adaptation (data)

**Impact:** LOW-MEDIUM
**Description:** Wide tables and dense data grids are unusable on mobile. Card transformations, horizontal scrolling, and density adjustments make data-heavy interfaces work on small screens.
