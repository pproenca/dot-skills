# iOS/SwiftUI Design

**Version 0.1.0**  
Apple iOS Human Interface Guidelines  
February 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive design guide based on Apple's Human Interface Guidelines for iOS applications. Contains 45+ rules across 8 categories covering design foundations, layout systems, navigation patterns, UI components, interaction design, user feedback, accessibility, and common UX patterns. Enables AI agents to generate iOS-compliant designs with proper spacing, colors, typography, and platform conventions.

---

## Table of Contents

1. [Design Foundations](references/_sections.md#1-design-foundations) — **CRITICAL**
   - 1.1 [Design App Icons Following Apple Guidelines](references/found-app-icons.md) — HIGH (creates recognizable, professional app identity)
   - 1.2 [Maintain Minimum Color Contrast Ratios](references/found-color-contrast.md) — HIGH (ensures text readability for all users including those with visual impairments)
   - 1.3 [Support Dark Mode System-Wide](references/found-dark-mode-support.md) — CRITICAL (respects user system preference for appearance)
   - 1.4 [Use San Francisco System Font with Text Styles](references/found-typography-san-francisco.md) — CRITICAL (enables Dynamic Type and consistent typography)
   - 1.5 [Use Semantic Colors for Automatic Dark Mode](references/found-semantic-colors.md) — CRITICAL (ensures automatic adaptation to light/dark modes)
   - 1.6 [Use SF Symbols for System-Consistent Icons](references/found-sf-symbols.md) — HIGH (provides consistent, scalable icons that match system UI)
   - 1.7 [Use System Accent Colors for Interactive Elements](references/found-system-colors.md) — HIGH (maintains visual consistency with iOS system apps)
2. [Layout & Spacing](references/_sections.md#2-layout-&-spacing) — **CRITICAL**
   - 2.1 [Constrain Text to Readable Width on iPad](references/layout-readable-content-width.md) — HIGH (prevents uncomfortably long lines of text on large screens)
   - 2.2 [Respect Safe Area Insets](references/layout-safe-areas.md) — CRITICAL (prevents content from being obscured by notch, Dynamic Island, or home indicator)
   - 2.3 [Show Scroll Indicators for Long Content](references/layout-scroll-indicators.md) — LOW (helps users understand content extent and position)
   - 2.4 [Use 8pt Grid for Spacing](references/layout-8pt-grid.md) — HIGH (creates consistent visual rhythm and scalable layouts)
   - 2.5 [Use Adaptive Layouts for Different Size Classes](references/layout-adaptive-layouts.md) — HIGH (ensures proper display across iPhone and iPad in all orientations)
   - 2.6 [Use System Standard Margins](references/layout-standard-margins.md) — MEDIUM-HIGH (aligns with system UI and other apps for familiar feel)
3. [Navigation Patterns](references/_sections.md#3-navigation-patterns) — **HIGH**
   - 3.1 [Design Clear Navigation Hierarchy](references/nav-hierarchical-structure.md) — HIGH (helps users understand where they are and how to navigate)
   - 3.2 [Integrate Search Using Searchable Modifier](references/nav-search-integration.md) — MEDIUM-HIGH (provides consistent search experience matching system apps)
   - 3.3 [Place Actions in Toolbar with Correct Placement](references/nav-toolbar-actions.md) — MEDIUM (positions actions where users expect them)
   - 3.4 [Use Navigation Bar for Hierarchical Navigation](references/nav-navigation-bar.md) — CRITICAL (enables standard back navigation and screen context)
   - 3.5 [Use Tab Bar for Top-Level Navigation](references/nav-tab-bar-navigation.md) — CRITICAL (provides familiar iOS navigation pattern for main app sections)
4. [UI Components](references/_sections.md#4-ui-components) — **HIGH**
   - 4.1 [Choose Appropriate Picker Styles](references/comp-pickers.md) — MEDIUM (matches picker style to context and data type)
   - 4.2 [Configure Text Fields with Appropriate Keyboard and Content Types](references/comp-text-field.md) — HIGH (enables autocomplete, validation, and correct keyboard)
   - 4.3 [Design List Cells with Standard Layouts](references/comp-list-cells.md) — HIGH (maintains consistency with system apps and user expectations)
   - 4.4 [Use Action Sheets for Contextual Choices](references/comp-action-sheets.md) — MEDIUM-HIGH (presents choices in context without full screen interruption)
   - 4.5 [Use Alerts Sparingly for Critical Information](references/comp-alerts-confirmations.md) — HIGH (reserves alerts for truly important decisions)
   - 4.6 [Use Appropriate Button Styles](references/comp-button-styles.md) — HIGH (communicates button importance and creates visual hierarchy)
   - 4.7 [Use Menus for Secondary Actions](references/comp-menus.md) — MEDIUM (organizes actions without cluttering the interface)
   - 4.8 [Use Segmented Controls for Mutually Exclusive Options](references/comp-segmented-controls.md) — MEDIUM (provides quick switching between related views)
   - 4.9 [Use Sheets for Modal Tasks](references/comp-sheets-presentation.md) — HIGH (provides appropriate modal context for focused tasks)
5. [Interaction Design](references/_sections.md#5-interaction-design) — **HIGH**
   - 5.1 [Handle Keyboard Appearance Gracefully](references/inter-keyboard-handling.md) — HIGH (prevents keyboard from obscuring input fields)
   - 5.2 [Maintain 44pt Minimum Touch Targets](references/inter-touch-targets.md) — CRITICAL (ensures tappable elements are accessible to all users)
   - 5.3 [Support Drag and Drop for Content Transfer](references/inter-drag-drop.md) — MEDIUM (enables intuitive content movement and sharing)
   - 5.4 [Support Pull-to-Refresh for Lists](references/inter-pull-to-refresh.md) — MEDIUM (enables manual refresh using familiar iOS gesture)
   - 5.5 [Use Haptic Feedback for Meaningful Events](references/inter-haptic-feedback.md) — MEDIUM-HIGH (provides tactile confirmation that enhances user experience)
   - 5.6 [Use Standard Gesture Patterns](references/inter-gesture-patterns.md) — HIGH (leverages muscle memory from other iOS apps)
6. [User Feedback](references/_sections.md#6-user-feedback) — **HIGH**
   - 6.1 [Confirm Successful Actions Appropriately](references/feed-success-confirmation.md) — MEDIUM (provides reassurance without being intrusive)
   - 6.2 [Design Helpful Empty States](references/feed-empty-states.md) — MEDIUM (guides users on how to populate empty screens)
   - 6.3 [Handle Errors with Clear Recovery Actions](references/feed-error-states.md) — HIGH (helps users understand and recover from problems)
   - 6.4 [Show Appropriate Loading Indicators](references/feed-loading-states.md) — HIGH (keeps users informed during wait times)
   - 6.5 [Use Notifications Judiciously](references/feed-notifications.md) — HIGH (respects user attention and maintains trust)
7. [UX Patterns](references/_sections.md#7-ux-patterns) — **MEDIUM**
   - 7.1 [Design Minimal Onboarding](references/ux-onboarding.md) — HIGH (gets users into app quickly while teaching essentials)
   - 7.2 [Minimize Data Entry Friction](references/ux-data-entry.md) — MEDIUM (reduces user effort and errors during input)
   - 7.3 [Organize Settings Logically](references/ux-settings-organization.md) — MEDIUM (helps users find and understand configuration options)
   - 7.4 [Request Permissions in Context](references/ux-permission-requests.md) — HIGH (improves permission grant rates and user trust)
   - 7.5 [Support Undo for Destructive Actions](references/ux-undo-redo.md) — MEDIUM (allows users to recover from mistakes)
   - 7.6 [Use Modality Appropriately](references/ux-modality-patterns.md) — MEDIUM-HIGH (reserves modal presentations for focused, temporary tasks)

---

## References

1. [https://developer.apple.com/design/human-interface-guidelines/](https://developer.apple.com/design/human-interface-guidelines/)
2. [https://developer.apple.com/design/human-interface-guidelines/designing-for-ios](https://developer.apple.com/design/human-interface-guidelines/designing-for-ios)
3. [https://developer.apple.com/design/human-interface-guidelines/accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility)
4. [https://developer.apple.com/design/human-interface-guidelines/color](https://developer.apple.com/design/human-interface-guidelines/color)
5. [https://developer.apple.com/design/human-interface-guidelines/dark-mode](https://developer.apple.com/design/human-interface-guidelines/dark-mode)
6. [https://developer.apple.com/design/human-interface-guidelines/sf-symbols](https://developer.apple.com/design/human-interface-guidelines/sf-symbols)
7. [https://developer.apple.com/design/human-interface-guidelines/layout](https://developer.apple.com/design/human-interface-guidelines/layout)
8. [https://developer.apple.com/design/human-interface-guidelines/navigation-and-search](https://developer.apple.com/design/human-interface-guidelines/navigation-and-search)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |