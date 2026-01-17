# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Directory Structure (struct)

**Impact:** CRITICAL
**Description:** Foundation decisions that cascade through all development; wrong structure requires costly rewrites as application scales.

## 2. Import & Dependencies (import)

**Impact:** CRITICAL
**Description:** Enforces unidirectional data flow and prevents circular dependencies that cause build failures and runtime bugs.

## 3. Module Boundaries (bound)

**Impact:** HIGH
**Description:** Maintains feature isolation preventing changes in one area from causing regressions across the codebase.

## 4. Data Fetching (fquery)

**Impact:** HIGH
**Description:** Keeps data logic domain-focused and prevents N+1 query patterns that multiply as features grow.

## 5. Component Organization (fcomp)

**Impact:** MEDIUM-HIGH
**Description:** Single-responsibility components enable parallel development and isolated testing.

## 6. State Management (fstate)

**Impact:** MEDIUM
**Description:** Feature-scoped state prevents global coupling and enables features to be developed independently.

## 7. Testing Strategy (test)

**Impact:** MEDIUM
**Description:** Feature isolation enables faster test execution and clearer failure attribution.

## 8. Naming Conventions (name)

**Impact:** LOW
**Description:** Consistent naming aids navigation and onboarding but has no runtime impact.
