# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. CLI & Project Setup (setup)

**Impact:** CRITICAL
**Description:** Correct initialization and configuration prevents cascading setup issues across all components and ensures proper path resolution.

## 2. Component Composition (comp)

**Impact:** CRITICAL
**Description:** shadcn/ui's core philosophy centers on composable patterns over wrapping or overriding, yielding maintainable and extensible code.

## 3. Styling & Theming (style)

**Impact:** HIGH
**Description:** CSS variables, the cn utility, and CVA variants determine a consistent visual system across light and dark modes.

## 4. Accessibility Patterns (access)

**Impact:** HIGH
**Description:** Radix primitives provide the foundation but require correct implementation for screen readers, keyboard navigation, and ARIA attributes.

## 5. Form Integration (form)

**Impact:** MEDIUM-HIGH
**Description:** React Hook Form and TanStack Form integration with Field components enables proper validation, error handling, and accessibility.

## 6. Data Display Components (data)

**Impact:** MEDIUM
**Description:** TanStack Table integration with pagination, sorting, and filtering patterns creates powerful data interfaces.

## 7. Layout & Navigation (layout)

**Impact:** MEDIUM
**Description:** Sidebar, navigation menu, and responsive patterns establish consistent application structure and user navigation.

## 8. Performance Optimization (perf)

**Impact:** LOW-MEDIUM
**Description:** Bundle size reduction through dynamic imports and preventing unnecessary re-renders improves application responsiveness.
