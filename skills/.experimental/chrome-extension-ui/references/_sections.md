# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Component Selection (comp)

**Impact:** CRITICAL
**Description:** Choosing the right UI surface (popup, side panel, content script) determines the extension's UX ceiling and user engagement patterns.

## 2. Accessibility & Navigation (access)

**Impact:** CRITICAL
**Description:** Keyboard navigation, ARIA attributes, and focus management affect all users and are required for inclusive, usable extensions.

## 3. Popup Design (popup)

**Impact:** HIGH
**Description:** Popup constraints (size limits, auto-close behavior, no state persistence) require specific patterns to maximize usability in limited space.

## 4. Side Panel UX (panel)

**Impact:** HIGH
**Description:** Side panels enable persistent workflows alongside web content, requiring distraction-free design that enhances rather than interrupts browsing.

## 5. Content Script UI (inject)

**Impact:** MEDIUM-HIGH
**Description:** Injecting UI into web pages requires style isolation, performance awareness, and careful conflict avoidance with host page elements.

## 6. Visual Feedback (feedback)

**Impact:** MEDIUM
**Description:** Loading states, error handling, badges, and notifications communicate extension state and build user trust through responsive feedback.

## 7. Options & Settings (options)

**Impact:** MEDIUM
**Description:** Settings pages need intuitive organization, proper persistence with chrome.storage, and sync capabilities across user devices.

## 8. Icons & Branding (brand)

**Impact:** LOW-MEDIUM
**Description:** Icon design, badge text, and visual consistency reinforce brand recognition and professional appearance in the browser toolbar.
