# React Feature-Based Architecture

**Version 0.1.0**  
Community  
January 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive architecture guide for organizing React applications by features, enabling scalable development with independent teams. Contains 42 rules across 8 categories, prioritized by impact from critical (directory structure and import rules) to incremental (naming conventions). Each rule includes detailed explanations, production-realistic code examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated refactoring and code generation.

---

## Table of Contents

1. [Directory Structure](references/_sections.md#1-directory-structure) — **CRITICAL**
   - 1.1 [Include Only Necessary Segments](references/struct-optional-segments.md) — HIGH (Prevents empty folder clutter; keeps features minimal and focused)
   - 1.2 [Keep Directory Hierarchy Flat](references/struct-flat-hierarchy.md) — CRITICAL (Reduces cognitive load; prevents 5+ level deep import paths)
   - 1.3 [Make Features Self-Contained](references/struct-feature-self-contained.md) — CRITICAL (Enables independent deployment and parallel team development)
   - 1.4 [Organize by Feature, Not Technical Type](references/struct-feature-folders.md) — CRITICAL (Eliminates cross-file navigation; reduces onboarding time by 50%+)
   - 1.5 [Separate App Layer from Features](references/struct-app-layer.md) — HIGH (Isolates global concerns; enables feature modules to remain pure)
   - 1.6 [Use Shared Layer for Truly Generic Code Only](references/struct-shared-layer.md) — CRITICAL (Prevents shared/ from becoming a dumping ground; maintains feature boundaries)
2. [Import & Dependencies](references/_sections.md#2-import-&-dependencies) — **CRITICAL**
   - 2.1 [Avoid Deep Barrel File Re-exports](references/import-avoid-barrel-files.md) — HIGH (Prevents tree-shaking failures; reduces bundle size by avoiding unused code)
   - 2.2 [Enforce Unidirectional Import Flow](references/import-unidirectional-flow.md) — CRITICAL (Prevents circular dependencies; enables deterministic build order)
   - 2.3 [Export Through Public API Only](references/import-public-api.md) — CRITICAL (Prevents deep imports; enables internal refactoring without breaking consumers)
   - 2.4 [Prohibit Cross-Feature Imports](references/import-no-cross-feature.md) — CRITICAL (Prevents feature coupling; enables independent feature development)
   - 2.5 [Use Consistent Path Aliases](references/import-path-aliases.md) — HIGH (Eliminates ../../../ chains; makes imports self-documenting)
   - 2.6 [Use Type-Only Imports for Types](references/import-type-only.md) — MEDIUM (Enables cross-feature type sharing without runtime coupling)
3. [Module Boundaries](references/_sections.md#3-module-boundaries) — **HIGH**
   - 3.1 [Define Explicit Interface Contracts](references/bound-interface-contracts.md) — HIGH (Prevents implicit dependencies; enables parallel feature development)
   - 3.2 [Enforce Feature Isolation](references/bound-feature-isolation.md) — HIGH (Changes in one feature have zero impact on others; enables fearless refactoring)
   - 3.3 [Keep Features Appropriately Sized](references/bound-feature-size.md) — MEDIUM (Right-sized features balance cohesion and manageability)
   - 3.4 [Minimize Shared State Between Features](references/bound-minimize-shared-state.md) — HIGH (Reduces coupling surface area; prevents state synchronization bugs)
   - 3.5 [Scope Routing to Feature Concerns](references/bound-feature-scoped-routing.md) — HIGH (Enables feature-level code splitting; prevents routing configuration sprawl)
   - 3.6 [Use Events for Cross-Feature Communication](references/bound-event-based-communication.md) — MEDIUM-HIGH (Decouples features at runtime; enables loose coupling without direct imports)
4. [Data Fetching](references/_sections.md#4-data-fetching) — **HIGH**
   - 4.1 [Avoid N+1 Query Patterns](references/fquery-avoid-n-plus-one.md) — HIGH (Prevents request count from scaling with data size; eliminates O(N) network calls)
   - 4.2 [Colocate Data Fetching with Features](references/fquery-colocate-with-feature.md) — HIGH (Makes features self-contained; enables independent API evolution)
   - 4.3 [Fetch at Server Component Level](references/fquery-server-component-fetching.md) — MEDIUM-HIGH (Eliminates client-server waterfalls; reduces bundle size by keeping fetch logic on server)
   - 4.4 [Fetch Independent Data in Parallel](references/fquery-parallel-fetching.md) — HIGH (Reduces total load time by ~50% for pages with multiple data sources)
   - 4.5 [Keep Query Functions Single-Purpose](references/fquery-single-responsibility.md) — HIGH (Prevents query permutation explosion as features grow)
   - 4.6 [Use Feature-Scoped Query Keys](references/fquery-feature-scoped-keys.md) — MEDIUM-HIGH (Enables targeted cache invalidation; prevents accidental cache collisions)
5. [Component Organization](references/_sections.md#5-component-organization) — **MEDIUM-HIGH**
   - 5.1 [Apply Single Responsibility to Components](references/fcomp-single-responsibility.md) — MEDIUM-HIGH (Enables parallel development and isolated testing; reduces component complexity)
   - 5.2 [Colocate Styles with Components](references/fcomp-colocate-styles.md) — MEDIUM (Enables complete component portability; prevents orphaned styles)
   - 5.3 [Prefer Composition Over Prop Drilling](references/fcomp-composition-over-props.md) — MEDIUM-HIGH (Eliminates prop drilling; enables flexible slot-based component design)
   - 5.4 [Separate Container and Presentational Concerns](references/fcomp-container-presentational.md) — MEDIUM (Enables design system reuse; keeps business logic testable)
   - 5.5 [Use Feature-Level Error Boundaries](references/fcomp-error-boundaries.md) — MEDIUM (Isolates failures to single features; prevents full-page crashes)
   - 5.6 [Use Props as Feature Boundaries](references/fcomp-props-as-data-boundary.md) — MEDIUM-HIGH (Creates clear interfaces between features; enables feature composition)
6. [State Management](references/_sections.md#6-state-management) — **MEDIUM**
   - 6.1 [Lift State Only as High as Necessary](references/fstate-lift-minimally.md) — MEDIUM (Reduces re-renders; keeps state close to where it's used)
   - 6.2 [Reset Feature State on Unmount](references/fstate-reset-on-unmount.md) — MEDIUM (Prevents stale state bugs; ensures clean feature initialization)
   - 6.3 [Scope State Stores to Features](references/fstate-feature-scoped-stores.md) — MEDIUM (Prevents global state coupling; enables feature-level state reset and testing)
   - 6.4 [Separate Server State from Client State](references/fstate-server-state-separation.md) — MEDIUM (Eliminates manual cache sync; leverages query library optimizations)
   - 6.5 [Use Context Sparingly for Feature State](references/fstate-context-sparingly.md) — MEDIUM (Prevents context re-render cascades; keeps features portable)
7. [Testing Strategy](references/_sections.md#7-testing-strategy) — **MEDIUM**
   - 7.1 [Colocate Tests with Features](references/test-colocate-with-feature.md) — MEDIUM (Makes test coverage visible; ensures tests move with features)
   - 7.2 [Create Feature-Specific Test Utilities](references/test-shared-utilities.md) — MEDIUM (Reduces test boilerplate; ensures consistent test setup)
   - 7.3 [Test Features in Isolation](references/test-feature-isolation.md) — MEDIUM (Enables faster tests; provides clear failure attribution)
   - 7.4 [Write Integration Tests at App Layer](references/test-integration-at-app-layer.md) — MEDIUM (Verifies feature composition; catches integration bugs)
8. [Naming Conventions](references/_sections.md#8-naming-conventions) — **LOW**
   - 8.1 [Use Consistent File Naming Conventions](references/name-file-conventions.md) — LOW (Enables pattern-based tooling; reduces cognitive load)
   - 8.2 [Use Descriptive Export Names](references/name-descriptive-exports.md) — LOW (Enables IDE autocomplete; makes imports self-documenting)
   - 8.3 [Use Domain-Driven Feature Names](references/name-feature-naming.md) — LOW (Improves discoverability; aligns code with business terminology)

---

## References

1. [https://www.robinwieruch.de/react-feature-architecture/](https://www.robinwieruch.de/react-feature-architecture/)
2. [https://feature-sliced.design/](https://feature-sliced.design/)
3. [https://github.com/alan2207/bulletproof-react/blob/master/docs/project-structure.md](https://github.com/alan2207/bulletproof-react/blob/master/docs/project-structure.md)
4. [https://legacy.reactjs.org/docs/faq-structure.html](https://legacy.reactjs.org/docs/faq-structure.html)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |