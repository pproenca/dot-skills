---
name: ios-hig
description: Apple Human Interface Guidelines for iOS. Covers navigation (tab bars, NavigationStack, toolbars), interaction design (touch targets, gestures, haptics), accessibility (VoiceOver, Dynamic Type, color contrast), user feedback (loading, errors, empty states), UX patterns (onboarding, permissions, modality, confirmation dialogs), and visual design (dark mode, SF Symbols, layout margins). This skill should be used when designing iOS user experiences, implementing HIG-compliant interactions, ensuring accessibility compliance, building navigation hierarchies, or reviewing apps for Apple design guideline compliance.
---

# Apple iOS HIG Best Practices

Comprehensive guide for Apple Human Interface Guidelines compliance in iOS apps built with SwiftUI. Contains 34 rules across 6 categories covering navigation, interaction design, accessibility, user feedback, UX patterns, and visual design.

## When to Apply

Reference these guidelines when:
- Building navigation hierarchies with tab bars, NavigationStack, or split views
- Designing touch interactions, gestures, and haptic feedback
- Ensuring accessibility with VoiceOver, Dynamic Type, and color contrast
- Implementing loading states, error handling, and empty states
- Building onboarding flows, permission requests, and confirmation dialogs
- Supporting dark mode, SF Symbols, and standard layout margins
- Reviewing apps for HIG compliance

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Navigation | CRITICAL | `nav-` |
| 2 | Interaction Design | CRITICAL | `inter-` |
| 3 | Accessibility | CRITICAL | `acc-` |
| 4 | User Feedback | HIGH | `feed-` |
| 5 | UX Patterns | HIGH | `ux-` |
| 6 | Visual Design | HIGH | `vis-` |

## Quick Reference

### 1. Navigation (CRITICAL)

- [`nav-tab-bar`](references/nav-tab-bar.md) - Design tab bars for top-level navigation
- [`nav-navigation-stack`](references/nav-navigation-stack.md) - Use NavigationStack for hierarchical navigation
- [`nav-toolbar-placement`](references/nav-toolbar-placement.md) - Place actions in toolbars using standard placements

### 2. Interaction Design (CRITICAL)

- [`inter-touch-targets`](references/inter-touch-targets.md) - Maintain 44pt minimum touch targets
- [`inter-gesture-patterns`](references/inter-gesture-patterns.md) - Use standard gesture patterns
- [`inter-haptic-feedback`](references/inter-haptic-feedback.md) - Add haptic feedback for meaningful events
- [`inter-keyboard-handling`](references/inter-keyboard-handling.md) - Handle keyboard appearance gracefully
- [`inter-drag-drop`](references/inter-drag-drop.md) - Support drag and drop for content transfer
- [`inter-pull-to-refresh`](references/inter-pull-to-refresh.md) - Support pull to refresh for lists
- [`inter-swipe-actions`](references/inter-swipe-actions.md) - Add swipe actions for contextual operations
- [`inter-list-search`](references/inter-list-search.md) - Use searchable for built-in search

### 3. Accessibility (CRITICAL)

- [`acc-labels`](references/acc-labels.md) - Provide meaningful accessibility labels
- [`acc-dynamic-type`](references/acc-dynamic-type.md) - Support Dynamic Type for all text
- [`acc-color-contrast`](references/acc-color-contrast.md) - Maintain sufficient color contrast
- [`acc-reduce-motion`](references/acc-reduce-motion.md) - Respect reduce motion preference
- [`acc-color-independent`](references/acc-color-independent.md) - Never rely on color alone
- [`acc-focus-management`](references/acc-focus-management.md) - Manage focus for assistive technologies
- [`acc-scaled-metric`](references/acc-scaled-metric.md) - Use ScaledMetric for adaptive sizing
- [`acc-view-that-fits`](references/acc-view-that-fits.md) - Use ViewThatFits for adaptive layouts

### 4. User Feedback (HIGH)

- [`feed-loading-states`](references/feed-loading-states.md) - Show appropriate loading indicators
- [`feed-error-states`](references/feed-error-states.md) - Handle errors with clear recovery actions
- [`feed-notifications`](references/feed-notifications.md) - Use notifications judiciously
- [`feed-success-confirmation`](references/feed-success-confirmation.md) - Confirm successful actions appropriately
- [`feed-empty-states`](references/feed-empty-states.md) - Design helpful empty states

### 5. UX Patterns (HIGH)

- [`ux-onboarding`](references/ux-onboarding.md) - Design minimal onboarding
- [`ux-permissions`](references/ux-permissions.md) - Request permissions in context
- [`ux-modality`](references/ux-modality.md) - Use modality appropriately
- [`ux-confirmation-dialog`](references/ux-confirmation-dialog.md) - Use confirmation dialogs for destructive actions
- [`ux-data-entry`](references/ux-data-entry.md) - Minimize data entry friction
- [`ux-undo`](references/ux-undo.md) - Support undo for destructive actions
- [`ux-settings`](references/ux-settings.md) - Organize settings logically

### 6. Visual Design (HIGH)

- [`vis-dark-mode`](references/vis-dark-mode.md) - Support dark mode with semantic colors
- [`vis-sf-symbols`](references/vis-sf-symbols.md) - Use SF Symbols with correct rendering mode and weight
- [`vis-layout-margins`](references/vis-layout-margins.md) - Use standard layout margins and safe areas

## How to Use

Read individual reference files for detailed explanations and code examples:

- [Section definitions](references/_sections.md) - Category structure and impact levels
- [Rule template](assets/templates/_template.md) - Template for adding new rules

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
