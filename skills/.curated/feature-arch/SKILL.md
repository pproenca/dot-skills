---
name: feature-arch
description: React feature-based architecture guidelines for scalable applications. This skill should be used when writing, reviewing, or refactoring React code to ensure proper feature organization. When invoked on a project, the agent produces a concrete target-architecture blueprint at docs/architecture/FEATURE-ARCH-TARGET.md showing the desired directory tree, per-feature public APIs, import-boundary matrix, and a numbered migration plan. Triggers on tasks involving project structure, feature organization, module boundaries, cross-feature imports, data fetching patterns, or component composition.
---

# Feature-Based Architecture Best Practices

Comprehensive architecture guide for organizing React applications by features, enabling scalable development with independent teams. Contains 42 rules across 8 categories, prioritized by impact from critical (directory structure, imports) to incremental (naming conventions). When invoked on a real project, the skill produces a project-specific blueprint that anchors every decision in those rules.

## Primary Output: The Target Architecture Blueprint

When an agent invokes this skill on a real project, the deliverable is a single
markdown file persisted at `docs/architecture/FEATURE-ARCH-TARGET.md` (or the
repo's existing docs location). The blueprint contains:

1. **Project context** — framework, state libraries, routing model, current shape.
2. **Identified features** — confirmed with the user, sourced from routes, docs, openspec, and code clusters.
3. **Target directory tree** — literal paths, not pseudo-trees.
4. **Per-feature public APIs** — exact named exports of each `index.ts`.
5. **Import-boundary matrix** — N×N table of feature relationships (`allowed` / `forbidden` / `via app` / `via events`).
6. **State & data ownership** — server-state and client-state owner per feature.
7. **Cross-feature communication policy** — composition, events, or shared slice — with rationale.
8. **Numbered migration plan** — file-level move/create/delete steps with S/M/L effort estimates.
9. **Human conformance checklist** — for code review and "definition of done".
10. **Open questions** — anything that needs a human decision before migration.

Every section cites the specific rules below that govern its decisions, so the
blueprint stays a projection of this skill — not a parallel authority.

### How the agent generates the blueprint

Follow the process in [references/_blueprint-process.md](references/_blueprint-process.md). Summary:

1. Gather context (package.json, src/ tree, README, CLAUDE.md, openspec/).
2. Identify candidate features from routes, docs, and code clusters.
3. Confirm the feature list with the user via `AskUserQuestion`.
4. Record explicit decisions (layer model, comm mechanism, state/routing owner).
5. Fill in [assets/templates/feature-arch-target.md.template](assets/templates/feature-arch-target.md.template) — every `{{placeholder}}` replaced with a literal project value.
6. Hand off: print path, summarise feature/step counts, list top-3 risks, suggest next action. Do not start executing migration steps in the same turn.

For very small projects (under ~10 source files), produce a one-page seed
structure instead and note that a full blueprint should follow after the 2nd–3rd
feature exists.

## When to Apply

Reference these guidelines when:
- A project asks for a feature-based architecture target (generate the blueprint).
- Creating new features or modules.
- Organizing project directory structure.
- Setting up import rules and boundaries.
- Implementing data fetching patterns.
- Composing components from multiple features.
- Reviewing code for architecture violations.

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Directory Structure | CRITICAL | `struct-` |
| 2 | Import & Dependencies | CRITICAL | `import-` |
| 3 | Module Boundaries | HIGH | `bound-` |
| 4 | Data Fetching | HIGH | `fquery-` |
| 5 | Component Organization | MEDIUM-HIGH | `fcomp-` |
| 6 | State Management | MEDIUM | `fstate-` |
| 7 | Testing Strategy | MEDIUM | `test-` |
| 8 | Naming Conventions | LOW | `name-` |

## Quick Reference

### 1. Directory Structure (CRITICAL)

- `struct-feature-folders` - Organize by feature, not technical type
- `struct-feature-self-contained` - Make features self-contained
- `struct-shared-layer` - Use shared layer for truly generic code only
- `struct-flat-hierarchy` - Keep directory hierarchy flat
- `struct-optional-segments` - Include only necessary segments
- `struct-app-layer` - Separate app layer from features

### 2. Import & Dependencies (CRITICAL)

- `import-unidirectional-flow` - Enforce unidirectional import flow
- `import-no-cross-feature` - Prohibit cross-feature imports
- `import-public-api` - Export through public API only
- `import-avoid-barrel-files` - Avoid deep barrel file re-exports
- `import-path-aliases` - Use consistent path aliases
- `import-type-only` - Use type-only imports for types

### 3. Module Boundaries (HIGH)

- `bound-feature-isolation` - Enforce feature isolation
- `bound-interface-contracts` - Define explicit interface contracts
- `bound-feature-scoped-routing` - Scope routing to feature concerns
- `bound-minimize-shared-state` - Minimize shared state between features
- `bound-event-based-communication` - Use events for cross-feature communication
- `bound-feature-size` - Keep features appropriately sized

### 4. Data Fetching (HIGH)

- `fquery-single-responsibility` - Keep query functions single-purpose
- `fquery-colocate-with-feature` - Colocate data fetching with features
- `fquery-parallel-fetching` - Fetch independent data in parallel
- `fquery-avoid-n-plus-one` - Avoid N+1 query patterns
- `fquery-feature-scoped-keys` - Use feature-scoped query keys
- `fquery-server-component-fetching` - Fetch at server component level

### 5. Component Organization (MEDIUM-HIGH)

- `fcomp-single-responsibility` - Apply single responsibility to components
- `fcomp-composition-over-props` - Prefer composition over prop drilling
- `fcomp-container-presentational` - Separate container and presentational concerns
- `fcomp-props-as-data-boundary` - Use props as feature boundaries
- `fcomp-colocate-styles` - Colocate styles with components
- `fcomp-error-boundaries` - Use feature-level error boundaries

### 6. State Management (MEDIUM)

- `fstate-feature-scoped-stores` - Scope state stores to features
- `fstate-server-state-separation` - Separate server state from client state
- `fstate-lift-minimally` - Lift state only as high as necessary
- `fstate-context-sparingly` - Use context sparingly for feature state
- `fstate-reset-on-unmount` - Reset feature state on unmount

### 7. Testing Strategy (MEDIUM)

- `test-colocate-with-feature` - Colocate tests with features
- `test-feature-isolation` - Test features in isolation
- `test-shared-utilities` - Create feature-specific test utilities
- `test-integration-at-app-layer` - Write integration tests at app layer

### 8. Naming Conventions (LOW)

- `name-feature-naming` - Use domain-driven feature names
- `name-file-conventions` - Use consistent file naming conventions
- `name-descriptive-exports` - Use descriptive export names

## How to Use

Read individual reference files for detailed explanations and code examples:

- [Blueprint process](references/_blueprint-process.md) - How to derive a project-specific target architecture
- [Blueprint template](assets/templates/feature-arch-target.md.template) - Template the agent fills in to produce the end-state document
- [Section definitions](references/_sections.md) - Category structure and impact levels
- [Rule template](assets/templates/_template.md) - Template for adding new rules
- Individual rules: `references/{prefix}-{slug}.md`

## Related Skills

- For feature planning, see `feature-spec` skill
- For data fetching, see `tanstack-query` skill
- For React component patterns, see `react-19` skill

## Full Compiled Document

For the complete guide with all rules expanded: `AGENTS.md`
