# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Design Decisions (decide)

**Impact:** CRITICAL
**Description:** Premature abstraction is the #1 design system killer in Rails. Knowing WHEN to extract a partial, component, or helper — and when to leave inline HTML alone — prevents codebase bloat and yields the largest maintainability gains.

## 2. Design Tokens (token)

**Impact:** CRITICAL
**Description:** A shared vocabulary of colors, spacing, typography, and radii eliminates visual inconsistency at the root. Tokens defined once propagate everywhere, making sweeping visual changes a single-line edit.

## 3. Partial Patterns (partial)

**Impact:** HIGH
**Description:** ERB partials handle 80% of Rails view reuse. Well-structured partials with explicit locals, collection rendering, and presenter objects reduce duplication without introducing component framework overhead.

## 4. Component Architecture (comp)

**Impact:** HIGH
**Description:** ViewComponent and Phlex provide testable, encapsulated view units for the 20% of UI that outgrows partials — complex conditional rendering, multi-slot layouts, and cross-cutting patterns used in 3+ contexts.

## 5. Form System (form)

**Impact:** MEDIUM-HIGH
**Description:** A custom FormBuilder enforces consistent labels, error display, help text, and accessibility across every form in the application. Forms are the highest-interaction surface and the most duplicated UI pattern.

## 6. Helper Patterns (helper)

**Impact:** MEDIUM
**Description:** View helpers generate small HTML fragments with logic — badges, status indicators, conditional classes. They fill the gap between inline ERB and full partials for output that is too small to warrant a file.

## 7. Stimulus Behaviors (stim)

**Impact:** MEDIUM
**Description:** Stimulus controllers provide the JavaScript behavior layer — toggles, dropdowns, copy-to-clipboard, form validation. Small, composable controllers replace JavaScript soup with declarative data attributes.

## 8. Consistency & Organization (org)

**Impact:** LOW-MEDIUM
**Description:** Naming conventions, file structure, Lookbook documentation, and deduplication audits prevent design system drift as the team and codebase grow.
