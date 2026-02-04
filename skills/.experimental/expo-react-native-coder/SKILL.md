---
name: expo-react-native-coder
description: Comprehensive Expo React Native feature development guide. This skill should be used when building mobile app screens, navigation, data fetching, authentication, deep linking, or native UX patterns with Expo. Triggers on tasks involving Expo Router, React Native components, mobile forms, or app configuration.
---

# Expo React Native Coder Best Practices

Comprehensive feature development guide for Expo React Native applications. Contains 50 rules across 10 categories, covering everything from project setup to testing. Includes production-ready code templates for common features.

## When to Apply

Reference these guidelines when:
- Setting up a new Expo project with TypeScript
- Building navigation with Expo Router (tabs, stacks, drawers, modals)
- Creating screens (list, detail, form, settings)
- Implementing authentication flows with protected routes
- Configuring deep linking and universal links

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Project Setup & Configuration | CRITICAL | `setup-` |
| 2 | Routing & Navigation | CRITICAL | `route-` |
| 3 | Screen Patterns & Layouts | HIGH | `screen-` |
| 4 | Data Fetching & State | HIGH | `data-` |
| 5 | Authentication & Security | HIGH | `auth-` |
| 6 | Deep Linking & Universal Links | HIGH | `link-` |
| 7 | Native UX Patterns | MEDIUM-HIGH | `ux-` |
| 8 | Forms & User Input | MEDIUM | `form-` |
| 9 | Assets & Theming | MEDIUM | `asset-` |
| 10 | Error Handling & Testing | MEDIUM | `test-` |

## Quick Reference

### 1. Project Setup & Configuration (CRITICAL)

- [`setup-typescript-config`](references/setup-typescript-config.md) - Configure TypeScript with strict mode
- [`setup-app-config-typescript`](references/setup-app-config-typescript.md) - Use typed app.config.ts
- [`setup-environment-variables`](references/setup-environment-variables.md) - EXPO_PUBLIC_ prefix for client vars
- [`setup-eas-build-profiles`](references/setup-eas-build-profiles.md) - EAS build profiles per environment
- [`setup-development-build`](references/setup-development-build.md) - Development builds vs Expo Go

### 2. Routing & Navigation (CRITICAL)

- [`route-file-based-routing`](references/route-file-based-routing.md) - File-based routing with Expo Router
- [`route-tab-navigator`](references/route-tab-navigator.md) - Tab navigator with route groups
- [`route-dynamic-segments`](references/route-dynamic-segments.md) - Dynamic route segments [param]
- [`route-stack-within-tabs`](references/route-stack-within-tabs.md) - Nested stack in tabs
- [`route-modal-presentation`](references/route-modal-presentation.md) - Modal screen presentation
- [`route-typed-routes`](references/route-typed-routes.md) - Enable typed routes
- [`route-drawer-navigator`](references/route-drawer-navigator.md) - Drawer navigator setup

### 3. Screen Patterns & Layouts (HIGH)

- [`screen-list-flashlist`](references/screen-list-flashlist.md) - FlashList for large lists
- [`screen-detail-params`](references/screen-detail-params.md) - Pass minimal data via params
- [`screen-loading-state`](references/screen-loading-state.md) - Loading and error states
- [`screen-pull-to-refresh`](references/screen-pull-to-refresh.md) - Pull-to-refresh pattern
- [`screen-header-options`](references/screen-header-options.md) - Configure screen headers
- [`screen-settings-list`](references/screen-settings-list.md) - Settings screen with SectionList

### 4. Data Fetching & State (HIGH)

- [`data-api-routes`](references/data-api-routes.md) - Server-side API routes
- [`data-secure-store`](references/data-secure-store.md) - SecureStore for sensitive data
- [`data-sqlite-local`](references/data-sqlite-local.md) - SQLite for complex local data
- [`data-fetch-on-focus`](references/data-fetch-on-focus.md) - Refetch on screen focus
- [`data-async-storage-simple`](references/data-async-storage-simple.md) - AsyncStorage for preferences
- [`data-abort-controller`](references/data-abort-controller.md) - Cancel fetch on unmount

### 5. Authentication & Security (HIGH)

- [`auth-protected-routes`](references/auth-protected-routes.md) - Stack.Protected guards
- [`auth-context-provider`](references/auth-context-provider.md) - Auth context with session
- [`auth-oauth-flow`](references/auth-oauth-flow.md) - OAuth with AuthSession
- [`auth-login-form`](references/auth-login-form.md) - Login form with validation
- [`auth-splash-loading`](references/auth-splash-loading.md) - Splash screen during auth check

### 6. Deep Linking & Universal Links (HIGH)

- [`link-deep-linking-scheme`](references/link-deep-linking-scheme.md) - Custom URL scheme
- [`link-universal-links-ios`](references/link-universal-links-ios.md) - iOS Universal Links
- [`link-android-app-links`](references/link-android-app-links.md) - Android App Links
- [`link-handle-incoming`](references/link-handle-incoming.md) - Handle incoming URLs

### 7. Native UX Patterns (MEDIUM-HIGH)

- [`ux-safe-area-insets`](references/ux-safe-area-insets.md) - SafeAreaView for notches
- [`ux-status-bar`](references/ux-status-bar.md) - Status bar styling
- [`ux-haptic-feedback`](references/ux-haptic-feedback.md) - Haptic feedback on actions
- [`ux-gesture-handler`](references/ux-gesture-handler.md) - Gesture handler for swipes
- [`ux-keyboard-avoiding`](references/ux-keyboard-avoiding.md) - KeyboardAvoidingView

### 8. Forms & User Input (MEDIUM)

- [`form-text-input-config`](references/form-text-input-config.md) - TextInput keyboard types
- [`form-controlled-inputs`](references/form-controlled-inputs.md) - Controlled inputs with useState
- [`form-submit-button-state`](references/form-submit-button-state.md) - Disable button during submit
- [`form-dismiss-keyboard`](references/form-dismiss-keyboard.md) - Dismiss keyboard on tap outside

### 9. Assets & Theming (MEDIUM)

- [`asset-image-optimization`](references/asset-image-optimization.md) - expo-image for caching
- [`asset-font-loading`](references/asset-font-loading.md) - Load fonts with useFonts
- [`asset-vector-icons`](references/asset-vector-icons.md) - @expo/vector-icons
- [`asset-splash-screen`](references/asset-splash-screen.md) - Splash screen configuration

### 10. Error Handling & Testing (MEDIUM)

- [`test-jest-setup`](references/test-jest-setup.md) - Jest with jest-expo preset
- [`test-component-testing`](references/test-component-testing.md) - Testing Library for components
- [`test-error-boundary`](references/test-error-boundary.md) - Error boundaries
- [`test-e2e-maestro`](references/test-e2e-maestro.md) - Maestro E2E testing

## Code Templates

Production-ready templates are available in `assets/templates/`:

| Template | Description |
|----------|-------------|
| `layouts/tab-layout.tsx` | Bottom tab navigator with icons |
| `layouts/auth-layout.tsx` | Root layout with protected routes |
| `screens/list-screen.tsx` | List with FlashList, refresh, states |
| `screens/detail-screen.tsx` | Detail screen with param handling |
| `screens/form-screen.tsx` | Form with validation, keyboard handling |
| `hooks/use-auth.tsx` | Auth context with SecureStore |
| `components/error-boundary.tsx` | Error boundary component |

## How to Use

Read individual reference files for detailed explanations and code examples:

- [Section definitions](references/_sections.md) - Category structure and impact levels
- [Rule template](assets/templates/_template.md) - Template for adding new rules

## Full Compiled Document

For a single comprehensive document with all rules, see [AGENTS.md](AGENTS.md).

## Reference Files

| File | Description |
|------|-------------|
| [AGENTS.md](AGENTS.md) | Complete compiled guide with all rules |
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/](assets/templates/) | Production-ready code templates |
| [metadata.json](metadata.json) | Version and reference information |
