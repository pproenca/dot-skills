# Sections

This file defines the categories and their order. The prefix in parentheses is
the filename prefix that groups rules. The order is the gate's fix-list priority —
violations in earlier categories cost more to leave in and are listed first in a
FAIL verdict.

---

## 1. Directory Structure (struct)

**Description:** Where code lives — feature folders over technical-type folders, a self-contained feature layout, a genuinely-shared `shared/` layer, and routing/provider composition owned by the app layer. Wrong structure cascades into every later category.

## 2. Import & Dependencies (import)

**Description:** Unidirectional flow (shared → features → app), no cross-feature imports, public-API-only access into features, no chained wildcard barrels, aliases over relative chains, and type-only import syntax.

## 3. Module Boundaries (bound)

**Description:** The contracts between features — typed props on exported components, feature-owned route builders instead of hardcoded path literals, and a minimal whitelist for global state.

## 4. Data Fetching (fquery)

**Description:** Query functions colocated with their feature, single-responsibility per query, feature-scoped query keys, parallel over sequential fetching, no N+1 loops, and server-component fetching where RSC exists.

## 5. Component Organization (fcomp)

**Description:** Composition over prop drilling, styles colocated with their components, and error boundaries isolating sibling feature roots.

## 6. State Management (fstate)

**Description:** Stores scoped to one business domain each, and server state kept out of client stores when a query library is present.

## 7. Testing Strategy (test)

**Description:** Tests colocated with their feature, unit tests isolated from other features' real providers, shared test utilities placed by ownership, and multi-feature integration tests at the app layer.

## 8. Naming Conventions (name)

**Description:** Singular domain-named feature folders, one consistent file-casing convention, and domain-descriptive export names from feature folders.
