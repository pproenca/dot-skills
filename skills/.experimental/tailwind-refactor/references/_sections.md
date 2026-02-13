# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Configuration Migration (config)

**Impact:** CRITICAL
**Description:** Migrating from JavaScript config to CSS-first `@theme`, `@import`, and `@utility` directives affects the entire project foundation and unlocks all v4 features.

## 2. Deprecated Utility Replacement (dep)

**Impact:** CRITICAL
**Description:** Utilities removed in v4 (`bg-opacity-*`, `flex-shrink-*`, `overflow-ellipsis`) cause build failures and must be replaced with their modern equivalents.

## 3. Renamed Utility Updates (rename)

**Impact:** HIGH
**Description:** Utilities renamed in v4 (`shadow-sm`→`shadow-xs`, `rounded-sm`→`rounded-xs`, `bg-gradient-*`→`bg-linear-*`) produce incorrect styles if not updated.

## 4. Class Consolidation (class)

**Impact:** HIGH
**Description:** Verbose multi-class patterns (`w-8 h-8`, `space-y-4`) can be replaced with single utilities (`size-8`, `gap-4`), reducing class count by 30-50%.

## 5. Arbitrary Value Cleanup (arb)

**Impact:** MEDIUM-HIGH
**Description:** Inline hex colors, magic numbers, and dynamic class construction create design drift and break Tailwind's purge — replace with `@theme` tokens.

## 6. Syntax Modernization (syntax)

**Impact:** MEDIUM
**Description:** Updating to v4 syntax patterns (CSS variable references, variant stacking order, important modifiers) prevents subtle bugs and improves consistency.

## 7. @apply & Architecture Cleanup (arch)

**Impact:** MEDIUM
**Description:** Reducing `@apply` overuse, migrating `@layer components` to `@utility`, and extracting components improves maintainability without changing visual output.

## 8. Modern Feature Adoption (adopt)

**Impact:** LOW-MEDIUM
**Description:** Leveraging new v4 features (container queries, `not-*` variant, `in-*` variant, `field-sizing-content`) produces cleaner markup for patterns that previously required workarounds.
