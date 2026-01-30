# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Query Selection (query)

**Impact:** CRITICAL
**Description:** Choosing the right query determines test reliability. Wrong queries test implementation details instead of user-visible behavior.

## 2. Async Handling (async)

**Impact:** CRITICAL
**Description:** Improper async handling causes flaky tests, race conditions, and false positives. Always await async operations correctly.

## 3. Common Anti-Patterns (anti)

**Impact:** CRITICAL
**Description:** Avoiding the most common mistakes that break tests or give false confidence. These patterns actively harm test quality.

## 4. User Interaction (user)

**Impact:** HIGH
**Description:** Using userEvent over fireEvent ensures realistic browser behavior and accessibility checks during interaction simulation.

## 5. Assertions (assert)

**Impact:** HIGH
**Description:** Using the right assertions with jest-dom matchers provides clearer error messages and tests the correct properties.

## 6. Component Setup (setup)

**Impact:** MEDIUM
**Description:** Efficient setup patterns reduce test coupling, improve speed, and make tests more maintainable.

## 7. Test Structure (struct)

**Impact:** MEDIUM
**Description:** Well-organized tests are easier to understand, maintain, and debug when failures occur.

## 8. Debugging (debug)

**Impact:** LOW-MEDIUM
**Description:** Effective debugging tools speed up test development and help diagnose failures quickly.

## 9. Accessibility Testing (a11y)

**Impact:** LOW
**Description:** Leveraging RTL's accessibility-first design to verify components meet accessibility requirements.
