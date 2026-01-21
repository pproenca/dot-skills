# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Component Architecture (arch)

**Impact:** CRITICAL
**Description:** Proper component structure and Radix primitive usage is foundational - architectural mistakes cascade to every consumer and are costly to fix.

## 2. Accessibility Preservation (ally)

**Impact:** CRITICAL
**Description:** shadcn/ui inherits WAI-ARIA compliance from Radix UI - breaking accessibility patterns excludes users and violates legal requirements.

## 3. Styling & Theming (style)

**Impact:** HIGH
**Description:** Consistent Tailwind and CSS variable usage ensures visual coherence and maintainable theming across the entire application.

## 4. Form Patterns (form)

**Impact:** HIGH
**Description:** Forms are critical UX touchpoints - proper React Hook Form and Zod integration ensures data integrity and user experience.

## 5. Data Display (data)

**Impact:** MEDIUM-HIGH
**Description:** Tables, lists, and data visualization patterns affect how users interact with large datasets and complex information.

## 6. Component Composition (comp)

**Impact:** MEDIUM
**Description:** Combining shadcn/ui primitives using compound component patterns maximizes reusability and maintains API consistency.

## 7. Performance Optimization (perf)

**Impact:** MEDIUM
**Description:** Bundle size management, lazy loading, and render optimization ensure fast load times and smooth interactions.

## 8. State Management (state)

**Impact:** LOW-MEDIUM
**Description:** Controlled vs uncontrolled patterns and state lifting decisions affect component predictability and debugging.
