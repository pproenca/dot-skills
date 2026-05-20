# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

These rules govern how an Expo (React Native) app, written in TypeScript, should be
built so it feels like a genuine iOS 26 app under Apple's Human Interface Guidelines.
Code examples are TSX/Expo — not Swift. Where dropping to native is the right call, the
rules point to `@expo/ui`, `expo-glass-effect`, and `expo-symbols` rather than re-document
their APIs.

---

## 1. Native Navigation Architecture (nav)

**Impact:** CRITICAL  
**Description:** Navigation is the frame every screen sits inside. A JavaScript-faked stack or tab bar reads as a web wrapper no matter how polished the screens are — gestures lag, headers don't blur, large titles don't collapse, and iOS 26 Liquid Glass chrome never appears. Choosing Expo Router's native stack and native tabs is the single decision that decides whether the app feels native.

## 2. Native Component Fidelity (native)

**Impact:** CRITICAL  
**Description:** Re-implementing iOS controls in JavaScript (custom switches, web-style dropdowns, Material dialogs) makes every interaction fight muscle memory users already have. Reaching for the platform's own Alert, action sheet, date picker, switch, context menu, share sheet, and SF Symbols inherits correct behavior, animation, accessibility, and appearance for free across every iOS version.

## 3. Layout & Adaptivity (layout)

**Impact:** HIGH  
**Description:** Content that ignores the safe area, the keyboard, dark mode, or larger text sizes breaks on real hardware the moment it leaves the simulator default. Safe-area insets, edge-to-edge backgrounds, keyboard avoidance, semantic colors, and content insets are what let one layout adapt across notches, Dynamic Island, orientation, and appearance modes.

## 4. Touch, Gestures & Haptics (touch)

**Impact:** HIGH  
**Description:** The native feel of iOS lives in the hand: 44pt targets, instant press feedback, swipe-to-delete, pull-to-refresh, the interactive swipe-back edge, and haptics that confirm outcomes. Gestures driven from the JavaScript thread stutter under load; the platform's own gesture and haptic primitives keep interaction crisp and predictable.

## 5. Visual System & Liquid Glass (visual)

**Impact:** HIGH  
**Description:** A coherent visual system — semantic system colors that track appearance, the system font and its Dynamic Type scale, a consistent spacing rhythm, restrained tint, and correctly applied iOS 26 materials and Liquid Glass — is what makes screens look like they belong to the OS. Hardcoded hex, ad-hoc spacing, and faked blur are the tells of a non-native app.

## 6. Motion & Feedback (motion)

**Impact:** MEDIUM-HIGH  
**Description:** Motion communicates state and spatial relationships, but only at 60/120fps. Animations driven on the JavaScript thread drop frames under load; running them on the UI thread with worklets keeps them smooth. Honest loading, empty, and error states — plus optimistic updates — make the app feel responsive even when the network is not.

## 7. Accessibility (acc)

**Impact:** MEDIUM-HIGH  
**Description:** Accessibility is an App Store quality bar and reaches the large share of users who rely on VoiceOver, larger text, or reduced motion. Accessibility roles and labels, Dynamic Type that is allowed to scale, Reduce Motion alternatives, sufficient contrast, and a logical focus order are what make an Expo app usable by everyone, not just the developer.

## 8. System Integration & Polish (system)

**Impact:** MEDIUM  
**Description:** The final layer that signals craft: permission prompts requested just in time with honest purpose strings, a correct status bar and appearance, a real app icon and launch experience, the right keyboard for each field, and deep links that resume context. These details are what separate a shipped product from a prototype.
