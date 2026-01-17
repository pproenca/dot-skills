# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Build Configuration (build)

**Impact:** CRITICAL
**Description:** Build tooling decisions cascade through the entire pipeline. Vite plugin vs PostCSS, content detection, and configuration approach determine baseline performance with 5-100× build time differences.

## 2. CSS Generation (gen)

**Impact:** CRITICAL
**Description:** How utilities are generated affects bundle size by 2-10×. @theme overuse, duplicate utilities, and JIT inefficiencies bloat CSS output and slow browser parsing.

## 3. Bundle Optimization (bundle)

**Impact:** HIGH
**Description:** CSS delivery impacts Core Web Vitals directly. Unused styles, missing compression, and suboptimal code splitting delay LCP and FCP by 100-500ms.

## 4. Utility Patterns (util)

**Impact:** HIGH
**Description:** Choosing correct utilities prevents layout thrashing and repaints. Class ordering, responsive variants, and utility composition affect browser rendering work.

## 5. Component Architecture (comp)

**Impact:** MEDIUM-HIGH
**Description:** How styles are organized in components affects maintainability and runtime performance. @apply misuse, extraction patterns, and variant usage impact both bundle size and DX.

## 6. Theming & Design Tokens (theme)

**Impact:** MEDIUM
**Description:** @theme directive usage, CSS variable organization, and dark mode implementation affect bundle size, runtime flexibility, and cascade layer efficiency.

## 7. Responsive & Adaptive (resp)

**Impact:** MEDIUM
**Description:** Breakpoint strategies, container queries, and adaptive patterns impact layout performance and CSS complexity. Mobile-first vs desktop-first affects generated CSS size.

## 8. Animation & Transitions (anim)

**Impact:** LOW-MEDIUM
**Description:** GPU-accelerated vs layout-triggering animations, transition utilities, and @starting-style usage affect paint performance and visual smoothness.
