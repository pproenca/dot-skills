---
name: ios-hig
description: Apple Human Interface Guidelines for iOS. Covers interaction design (touch targets, gestures, haptics), user feedback (loading, errors, empty states), UX patterns (onboarding, permissions, modality), accessibility (VoiceOver, Dynamic Type, color contrast), and input patterns. This skill should be used when designing iOS user experiences, implementing HIG-compliant interactions, ensuring accessibility compliance, or building forms and input flows.
---

# iOS HIG — Human Interface Guidelines

Comprehensive guide for Apple Human Interface Guidelines compliance in iOS apps. Contains 34 rules across 6 categories covering interaction design, user feedback, UX patterns, accessibility, and input handling.

## When to Apply

Reference these guidelines when:
- Designing touch interactions, gestures, and haptic feedback
- Implementing loading states, error handling, and empty states
- Building onboarding flows, permission requests, and settings screens
- Ensuring accessibility with VoiceOver, Dynamic Type, and color contrast
- Creating forms with toggles, pickers, text fields, and buttons
- Reviewing apps for HIG compliance

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Interaction Design | CRITICAL | `inter-` |
| 2 | Accessibility | CRITICAL | `acc-` |
| 3 | User Feedback | HIGH | `feed-` |
| 4 | UX Patterns | HIGH | `ux-` |
| 5 | Lists & Input | MEDIUM-HIGH | `input-` |
| 6 | List Data | MEDIUM | `list-` |

## Quick Reference

### 1. Interaction Design (CRITICAL)

- [`inter-touch-targets`](references/inter-touch-targets.md) - Ensure minimum touch target size
- [`inter-gesture-patterns`](references/inter-gesture-patterns.md) - Use standard gesture patterns
- [`inter-haptic-feedback`](references/inter-haptic-feedback.md) - Add haptic feedback for interactions
- [`inter-keyboard-handling`](references/inter-keyboard-handling.md) - Handle keyboard properly
- [`inter-drag-drop`](references/inter-drag-drop.md) - Implement drag and drop
- [`inter-pull-to-refresh`](references/inter-pull-to-refresh.md) - Support pull to refresh
- [`inter-swipe-actions`](references/inter-swipe-actions.md) - Add swipe actions to list rows
- [`inter-list-search`](references/inter-list-search.md) - Make lists searchable

### 2. User Feedback (HIGH)

- [`feed-loading-states`](references/feed-loading-states.md) - Show loading states
- [`feed-error-states`](references/feed-error-states.md) - Display error states clearly
- [`feed-notifications`](references/feed-notifications.md) - Use notifications appropriately
- [`feed-success-confirmation`](references/feed-success-confirmation.md) - Confirm successful actions
- [`feed-empty-states`](references/feed-empty-states.md) - Design empty states

### 3. UX Patterns (HIGH)

- [`ux-onboarding`](references/ux-onboarding.md) - Design effective onboarding
- [`ux-permissions`](references/ux-permissions.md) - Request permissions properly
- [`ux-modality`](references/ux-modality.md) - Use modality patterns correctly
- [`ux-data-entry`](references/ux-data-entry.md) - Optimize data entry flows
- [`ux-undo`](references/ux-undo.md) - Support undo and redo
- [`ux-settings`](references/ux-settings.md) - Organize settings screens

### 4. Accessibility (CRITICAL)

- [`acc-labels`](references/acc-labels.md) - Add accessibility labels to interactive elements
- [`acc-dynamic-type`](references/acc-dynamic-type.md) - Support Dynamic Type for all text
- [`acc-color-contrast`](references/acc-color-contrast.md) - Maintain sufficient color contrast
- [`acc-reduce-motion`](references/acc-reduce-motion.md) - Respect reduce motion preference
- [`acc-color-independent`](references/acc-color-independent.md) - Don't rely on color alone
- [`acc-focus-management`](references/acc-focus-management.md) - Manage accessibility focus
- [`acc-scaled-metric`](references/acc-scaled-metric.md) - Use ScaledMetric for adaptive sizing
- [`acc-view-that-fits`](references/acc-view-that-fits.md) - Use ViewThatFits for adaptive layouts
- [`acc-inclusive`](references/acc-inclusive.md) - Build inclusive features

### 5. Lists & Input (MEDIUM-HIGH)

- [`input-list-foreach`](references/input-list-foreach.md) - Use ForEach for dynamic lists
- [`input-toggle-forms`](references/input-toggle-forms.md) - Build toggle-based forms
- [`input-picker-selection`](references/input-picker-selection.md) - Implement picker selection
- [`input-textfield-binding`](references/input-textfield-binding.md) - Bind text fields to state
- [`input-button-actions`](references/input-button-actions.md) - Handle button actions

### 6. List Data (MEDIUM)

- [`list-identifiable-data`](references/list-identifiable-data.md) - Use Identifiable for list data

## How to Use

Read individual reference files for detailed explanations and code examples:

- [Section definitions](references/_sections.md) - Category structure and impact levels
- [Rule template](assets/templates/_template.md) - Template for adding new rules

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
