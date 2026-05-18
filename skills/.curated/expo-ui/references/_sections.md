# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Setup & Host Boundaries (host)

**Impact:** CRITICAL  
**Description:** The `Host` component is the bridge between React Native and SwiftUI. Misconfigured Host boundaries (missing wrapper, wrong sizing mode, nested React Native views) cause every downstream component to fail layout or rendering.

## 2. iOS 26 HIG Composition Rules (hig)

**Impact:** CRITICAL  
**Description:** Apple's Human Interface Guidelines define which components compose, which conflict, and how Liquid Glass material must be applied. Violations look broken to users and break the Liquid Glass appearance entirely.

## 3. Modifiers System (mod)

**Impact:** CRITICAL  
**Description:** Every component in `@expo/ui/swift-ui` accepts a `modifiers` array — applying styles through React Native's `style` prop silently does nothing. Modifier composition order also affects visual outcome.

## 4. Layout Components (layout)

**Impact:** HIGH  
**Description:** Stack/Grid/Form/ScrollView/Section choices wrap every component below them. Wrong layout container forces children into the wrong native rendering pipeline (e.g., Form chrome vs raw ScrollView).

## 5. Input & Controls (input)

**Impact:** HIGH  
**Description:** Button, TextField, Toggle, Picker, Slider, Stepper, DatePicker, ColorPicker. Controlled-vs-uncontrolled mistakes and missing `role`/`style` modifiers produce inputs that look wrong, lose focus, or skip native validation.

## 6. Navigation & Overlays (nav)

**Impact:** HIGH  
**Description:** Alert, ConfirmationDialog, BottomSheet, Popover, Menu, ContextMenu, SwipeActions, TabView, DisclosureGroup, ShareLink, Link. HIG-conflicting combinations (popover on iPhone, stacked modals, swipe + context menu on the same row) confuse users.

## 7. Display & Feedback (display)

**Impact:** MEDIUM-HIGH  
**Description:** Text, Image, Label, Chart, Gauge, ProgressView, Divider. Surface area is large but errors are local — wrong systemName, missing markdown flag, indeterminate progress misconfigured.

## 8. State & Cross-Cutting Patterns (state)

**Impact:** MEDIUM  
**Description:** `useNativeState`, ObservableState worklet writes, controlled vs uncontrolled props, platform availability guards, imperative refs (TextFieldRef). These patterns recur across every interactive component.
