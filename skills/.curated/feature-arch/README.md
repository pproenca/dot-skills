# Feature-Based Architecture Skill

A comprehensive guide for organizing React applications using feature-based architecture patterns. This skill helps ensure scalable, maintainable codebases by enforcing proper feature isolation, import boundaries, and composition patterns.

When an agent invokes this skill on a real project, it produces a concrete
target-architecture blueprint at `docs/architecture/FEATURE-ARCH-TARGET.md`
showing exactly what the project's feature-based structure should look like —
directory tree, public APIs, import-boundary matrix, and a numbered migration
plan. See [`references/_blueprint-process.md`](references/_blueprint-process.md)
for the discovery and generation workflow, and
[`assets/templates/feature-arch-target.md.template`](assets/templates/feature-arch-target.md.template)
for the deliverable shape.

## Overview

Feature-based architecture organizes code by business domain rather than technical concerns. Instead of grouping all components in one folder and all hooks in another, code is grouped by the feature it belongs to (user, cart, checkout, etc.).

## Key Principles

1. **Feature Isolation**: Each feature is self-contained and can be developed, tested, and deployed independently
2. **Unidirectional Imports**: `shared → features → app` - no backwards imports
3. **No Cross-Feature Imports**: Features compose at the app layer, not by importing from each other
4. **Colocated Code**: Tests, styles, and utilities live with the feature they belong to

## Structure

```
.claude/skills/feature-based-architecture/
├── SKILL.md          # Entry point with quick reference
├── AGENTS.md         # Compiled comprehensive guide (generated)
├── metadata.json     # Version and reference information
├── README.md         # This file
└── rules/
    ├── _sections.md  # Category definitions
    ├── _template.md  # Rule template
    └── *.md          # 42 individual rules
```

## Categories

| Category | Prefix | Impact | Rules |
|----------|--------|--------|-------|
| Directory Structure | `struct-` | CRITICAL | 6 |
| Import & Dependencies | `import-` | CRITICAL | 6 |
| Module Boundaries | `bound-` | HIGH | 6 |
| Data Fetching | `query-` | HIGH | 6 |
| Component Organization | `comp-` | MEDIUM-HIGH | 6 |
| State Management | `state-` | MEDIUM | 5 |
| Testing Strategy | `test-` | MEDIUM | 4 |
| Naming Conventions | `name-` | LOW | 3 |

## Usage

This skill is automatically triggered when tasks involve:
- A project asking for a feature-based architecture target (produces the blueprint)
- Project structure decisions
- Feature organization
- Module boundaries
- Cross-feature communication
- Data fetching patterns
- Component composition

### Producing the blueprint

When the trigger is "give me the target architecture for this project" (or
similar), the agent:

1. Reads the project context (`package.json`, `src/` tree, README, CLAUDE.md, `openspec/`).
2. Identifies candidate features from routes, docs, and code clusters.
3. Confirms the feature list with the user.
4. Records explicit decisions (layering, cross-feature comm, state and routing owners).
5. Fills in the blueprint template and persists it at `docs/architecture/FEATURE-ARCH-TARGET.md`.
6. Hands off — does not start executing migration steps in the same turn.

Full workflow lives in [`references/_blueprint-process.md`](references/_blueprint-process.md).

## References

- [Robin Wieruch - React Feature Architecture](https://www.robinwieruch.de/react-feature-architecture/)
- [Feature-Sliced Design](https://feature-sliced.design/)
- [Bulletproof React](https://github.com/alan2207/bulletproof-react)
