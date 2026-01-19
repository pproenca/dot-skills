# UI/UX Frontend Design

**Version 0.1.0**  
UI/UX Best Practices  
January 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive UI/UX and frontend design best practices guide, designed for AI agents and LLMs. Contains 42 rules across 8 categories, prioritized by impact from critical (accessibility compliance, Core Web Vitals) to incremental (animation performance). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated code review and generation.

---

## Table of Contents

1. [Accessibility & WCAG Compliance](references/_sections.md#1-accessibility-&-wcag-compliance) — **CRITICAL**
   - 1.1 [Ensure Full Keyboard Navigation](references/access-keyboard-navigation.md) — CRITICAL (enables access for motor-impaired users and power users)
   - 1.2 [Ensure Minimum Touch Target Size](references/access-target-size.md) — CRITICAL (enables users with motor impairments to tap controls accurately)
   - 1.3 [Maintain Logical Heading Hierarchy](references/access-heading-hierarchy.md) — CRITICAL (enables screen reader users to navigate and understand page structure)
   - 1.4 [Provide Meaningful Alt Text for Images](references/access-alt-text.md) — CRITICAL (enables blind users to understand image content)
   - 1.5 [Provide Visible Focus Indicators](references/access-focus-indicators.md) — CRITICAL (enables keyboard users to track position on page)
   - 1.6 [Use ARIA Labels for Icon-Only Controls](references/access-aria-labels.md) — CRITICAL (enables screen readers to announce button purpose)
   - 1.7 [Use Semantic HTML Elements](references/access-semantic-html.md) — CRITICAL (enables screen reader navigation and improves SEO)
2. [Core Web Vitals Optimization](references/_sections.md#2-core-web-vitals-optimization) — **CRITICAL**
   - 2.1 [Improve Interaction to Next Paint](references/cwv-improve-inp.md) — CRITICAL (INP under 200ms makes UI feel responsive)
   - 2.2 [Inline Critical CSS and Defer the Rest](references/cwv-critical-css.md) — CRITICAL (eliminates render-blocking CSS, 200-500ms faster FCP)
   - 2.3 [Lazy Load Offscreen Images and Iframes](references/cwv-lazy-load-offscreen.md) — CRITICAL (reduces initial page weight by 30-60%)
   - 2.4 [Minimize Cumulative Layout Shift](references/cwv-minimize-cls.md) — CRITICAL (CLS under 0.1 prevents frustrating misclicks)
   - 2.5 [Optimize Largest Contentful Paint](references/cwv-optimize-lcp.md) — CRITICAL (LCP under 2.5s improves SEO rankings by 8-15%)
   - 2.6 [Serve Responsive Images with srcset](references/cwv-responsive-images.md) — CRITICAL (reduces image payload by 40-70% on mobile)
3. [Visual Hierarchy & Layout](references/_sections.md#3-visual-hierarchy-&-layout) — **HIGH**
   - 3.1 [Design for F-Pattern Reading Behavior](references/layout-f-pattern.md) — HIGH (increases CTA visibility by 30-50%)
   - 3.2 [Establish Clear Visual Hierarchy](references/layout-visual-hierarchy.md) — HIGH (improves CTA click-through rates by 20-40%)
   - 3.3 [Group Related Elements with Proximity](references/layout-proximity-grouping.md) — HIGH (reduces cognitive load, clarifies content relationships)
   - 3.4 [Limit to One Primary Call-to-Action Per Screen](references/layout-single-cta.md) — HIGH (reduces decision paralysis, improves click-through rates)
   - 3.5 [Use a Consistent Grid System](references/layout-grid-system.md) — HIGH (creates visual harmony and faster layout development)
   - 3.6 [Use Whitespace to Improve Readability](references/layout-whitespace.md) — HIGH (reduces cognitive load by 20%, improves comprehension)
4. [Responsive & Mobile-First Design](references/_sections.md#4-responsive-&-mobile-first-design) — **HIGH**
   - 4.1 [Configure Viewport Meta Tag Correctly](references/resp-viewport-meta.md) — HIGH (enables proper mobile rendering, prevents zoom issues)
   - 4.2 [Design Mobile-First with min-width Queries](references/resp-mobile-first.md) — HIGH (20-30% smaller CSS, supports 60%+ mobile traffic)
   - 4.3 [Size Touch Targets for Mobile Interaction](references/resp-touch-targets.md) — HIGH (reduces tap errors by 50%+, improves mobile usability)
   - 4.4 [Use Container Queries for Component-Based Layouts](references/resp-container-queries.md) — HIGH (enables truly reusable responsive components)
   - 4.5 [Use Fluid Typography with clamp()](references/resp-fluid-typography.md) — HIGH (eliminates abrupt font size jumps, reduces CSS)
5. [Typography & Font Loading](references/_sections.md#5-typography-&-font-loading) — **MEDIUM-HIGH**
   - 5.1 [Constrain Line Length for Readability](references/typo-readable-line-length.md) — MEDIUM-HIGH (improves reading comprehension by 20%+)
   - 5.2 [Preload Critical Web Fonts](references/typo-preload-fonts.md) — MEDIUM-HIGH (reduces font load time by 100-300ms)
   - 5.3 [Set Appropriate Line Height for Text Blocks](references/typo-line-height.md) — MEDIUM-HIGH (improves readability by 25%+, reduces eye strain)
   - 5.4 [Use font-display to Control Loading Behavior](references/typo-font-display.md) — MEDIUM-HIGH (eliminates FOIT, reduces CLS from font loading)
   - 5.5 [Use System Font Stack for Performance-Critical Text](references/typo-system-font-stack.md) — MEDIUM-HIGH (0ms font load time, eliminates FOUT/FOIT)
6. [Color & Contrast](references/_sections.md#6-color-&-contrast) — **MEDIUM**
   - 6.1 [Meet WCAG Contrast Ratio Requirements](references/color-contrast-ratio.md) — MEDIUM (makes text readable for 8%+ of users with visual impairments)
   - 6.2 [Never Use Color Alone to Convey Information](references/color-not-only-indicator.md) — MEDIUM (enables 8% of men with color blindness to understand content)
   - 6.3 [Support Dark Mode with Color Scheme](references/color-dark-mode.md) — MEDIUM (reduces eye strain and battery usage for 80%+ of users)
   - 6.4 [Use Semantic Color Names in Design Tokens](references/color-semantic-palette.md) — MEDIUM (enables consistent theming and easier maintenance)
7. [Forms & Validation UX](references/_sections.md#7-forms-&-validation-ux) — **MEDIUM**
   - 7.1 [Enable Browser Autocomplete with Correct Attributes](references/form-autocomplete.md) — MEDIUM (reduces form filling time by 30%+)
   - 7.2 [Place Labels Above Input Fields](references/form-labels-above.md) — MEDIUM (improves form completion speed by 15%)
   - 7.3 [Use Correct HTML Input Types for Mobile Keyboards](references/form-input-types.md) — MEDIUM (reduces typing effort by showing appropriate keyboard)
   - 7.4 [Use Inline Validation After Field Blur](references/form-inline-validation.md) — MEDIUM (reduces form abandonment by 22%)
   - 7.5 [Write Actionable Error Messages](references/form-error-messages.md) — MEDIUM (reduces user confusion and support requests by 30%)
8. [Animation & Performance](references/_sections.md#8-animation-&-performance) — **LOW-MEDIUM**
   - 8.1 [Animate Only GPU-Accelerated Properties](references/anim-gpu-properties.md) — LOW-MEDIUM (maintains 60fps, eliminates jank on complex animations)
   - 8.2 [Respect User Motion Preferences](references/anim-reduced-motion.md) — LOW-MEDIUM (prevents motion sickness for 35% of users affected by vestibular disorders)
   - 8.3 [Use Appropriate Animation Duration and Easing](references/anim-duration-easing.md) — LOW-MEDIUM (100-400ms optimal ranges reduce perceived latency)
   - 8.4 [Use will-change Sparingly for Animation Hints](references/anim-will-change.md) — LOW-MEDIUM (enables GPU layer promotion without overusing memory)

---

## References

1. [https://www.w3.org/WAI/WCAG22/quickref/](https://www.w3.org/WAI/WCAG22/quickref/)
2. [https://web.dev/articles/vitals](https://web.dev/articles/vitals)
3. [https://www.nngroup.com/](https://www.nngroup.com/)
4. [https://developer.mozilla.org/](https://developer.mozilla.org/)
5. [https://developers.google.com/search/docs/appearance/core-web-vitals](https://developers.google.com/search/docs/appearance/core-web-vitals)
6. [https://baymard.com/](https://baymard.com/)
7. [https://m3.material.io/](https://m3.material.io/)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |