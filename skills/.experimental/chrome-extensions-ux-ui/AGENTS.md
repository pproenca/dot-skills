# Chrome Extensions

**Version 0.1.0**  
Chrome Extensions Community  
January 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive UX/UI design guide for Chrome Extensions, optimized for Manifest V3. Contains 42 rules across 8 categories, prioritized by impact from critical (component selection, accessibility) to incremental (icons and branding). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide extension development and code review.

---

## Table of Contents

1. [Component Selection](references/_sections.md#1-component-selection) — **CRITICAL**
   - 1.1 [Choose Side Panel for Persistent Tasks](references/comp-popup-vs-sidepanel.md) — CRITICAL (5-10× longer engagement sessions)
   - 1.2 [Design for Single Purpose](references/comp-single-purpose.md) — CRITICAL (required for Chrome Web Store approval)
   - 1.3 [Provide Descriptive Action Tooltips](references/comp-action-tooltip.md) — CRITICAL (prevents user confusion and misdirected clicks)
   - 1.4 [Request Minimal Permissions](references/comp-minimal-permissions.md) — CRITICAL (40-60% higher install conversion rate)
   - 1.5 [Use Content Scripts for In-Page UI](references/comp-content-script-ui.md) — CRITICAL (eliminates context switching entirely)
2. [Accessibility & Navigation](references/_sections.md#2-accessibility-&-navigation) — **CRITICAL**
   - 2.1 [Avoid Keyboard Focus Traps](references/access-focus-trap.md) — CRITICAL (WCAG 2.1.2 - users must be able to exit any UI)
   - 2.2 [Enable Complete Keyboard Navigation](references/access-keyboard-navigation.md) — CRITICAL (required for accessibility compliance)
   - 2.3 [Ensure Sufficient Color Contrast](references/access-color-contrast.md) — CRITICAL (WCAG AA requires 4.5:1 for normal text)
   - 2.4 [Maintain Visible Focus Indicators](references/access-focus-visible.md) — CRITICAL (WCAG 2.4.7 requirement for keyboard users)
   - 2.5 [Use ARIA Labels for Icon-Only Buttons](references/access-aria-labels.md) — CRITICAL (makes UI comprehensible to screen reader users)
   - 2.6 [Use Semantic HTML Elements](references/access-semantic-html.md) — CRITICAL (built-in keyboard and screen reader support)
3. [Popup Design](references/_sections.md#3-popup-design) — **HIGH**
   - 3.1 [Design Within Popup Size Limits](references/popup-size-constraints.md) — HIGH (prevents content clipping and scroll issues)
   - 3.2 [Handle Popup Auto-Close Gracefully](references/popup-auto-close.md) — HIGH (prevents data loss and user frustration)
   - 3.3 [Keep JavaScript in External Files](references/popup-external-js.md) — HIGH (required by Content Security Policy)
   - 3.4 [Make the Primary Action Obvious](references/popup-primary-action.md) — HIGH (reduces time-to-action by 60-80%)
   - 3.5 [Render Popup Content Instantly](references/popup-instant-render.md) — HIGH (200-500ms perceived as laggy by users)
   - 3.6 [Use Dynamic Popups for State-Based UI](references/popup-dynamic-switch.md) — HIGH (reduces cognitive load by showing relevant UI)
4. [Side Panel UX](references/_sections.md#4-side-panel-ux) — **HIGH**
   - 4.1 [Choose Tab-Specific vs Window-Wide Panels](references/panel-tab-vs-window.md) — HIGH (determines context relevance and user expectations)
   - 4.2 [Design for Variable Panel Widths](references/panel-responsive-width.md) — HIGH (prevents layout breaking when users resize)
   - 4.3 [Design Non-Distracting Side Panels](references/panel-non-distracting.md) — HIGH (increases session duration by 3-5×)
   - 4.4 [Lazy Load Panel Sections](references/panel-lazy-sections.md) — HIGH (50-80% faster initial panel render)
   - 4.5 [Sync Panel Content with Page Context](references/panel-page-context.md) — HIGH (makes panel feel integrated rather than disconnected)
5. [Content Script UI](references/_sections.md#5-content-script-ui) — **MEDIUM-HIGH**
   - 5.1 [Clean Up Injected Elements on Removal](references/inject-cleanup.md) — MEDIUM-HIGH (prevents memory leaks and DOM pollution)
   - 5.2 [Inject UI After DOM Ready](references/inject-document-ready.md) — MEDIUM-HIGH (prevents null reference errors and race conditions)
   - 5.3 [Use Maximum Z-Index for Overlays](references/inject-z-index.md) — MEDIUM-HIGH (ensures UI visibility on all websites)
   - 5.4 [Use Shadow DOM for Style Isolation](references/inject-shadow-dom.md) — MEDIUM-HIGH (prevents 100% of CSS conflicts with host pages)
   - 5.5 [Use Unique IDs to Prevent Conflicts](references/inject-unique-ids.md) — MEDIUM-HIGH (prevents ID collision with page elements)
6. [Visual Feedback](references/_sections.md#6-visual-feedback) — **MEDIUM**
   - 6.1 [Confirm Successful Actions](references/feedback-success-confirmation.md) — MEDIUM (builds user confidence and trust)
   - 6.2 [Show Loading States for Async Operations](references/feedback-loading-states.md) — MEDIUM (reduces perceived wait time by 40%)
   - 6.3 [Show Progress for Long Operations](references/feedback-progress-indication.md) — MEDIUM (reduces abandonment during multi-step processes)
   - 6.4 [Use Badge for At-a-Glance Status](references/feedback-badge-status.md) — MEDIUM (communicates state without opening extension)
   - 6.5 [Use Notifications Sparingly](references/feedback-notifications.md) — MEDIUM (prevents notification fatigue and user annoyance)
   - 6.6 [Write Actionable Error Messages](references/feedback-error-messages.md) — MEDIUM (60% faster error recovery when users know what to do)
7. [Options & Settings](references/_sections.md#7-options-&-settings) — **MEDIUM**
   - 7.1 [Auto-Save Settings on Change](references/options-auto-save.md) — MEDIUM (eliminates lost settings and save button friction)
   - 7.2 [Provide Sensible Default Settings](references/options-sensible-defaults.md) — MEDIUM (extension works immediately without configuration)
   - 7.3 [Sync Settings Across Devices](references/options-sync-storage.md) — MEDIUM (seamless experience across user's computers)
   - 7.4 [Use Embedded Options for Simple Settings](references/options-embedded-page.md) — MEDIUM (keeps users in context without tab switching)
8. [Icons & Branding](references/_sections.md#8-icons-&-branding) — **LOW-MEDIUM**
   - 8.1 [Create Quality Web Store Assets](references/brand-web-store-assets.md) — LOW-MEDIUM (30-50% higher conversion from store listing)
   - 8.2 [Design a Distinctive Toolbar Icon](references/brand-distinctive-icon.md) — LOW-MEDIUM (improves findability in crowded toolbar)
   - 8.3 [Keep Badge Text Under 4 Characters](references/brand-badge-text.md) — LOW-MEDIUM (ensures text is fully visible on toolbar)
   - 8.4 [Maintain Consistent Visual Style](references/brand-consistent-styling.md) — LOW-MEDIUM (builds brand recognition and professional appearance)
   - 8.5 [Provide All Required Icon Sizes](references/brand-icon-sizes.md) — LOW-MEDIUM (ensures crisp display across all contexts)

---

## References

1. [https://developer.chrome.com/docs/extensions/develop/ui](https://developer.chrome.com/docs/extensions/develop/ui)
2. [https://developer.chrome.com/docs/extensions/mv3/a11y/](https://developer.chrome.com/docs/extensions/mv3/a11y/)
3. [https://developer.chrome.com/docs/webstore/best-practices](https://developer.chrome.com/docs/webstore/best-practices)
4. [https://developer.chrome.com/docs/extensions/develop/ui/add-popup](https://developer.chrome.com/docs/extensions/develop/ui/add-popup)
5. [https://developer.chrome.com/docs/extensions/reference/api/sidePanel](https://developer.chrome.com/docs/extensions/reference/api/sidePanel)
6. [https://developer.chrome.com/docs/extensions/develop/concepts/content-scripts](https://developer.chrome.com/docs/extensions/develop/concepts/content-scripts)
7. [https://developer.chrome.com/docs/webstore/branding](https://developer.chrome.com/docs/webstore/branding)
8. [https://www.w3.org/WAI/WCAG21/Understanding/](https://www.w3.org/WAI/WCAG21/Understanding/)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |