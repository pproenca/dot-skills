# Feature-Based Architecture Skill

A comprehensive guide for organizing React applications using feature-based architecture patterns. This skill helps ensure scalable, maintainable codebases by enforcing proper feature isolation, import boundaries, and composition patterns.

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
- Project structure decisions
- Feature organization
- Module boundaries
- Cross-feature communication
- Data fetching patterns
- Component composition

## References

- [Robin Wieruch - React Feature Architecture](https://www.robinwieruch.de/react-feature-architecture/)
- [Feature-Sliced Design](https://feature-sliced.design/)
- [Bulletproof React](https://github.com/alan2207/bulletproof-react)
