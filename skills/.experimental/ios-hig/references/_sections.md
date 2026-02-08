# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Interaction Design (inter)

**Impact:** CRITICAL
**Description:** Touch targets, gestures, haptics, keyboard handling, and swipe actions define how users physically interact with your app. Getting these wrong breaks the native iOS feel.

## 2. User Feedback (feed)

**Impact:** HIGH
**Description:** Loading states, error handling, notifications, success confirmation, and empty states communicate system status to users. Clear feedback builds trust and reduces confusion.

## 3. UX Patterns (ux)

**Impact:** HIGH
**Description:** Onboarding, permissions, modality, data entry, undo, and settings organization follow Apple's established patterns that users already understand.

## 4. Accessibility (acc)

**Impact:** CRITICAL
**Description:** VoiceOver labels, Dynamic Type, color contrast, reduce motion, and focus management are not optional. Accessibility support is required for App Store quality and reaches 15%+ of users.

## 5. Lists & Input (input)

**Impact:** MEDIUM-HIGH
**Description:** ForEach patterns, toggles, pickers, text fields, and button actions are the building blocks of interactive forms and data-driven lists.

## 6. List Data (list)

**Impact:** MEDIUM
**Description:** Identifiable data patterns ensure SwiftUI can efficiently diff and animate list changes.
