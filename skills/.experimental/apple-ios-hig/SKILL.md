---
name: apple-ios-hig
description: Apple Human Interface Guidelines for iOS design. Use when building iOS/SwiftUI apps, designing mobile interfaces, or creating user experiences that need to feel native to Apple platforms. Covers color, typography, navigation, components, accessibility, and interaction patterns.
---

# Apple iOS/SwiftUI Design Best Practices

Comprehensive design guide based on Apple's Human Interface Guidelines for iOS applications. Contains 45+ rules across 8 categories covering design foundations, layout systems, navigation patterns, UI components, interaction design, user feedback, accessibility, and common UX patterns.

## When to Apply

Reference these guidelines when:
- Building iOS or iPadOS applications with SwiftUI or UIKit
- Designing mobile interfaces that should feel native to Apple platforms
- Implementing navigation, components, or interaction patterns
- Ensuring accessibility compliance (VoiceOver, Dynamic Type)
- Creating onboarding, forms, or settings screens

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Design Foundations | CRITICAL | `found-` |
| 2 | Layout & Spacing | CRITICAL | `layout-` |
| 3 | Navigation Patterns | HIGH | `nav-` |
| 4 | UI Components | HIGH | `comp-` |
| 5 | Interaction Design | HIGH | `inter-` |
| 6 | User Feedback | MEDIUM-HIGH | `feed-` |
| 7 | Accessibility | HIGH | `a11y-` |
| 8 | UX Patterns | MEDIUM | `ux-` |

## Quick Reference

### 1. Design Foundations (CRITICAL)

- [`found-semantic-colors`](references/found-semantic-colors.md) - Use semantic colors for automatic dark mode
- [`found-system-colors`](references/found-system-colors.md) - Use system accent colors for interactive elements
- [`found-typography-san-francisco`](references/found-typography-san-francisco.md) - Use San Francisco with text styles
- [`found-dark-mode-support`](references/found-dark-mode-support.md) - Support dark mode system-wide
- [`found-sf-symbols`](references/found-sf-symbols.md) - Use SF Symbols for icons
- [`found-color-contrast`](references/found-color-contrast.md) - Maintain minimum contrast ratios
- [`found-app-icons`](references/found-app-icons.md) - Design app icons following guidelines

### 2. Layout & Spacing (CRITICAL)

- [`layout-safe-areas`](references/layout-safe-areas.md) - Respect safe area insets
- [`layout-8pt-grid`](references/layout-8pt-grid.md) - Use 8pt grid for spacing
- [`layout-readable-content-width`](references/layout-readable-content-width.md) - Constrain text to readable width
- [`layout-adaptive-layouts`](references/layout-adaptive-layouts.md) - Use adaptive layouts for size classes
- [`layout-standard-margins`](references/layout-standard-margins.md) - Use system standard margins
- [`layout-scroll-indicators`](references/layout-scroll-indicators.md) - Show scroll indicators for long content

### 3. Navigation Patterns (HIGH)

- [`nav-tab-bar-navigation`](references/nav-tab-bar-navigation.md) - Use tab bar for top-level navigation
- [`nav-navigation-bar`](references/nav-navigation-bar.md) - Use navigation bar for hierarchy
- [`nav-hierarchical-structure`](references/nav-hierarchical-structure.md) - Design clear navigation hierarchy
- [`nav-search-integration`](references/nav-search-integration.md) - Integrate search using searchable modifier
- [`nav-toolbar-actions`](references/nav-toolbar-actions.md) - Place actions in toolbar correctly

### 4. UI Components (HIGH)

- [`comp-button-styles`](references/comp-button-styles.md) - Use appropriate button styles
- [`comp-text-field`](references/comp-text-field.md) - Configure text fields with content types
- [`comp-list-cells`](references/comp-list-cells.md) - Design list cells with standard layouts
- [`comp-sheets-presentation`](references/comp-sheets-presentation.md) - Use sheets for modal tasks
- [`comp-alerts-confirmations`](references/comp-alerts-confirmations.md) - Use alerts sparingly
- [`comp-action-sheets`](references/comp-action-sheets.md) - Use action sheets for contextual choices
- [`comp-segmented-controls`](references/comp-segmented-controls.md) - Use segmented controls for exclusive options
- [`comp-menus`](references/comp-menus.md) - Use menus for secondary actions
- [`comp-pickers`](references/comp-pickers.md) - Choose appropriate picker styles

### 5. Interaction Design (HIGH)

- [`inter-touch-targets`](references/inter-touch-targets.md) - Maintain 44pt minimum touch targets
- [`inter-gesture-patterns`](references/inter-gesture-patterns.md) - Use standard gesture patterns
- [`inter-haptic-feedback`](references/inter-haptic-feedback.md) - Use haptic feedback for meaningful events
- [`inter-keyboard-handling`](references/inter-keyboard-handling.md) - Handle keyboard appearance gracefully
- [`inter-drag-drop`](references/inter-drag-drop.md) - Support drag and drop for content transfer
- [`inter-pull-to-refresh`](references/inter-pull-to-refresh.md) - Support pull-to-refresh for lists

### 6. User Feedback (MEDIUM-HIGH)

- [`feed-loading-states`](references/feed-loading-states.md) - Show appropriate loading indicators
- [`feed-error-states`](references/feed-error-states.md) - Handle errors with clear recovery actions
- [`feed-notifications`](references/feed-notifications.md) - Use notifications judiciously
- [`feed-success-confirmation`](references/feed-success-confirmation.md) - Confirm actions appropriately
- [`feed-empty-states`](references/feed-empty-states.md) - Design helpful empty states

### 7. Accessibility (HIGH)

- [`a11y-voiceover-labels`](references/a11y-voiceover-labels.md) - Provide meaningful VoiceOver labels
- [`a11y-dynamic-type`](references/a11y-dynamic-type.md) - Support Dynamic Type for all text
- [`a11y-reduce-motion`](references/a11y-reduce-motion.md) - Respect reduce motion preference
- [`a11y-color-independent`](references/a11y-color-independent.md) - Never rely on color alone
- [`a11y-focus-management`](references/a11y-focus-management.md) - Manage focus for assistive technologies

### 8. UX Patterns (MEDIUM)

- [`ux-onboarding`](references/ux-onboarding.md) - Design minimal onboarding
- [`ux-permission-requests`](references/ux-permission-requests.md) - Request permissions in context
- [`ux-modality-patterns`](references/ux-modality-patterns.md) - Use modality appropriately
- [`ux-data-entry`](references/ux-data-entry.md) - Minimize data entry friction
- [`ux-undo-redo`](references/ux-undo-redo.md) - Support undo for destructive actions
- [`ux-settings-organization`](references/ux-settings-organization.md) - Organize settings logically

## How to Use

Read individual reference files for detailed explanations with code examples showing both incorrect and correct implementations.

- [Section definitions](references/_sections.md) - Category structure and impact levels
- [Rule template](assets/templates/_template.md) - Template for adding new rules

## Full Compiled Document

For a single comprehensive document with all rules, see [AGENTS.md](AGENTS.md).

## Reference Files

| File | Description |
|------|-------------|
| [AGENTS.md](AGENTS.md) | Complete compiled guide with all rules |
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/](assets/templates/) | Rule template for extensions |
| [metadata.json](metadata.json) | Version and reference information |
